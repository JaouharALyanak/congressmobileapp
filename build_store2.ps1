$CONFIG = "configs/smr26_store2.json"
$OUT    = "releases/store2"

New-Item -ItemType Directory -Force -Path $OUT | Out-Null

Write-Host "Building APK..." -ForegroundColor Cyan
flutter build apk --release --dart-define-from-file=$CONFIG
if (-not $?) { Write-Host "APK build failed" -ForegroundColor Red; exit 1 }

Write-Host "Building AAB..." -ForegroundColor Cyan
flutter build appbundle --release --dart-define-from-file=$CONFIG
if (-not $?) { Write-Host "AAB build failed" -ForegroundColor Red; exit 1 }

Copy-Item "build/app/outputs/flutter-apk/SMR2026-release.apk" "$OUT/smr26-release.apk" -Force
Copy-Item "build/app/outputs/bundle/release/app-release.aab"  "$OUT/smr26-release.aab"  -Force

Write-Host ""
Write-Host "Done! Fichiers dans $OUT :" -ForegroundColor Green
Get-ChildItem $OUT
