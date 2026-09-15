# Local regression checks only. Certificate stores and native Windows APIs are
# mocked or inspected structurally; no certificate store is opened or modified.
param([string] $GoRoot)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Write-Host 'Running mocked trust-helper tests; no certificate stores will be opened.'
$wrapper = Join-Path $PSScriptRoot 'run_dist_tests.ps1'
$tokens = $null
$parseErrors = $null
$ast = [Management.Automation.Language.Parser]::ParseFile($wrapper, [ref] $tokens, [ref] $parseErrors)
if ($parseErrors.Count) { throw ($parseErrors | Out-String) }
# Load only function declarations. The entry point and certificate-store APIs
# are never run by these tests; stores are represented by plain hashtables.
foreach ($statement in $ast.EndBlock.Statements) {
    if ($statement -is [Management.Automation.Language.FunctionDefinitionAst]) {
        . ([scriptblock]::Create($statement.Extent.Text))
    }
}
function Assert-Equal($Actual, $Expected, [string] $Context) {
    if ($Actual -cne $Expected) { throw "$Context expected [$Expected], got [$Actual]" }
}
function Test-Lifetime {
    param([string] $Name, [hashtable] $Options, [int] $Expected, [string] $ExpectedEvents)
    $state = @{ UserRoot = $false; MachineRoot = $false; UserDisallowed = $false; MachineDisallowed = $false }
    foreach ($key in @('UserRoot', 'MachineRoot', 'UserDisallowed', 'MachineDisallowed')) {
        if ($Options.ContainsKey($key)) { $state[$key] = $Options[$key] }
    }
    $events = [Collections.Generic.List[string]]::new()
    $initialUser = $state.UserRoot
    $status = Invoke-GoTestsWithRoot -AllowTemporaryRoot ($Options.Allow -eq $true) -ReadState {
        if ($events.Contains('add') -and -not $events.Contains('remove') -and $Options.BadProvision) {
            return [pscustomobject]@{ UserRoot = $false; MachineRoot = $false; UserDisallowed = $false; MachineDisallowed = $false }
        }
        return [pscustomobject] $state
    } -AddRoot {
        $events.Add('add')
        if ($Options.AddThrows) { throw 'simulated add failure' }
        $state.UserRoot = $true
    } -RemoveRoot {
        $events.Add('remove')
        if ($Options.RemoveThrows) { throw 'simulated remove failure' }
        if (-not $Options.RemoveNoop) { $state.UserRoot = $false }
    } -RunTests {
        $events.Add('run')
        if ($Options.TestThrows) { throw 'simulated test launch failure' }
        if ($Options.ContainsKey('TestStatus')) { return $Options.TestStatus }
        return 0
    } 2> $null
    Assert-Equal $status $Expected $Name
    Assert-Equal ($events -join ',') $ExpectedEvents "$Name events"
    if (-not $Options.RemoveThrows -and -not $Options.RemoveNoop) {
        Assert-Equal $state.UserRoot $initialUser "$Name restoration"
    }
    Write-Host "PASS $Name"
}
# Populate optional keys so StrictMode also applies inside every adapter.
function Scenario([string] $Name, [hashtable] $Overrides, [int] $Expected, [string] $Events) {
    $options = @{ Allow = $false; AddThrows = $false; RemoveThrows = $false; RemoveNoop = $false; TestThrows = $false; BadProvision = $false }
    foreach ($key in $Overrides.Keys) { $options[$key] = $Overrides[$key] }
    Test-Lifetime $Name $options $Expected $Events
}
Scenario 'existing user root' @{ UserRoot = $true } 0 'run'
Scenario 'existing machine root and child failure' @{ MachineRoot = $true; TestStatus = 17 } 17 'run'
Scenario 'missing root without authorization' @{} 1 ''
Scenario 'user distrust overrides existing root' @{ UserRoot = $true; UserDisallowed = $true; Allow = $true } 1 ''
Scenario 'machine distrust rejects provisioning' @{ MachineDisallowed = $true; Allow = $true } 1 ''
Scenario 'temporary root success' @{ Allow = $true } 0 'add,run,remove'
Scenario 'temporary root child failure' @{ Allow = $true; TestStatus = 17 } 17 'add,run,remove'
Scenario 'temporary root launch exception' @{ Allow = $true; TestThrows = $true } 1 'add,run,remove'
Scenario 'add failure never removes unowned entry' @{ Allow = $true; AddThrows = $true } 1 'add'
Scenario 'provision verification failure cleans up' @{ Allow = $true; BadProvision = $true } 1 'add,remove'
Scenario 'cleanup exception changes success to failure' @{ Allow = $true; RemoveThrows = $true } 1 'add,run,remove'
Scenario 'cleanup exception preserves child failure' @{ Allow = $true; TestStatus = 17; RemoveThrows = $true } 17 'add,run,remove'
Scenario 'cleanup no-op is detected' @{ Allow = $true; RemoveNoop = $true } 1 'add,run,remove'

$required = @{
    GO_TEST_ALLOW_TEMPORARY_USER_ROOT = '1'; GITHUB_ACTIONS = 'true'
    RUNNER_ENVIRONMENT = 'github-hosted'
}
$saved = @{}
try {
    foreach ($name in $required.Keys) {
        $saved[$name] = [Environment]::GetEnvironmentVariable($name, 'Process')
        [Environment]::SetEnvironmentVariable($name, $required[$name], 'Process')
    }
    Assert-Equal (Test-DisposableWindowsArm64Runner) $true 'all runtime guards'
    foreach ($name in $required.Keys) {
        [Environment]::SetEnvironmentVariable($name, $null, 'Process')
        Assert-Equal (Test-DisposableWindowsArm64Runner) $false "missing $name"
        [Environment]::SetEnvironmentVariable($name, $required[$name], 'Process')
    }
    [Environment]::SetEnvironmentVariable('RUNNER_ENVIRONMENT', 'self-hosted', 'Process')
    Assert-Equal (Test-DisposableWindowsArm64Runner) $false 'self-hosted refusal'
} finally {
    foreach ($name in $saved.Keys) { [Environment]::SetEnvironmentVariable($name, $saved[$name], 'Process') }
}
Write-Host 'PASS execution-time runner and opt-in guards'

if (-not $GoRoot) {
    $goExecutable = (Get-Command go -CommandType Application -ErrorAction Stop).Source
    $reportedRoot = @(& $goExecutable env GOROOT)
    if ($LASTEXITCODE -ne 0 -or $reportedRoot.Count -ne 1) {
        throw 'Could not obtain GOROOT; supply -GoRoot with a Go source directory.'
    }
    $GoRoot = $reportedRoot[0]
}
$rootDirectory = Get-Item -LiteralPath $GoRoot -ErrorAction Stop
if (-not $rootDirectory.PSIsContainer) { throw '-GoRoot must name a Go source directory.' }
$cert = Get-GoFixtureRoot $rootDirectory.FullName
try {
    Assert-Equal (Get-CertificateSha256 $cert) '4348A0E9444C78CB265E058D5E8944B4D84F9662BD26DB257F8934A443C70161' 'fixture fingerprint'
} finally { $cert.Dispose() }
Write-Host 'PASS source fixture extraction and DER pin'
Initialize-GoWindowsApi
Assert-Equal ([GoFeedstockTemporaryTrust].GetMethods().Name -contains 'CertAddCertificateContextToStore') $true 'native declarations compile'
Assert-Equal ([GoFeedstockTemporaryTrust].GetMethods().Name -contains 'IsWow64Process2') $true 'native architecture declaration compiles'
Write-Host 'PASS native API declaration compilation; native methods were not invoked'

# The initializer is defined in script scope, so install its compiler shim in
# that same scope. No P/Invoke method or certificate store is used by this shim.
$script:CompilerProbe = $null
function Add-Type {
    [CmdletBinding()]
    param([string] $TypeDefinition)
    Assert-Equal ([string]::IsNullOrEmpty([Environment]::GetEnvironmentVariable('LIB', 'Process'))) $true 'compiler LIB isolation'
    $script:CompilerProbe.Calls++
    if ($script:CompilerProbe.CompilationFails) { throw 'simulated C# compilation failure' }
}
function Test-CompilerEnvironmentScope {
    param([string] $LibraryPath, [bool] $CompilationFails)
    $originalLibraryPath = [Environment]::GetEnvironmentVariable('LIB', 'Process')
    $script:CompilerProbe = [pscustomobject]@{ Calls = 0; CompilationFails = $CompilationFails }
    try {
        [Environment]::SetEnvironmentVariable('LIB', $LibraryPath, 'Process')
        $expectedLibraryPath = [Environment]::GetEnvironmentVariable('LIB', 'Process')
        $failed = $false
        try { Initialize-GoWindowsApi } catch { $failed = $true }
        Assert-Equal $script:CompilerProbe.Calls 1 'compiler called with isolated LIB'
        Assert-Equal $failed $CompilationFails 'compiler errors remain fatal'
        Assert-Equal ([Environment]::GetEnvironmentVariable('LIB', 'Process')) $expectedLibraryPath 'LIB restored'
    } finally {
        [Environment]::SetEnvironmentVariable('LIB', $originalLibraryPath, 'Process')
    }
}
foreach ($libraryPath in @($null, 'C:\missing conda prefix\Library\lib;C:\existing\lib')) {
    Test-CompilerEnvironmentScope $libraryPath $false
    Test-CompilerEnvironmentScope $libraryPath $true
}
Remove-Item Function:\Add-Type
Write-Host 'PASS compiler LIB isolation and exact restoration after success/failure'

$script:NativeCalls = [Collections.Generic.List[string]]::new()
$script:FocusedExit = 0
$script:SuiteExit = 23
$script:ThrowOnCall = 0
function Fake-Go {
    foreach ($name in @('SSL_CERT_FILE', 'SSL_CERT_DIR')) {
        Assert-Equal ([string]::IsNullOrEmpty([Environment]::GetEnvironmentVariable($name, 'Process'))) $true "$name platform-test isolation"
    }
    Assert-Equal $env:GODEBUG 'x509sslcertoverrideplatform=1' 'upstream override behavior remains enabled'
    $script:NativeCalls.Add(($args -join '|'))
    if ($script:NativeCalls.Count -eq $script:ThrowOnCall) { throw 'simulated Go launch failure' }
    if ($args[0] -ceq 'test') { $global:LASTEXITCODE = $script:FocusedExit }
    else { $global:LASTEXITCODE = $script:SuiteExit }
}
function Test-CertificateEnvironmentScope {
    param([string] $CertFile, [string] $CertDirectory, [int] $FocusedExit, [int] $SuiteExit, [int] $ThrowOnCall)
    $original = @{}
    foreach ($name in @('SSL_CERT_FILE', 'SSL_CERT_DIR', 'GODEBUG')) {
        $original[$name] = [Environment]::GetEnvironmentVariable($name, 'Process')
    }
    try {
        [Environment]::SetEnvironmentVariable('SSL_CERT_FILE', $CertFile, 'Process')
        [Environment]::SetEnvironmentVariable('SSL_CERT_DIR', $CertDirectory, 'Process')
        [Environment]::SetEnvironmentVariable('GODEBUG', 'x509sslcertoverrideplatform=1', 'Process')
        $expected = @{}
        foreach ($name in $original.Keys) { $expected[$name] = [Environment]::GetEnvironmentVariable($name, 'Process') }
        $script:NativeCalls.Clear()
        $script:FocusedExit = $FocusedExit
        $script:SuiteExit = $SuiteExit
        $script:ThrowOnCall = $ThrowOnCall
        $thrown = $false
        try { $status = Invoke-AuthoritativeGoTests 'Fake-Go' } catch {
            if ($_.Exception.Message -cne 'simulated Go launch failure') { throw }
            $thrown = $true
        }
        Assert-Equal $thrown ($ThrowOnCall -gt 0) 'launch exceptions preserved'
        $expectedCalls = if ($FocusedExit -ne 0 -or $ThrowOnCall -eq 1) { 1 } else { 2 }
        Assert-Equal $script:NativeCalls.Count $expectedCalls 'focused failure stops before suite'
        Assert-Equal $script:NativeCalls[0] 'test|-count=1|-v|-run=^Test(Go|System)Verify$/^SHA-384$|crypto/x509' 'focused arguments'
        if ($expectedCalls -eq 2) {
            Assert-Equal $script:NativeCalls[1] 'tool|dist|test|-k|-v|-no-rebuild' 'authoritative arguments'
        }
        if (-not $thrown) {
            $expectedStatus = if ($FocusedExit -ne 0) { $FocusedExit } else { $SuiteExit }
            Assert-Equal $status $expectedStatus 'Go exit code preserved'
        }
        foreach ($name in $expected.Keys) {
            Assert-Equal ([Environment]::GetEnvironmentVariable($name, 'Process')) $expected[$name] "$name restored unchanged"
        }
    } finally {
        foreach ($name in $original.Keys) { [Environment]::SetEnvironmentVariable($name, $original[$name], 'Process') }
    }
}
foreach ($certFile in @($null, 'C:\pixi build\Library\ssl\cacert.pem')) {
    foreach ($certDirectory in @($null, 'C:\pixi build\Library\ssl\certs;C:\other certs')) {
        Test-CertificateEnvironmentScope $certFile $certDirectory 0 0 0
        Test-CertificateEnvironmentScope $certFile $certDirectory 0 23 0
        Test-CertificateEnvironmentScope $certFile $certDirectory 29 0 0
        Test-CertificateEnvironmentScope $certFile $certDirectory 0 0 1
        Test-CertificateEnvironmentScope $certFile $certDirectory 0 0 2
    }
}
Write-Host 'PASS 20 certificate-environment cases: fixed commands, exact restoration, and failure propagation'

# Check the entry point without executing it. All platform guards must throw
# before the first certificate store is even constructed.
$mainBlocks = @($ast.EndBlock.Statements | Where-Object {
    $_ -is [Management.Automation.Language.TryStatementAst]
})
Assert-Equal $mainBlocks.Count 1 'one guarded entry point'
$main = $mainBlocks[0]
$firstStore = $main.Body.Find({
    param($node)
    $node -is [Management.Automation.Language.TypeExpressionAst] -and
        $node.TypeName.FullName -eq 'Security.Cryptography.X509Certificates.X509Store'
}, $false)
if ($null -eq $firstStore) { throw 'Certificate store construction was not found.' }
$guards = @($main.Body.Statements | Where-Object {
    $_ -is [Management.Automation.Language.IfStatementAst]
})
$guardPatterns = @{
    'actual Windows platform' = '\[Environment\]::OSVersion\.Platform\s+-ne\s+\[PlatformID\]::Win32NT'
    'native ARM64 process and machine' = '\$processMachine\s+-ne\s+0\s+-or\s+\$nativeMachine\s+-ne\s+0xaa64'
    'Go native host and target' = '\$goEnvironment\[0\].*windows[\s\S]*\$goEnvironment\[1\].*arm64[\s\S]*\$goEnvironment\[2\].*windows[\s\S]*\$goEnvironment\[3\].*arm64'
}
foreach ($name in $guardPatterns.Keys) {
    $matching = @($guards | Where-Object {
        $_.Clauses[0].Item1.Extent.Text -match $guardPatterns[$name]
    })
    Assert-Equal $matching.Count 1 "$name guard"
    $throws = @($matching[0].Clauses[0].Item2.Statements | Where-Object {
        $_ -is [Management.Automation.Language.ThrowStatementAst]
    })
    Assert-Equal $throws.Count 1 "$name refusal"
    Assert-Equal ($matching[0].Extent.EndOffset -lt $firstStore.Extent.StartOffset) $true "$name before stores"
}
$architectureCalls = @($main.Body.FindAll({
    param($node)
    $node -is [Management.Automation.Language.InvokeMemberExpressionAst] -and
        $node.Member.Value -eq 'IsWow64Process2'
}, $false))
Assert-Equal $architectureCalls.Count 1 'actual process architecture query'
Assert-Equal ($architectureCalls[0].Extent.EndOffset -lt $firstStore.Extent.StartOffset) $true 'architecture query before stores'
Write-Host 'PASS structural native platform guards; Windows API paths remain unexecuted'

Write-Host 'ALL WRAPPER SELF-TESTS PASSED; certificate-store and Go command paths were mocked.'
