param([string]$Separator = "-", [ValidateRange(0, [int]::MaxValue)][int]$SplitIndex = 0)
Write-Host "`nSet-MajorMinorPatchBuildVersionVariable script executed"
Write-Host   "======================================================="

if ([string]::IsNullOrWhiteSpace($Separator))
{
    throw "Parameter `$Separator must not be null or white space."
}

$semanticVersion = "$($env:APPVEYOR_BUILD_VERSION.Split($Separator)[$SplitIndex]).$env:APPVEYOR_BUILD_NUMBER"
Set-AppveyorBuildVariable "MAJOR_MINOR_PATCH_BUILD_VERSION" $semanticVersion
