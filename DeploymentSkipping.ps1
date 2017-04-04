$skipDeploymentDirective = "[skip deployment]"

if (($env:APPVEYOR_REPO_COMMIT_MESSAGE -match $skipDeploymentDirective) -or ($env:APPVEYOR_REPO_COMMIT_MESSAGE_EXTENDED -match $skipDeploymentDirective))
{
	$message = "Commit message contains $skipDeploymentDirective so deployment is skipped in this build."
	Add-AppveyorMessage $message
	Write-Host $message

	Set-AppveyorBuildVariable "SKIP_DEPLOYMENT" $true
}
else
{
	Set-AppveyorBuildVariable "SKIP_DEPLOYMENT" $false
}
