@echo off
:: Esporta Erbalta per itch.io e Game Jolt, nella cartella build\ accanto al progetto:
::   build\windows\Erbalta.exe        (un solo file, il .pck e' dentro)
::   build\Erbalta-windows.zip        da caricare come "Windows"
::   build\web\index.html + file      la versione da giocare nel browser
::   build\Erbalta-web.zip            da caricare come "HTML5 / gioca nel browser"
::
:: Serve il percorso di Godot: o la variabile GODOT_BIN, oppure
::     export.cmd C:\percorso\Godot.exe
:: e i "template di esportazione" della stessa versione di Godot
:: (nell'editor: Editor > Gestisci modelli di esportazione > Scarica e installa).
setlocal
set "GODOT=%~1"
if "%GODOT%"=="" set "GODOT=%GODOT_BIN%"
if "%GODOT%"=="" (
    echo Manca il percorso di Godot: export.cmd C:\percorso\Godot.exe
    exit /b 1
)
cd /d "%~dp0"
if not exist "..\build\windows" mkdir "..\build\windows"
if not exist "..\build\web" mkdir "..\build\web"

"%GODOT%" --headless --path . --export-release "Windows Desktop" "../build/windows/Erbalta.exe" || exit /b 1
"%GODOT%" --headless --path . --export-release "Web" "../build/web/index.html" || exit /b 1

powershell -NoProfile -Command "Compress-Archive -Force -Path '..\build\windows\*' -DestinationPath '..\build\Erbalta-windows.zip'; Compress-Archive -Force -Path '..\build\web\*' -DestinationPath '..\build\Erbalta-web.zip'" || exit /b 1
echo.
echo Fatto: build\Erbalta-windows.zip e build\Erbalta-web.zip
