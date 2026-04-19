@echo off
REM Windows batch helper for the longitudinal mixed-model pipeline.

set "RSCRIPT_CMD="
for /f "delims=" %%I in ('where Rscript 2^>nul') do (
    set "RSCRIPT_CMD=%%I"
    goto :run_pipeline
)

for /f "delims=" %%I in ('dir /b /s "C:\Program Files\R\Rscript.exe" 2^>nul') do (
    set "RSCRIPT_CMD=%%I"
    goto :run_pipeline
)

echo Error: Rscript.exe was not found in PATH or under C:\Program Files\R.
pause
exit /b 1

:run_pipeline
echo ==========================================
echo Starting longitudinal judgement pipeline
echo ==========================================
"%RSCRIPT_CMD%" run_pipeline.R
if %errorlevel% neq 0 (
    echo.
    echo Error: Pipeline execution failed.
    pause
    exit /b 1
)

echo.
echo ==========================================
echo Pipeline execution finished successfully
echo ==========================================
pause
