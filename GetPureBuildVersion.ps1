$pureBuildVersion = $env:APPVEYOR_BUILD_VERSION.Split("-") | Select-Object -first 1
Set-AppveyorBuildVariable "PURE_BUILD_VERSION" $pureBuildVersion

# Check whether this is commit in branch 'master' and not just PR to the branch
if (($env:APPVEYOR_REPO_BRANCH -eq "master") -and ($env:APPVEYOR_PULL_REQUEST_TITLE -eq $null) -and ($env:APPVEYOR_PULL_REQUEST_NUMBER -eq $null))
{
	$message = "Changing the build version from '$env:APPVEYOR_BUILD_VERSION' to '$pureBuildVersion'"
	Add-AppveyorMessage $message
	Write-Host $message

	Update-AppveyorBuild -Version $pureBuildVersion
	# Set the environment variable explicitly so it will be preserved to deployments (specifically GitHub Releases)
	Set-AppveyorBuildVariable "APPVEYOR_BUILD_VERSION" $pureBuildVersion
}
