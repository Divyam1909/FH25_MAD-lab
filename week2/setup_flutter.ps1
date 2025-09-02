# Flutter Web Setup Script for Windows
# Run with: .\setup_flutter.ps1

Write-Host "Checking Flutter..." -ForegroundColor Cyan

# Check if Flutter is installed
$flutterCheck = Get-Command flutter -ErrorAction SilentlyContinue
if (-not $flutterCheck) {
    Write-Host "Flutter not found. Please install Flutter first." -ForegroundColor Red
    Write-Host "Download from: https://docs.flutter.dev/get-started/install/windows" -ForegroundColor Yellow
    exit 1
}

Write-Host "Flutter found!" -ForegroundColor Green

# Enable web support
Write-Host "Enabling Flutter web..." -ForegroundColor Cyan
flutter config --enable-web

# Get dependencies
Write-Host "Getting Flutter dependencies..." -ForegroundColor Cyan
flutter pub get

# Function to build and serve
function Start-FlutterWeb {
    Write-Host "Building Flutter web..." -ForegroundColor Cyan
    flutter clean
    flutter pub get
    flutter build web --release --pwa-strategy=none
    
    Write-Host "Starting server on port 8080..." -ForegroundColor Green
    Set-Location "build/web"
    
    # Kill any existing Python processes on port 8080
    $pythonProcs = Get-Process python -ErrorAction SilentlyContinue | Where-Object {
        try {
            $connections = netstat -ano | Select-String ":8080" | Select-String $_.Id
            return $connections.Count -gt 0
        } catch {
            return $false
        }
    }
    
    if ($pythonProcs) {
        Write-Host "Stopping existing server..." -ForegroundColor Yellow
        $pythonProcs | Stop-Process -Force
    }
    
    # Start new server
    Start-Process -FilePath "python" -ArgumentList "-m", "http.server", "8080" -WindowStyle Hidden
    Set-Location "../.."
    
    Start-Sleep -Seconds 2
    Write-Host "Server running at: http://localhost:8080" -ForegroundColor Green
}

# Initial build and serve
Start-FlutterWeb

# Interactive menu
do {
    Write-Host ""
    Write-Host "Commands:" -ForegroundColor Cyan
    Write-Host "  r - Rebuild and restart server" -ForegroundColor White
    Write-Host "  o - Open browser" -ForegroundColor White
    Write-Host "  q - Quit" -ForegroundColor White
    Write-Host ""
    $choice = Read-Host "Enter choice (r/o/q)"
    
    switch ($choice.ToLower()) {
        "r" {
            Start-FlutterWeb
        }
        "o" {
            Write-Host "Opening browser..." -ForegroundColor Green
            $ts = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
            Start-Process "http://localhost:8080/?v=$ts"
        }
        "q" {
            Write-Host "Stopping server and exiting..." -ForegroundColor Yellow
            # Stop Python processes
            Get-Process python -ErrorAction SilentlyContinue | Where-Object {
                try {
                    $connections = netstat -ano | Select-String ":8080" | Select-String $_.Id
                    return $connections.Count -gt 0
                } catch {
                    return $false
                }
            } | Stop-Process -Force
            break
        }
        default {
            Write-Host "Invalid choice. Please enter r, o, or q" -ForegroundColor Red
        }
    }
} while ($true) 