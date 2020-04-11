# go-feedstock patches

## Regenerating the patches
The patches in this folder were created as follows:

```shell script
hub clone sodre/go
cd go
git checkout feedstock-go1.12
git format-patch release-branch.go1.12 -o ..
cd ..
rm -rf go
```

Then each patch is added to the the patches section in meta.yaml.

## Rebasing patches to new go releases
TBD
