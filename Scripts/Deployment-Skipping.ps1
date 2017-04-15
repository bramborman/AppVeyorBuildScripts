Write-Host "`nDeployment-Skipping script executed"
Write-Host   "==================================="

$skipDeploymentDirectives 	= "[skip deployment]", "[deployment skip]"
$isInCommitMessage 			= @($skipDeploymentDirectives | Where-Object{ $env:APPVEYOR_REPO_COMMIT_MESSAGE.Contains($_) }).Length -gt 0
$isInExtendedCommitMessage 	= @($skipDeploymentDirectives | Where-Object{ $env:APPVEYOR_REPO_COMMIT_MESSAGE_EXTENDED.Contains($_) }).Length -gt 0

if ($isInCommitMessage -or $isInExtendedCommitMessage)
{
	$message = "Deployment should be skipped in this build"
	Add-AppveyorMessage $message
	Write-Host $message

	Set-AppveyorBuildVariable "SKIP_DEPLOYMENT" $true
}
else
{
	Set-AppveyorBuildVariable "SKIP_DEPLOYMENT" $false
}
