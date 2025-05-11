@echo off
setlocal enabledelayedexpansion

echo Claude CLI Installer for Windows
echo -------------------------------
echo.

:: Setup colors for console output
set "GREEN=[92m"
set "RED=[91m"
set "BLUE=[94m"
set "NC=[0m"

:: Function to print success message
call :PrintSuccess "Starting Claude CLI installation"

:: Check for Python installation
python --version > nul 2>&1
if %errorlevel% neq 0 (
    call :PrintError "Python is not installed or not in PATH."
    call :PrintInfo "Please install Python 3.7 or higher from https://www.python.org/downloads/"
    exit /b 1
)

for /f "tokens=*" %%a in ('python --version 2^>^&1') do set PYTHON_VERSION=%%a
call :PrintSuccess "Found %PYTHON_VERSION%"

:: Get the script directory
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
call :PrintInfo "Installation directory: %SCRIPT_DIR%"

:: Check if the script file exists
if not exist "%SCRIPT_DIR%\claude_cli.py" (
    call :PrintError "Script file claude_cli.py not found in %SCRIPT_DIR%"
    exit /b 1
)

:: Install required packages
call :PrintInfo "Installing required packages..."
python -m pip install anthropic > nul 2>&1
if %errorlevel% neq 0 (
    call :PrintError "Failed to install required packages."
    call :PrintInfo "Please run: python -m pip install anthropic"
    exit /b 1
)
call :PrintSuccess "Packages installed successfully"

:: Create batch file for claude command
call :PrintInfo "Creating 'claude' command..."
set "BATCH_FILE=%SCRIPT_DIR%\claude.bat"

echo @echo off > "%BATCH_FILE%"
echo :: Claude CLI wrapper batch file >> "%BATCH_FILE%"
echo. >> "%BATCH_FILE%"
echo :: Check for API key >> "%BATCH_FILE%"
echo if "%%ANTHROPIC_API_KEY%%"=="" ( >> "%BATCH_FILE%"
echo   if exist "%%USERPROFILE%%\.claude_api_key" ( >> "%BATCH_FILE%"
echo     for /f "tokens=*" %%%%a in ('type "%%USERPROFILE%%\.claude_api_key"') do set "ANTHROPIC_API_KEY=%%%%a" >> "%BATCH_FILE%"
echo   ) else ( >> "%BATCH_FILE%"
echo     echo %RED%Error: ANTHROPIC_API_KEY environment variable not set and no API key found.%NC% >> "%BATCH_FILE%"
echo     echo %BLUE%Please set it with: setx ANTHROPIC_API_KEY "your_api_key"%NC% >> "%BATCH_FILE%"
echo     echo %BLUE%Or create a file at %%USERPROFILE%%\.claude_api_key containing your API key.%NC% >> "%BATCH_FILE%"
echo     exit /b 1 >> "%BATCH_FILE%"
echo   ) >> "%BATCH_FILE%"
echo ) >> "%BATCH_FILE%"
echo. >> "%BATCH_FILE%"
echo :: Run the Python script >> "%BATCH_FILE%"
echo python "%SCRIPT_DIR%\claude_cli.py" %%* >> "%BATCH_FILE%"

:: Make sure the script is executable
call :PrintSuccess "Created 'claude' command batch file"

:: Prompt for API key if not set
set "API_KEY_FILE=%USERPROFILE%\.claude_api_key"

if exist "%API_KEY_FILE%" (
    call :PrintSuccess "API key file already exists at %API_KEY_FILE%"
) else (
    echo.
    call :PrintInfo "Would you like to set up your Anthropic API key now? (Y/N)"
    set /p setup_key=
    
    if /i "!setup_key!"=="Y" (
        echo.
        call :PrintInfo "Enter your Anthropic API key:"
        set /p api_key=
        
        echo !api_key!> "%API_KEY_FILE%"
        call :PrintSuccess "API key saved to %API_KEY_FILE%"
    ) else (
        echo.
        call :PrintInfo "You'll need to set the ANTHROPIC_API_KEY environment variable later"
        call :PrintInfo "or create a file at %API_KEY_FILE% containing your API key."
    )
)

:: Setup PATH options
echo.
call :PrintInfo "Would you like to add claude to your PATH? (Y/N)"
set /p add_to_path=

if /i "!add_to_path!"=="Y" (
    echo.
    call :PrintInfo "Select installation method:"
    echo   1. Add to current user PATH (recommended)
    echo   2. Create shortcut in Windows directory (requires administrator privileges)
    echo   3. Skip this step
    
    set /p install_method=
    
    if "!install_method!"=="1" (
        :: Add to user PATH
        for /f "tokens=2*" %%a in ('reg query HKCU\Environment /v PATH') do set "user_path=%%b"
        
        :: Check if the path is already in PATH
        echo !user_path! | findstr /C:"%SCRIPT_DIR%" > nul
        if %errorlevel% neq 0 (
            setx PATH "!user_path!;%SCRIPT_DIR%"
            call :PrintSuccess "Added %SCRIPT_DIR% to your PATH."
            call :PrintInfo "Please restart your terminal for changes to take effect."
        ) else (
            call :PrintSuccess "%SCRIPT_DIR% is already in your PATH."
        )
    ) else if "!install_method!"=="2" (
        :: Create shortcut in Windows directory
        call :PrintInfo "Creating shortcut in Windows directory..."
        copy "%BATCH_FILE%" "%WINDIR%\claude.bat" > nul 2>&1
        
        if %errorlevel% neq 0 (
            call :PrintError "Failed to create shortcut in Windows directory."
            call :PrintInfo "This requires administrator privileges."
            echo.
            call :PrintInfo "You can manually copy the batch file:"
            echo copy "%BATCH_FILE%" "%WINDIR%\claude.bat"
        ) else (
            call :PrintSuccess "Successfully created claude.bat in Windows directory."
        )
    ) else (
        call :PrintInfo "Skipping PATH setup."
        call :PrintInfo "You can manually run claude with: %BATCH_FILE%"
    )
) else (
    call :PrintInfo "Skipping PATH setup."
    call :PrintInfo "You can manually run claude with: %BATCH_FILE%"
)

echo.
call :PrintInfo "Creating shortcut batch file for quick access..."
echo @echo off > "%SCRIPT_DIR%\c.bat"
echo :: Claude CLI quick shortcut >> "%SCRIPT_DIR%\c.bat"
echo claude start %%* >> "%SCRIPT_DIR%\c.bat"
call :PrintSuccess "Created c.bat shortcut."

:: Final check
echo.
call :PrintSuccess "Installation complete!"
call :PrintInfo "Testing Claude CLI..."
python "%SCRIPT_DIR%\claude_cli.py" check

echo.
call :PrintInfo "You can now use the following commands:"
echo   claude start  - Start an immediate chat session with Claude
echo   claude ask    - Ask Claude a single question
echo   claude chat   - Start an interactive chat session with more options
echo   claude check  - Check the environment and configuration
echo.
echo If you added the shortcut:
echo   c             - Quick shortcut to start a chat session
echo.
call :PrintInfo "If you added Claude to your PATH, you may need to restart your terminal."
echo.
call :PrintSuccess "Enjoy using Claude CLI!"

goto :EOF

:PrintSuccess
echo %GREEN%✓ %~1%NC%
exit /b 0

:PrintError
echo %RED%✗ %~1%NC%
exit /b 0

:PrintInfo
echo %BLUE%→ %~1%NC%
exit /b 0

endlocal