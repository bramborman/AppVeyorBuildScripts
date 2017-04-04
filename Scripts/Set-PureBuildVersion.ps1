param([string[]]$Branches = "master", [string]$Separator = "-", [ValidateRange(0, [int]::MaxValue)][int]$SplitIndex = 1)
Write-Host "Set-PureBuildVersion script executed"
Write-Host "====================================`n"

if (($Branches -eq $null) -or ([string]::IsNullOrWhiteSpace($Branches.ToString())))
{
	throw "Parameter `$Branches must not be null or empty."
}

if ([string]::IsNullOrWhiteSpace($Branches))
{
    throw "Parameter `$Branches must not be null or white space."
}

$pureBuildVersion = $env:APPVEYOR_BUILD_VERSION.Split($Separator) | Select-Object -first $SplitIndex
Set-AppveyorBuildVariable "PURE_BUILD_VERSION" $pureBuildVersion

$changeBuildVersion = @($Branches | Where-Object{ $_ -eq $env:APPVEYOR_REPO_BRANCH }).Length -gt 0

# Check whether this is commit to the specified branch and not just PR to the branch
if ($changeBuildVersion -and ($env:APPVEYOR_PULL_REQUEST_TITLE -eq $null) -and ($env:APPVEYOR_PULL_REQUEST_NUMBER -eq $null))
{
	$message = "Changing the build version from '$env:APPVEYOR_BUILD_VERSION' to '$pureBuildVersion'"
	Add-AppveyorMessage $message
	Write-Host $message

	Update-AppveyorBuild -Version $pureBuildVersion
	# Set the environment variable explicitly so it will be preserved to deployments (specifically GitHub Releases)
	Set-AppveyorBuildVariable "APPVEYOR_BUILD_VERSION" $pureBuildVersion
}
