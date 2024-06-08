@echo off
setlocal

:: Set paths
set LOVE_PATH="C:\Program Files\LOVE\love.exe"
set PROJECT_DIR=%cd%
set OUTPUT_LOVE="kreem.love"
set OUTPUT_EXE="kreem.exe"

:: Change to the project directory (if not already there)
cd /d %PROJECT_DIR%

:: Check if 7-Zip is installed
if not exist "%ProgramFiles%\7-Zip\7z.exe" (
    echo 7-Zip not found. Please install 7-Zip or modify the script to point to your zip utility.
    pause
    exit /b 1
)

:: Remove previous .love file if it exists
if exist %OUTPUT_LOVE% del %OUTPUT_LOVE%

:: Zip the folder excluding .vscode and .gitignore
"%ProgramFiles%\7-Zip\7z.exe" a -r -tzip %OUTPUT_LOVE% * -xr!.vscode -xr!.gitignore

:: Check if the love file was created
if not exist %OUTPUT_LOVE% (
    echo Failed to create %OUTPUT_LOVE%
    pause
    exit /b 1
)

:: Create the executable
copy /b %LOVE_PATH%+%OUTPUT_LOVE% %OUTPUT_EXE%

:: Check if the executable was created
if exist %OUTPUT_EXE% (
    echo Successfully created %OUTPUT_EXE%
) else (
    echo Failed to create %OUTPUT_EXE%
)

pause
