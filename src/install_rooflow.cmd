@echo off
setlocal enabledelayedexpansion

echo --- Starting RooFlow config setup ---

:: Check for Git
where git >nul 2>nul
if %errorlevel% neq 0 (
    echo Error: git is not found in your PATH.
    echo Please install Git and ensure it's added to your system's PATH.
    echo You can download Git from: https://git-scm.com/download/win
    exit /b 1
) else (
    echo Found git executable.
)

:: Define a temporary directory for cloning
:: FIXED TYPO: Was TEMP_CLONEDIR in one place, TEMP_CLONE_DIR in others. Standardizing.
set "TEMP_CLONE_DIR=%TEMP%\RooFlowClone_%RANDOM%"
echo Cloning target: %TEMP_CLONE_DIR%

:: Clone the repository
echo Cloning RooFlow repository...
git clone --depth 1 https://github.com/GreatScottyMac/RooFlow "%TEMP_CLONE_DIR%"
if %errorlevel% neq 0 (
    echo Error: Failed to clone RooFlow repository. Check your internet connection and Git setup.
    exit /b 1
)

:: Check if clone was successful by checking for the src dir
if not exist "%TEMP_CLONE_DIR%\src" (
    echo Error: RooFlow repository clone seems incomplete. Config directory not found in temp location.
    if exist "%TEMP_CLONE_DIR%" rmdir /s /q "%TEMP_CLONE_DIR%" >nul 2>nul
    exit /b 1
)

:: --- MODIFIED COPY SECTION START ---
echo Copying specific configuration items...

set "COPY_ERROR=0"

:: 1. Copy .roo directory and its contents
echo Copying .roo directory...
robocopy "%TEMP_CLONE_DIR%\src\.roo" "%CD%\.roo" /E /NFL /NDL /NJH /NJS /nc /ns /np
if %errorlevel% gtr 7 (
    echo   ERROR: Failed to copy .roo directory. Robocopy Errorlevel: %errorlevel%
    set "COPY_ERROR=1"
) else (
    echo   Copied .roo directory.
)

:: 2. Copy .roomodes file
if %COPY_ERROR% equ 0 (
    echo Copying .roomodes...
    copy /Y "%TEMP_CLONE_DIR%\src\.roomodes" "%CD%\" > nul
    if errorlevel 1 (
        echo   ERROR: Failed to copy .roomodes. Check source file exists and permissions.
        set "COPY_ERROR=1"
    ) else (
        echo   Copied .roomodes.
    )
)

:: 3. Copy insert-variables.cmd file
if %COPY_ERROR% equ 0 (
    echo Copying insert-variables.cmd...
    copy /Y "%TEMP_CLONE_DIR%\src\insert-variables.cmd" "%CD%\" > nul
    if errorlevel 1 (
        echo   ERROR: Failed to copy insert-variables.cmd. Check source file exists and permissions.
        set "COPY_ERROR=1"
    ) else (
        echo   Copied insert-variables.cmd.
    )
)

:: Check if any copy operation failed before proceeding
if %COPY_ERROR% equ 1 (
    echo ERROR: One or more essential files/directories could not be copied. Aborting setup.
    if exist "%TEMP_CLONE_DIR%" rmdir /s /q "%TEMP_CLONE_DIR%" >nul 2>nul
    exit /b 1
)

:: --- MODIFIED COPY SECTION END ---


:: --- MODIFIED CLEANUP SECTION START ---
echo Cleaning up temporary clone directory...
if exist "%TEMP_CLONE_DIR%" (
    rmdir /s /q "%TEMP_CLONE_DIR%" >nul 2>nul
    if errorlevel 1 (
       echo   Warning: Failed to completely remove temporary clone directory: %TEMP_CLONE_DIR%
    ) else (
       echo   Removed temporary clone directory.
    )
) else ( echo Temp clone directory not found to remove. )

:: Removed cleanup for insert-variables.sh (never copied)
:: Removed cleanup for default-mode directory (never copied)
:: --- MODIFIED CLEANUP SECTION END ---


:: Check if the essential copied items exist before running script
if not exist "%CD%\.roo" (
    echo Error: .roo directory not found after specific copy. Setup failed.
    exit /b 1
)
if not exist "%CD%\insert-variables.cmd" (
    echo Error: insert-variables.cmd not found after specific copy. Setup failed.
    exit /b 1
)

:: Run the setup script
echo Running insert-variables.cmd...
call insert-variables.cmd
if %errorlevel% neq 0 (
    echo Error: insert-variables.cmd failed to execute properly.
    rem Do not attempt self-delete if the main script failed
    exit /b 1
)

echo insert-variables.cmd completed successfully. Removing it...
del /q /f insert-variables.cmd >nul 2>nul
if errorlevel 1 (
    echo Warning: Failed to delete insert-variables.cmd after execution.
)

echo --- RooFlow config setup complete ---

:: Schedule self-deletion
echo Scheduling self-deletion of install_rooflow.cmd...
start "" /b cmd /c "timeout /t 1 > nul && del /q /f "%~f0""

endlocal
exit /b 0
