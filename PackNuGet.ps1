foreach ($nuspec in $(Get-Item *.nuspec))
{
    nuget pack "$nuspec" -Version $env:APPVEYOR_BUILD_VERSION

    # Throw the exception if NuGet creation fails to make the AppVeyor build fail too
    if($LastExitCode -ne 0)
    {
        $host.SetShouldExit($LastExitCode)
    }
}

Push-AppveyorArtifact *.nupkg
