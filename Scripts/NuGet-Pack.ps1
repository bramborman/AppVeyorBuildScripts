param([string]$Filter = "*", [switch]$UWPMultiArchitecture = $false, [string]$DllName, [string]$ProjectFolderNameFilter)

if ([string]::IsNullOrWhiteSpace($Filter))
{
    throw "Parameter `$Filter must not be null or white space."
}

if ($UWPMultiArchitecture)
{
    if ([string]::IsNullOrWhiteSpace($DllName))
    {
        throw "Parameter `$DllName must not be null or white space when `$UWPMultiArchitecture is true."
    }
    
    if ([string]::IsNullOrWhiteSpace($ProjectFolderNameFilter))
    {
        throw "Parameter `$ProjectFolderNameFilter must not be null or white space when `$UWPMultiArchitecture is true."
    }

    # Find the newest version of the NETFX Tools
    $netfxParentFolder 	= Join-Path ${Env:ProgramFiles(x86)} "Microsoft SDKs\Windows\v10.0A\bin\"
    $netfxFolders 		= Get-ChildItem $netfxParentFolder -Directory -Filter "NETFX * Tools"
    # Sort folders using regex to sort numbers logically - 1.0.0, 2.0.0, 10.0.0 - instead of 1.0.0, 10.0.0, 2.0.0
    # Select the newest NETFX Tools folder
    $netfxFolder		= $netfxFolders | Sort-Object { [regex]::Replace($_.Name, '\d+', { $args[0].Value.PadLeft(20) }) } | Select-Object -Last 1
    $corFlags			= Join-Path (Join-Path $netfxParentFolder $netfxFolder) "x64\CorFlags.exe"

    if (!(Test-Path $corFlags))
    {
        # Try to find x86 version (not sure if it really exists)
        $corFlags = Join-Path (Join-Path $netfxParentFolder $netfxFolder) "CorFlags.exe"
    }

    if (!(Test-Path $corFlags))
    {
        throw "Unable to find CorFlags.exe. `$corFlags: '$corFlags'"
    }

    Write-Host "`nSelected CorFlags file:" $corFlags
    
    $projectFolders     = Get-ChildItem -Directory -Filter $ProjectFolderNameFilter
    $binFolders 		= $projectFolders | ForEach-Object{ Get-ChildItem $_.FullName -Directory -Filter "bin" }
    $referenceCreated   = $false

    # Create reference assemblies, because NuGet packages cannot be used otherwise.
    # This creates them for all outputs that match the filter, in all output directories of all projects.
    # It's a bit overkill but who cares - the process is very fast and keeps the script simple.
    foreach ($binFolder in $binFolders)
    {
        $x86Folder 			= Join-Path $binFolder.FullName "x86"
        $referenceFolder 	= Join-Path $binFolder.FullName "Reference"
            
        if (!(Test-Path $x86Folder))
        {
            Write-Host "Skipping reference assembly generation for $($binFolder.FullName) because it has no x86 directory."
            continue;
        }
        
        if (Test-Path $referenceFolder)
        {
            Remove-Item -Recurse $referenceFolder
        }
        
        New-Item $referenceFolder -ItemType Directory
        New-Item "$referenceFolder\Release" -ItemType Directory
        
        $dlls = Get-ChildItem "$x86Folder\Release" -File -Filter $DllName
        
        foreach ($dll in $dlls)
        {
            Copy-Item $dll.FullName "$referenceFolder\Release"
        }
        
        $dlls = Get-ChildItem "$referenceFolder\Release" -File -Filter $DllName
        
        foreach ($dll in $dlls)
        {
            Write-Host "`n`nConverting to AnyCPU: $dll"
            & $corFlags /32bitreq- $($dll.FullName)
        }

        $referenceCreated = $true
    }

    if ($referenceCreated -eq $false)
    {
        throw "Reference assemblies were not created.`n`$binFolders: '$binFolders'"
    }
}

$nuspecs = Get-Item "$Filter.nuspec"

if ($nuspecs -eq $null)
{
    throw "Unable to find any .nuspec file."
}

foreach ($nuspec in $nuspecs)
{
    nuget pack "$nuspec" -Version $env:APPVEYOR_BUILD_VERSION

    # Throw the exception if NuGet creation fails to make the AppVeyor build fail too
    if($LastExitCode -ne 0)
    {
        $host.SetShouldExit($LastExitCode)
    }
}

Push-AppveyorArtifact *.nupkg
