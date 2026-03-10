#!/usr/bin/env pwsh
# MediSync Debug Test Script

Write-Host "=== MediSync Blank Pages Debug ===" -ForegroundColor Cyan
Write-Host ""

Write-Host "[1/3] Checking dependencies..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "Pub get failed!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[2/3] Running app with debug output..." -ForegroundColor Yellow
Write-Host "Watch the console for messages starting with [DEBUG]" -ForegroundColor Cyan
Write-Host "If you see blank pages, check these messages:" -ForegroundColor Cyan
Write-Host "  - '[DEBUG] DoctorDashboard initState' should show list counts" -ForegroundColor Green
Write-Host "  - '[DEBUG] Building tab body for: Dashboard' should appear" -ForegroundColor Green
Write-Host "  - '[DEBUG] _DashboardTab build - patients: 5' should show" -ForegroundColor Green
Write-Host ""

flutter run

Write-Host ""
Write-Host "[3/3] Debug test complete" -ForegroundColor Cyan
