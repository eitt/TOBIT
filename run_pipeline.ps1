# Windows PowerShell helper for the longitudinal mixed-model pipeline.

$rscriptCommand = Get-Command "Rscript" -ErrorAction SilentlyContinue
if (-not $rscriptCommand) {
    $fallback = Get-ChildItem "C:\Program Files\R" -Recurse -Filter Rscript.exe -ErrorAction SilentlyContinue |
        Sort-Object FullName -Descending |
        Select-Object -First 1
    if ($fallback) {
        $rscriptPath = $fallback.FullName
    } else {
        Write-Host "Error: Rscript.exe was not found in PATH or under C:\Program Files\R." -ForegroundColor Red
        exit 1
    }
} else {
    $rscriptPath = $rscriptCommand.Source
}

Write-Host ">>> Starting longitudinal judgement pipeline <<<" -ForegroundColor Cyan
& $rscriptPath run_pipeline.R
if ($LASTEXITCODE -ne 0) {
    Write-Host ">>> Pipeline execution failed <<<" -ForegroundColor Red
    exit $LASTEXITCODE
}
Write-Host ">>> Pipeline execution finished successfully <<<" -ForegroundColor Cyan
