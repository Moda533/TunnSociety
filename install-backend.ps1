# install-backend.ps1
# Restore, build, migrate, then run the ASP.NET Core API (Development + Laragon MySQL).

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$backendPath = Join-Path $root "backend\TunSociety.Api"

# Ensure Development settings are used.
$env:ASPNETCORE_ENVIRONMENT = "Development"
# Force standard dev ports to avoid conflicts.
$env:ASPNETCORE_URLS = "https://localhost:5001;http://localhost:5000"

# Laragon MySQL (update user/password if needed).
$env:ConnectionStrings__DefaultConnection = "server=localhost;port=3306;database=tunsociety_db;user=root;password="

Push-Location $backendPath
try {
  Write-Host "Restoring .NET packages..."
  dotnet restore

  Write-Host "Building API..."
  dotnet build

  # Install EF tool if missing.
  if (-not (Get-Command dotnet-ef -ErrorAction SilentlyContinue)) {
    Write-Host "Installing dotnet-ef tool..."
    dotnet tool install --global dotnet-ef
  }

  # Create initial migration only if none exist.
  $migrationsPath = Join-Path $backendPath "Migrations"
  $migrationFiles = Get-ChildItem $migrationsPath -Filter "*.cs" -ErrorAction SilentlyContinue
  if (-not $migrationFiles) {
    Write-Host "Creating initial EF migration..."
    dotnet ef migrations add InitialCreate
  }

  Write-Host "Applying EF migrations..."
  dotnet ef database update

  Write-Host "Starting API..."
  dotnet run
}
finally {
  Pop-Location
}
