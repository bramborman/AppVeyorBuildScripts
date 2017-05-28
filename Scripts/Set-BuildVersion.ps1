param([string]$Template = "[Version]-[Branch]_[DateTime]_[Build]")
Write-Host "`nSet-BuildVersion script executed"
Write-Host   "================================"

if ([string]::IsNullOrWhiteSpace($Template))
{
    throw "Parameter `$Template must not be null or white space."
}

$newBuildVersion = $Template.Replace("[Version]", $env:APPVEYOR_BUILD_VERSION)
$newBuildVersion = $newBuildVersion.Replace("[Branch]", $env:APPVEYOR_REPO_BRANCH)
$newBuildVersion = $newBuildVersion.Replace("[DateTime]", [DateTime]::UtcNow.ToString("yyyy-MM-dd_HH:mm:ss"))
$newBuildVersion = $newBuildVersion.Replace("[Build]", $env:APPVEYOR_BUILD_VERSION)

Update-AppveyorBuild -Version $newBuildVersion
# Set the environment variable explicitly so it will be preserved to deployments (specifically GitHub Releases)
Set-AppveyorBuildVariable "APPVEYOR_BUILD_VERSION" $newBuildVersion
