param(
    $location,
    $rgName,
    $owner,
    $costCenter,
    $application,
    $description,
    $repo
)

$tag= @{
    Owner= $owner;
    CostCenter = $costCenter;
    Application = $application;
    Description = $description;
    Repositery = $repo; 
}

try {
    Write-Host "Now creating the rg"
    if (Get-AzResourceGroup -Name $rgName -ErrorAction SilentlyContinue) {
        # Resource group exists, override it
        Write-Host "Resource group '$rgName' already exists. Overriding..."
    
        # Remove the existing resource group
        Remove-AzResourceGroup -Name $resourceGroupName -Force
    }
    $deployment= New-AzResourceGroup -Name "${rgName}" -Location "${location}" -Tag ${tag}
    Write-Host $deployment
}
catch {
    $message = $_.Exception.Message
    $stackTraceText = $_.Exception.StackTrace
    Write-Host "Failed :"
    Write-Host $message
    Write-Host $stackTraceText
    throw "script halted"
}