# install-frontend.ps1
# Install Angular dependencies and run the dev server.

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$frontendPath = Join-Path $root "frontend\tun-society"

Push-Location $frontendPath
try {
  Write-Host "Installing frontend dependencies..."
  npm install

  Write-Host "Starting Angular dev server..."
  npx ng serve
}
finally {
  Pop-Location
}
