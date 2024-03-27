param (
    $filePath,
    $bicepTemplate,
    $outFile
)

try {
    Write-Host "Now compiling BICEP to ARM"
    az bicep upgrade
    az bicep build --file "${filePath}/${bicepTemplate}" --outfile "${filePath}/${outFile}"
    $files= Get-Children -Path "${filePath}"
    Write-Host "Show files ...."
    Write-Host "${files}"
}
catch {
   $message =  $_.Exception.Message
   $stackTrace = $_.Exception.StackTrace
   Write-Host "failed : "
   Write-Host $message
   Write-Host $stackTrace
   Write-Host "Script halted"
}