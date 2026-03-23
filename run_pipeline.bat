@echo off
REM Windows batch script to run the Tobit pipeline.
REM This makes it easy for double-clicking or running from CMD.

echo ==========================================
echo Starting Tobit Pipeline Execution
echo ==========================================

where Rscript >nul 2>nul
if %errorlevel% neq 0 (
    echo Error: Rscript was not found in your PATH.
    echo Please ensure R is installed and Rscript.exe is in your environment variables.
    pause
    exit /b 1
)

Rscript run_pipeline.R
if %errorlevel% neq 0 (
    echo.
    echo Error: Pipeline execution failed.
    pause
    exit /b 1
)

echo.
echo ==========================================
echo Pipeline Execution Finished Successfully.
echo ==========================================
pause
