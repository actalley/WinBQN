Task default -depends Packages

Task Dist -depends CygwinDist, Msys2Dist {

}

Task CygwinDist {

    Invoke-psake .\cygwin\psakefile.ps1 PackageCBQNMinttyStandalone
    Invoke-psake .\cygwin\psakefile.ps1 PackageCBQNStandalone
}

Task Msys2Dist {

    Invoke-psake .\msys2\psakefile.ps1 PackageCBQNMinttyStandalone
    Invoke-psake .\msys2\psakefile.ps1 PackageCBQNStandalone    
}

Task Clean {

    Invoke-psake .\cygwin\psakefile.ps1 Clean
    Invoke-psake .\msys2\psakefile.ps1 Clean
}