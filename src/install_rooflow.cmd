@echo off
setlocal enabledelayedexpansion

echo --- Starting RooFlow config setup ---

:: Define a temporary directory for the download
set "TEMP_TAR_PATH=%TEMP%\RooFlowTar_%RANDOM%.tar.gz"
echo Download target: %TEMP_TAR_PATH%

:: Download the latest release
echo Downloading latest release...
curl -L -o %TEMP_TAR_PATH% https://github.com/NamesMT/RooFlow-generic/releases/latest/download/dist.tar.gz

:: Check if download was successful
if not exist "%TEMP_TAR_PATH%" (
    echo Error: Download seems incomplete. tar file not found.
    exit /b 1
)

:: Create temporary directory in project and extract
echo Extracting file to temporary directory...
mkdir .tmp\RooFlow
tar -xzf %TEMP_TAR_PATH% -C .tmp\RooFlow
:: Check if extract was successful
if not exist ".tmp\RooFlow\.roomodes" (
    echo Error: Extract seems to encounter an error, .roomodes file not found..
    rmdir /s /q .tmp
    exit /b 1
)
echo Extraction done

set "COPY_ERROR=0"

:: 1. Copy .roo directory and its contents
echo Copying .roo directory...
robocopy ".tmp\RooFlow\.roo" "%CD%\.roo" /E /NFL /NDL /NJH /NJS /nc /ns /np
if %errorlevel% gtr 7 (
    echo   ERROR: Failed to copy .roo directory. Robocopy Errorlevel: %errorlevel%
    set "COPY_ERROR=1"
) else (
    echo   Copied .roo directory.
)

:: 2. Copy .roomodes file
if %COPY_ERROR% equ 0 (
    echo Copying .roomodes...
    copy /Y ".tmp\RooFlow\.roomodes" "%CD%\" > nul
    if errorlevel 1 (
        echo   ERROR: Failed to copy .roomodes. Check source file exists and permissions.
        set "COPY_ERROR=1"
    ) else (
        echo   Copied .roomodes.
    )
)

:: Check if any copy operation failed before proceeding
if %COPY_ERROR% equ 1 (
    echo ERROR: One or more essential files/directories could not be copied. Aborting setup.
    if exist "%TEMP_SRC_DIR%" rmdir /s /q "%TEMP_SRC_DIR%" >nul 2>nul
    exit /b 1
)

:: --- MODIFIED COPY SECTION END ---


:: Schedule self-deletion
echo Scheduling self-deletion of installation files...
del /q %TEMP_TAR_PATH%
rmdir /s /q .tmp
start "" /b cmd /c "timeout /t 1 > nul && del /q /f "%~f0""

endlocal
exit /b 0
