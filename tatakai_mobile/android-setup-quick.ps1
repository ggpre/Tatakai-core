# Quick Android Setup for Flutter
Write-Host "=== Android Setup for Flutter ===" -ForegroundColor Cyan
Write-Host ""

# Accept licenses
Write-Host "Accepting Android licenses..." -ForegroundColor Yellow
flutter doctor --android-licenses

# Check doctor
Write-Host ""
Write-Host "Checking Flutter setup..." -ForegroundColor Yellow
flutter doctor

# List emulators
Write-Host ""
Write-Host "Available emulators:" -ForegroundColor Yellow
flutter emulators

Write-Host ""
Write-Host "=== Next Steps ===" -ForegroundColor Green
Write-Host "1. If no emulators listed, open Android Studio" -ForegroundColor White
Write-Host "2. Go to: More Actions → Virtual Device Manager" -ForegroundColor White
Write-Host "3. Click: Create Device" -ForegroundColor White
Write-Host "4. Select: Pixel 7 or Pixel 8" -ForegroundColor White
Write-Host "5. Download: Android 14 (UpsideDownCake)" -ForegroundColor White
Write-Host "6. Click: Finish" -ForegroundColor White
Write-Host ""
Write-Host "Then run:" -ForegroundColor Cyan
Write-Host "  flutter emulators" -ForegroundColor White
Write-Host "  flutter emulators --launch <name>" -ForegroundColor White
Write-Host "  flutter run" -ForegroundColor White
