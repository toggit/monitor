Clear-Host

$myDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host $myDir\servers.json

$Servers = Get-Content -Raw -Path $myDir\servers.json | ConvertFrom-Json

$Servers