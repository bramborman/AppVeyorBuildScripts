param([string]$Separator = "-", [ValidateRange(0, [int]::MaxValue)][int]$SplitIndex = 0)
Write-Host "`nSet-SemanticVersionVariable script executed"
Write-Host   "==========================================="

if ([string]::IsNullOrWhiteSpace($Separator))
{
    throw "Parameter `$Separator must not be null or white space."
}

$semanticVersion = $env:APPVEYOR_BUILD_VERSION.Split($Separator)[$SplitIndex]
Set-AppveyorBuildVariable "SEMANTIC_VERSION" $semanticVersion
