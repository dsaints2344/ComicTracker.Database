#!/usr/bin/env pwsh

Param(
    [string] [Parameter(Mandatory = $false)] $ContainerName = "grate-sqlserver",
    [int] [Parameter(Mandatory = $false)] $HostPort = 1434,
    [string] [Parameter(Mandatory = $false)] $SqlPassword = "YourStrong!Passw0rd",
    [string] [Parameter(Mandatory = $false)] $Image = "mcr.microsoft.com/mssql/server:2025-latest"
)

$ErrorActionPreference = "Stop"

$Root = Resolve-Path (Join-Path $PSScriptRoot "..")
$DbScriptsRoot = Join-Path $Root "db"
$DatabaseName = (Get-ChildItem $DbScriptsRoot -Directory | Select-Object -First 1 -ExpandProperty Name)

if ([string]::IsNullOrWhiteSpace($DatabaseName)) {
    Write-Error "Could not infer database name from '$DbScriptsRoot'."
    exit 1
}

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Error "Docker CLI not found. Install Docker Desktop and ensure 'docker' is on PATH."
    exit 1
}

if ($SqlPassword -eq "YourStrong!Passw0rd") {
    Write-Warning "Using default SA password. Override with -SqlPassword for non-local usage."
}

$existingContainerId = docker ps -a --filter "name=^/${ContainerName}$" --format "{{.ID}}"

if ([string]::IsNullOrWhiteSpace($existingContainerId)) {
    Write-Host "Creating SQL Server container '$ContainerName' on localhost:$HostPort..."
    docker run -d `
        --name "$ContainerName" `
        -e "ACCEPT_EULA=Y" `
        -e "MSSQL_SA_PASSWORD=$SqlPassword" `
        -p "${HostPort}:1433" `
        "$Image" | Out-Null
}
else {
    $isRunning = docker ps --filter "name=^/${ContainerName}$" --format "{{.ID}}"
    if ([string]::IsNullOrWhiteSpace($isRunning)) {
        Write-Host "Starting existing SQL Server container '$ContainerName'..."
        docker start "$ContainerName" | Out-Null
    }
    else {
        Write-Host "Container '$ContainerName' is already running."
    }
}

Write-Host "Waiting for SQL Server to become ready..."
$ready = $false
for ($i = 0; $i -lt 60; $i++) {
    $logs = docker logs "$ContainerName" 2>&1
    if ($logs -match "SQL Server is now ready for client connections") {
        $ready = $true
        break
    }
    Start-Sleep -Seconds 1
}

if (-not $ready) {
    Write-Warning "SQL Server did not report ready within timeout. Check logs with: docker logs $ContainerName"
}

$connectionString = "Data Source=localhost,$HostPort;Initial Catalog=$DatabaseName;User Id=sa;Password=$SqlPassword;Encrypt=false"

Write-Host ""
Write-Host "SQL Server container is up."
Write-Host ""
Write-Host "Connection string (matches .envrc format):"
Write-Host "export ConnectionStrings__$DatabaseName='$connectionString'"
Write-Host ""
Write-Host "Useful commands:"
Write-Host "  docker logs $ContainerName"
Write-Host "  docker stop $ContainerName"
Write-Host "  docker rm -f $ContainerName"
