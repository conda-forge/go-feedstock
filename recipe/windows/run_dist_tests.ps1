# Go's SHA-384 system-verifier fixture requires DigiCert Global Root CA.
# Microsoft still includes this exact root for Server Authentication:
# https://ccadb.my.salesforce-sites.com/microsoft/IncludedCACertificateReportForMSFTCSV
# GitHub's Windows image disables automatic root updates after provisioning:
# https://github.com/actions/runner-images/blob/win11-arm64/20260830.155/images/windows/scripts/build/Install-RootCA.ps1
# Provision only this prerequisite, temporarily, on an explicitly opted-in
# disposable runner. The Go sources, verification flags, and tests stay intact.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-CertificateSha256 {
    param([Security.Cryptography.X509Certificates.X509Certificate2] $Certificate)
    $hasher = [Security.Cryptography.SHA256]::Create()
    try {
        return [BitConverter]::ToString($hasher.ComputeHash($Certificate.RawData)).Replace('-', '')
    } finally {
        $hasher.Dispose()
    }
}

function Get-GoFixtureRoot {
    param([string] $GoRoot)
    $source = [IO.File]::ReadAllText((Join-Path $GoRoot 'src/crypto/x509/verify_test.go'))
    $pattern = '(?m)^const digicertRoot = `-----BEGIN CERTIFICATE-----\r?\n(?<body>[A-Za-z0-9+/=\r\n]+)-----END CERTIFICATE-----`\r?$'
    $matches = [regex]::Matches($source, $pattern)
    if ($matches.Count -ne 1) {
        throw 'Expected exactly one upstream digicertRoot certificate fixture.'
    }
    $der = [Convert]::FromBase64String($matches[0].Groups['body'].Value)
    $certificate = [Security.Cryptography.X509Certificates.X509Certificate2]::new($der)
    if ($certificate.Thumbprint -ne 'A8985D3A65E5E5C4B2D7D66D40C6DD2FB19C5436' -or
        (Get-CertificateSha256 $certificate) -ne '4348A0E9444C78CB265E058D5E8944B4D84F9662BD26DB257F8934A443C70161') {
        $certificate.Dispose()
        throw 'The Go fixture is not the pinned DigiCert Global Root CA certificate.'
    }
    return $certificate
}

function Test-DisposableWindowsArm64Runner {
    # These are checked at execution time, never serialized from a publisher's
    # environment into the package. Missing or scrubbed variables fail closed.
    # The entry point independently checks the actual OS and Go host/target;
    # RUNNER_OS/RUNNER_ARCH claims are neither needed nor passed through.
    return ($env:GO_TEST_ALLOW_TEMPORARY_USER_ROOT -ceq '1' -and
        $env:GITHUB_ACTIONS -ceq 'true' -and
        $env:RUNNER_ENVIRONMENT -ceq 'github-hosted')
}

function Test-PinnedRootInStore {
    param(
        [ValidateSet('Root', 'Disallowed')] [string] $Name,
        [Security.Cryptography.X509Certificates.StoreLocation] $Location,
        [Security.Cryptography.X509Certificates.X509Certificate2] $Certificate
    )
    $store = [Security.Cryptography.X509Certificates.X509Store]::new($Name, $Location)
    try {
        $store.Open([Security.Cryptography.X509Certificates.OpenFlags]::ReadOnly)
        $found = $store.Certificates.Find(
            [Security.Cryptography.X509Certificates.X509FindType]::FindByThumbprint,
            $Certificate.Thumbprint, $false)
        try {
            foreach ($entry in $found) {
                if ((Get-CertificateSha256 $entry) -ne (Get-CertificateSha256 $Certificate)) {
                    throw "Certificate thumbprint collision in $Location\$Name."
                }
            }
            return ($found.Count -gt 0)
        } finally {
            foreach ($entry in $found) { $entry.Dispose() }
        }
    } finally {
        $store.Close()
    }
}

function Get-GoRootStoreState {
    param([Security.Cryptography.X509Certificates.X509Certificate2] $Certificate)
    return [pscustomobject]@{
        UserRoot = Test-PinnedRootInStore Root CurrentUser $Certificate
        MachineRoot = Test-PinnedRootInStore Root LocalMachine $Certificate
        UserDisallowed = Test-PinnedRootInStore Disallowed CurrentUser $Certificate
        MachineDisallowed = Test-PinnedRootInStore Disallowed LocalMachine $Certificate
    }
}

function Initialize-GoWindowsApi {
    # CERT_STORE_ADD_NEW gives an atomic ownership decision: unlike X509Store.Add,
    # it cannot replace an entry that appeared after the read-only snapshot.
    # Windows PowerShell 5.1's C# compiler reads LIB. Conda can set it to native
    # library directories absent from this no-CGo test prefix. These framework-
    # only declarations do not use that search path. Isolate just compilation,
    # then restore LIB even if Add-Type fails; Go's environment is unchanged.
    $savedLibraryPath = [Environment]::GetEnvironmentVariable('LIB', 'Process')
    $clearLibraryPath = -not [string]::IsNullOrEmpty($savedLibraryPath)
    try {
        if ($clearLibraryPath) {
            [Environment]::SetEnvironmentVariable('LIB', $null, 'Process')
        }
        Add-Type -ErrorAction Stop -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class GoFeedstockTemporaryTrust {
    [DllImport("kernel32.dll")]
    public static extern IntPtr GetCurrentProcess();
    [DllImport("kernel32.dll", SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool IsWow64Process2(
        IntPtr process, out ushort processMachine, out ushort nativeMachine);
    [DllImport("crypt32.dll", SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool CertAddCertificateContextToStore(
        IntPtr store, IntPtr certificate, uint disposition, out IntPtr added);
    [DllImport("crypt32.dll", SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool CertDeleteCertificateFromStore(IntPtr certificate);
    [DllImport("crypt32.dll", SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool CertFreeCertificateContext(IntPtr certificate);
}
'@
    } finally {
        if ($clearLibraryPath) {
            [Environment]::SetEnvironmentVariable('LIB', $savedLibraryPath, 'Process')
        }
    }
}

function Invoke-GoTestsWithRoot {
    # Keeping the lifetime logic separate permits tests with in-memory adapters.
    # The script's entry point supplies the fixed stores and Go commands below;
    # no command-line option can substitute a certificate, store, or test command.
    param(
        [scriptblock] $ReadState,
        [scriptblock] $AddRoot,
        [scriptblock] $RemoveRoot,
        [scriptblock] $RunTests,
        [bool] $AllowTemporaryRoot
    )
    $added = $false
    $testStatus = 1
    try {
        $initial = & $ReadState
        if ($initial.UserDisallowed -or $initial.MachineDisallowed) {
            throw 'The fixture root is explicitly disallowed; refusing to override that policy.'
        }
        if (-not ($initial.UserRoot -or $initial.MachineRoot)) {
            if (-not $AllowTemporaryRoot) {
                throw ('The DigiCert fixture root is missing. Temporary CurrentUser trust requires ' +
                    'GO_TEST_ALLOW_TEMPORARY_USER_ROOT=1 on a disposable native GitHub-hosted Windows ARM64 runner.')
            }
            & $AddRoot | Out-Null
            $added = $true
            $provisioned = & $ReadState
            if (-not $provisioned.UserRoot -or $provisioned.UserDisallowed -or $provisioned.MachineDisallowed) {
                throw 'The temporary fixture root was not provisioned in an allowed CurrentUser store.'
            }
            Write-Host 'Temporarily provisioned the pinned DigiCert fixture root in CurrentUser\Root.'
        } else {
            Write-Host 'The pinned DigiCert fixture root is already installed; certificate stores are unchanged.'
        }
        $testStatus = [int] (& $RunTests)
    } catch {
        Write-Error -ErrorAction Continue $_
        $testStatus = 1
    } finally {
        if ($added) {
            try {
                & $RemoveRoot | Out-Null
                $restored = & $ReadState
                if ($restored.UserRoot) {
                    throw 'The temporary DigiCert fixture root remains in CurrentUser\Root.'
                }
                Write-Host 'Removed the temporary fixture root and verified CurrentUser\Root restoration.'
            } catch {
                Write-Error -ErrorAction Continue ('Fixture trust cleanup failed: ' + $_)
                if ($testStatus -eq 0) { $testStatus = 1 }
            }
        }
    }
    return $testStatus
}

function Invoke-AuthoritativeGoTests {
    param([string] $GoExecutable)
    # Go 1.27 uses an on-disk pool instead of Windows certificate APIs when
    # either SSL_CERT_* override is set (https://go.dev/doc/go1.27#crypto/x509).
    # These native stdlib tests require platform roots. Isolate the inherited
    # build-tool overrides for both commands, then restore them on every exit.
    # Upstream override tests still set their own variables; GODEBUG is unchanged.
    $certificateOverrides = @{}
    foreach ($name in @('SSL_CERT_FILE', 'SSL_CERT_DIR')) {
        $value = [Environment]::GetEnvironmentVariable($name, 'Process')
        if (-not [string]::IsNullOrEmpty($value)) { $certificateOverrides[$name] = $value }
    }
    try {
        foreach ($name in $certificateOverrides.Keys) {
            Write-Host "Isolating inherited $name for the native Windows certificate tests."
            [Environment]::SetEnvironmentVariable($name, $null, 'Process')
        }
        & $GoExecutable test -count=1 -v '-run=^Test(Go|System)Verify$/^SHA-384$' crypto/x509 | Out-Host
        $focusedStatus = $LASTEXITCODE
        if ($focusedStatus -ne 0) { return $focusedStatus }
        & $GoExecutable tool dist test -k -v -no-rebuild | Out-Host
        return $LASTEXITCODE
    } finally {
        foreach ($name in $certificateOverrides.Keys) {
            [Environment]::SetEnvironmentVariable($name, $certificateOverrides[$name], 'Process')
        }
    }
}

$certificate = $null
$writableStore = $null
$addedContext = [pscustomobject]@{ Value = [IntPtr]::Zero }
$result = 1
try {
    if ([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT) {
        throw 'This wrapper requires native Windows ARM64; no certificate stores were opened.'
    }
    Initialize-GoWindowsApi
    # Read actual process and host architecture. Environment variables can be
    # scrubbed by rattler or describe an outer emulated shell. IsWow64Process2
    # is available on Windows 11 and works with Windows PowerShell 5.1.
    [System.UInt16] $processMachine = 0
    [System.UInt16] $nativeMachine = 0
    if (-not [GoFeedstockTemporaryTrust]::IsWow64Process2(
        [GoFeedstockTemporaryTrust]::GetCurrentProcess(), [ref] $processMachine, [ref] $nativeMachine)) {
        throw [ComponentModel.Win32Exception]::new([Runtime.InteropServices.Marshal]::GetLastWin32Error())
    }
    if ($processMachine -ne 0 -or $nativeMachine -ne 0xaa64) {
        throw 'This wrapper requires a native ARM64 process on Windows ARM64; no certificate stores were opened.'
    }
    # PowerShell 7 may opt into exceptions for native nonzero exit codes.
    # Preserve those codes explicitly, as Windows PowerShell 5.1 does.
    if (Get-Variable PSNativeCommandUseErrorActionPreference -ErrorAction SilentlyContinue) {
        $PSNativeCommandUseErrorActionPreference = $false
    }
    $goExecutable = (Get-Command go -CommandType Application -ErrorAction Stop).Source
    $goEnvironment = @(& $goExecutable env GOHOSTOS GOHOSTARCH GOOS GOARCH GOROOT)
    if ($LASTEXITCODE -ne 0 -or $goEnvironment.Count -ne 5 -or
        $goEnvironment[0] -cne 'windows' -or $goEnvironment[1] -cne 'arm64' -or
        $goEnvironment[2] -cne 'windows' -or $goEnvironment[3] -cne 'arm64') {
        throw 'The installed Go toolchain must have native windows/arm64 host and target.'
    }
    $certificate = Get-GoFixtureRoot $goEnvironment[4]
    # Only this CurrentUser store can be opened for writing. Keeping its handle
    # alive makes the add/remove lifetime explicit even when the tests fail.
    $writableStore = [Security.Cryptography.X509Certificates.X509Store]::new(
        'Root', [Security.Cryptography.X509Certificates.StoreLocation]::CurrentUser)
    $result = Invoke-GoTestsWithRoot -AllowTemporaryRoot (Test-DisposableWindowsArm64Runner) -ReadState {
        Get-GoRootStoreState $certificate
    } -AddRoot {
        $writableStore.Open([Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite)
        $context = [IntPtr]::Zero
        if (-not [GoFeedstockTemporaryTrust]::CertAddCertificateContextToStore(
            $writableStore.StoreHandle, $certificate.Handle, 1, [ref] $context)) {
            throw [ComponentModel.Win32Exception]::new([Runtime.InteropServices.Marshal]::GetLastWin32Error())
        }
        $addedContext.Value = $context
    } -RemoveRoot {
        # Delete the exact context returned by ADD_NEW, not a later lookup by
        # thumbprint. The API releases that context even when deletion fails.
        $context = $addedContext.Value
        $addedContext.Value = [IntPtr]::Zero
        if (-not [GoFeedstockTemporaryTrust]::CertDeleteCertificateFromStore($context)) {
            throw [ComponentModel.Win32Exception]::new([Runtime.InteropServices.Marshal]::GetLastWin32Error())
        }
    } -RunTests {
        Invoke-AuthoritativeGoTests $goExecutable
    }
} catch {
    Write-Error -ErrorAction Continue $_
    $result = 1
} finally {
    if ($addedContext.Value -ne [IntPtr]::Zero) {
        [void] [GoFeedstockTemporaryTrust]::CertFreeCertificateContext($addedContext.Value)
    }
    if ($null -ne $writableStore) { $writableStore.Close() }
    if ($null -ne $certificate) { $certificate.Dispose() }
}
exit $result
