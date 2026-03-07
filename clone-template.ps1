$projectName = (Read-Host "Enter the new project name").Trim()

if ([string]::IsNullOrWhiteSpace($projectName) -or $projectName -match '[<>:"/\\|?*]') {
    Write-Host "Invalid project name. Cannot be empty or contain < > : `" / \ | ? *"
    Read-Host "Press Enter to exit"
    exit
}

$sourcePath = $PSScriptRoot
$parentPath = Split-Path -Path $sourcePath -Parent
$targetPath = Join-Path -Path $parentPath -ChildPath $projectName

if (Test-Path -Path $targetPath) {
    Write-Host "A folder with this name already exists at the destination."
    Read-Host "Press Enter to exit"
    exit
}

$currentFolderName = Split-Path -Path $sourcePath -Leaf
$slnFileName = "$currentFolderName.sln"

$dotFolders = Get-ChildItem -Path $sourcePath -Directory -Force | Where-Object { $_.Name.StartsWith('.') } | Select-Object -ExpandProperty Name
$excludedDirs = @("Library", "obj", "Temp", "Logs", "UserSettings") + $dotFolders
$excludedFiles = @($slnFileName, $MyInvocation.MyCommand.Name)

Write-Host "Copying files..."
robocopy $sourcePath $targetPath /E /XD $excludedDirs /XF $excludedFiles /NFL /NDL /NJH /NJS

$projectSettingsPath = Join-Path -Path $targetPath -ChildPath "ProjectSettings\ProjectSettings.asset"
if (Test-Path -Path $projectSettingsPath) {
    $settingsContent = Get-Content -Path $projectSettingsPath
    $settingsContent = $settingsContent -replace '(?<=productName:\s).*', $projectName
    Set-Content -Path $projectSettingsPath -Value $settingsContent
}

Write-Host "Project '$projectName' successfully created at: $targetPath"
Read-Host "Press Enter to exit"