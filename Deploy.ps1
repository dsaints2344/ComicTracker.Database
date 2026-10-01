#!/usr/bin/env pwsh

Param(
    [string]  [Parameter(Mandatory=$false)] $Environment="",
    [string]  [Parameter(Mandatory=$false)] $ConnectionString="",
    [string]  [Parameter(Mandatory=$false)] $Version=""
)


If ("$($Environment)" -eq "")
{
    $Environment = $env:GrateEnvironment
}

If ("$($ConnectionString)" -eq ""){
    $ConnectionString=$env:ConnectionStrings__ComicTracker
}

# Check that all input parameters are OK

If ("$($ConnectionString)" -eq "") {
    Write-Error "You must either supply the '-ConnectionString' parameter, or the environment variable ConnectionStrings__ComicTracker must be set."
    Exit 1;
}

If ("$($Environment)" -eq "") {
    Write-Error "You must either supply the '-Environment' parameter, or the environment variable GrateEnvironment must be set."
    Exit 1;
}

# Make sure we have all required tools (grate and gitversion, specifically)
dotnet tool restore

# Generate version number if not supplied as a parameter
If ("$($Version)" -eq "")
{
    $Version = "$( dotnet gitversion -showvariable SemVer )"
}

# Call the actual deploy ps1
./scripts/Deploy.ps1 `
  -Environment "$($Environment)" `
  -ConnectionString "$($ConnectionString)" `
  -Version "$($Version)" 
