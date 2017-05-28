param([string]$Template = "[Version]-[Branch]-[DateTime]-[Build]", [string]$Separator = "-")
Write-Host "`nSet-BuildVersion script executed"
Write-Host   "================================"

if ([string]::IsNullOrWhiteSpace($Template))
{
    throw "Parameter `$Template must not be null or white space."
}

if ([string]::IsNullOrWhiteSpace($Separator))
{
    throw "Parameter `$Separator must not be null or white space."
}

$buildVersion = $env:APPVEYOR_BUILD_VERSION
$version = $buildVersion.Substring(0, $buildVersion.IndexOf($Separator))

$newBuildVersion = $Template.Replace("[Version]", $version)
$newBuildVersion = $newBuildVersion.Replace("[Branch]", $env:APPVEYOR_REPO_BRANCH)
$newBuildVersion = $newBuildVersion.Replace("[DateTime]", [DateTime]::UtcNow.ToString("yyyyMMdd-HHmmss"))
$newBuildVersion = $newBuildVersion.Replace("[Build]", $env:APPVEYOR_BUILD_NUMBER)

Update-AppveyorBuild -Version $newBuildVersion
# Set the environment variable explicitly so it will be preserved to deployments (specifically GitHub Releases)
Set-AppveyorBuildVariable "APPVEYOR_BUILD_VERSION" $newBuildVersion
