Task default -depends Packages

Task Dist -depends Msys2Dist {

}

Task Msys2Dist {

    Invoke-psake .\msys2\psakefile.ps1 PackageCBQNMinttyStandalone
    Invoke-psake .\msys2\psakefile.ps1 PackageCBQNStandalone    
}

Task Clean {

    Invoke-psake .\msys2\psakefile.ps1 Clean
}