# Variable declaration
$logPath = ".\MyLogFile.txt"
$filePath = "MyFile.txt"

# Script starts here
Write-Output "Script starts here"

New-Item MyFolder -itemtype Directory

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Add-Content $logPath "$timestamp - Created the directory MyFolder"

Set-Location MyFolder
New-Item $filePath -itemtype File
Set-Content $filePath "Hello, World!"
# Loop 1,000 times
for ($i = 1; $i -le 1000; $i++) {
    # Generate random text (you can use New-Guid or another method)
    $randomText = [guid]::NewGuid().ToString()

    # Append the random text to the file
    Add-Content $filePath "Line $i $randomText"
}

Rename-Item $filePath MyNewFile.txt

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Add-Content $logPath "$timestamp - Created and renamed file"

# Get-Content MyNewFile.txt
Set-Location ..
if (Test-Path MyFolder\MyNewFile.txt) {
    Write-Output "File exists, proceeding with deletion"
    Remove-Item MyFolder -Recurse

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content $logPath "$timestamp - Deleted MyFolder"

    Write-Output "Done"
} else {
    Write-Output "File does not exist, skipping deletion"
}

# End of script