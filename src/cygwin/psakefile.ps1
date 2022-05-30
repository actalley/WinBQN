
properties {

    $cygwinRoot = 'C:\Cygwin'
    $cygwinBash = "$cygwinRoot\bin\bash.exe"

    $CBQNRepository = 'https://github.com/dzaima/CBQN'
    $CBQNPath = '.\CBQN'

    $rlwrapRepository = 'https://github.com/hanslub42/rlwrap'
    $RlwrapPath = '.\rlwrap'

    $BQNRepository = 'https://github.com/mlochbaum/BQN'
    $BQNPath = '..\common\BQN'

    $packageCBQNName = 'cbqn-cygwin-standalone-x86_64'
    $packageCBQNPath = "..\..\dist\$packageCBQNName"
    $packageCBQNZipPath = "..\..\dist\$packageCBQNName.zip"
    $packageCBQNFilesToCopy = @{
        "$cygwinRoot\bin\cygwin1.dll"                       = "$packageCBQNPath\cygwin1.dll"
        "$cygwinRoot\bin\cygffi-6.dll"                      = "$packageCBQNPath\cygffi-6.dll"
        "$cygwinRoot\usr\share\doc\Cygwin\CYGWIN_LICENSE"   = "$packageCBQNPath\CYGWIN_LICENSE"
        "$CBQNPath\BQN.exe"                                 = "$packageCBQNPath\BQN.exe"
        "$CBQNPath\LICENSE"                                 = "$packageCBQNPath\CBQN_LICENSE"
    }

    $packageCBQNMinttyName = 'cbqn-cygwin-mintty-standalone-x86_64'
    $packageCBQNMinttyPath = "..\..\dist\$packageCBQNMinttyName"
    $packageCBQNMinttyZipPath = "..\..\dist\$packageCBQNMinttyName.zip"
    $packageCBQNMinttyFolders =
        "$packageCBQNMinttyPath\bin",
        "$packageCBQNMinttyPath\etc",
        "$packageCBQNMinttyPath\licenses",
        "$packageCBQNMinttyPath\usr\share\terminfo\78" 
    $packageCBQNMinttyFilesToCopy = @{
        "$cygwinRoot\bin\cygncursesw-10.dll"                = "$packageCBQNMinttyPath\bin\cygncursesw-10.dll"
        "$cygwinRoot\bin\cygreadline7.dll"                  = "$packageCBQNMinttyPath\bin\cygreadline7.dll"
        "$cygwinRoot\bin\cygwin1.dll"                       = "$packageCBQNMinttyPath\bin\cygwin1.dll"
        "$cygwinRoot\bin\cygffi-6.dll"                      = "$packageCBQNMinttyPath\bin\cygffi-6.dll"
        "$cygwinRoot\bin\cygwin-console-helper.exe"         = "$packageCBQNMinttyPath\bin\cygwin-console-helper.exe"
        "$cygwinRoot\bin\mintty.exe"                        = "$packageCBQNMinttyPath\bin\mintty.exe"
        "$cygwinRoot\usr\share\terminfo\78\xterm"           = "$packageCBQNMinttyPath\usr\share\terminfo\78\xterm"
        "$cygwinRoot\usr\share\terminfo\78\xterm-256color"  = "$packageCBQNMinttyPath\usr\share\terminfo\78\xterm-256color"
        "$CBQNPath\BQN.exe"                                 = "$packageCBQNMinttyPath\bin\BQN.exe"
        "$RlwrapPath\src\rlwrap.exe"                        = "$packageCBQNMinttyPath\bin\rlwrap.exe"
        "$BQNPath\editors\inputrc"                          = "$packageCBQNMinttyPath\.bqn.inputrc"
        "$cygwinRoot\usr\share\doc\Cygwin\CYGWIN_LICENSE"   = "$packageCBQNMinttyPath\licenses\CYGWIN_LICENSE"
        "$cygwinRoot\usr\share\doc\mintty\LICENSE"          = "$packageCBQNMinttyPath\licenses\MINTTY_LICENSE"
        "$cygwinRoot\usr\share\doc\mintty\LICENSE.bundling" = "$packageCBQNMinttyPath\licenses\MINTTY_LICENSE.bundling"
        "$CBQNPath\LICENSE"                                 = "$packageCBQNMinttyPath\licenses\CBQN_LICENSE"
        "$RlwrapPath\COPYING"                               = "$packageCBQNMinttyPath\licenses\RLWRAP_LICENSE"
        "..\common\minttyrc"                                = "$packageCBQNMinttyPath\etc\minttyrc"
        ".\bqn.bat"                                         = "$packageCBQNMinttyPath\bqn.bat"
    }

    $filesToClean =
        $packageCBQNPath,
        $packageCBQNZipPath,
        $packageCBQNMinttyPath,
        $packageCBQNMinttyZipPath,
        "$CBQNPath\BQN.exe"
}

Task default -depends All

Task All {

}

Task PackageCBQNStandalone `
    -depends BuildCBQN `
    -description "Builds standalone CBQN Cygwin package" `
    -requiredVariables packageCBQNPath, packageCBQNZipPath, packageCBQNFilesToCopy `
    -precondition { -not ( Test-Path -Path $packageCBQNPath ) -and -not ( Test-Path -Path $packageCBQNZipPath ) } `
{

    New-Item -Path $packageCBQNPath -ItemType Directory -Force | Out-Null

    $packageCBQNFilesToCopy.GetEnumerator() | ForEach-Object {

        Copy-Item -Path $_.Name -Destination $_.Value
    }

    $packageCBQNFilesToCopy.GetEnumerator() | ForEach-Object {

        Assert ( Test-Path -Path $_.Value ) "`"$($_.Value)`" does not exist!"
    }

    Compress-Archive -Path $packageCBQNPath -DestinationPath $packageCBQNZipPath -CompressionLevel Optimal

    Assert ( Test-Path -Path $packageCBQNZipPath ) "`"$packageCBQNZipPath`" does not exist!"
}

Task PackageCBQNMinttyStandalone `
    -depends CloneBQN, BuildCBQN, BuildRlwrap `
    -description "Builds standalone CBQN Cygwin package with rlwrap and Mintty" `
    -requiredVariables packageCBQNMinttyPath, packageCBQNMinttyZipPath, packageCBQNMinttyFilesToCopy `
    -precondition { -not ( Test-Path -Path $packageCBQNMinttyPath ) -and -not ( Test-Path -Path $packageCBQNMinttyZipPath ) } `
{

    New-Item -Path $packageCBQNMinttyPath -ItemType Directory -Force | Out-Null

    $packageCBQNMinttyFolders | ForEach-Object {

        New-Item -Path $_ -ItemType Directory -Force | Out-Null
    }

    $packageCBQNMinttyFilesToCopy.GetEnumerator() | ForEach-Object {

        Copy-Item -Path $_.Name -Destination $_.Value
    }

    $packageCBQNMinttyFilesToCopy.GetEnumerator() | ForEach-Object {

        Assert ( Test-Path -Path $_.Value ) "`"$($_.Value)`" does not exist!"
    }

    Compress-Archive -Path $packageCBQNMinttyPath -DestinationPath $packageCBQNMinttyZipPath -CompressionLevel Optimal

    Assert ( Test-Path -Path $packageCBQNMinttyZipPath ) "`"$packageCBQNMinttyZipPath`" does not exist!"
}

Task BuildCBQN `
    -depends CloneCBQN `
    -description 'Builds CBQN' `
    -requiredVariables cygwinBash, CBQNPath `
    -precondition { -not ( Test-Path -Path "$CBQNPath\BQN.exe" ) } `
{

    Push-Location -Path $CBQNPath

    $env:CHERE_INVOKING = 1
    & $cygwinBash --login -c 'make OUTPUT="BQN.exe"'

    Pop-Location

    Assert ( Test-Path -Path "$CBQNPath\BQN.exe" ) "`"$CBQNPath\BQN.exe`" does not exist!"
}

Task BuildRlwrap `
    -depends CloneRlwrap `
    -description 'Builds rlwrap' `
    -requiredVariables cygwinBash, RlwrapPath `
    -precondition { -not ( Test-Path -Path "$RlwrapPath\src\rlwrap.exe" ) } `
{

    Push-Location -Path $RlwrapPath

    $env:CHERE_INVOKING = 1
    & $cygwinBash --login -c 'autoupdate; autoreconf --install; ./configure; make'

    Pop-Location

    Assert ( Test-Path -Path "$RlwrapPath\src\rlwrap.exe" ) "`"$RlwrapPath\src\rlwrap.exe`" does not exist!"
}

Task CloneBQN `
    -description 'Clones BQN repository' `
    -requiredVariables bqnRepository, BQNPath `
    -precondition { -not ( Test-Path -Path $BQNPath ) } `
{

    if ( -not $env:Path.Contains('C:\Program Files\Git\cmd') ) {

        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine")
    }

    Push-Location -Path ($BQNPath | Split-Path -Parent)

    & "git.exe" clone $bqnRepository

    Pop-Location
}

Task CloneCBQN `
    -description 'Clones CBQN repository using Cygwin git' `
    -requiredVariables cygwinBash, CBQNRepository `
    -precondition { -not ( Test-Path -Path $CBQNPath ) } `
{

    $env:CHERE_INVOKING = 1
    & $cygwinBash --login -c "git clone $CBQNRepository"
}

Task CloneRlwrap `
    -description 'Clones rlwrap repository using Cygwin git' `
    -requiredVariables cygwinBash, rlwrapRepository `
    -precondition { -not ( Test-Path -Path $RlwrapPath ) } `
{

    $env:CHERE_INVOKING = 1
    & $cygwinBash --login -c "git clone $rlwrapRepository"
}

Task Clean `
    -depends CleanCBQN, CleanRlwrap `
    -requiredVariables filesToClean, RlwrapPath `
{

    $filesToClean |
        Where-Object { Test-Path -Path $_ } |
        ForEach-Object { Remove-Item -Path $_ -Force -Recurse }
}

Task CleanCBQN `
    -requiredVariables cygwinBash, CBQNPath `
    -precondition { Test-Path -Path $CBQNPath } `
{
    
    Push-Location -Path $CBQNPath

    $env:CHERE_INVOKING = 1
    & $cygwinBash --login -c "make clean"

    Pop-Location
}

Task CleanRlwrap `
    -requiredVariables cygwinBash, RlwrapPath `
    -precondition { Test-Path -Path $RlwrapPath } `
{
    
    Push-Location -Path $RlwrapPath

    $env:CHERE_INVOKING = 1
    & $cygwinBash --login -c "make clean"

    Pop-Location
}