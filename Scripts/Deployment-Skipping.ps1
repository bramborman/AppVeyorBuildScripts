Write-Host "Deployment-Skipping script executed"
Write-Host "===================================`n"

$skipDeploymentDirectives 	= "[skip deployment]", "[deployment skip]"
$isInCommitMessage 			= @($skipDeploymentDirectives | Where-Object{ $env:APPVEYOR_REPO_COMMIT_MESSAGE -match $_ }).Length -gt 0
$isInExtendedCommitMessage 	= @($skipDeploymentDirectives | Where-Object{ $env:APPVEYOR_REPO_COMMIT_MESSAGE_EXTENDED -match $_ }).Length -gt 0

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
