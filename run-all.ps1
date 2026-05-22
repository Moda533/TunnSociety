# run-all.ps1
# Starts backend and frontend in parallel with logs.

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$logDir = Join-Path $root "logs"
New-Item -ItemType Directory -Force -Path $logDir | Out-Null

$runId = Get-Date -Format "yyyyMMdd_HHmmss"
$runLogDir = Join-Path $logDir $runId
New-Item -ItemType Directory -Force -Path $runLogDir | Out-Null

$shell = $null
if (Get-Command pwsh -ErrorAction SilentlyContinue) {
  $shell = (Get-Command pwsh).Source
}
elseif (Get-Command powershell -ErrorAction SilentlyContinue) {
  $shell = (Get-Command powershell).Source
}
else {
  throw "Neither pwsh nor powershell was found. Install PowerShell or check PATH."
}

$backendLog = Join-Path $runLogDir "backend.log"
$backendErr = Join-Path $runLogDir "backend.err.log"
$frontendLog = Join-Path $runLogDir "frontend.log"
$frontendErr = Join-Path $runLogDir "frontend.err.log"
New-Item -ItemType File -Force -Path $backendLog, $backendErr, $frontendLog, $frontendErr | Out-Null

Write-Host "Starting backend and frontend..."

$backend = Start-Process -FilePath $shell -ArgumentList @(
  "-ExecutionPolicy", "Bypass", "-File", (Join-Path $root "install-backend.ps1")
) -WorkingDirectory $root -RedirectStandardOutput $backendLog -RedirectStandardError $backendErr -PassThru

$frontend = Start-Process -FilePath $shell -ArgumentList @(
  "-ExecutionPolicy", "Bypass", "-File", (Join-Path $root "install-frontend.ps1")
) -WorkingDirectory $root -RedirectStandardOutput $frontendLog -RedirectStandardError $frontendErr -PassThru

Write-Host "Streaming logs from $runLogDir ... (Ctrl+C to stop all)"
try {
  Get-Content -Path $backendLog, $backendErr, $frontendLog, $frontendErr -Wait
}
finally {
  Write-Host "Stopping services..."
  foreach ($proc in @($backend, $frontend)) {
    if ($proc -and -not $proc.HasExited) {
      Stop-Process -Id $proc.Id -Force
    }
  }
}
