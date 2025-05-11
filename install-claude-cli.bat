@echo off
setlocal enabledelayedexpansion

echo Claude CLI Installer for Windows
echo -------------------------------
echo.

:: Check for Python installation
python --version > nul 2>&1
if %errorlevel% neq 0 (
    echo Error: Python is not installed or not in PATH.
    echo Please install Python 3.7 or higher from https://www.python.org/downloads/
    exit /b 1
)

:: Get the script directory
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

:: Install required packages
echo Installing required packages...
pip install anthropic > nul 2>&1
if %errorlevel% neq 0 (
    echo Error: Failed to install required packages.
    echo Please run: pip install anthropic
    exit /b 1
)

:: Create batch file for claude command
echo Creating claude command...
set "BATCH_FILE=%SCRIPT_DIR%\claude.bat"

echo @echo off > "%BATCH_FILE%"
echo python "%SCRIPT_DIR%\claude-cli.py" %%* >> "%BATCH_FILE%"

:: Prompt for API key if not set
set "API_KEY_FILE=%USERPROFILE%\.claude_api_key"

if exist "%API_KEY_FILE%" (
    echo API key file already exists at %API_KEY_FILE%
) else (
    echo.
    echo Would you like to set up your Anthropic API key now? (Y/N)
    set /p setup_key=
    
    if /i "!setup_key!"=="Y" (
        echo.
        echo Enter your Anthropic API key:
        set /p api_key=
        
        echo !api_key!> "%API_KEY_FILE%"
        echo API key saved to %API_KEY_FILE%
    ) else (
        echo.
        echo You'll need to set the ANTHROPIC_API_KEY environment variable later
        echo or create a file at %API_KEY_FILE% containing your API key.
    )
)

:: Setup PATH options
echo.
echo Would you like to add claude to your PATH? (Y/N)
set /p add_to_path=

if /i "!add_to_path!"=="Y" (
    echo.
    echo Select installation method:
    echo 1. Add to current user PATH (recommended)
    echo 2. Create shortcut in Windows directory (requires administrator privileges)
    echo 3. Skip this step
    
    set /p install_method=
    
    if "!install_method!"=="1" (
        :: Add to user PATH
        for /f "tokens=2*" %%a in ('reg query HKCU\Environment /v PATH') do set "user_path=%%b"
        
        :: Check if the path is already in PATH
        echo !user_path! | findstr /C:"%SCRIPT_DIR%" > nul
        if %errorlevel% neq 0 (
            setx PATH "!user_path!;%SCRIPT_DIR%"
            echo Added %SCRIPT_DIR% to your PATH.
            echo Please restart your terminal for changes to take effect.
        ) else (
            echo %SCRIPT_DIR% is already in your PATH.
        )
    ) else if "!install_method!"=="2" (
        :: Create shortcut in Windows directory
        echo Creating shortcut in Windows directory...
        copy "%BATCH_FILE%" "%WINDIR%\claude.bat" > nul 2>&1
        
        if %errorlevel% neq 0 (
            echo Error: Failed to create shortcut in Windows directory.
            echo This requires administrator privileges.
            echo.
            echo You can manually copy the batch file:
            echo copy "%BATCH_FILE%" "%WINDIR%\claude.bat"
        ) else (
            echo Successfully created claude.bat in Windows directory.
        )
    ) else (
        echo Skipping PATH setup.
        echo You can manually run claude with: %BATCH_FILE%
    )
) else (
    echo Skipping PATH setup.
    echo You can manually run claude with: %BATCH_FILE%
)

echo.
echo Creating shortcut batch file for quick access...
echo @echo off > "%SCRIPT_DIR%\c.bat"
echo claude start %%* >> "%SCRIPT_DIR%\c.bat"
echo Created c.bat shortcut.

echo.
echo Installation complete!
echo.
echo You can now use the following commands:
echo   claude start  - Start an immediate chat session with Claude
echo   claude ask    - Ask Claude a single question
echo   claude chat   - Start an interactive chat session with more options
echo.
echo If you added Claude to your PATH, you may need to restart your terminal.
echo.
echo Enjoy using Claude CLI!

endlocal