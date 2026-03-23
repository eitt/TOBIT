# run_pipeline.ps1
# Helper script to run the Tobit pipeline on Windows PowerShell.
# This ensures Rscript is used and the environment is checked.

if (!(Get-Command "Rscript" -ErrorAction SilentlyContinue)) {
    Write-Host "Error: Rscript was not found in your PATH." -ForegroundColor Red
    Write-Host "Please ensure R is installed and Rscript.exe is in your environment variables."
    exit 1
}

Write-Host ">>> Starting Tobit Pipeline Execution <<<" -ForegroundColor Cyan
Rscript run_pipeline.R
Write-Host ">>> Pipeline Execution Finished <<<" -ForegroundColor Cyan
