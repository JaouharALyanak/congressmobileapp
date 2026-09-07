@echo off
setlocal enabledelayedexpansion

:: ============================================================
::  build_android.bat  <config_name> [apk|aab|all]
::  Exemples :
::    scripts\build_android.bat smr26
::    scripts\build_android.bat smr26 aab
::    scripts\build_android.bat smr26 all
:: ============================================================

SET CONFIG=%1
SET TARGET=%2
IF "%TARGET%"=="" SET TARGET=apk

IF "%CONFIG%"=="" (
    echo [ERREUR] Specifie un nom de config. Ex: scripts\build_android.bat smr26
    exit /b 1
)

SET CONFIG_FILE=configs\%CONFIG%.json
SET ICON_SRC=assets\icons\%CONFIG%.png
SET ICON_DST=assets\icon\app_icon.png

IF NOT EXIST "%CONFIG_FILE%" (
    echo [ERREUR] Fichier de config introuvable : %CONFIG_FILE%
    exit /b 1
)

echo.
echo =====================================================
echo  Build : %CONFIG%  ^|  Cible : %TARGET%
echo =====================================================

:: ── 1. Icone ───────────────────────────────────────────────
IF EXIST "%ICON_SRC%" (
    echo [1/3] Icone trouvee : %ICON_SRC%
    copy /Y "%ICON_SRC%" "%ICON_DST%" >nul
    cmd /c dart run flutter_launcher_icons
    echo [1/3] Icones generees.
) ELSE (
    echo [1/3] Pas d'icone specifique, icone par defaut utilisee.
)

:: ── 2. Build ────────────────────────────────────────────────
IF "%TARGET%"=="apk" GOTO BUILD_APK
IF "%TARGET%"=="aab" GOTO BUILD_AAB
IF "%TARGET%"=="all" GOTO BUILD_ALL
echo [ERREUR] Cible inconnue : %TARGET%  ^(valeurs : apk ^| aab ^| all^)
exit /b 1

:BUILD_APK
echo [2/3] Build APK en cours ^(peut prendre 3-5 minutes^)...
cmd /c flutter build apk --release --dart-define-from-file=%CONFIG_FILE%
IF %ERRORLEVEL% NEQ 0 ( echo [ERREUR] Build APK echoue. & exit /b 1 )
echo [3/3] Renommage de l'APK...
SET APK_SRC=build\app\outputs\flutter-apk\app-release.apk
SET APK_DST=build\app\outputs\flutter-apk\%CONFIG%-release.apk
IF EXIST "%APK_SRC%" ( move /Y "%APK_SRC%" "%APK_DST%" >nul & echo  APK genere : %APK_DST% )
GOTO DONE

:BUILD_AAB
echo [2/3] Build AAB en cours ^(peut prendre 3-5 minutes^)...
cmd /c flutter build appbundle --release --dart-define-from-file=%CONFIG_FILE%
IF %ERRORLEVEL% NEQ 0 ( echo [ERREUR] Build AAB echoue. & exit /b 1 )
echo [3/3] Renommage de l'AAB...
SET AAB_SRC=build\app\outputs\bundle\release\app-release.aab
SET AAB_DST=build\app\outputs\bundle\release\%CONFIG%-release.aab
IF EXIST "%AAB_SRC%" ( move /Y "%AAB_SRC%" "%AAB_DST%" >nul & echo  AAB genere : %AAB_DST% )
GOTO DONE

:BUILD_ALL
CALL :BUILD_APK
CALL :BUILD_AAB
GOTO DONE

:DONE
echo.
echo  Build termine avec succes !
echo =====================================================
endlocal
