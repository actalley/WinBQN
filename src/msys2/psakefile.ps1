
properties {

    $msys2Root = 'C:\MSYS2'
    $msys2Bash = "$msys2Root\usr\bin\bash.exe"

    $CBQNRepository = 'https://github.com/dzaima/CBQN'
    $CBQNPath = '.\CBQN'

    $rlwrapRepository = 'https://github.com/hanslub42/rlwrap'
    $RlwrapPath = '.\rlwrap'

    $BQNRepository = 'https://github.com/mlochbaum/BQN'
    $BQNPath = '..\common\BQN'

    $packageCBQNName = 'cbqn-msys2-standalone-x86_64'
    $packageCBQNPath = "..\..\dist\$packageCBQNName"
    $packageCBQNZipPath = "..\..\dist\$packageCBQNName.zip"
    $packageCBQNFilesToCopy = @{
        "$msys2Root\usr\bin\msys-2.0.dll"                       = "$packageCBQNPath\msys-2.0.dll"
        "$msys2Root\usr\share\doc\Msys\CYGWIN_LICENSE"          = "$packageCBQNPath\CYGWIN_LICENSE"
        "$CBQNPath\BQN.exe"                                     = "$packageCBQNPath\BQN.exe"
        "$CBQNPath\LICENSE"                                     = "$packageCBQNPath\CBQN_LICENSE"
    }

    $packageCBQNMinttyName = 'cbqn-msys2-mintty-standalone-x86_64'
    $packageCBQNMinttyPath = "..\..\dist\$packageCBQNMinttyName"
    $packageCBQNMinttyZipPath = "..\..\dist\$packageCBQNMinttyName.zip"
    $packageCBQNMinttyFolders =
        "$packageCBQNMinttyPath\usr\bin",
        "$packageCBQNMinttyPath\etc",
        "$packageCBQNMinttyPath\licenses",
        "$packageCBQNMinttyPath\usr\share\terminfo\78" 
    $packageCBQNMinttyFilesToCopy = @{
        "$msys2Root\usr\bin\msys-ncursesw6.dll"                 = "$packageCBQNMinttyPath\usr\bin\msys-ncursesw6.dll"
        "$msys2Root\usr\bin\msys-readline8.dll"                 = "$packageCBQNMinttyPath\usr\bin\msys-readline8.dll"
        "$msys2Root\usr\bin\msys-2.0.dll"                       = "$packageCBQNMinttyPath\usr\bin\msys-2.0.dll"
        "$msys2Root\usr\bin\cygwin-console-helper.exe"          = "$packageCBQNMinttyPath\usr\bin\cygwin-console-helper.exe"
        "$msys2Root\usr\bin\mintty.exe"                         = "$packageCBQNMinttyPath\usr\bin\mintty.exe"
        "$msys2Root\usr\share\terminfo\78\xterm"                = "$packageCBQNMinttyPath\usr\share\terminfo\78\xterm"
        "$CBQNPath\BQN.exe"                                     = "$packageCBQNMinttyPath\usr\bin\BQN.exe"
        "$RlwrapPath\src\rlwrap.exe"                            = "$packageCBQNMinttyPath\usr\bin\rlwrap.exe"
        "$BQNPath\editors\inputrc"                              = "$packageCBQNMinttyPath\.bqn.inputrc"
        "$msys2Root\usr\share\doc\Msys\CYGWIN_LICENSE"          = "$packageCBQNMinttyPath\licenses\CYGWIN_LICENSE"
        "$msys2Root\usr\share\licenses\mintty\LICENSE"          = "$packageCBQNMinttyPath\licenses\MINTTY_LICENSE"
        "$msys2Root\usr\share\licenses\mintty\LICENSE.bundling" = "$packageCBQNMinttyPath\licenses\MINTTY_LICENSE.bundling"
        "$CBQNPath\LICENSE"                                     = "$packageCBQNMinttyPath\licenses\CBQN_LICENSE"
        "$RlwrapPath\COPYING"                                   = "$packageCBQNMinttyPath\licenses\RLWRAP_LICENSE"
        "..\common\minttyrc"                                    = "$packageCBQNMinttyPath\etc\minttyrc"
        ".\bqn.bat"                                             = "$packageCBQNMinttyPath\bqn.bat"
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
    -description "Builds standalone CBQN Msys2 package" `
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
    -description "Builds standalone CBQN Msys2 package with rlwrap and Mintty" `
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
    -requiredVariables msys2Bash, CBQNPath `
    -precondition { -not ( Test-Path -Path "$CBQNPath\BQN.exe" ) } `
{

    Push-Location -Path $CBQNPath

    $env:CHERE_INVOKING = 1
    & $msys2Bash --login -c "make PIE=''"

    Pop-Location

    Assert ( Test-Path -Path "$CBQNPath\BQN.exe" ) "`"$CBQNPath\BQN.exe`" does not exist!"
}

Task BuildRlwrap `
    -depends CloneRlwrap `
    -description 'Builds rlwrap' `
    -requiredVariables msys2Bash, RlwrapPath `
    -precondition { -not ( Test-Path -Path "$RlwrapPath\src\rlwrap.exe" ) } `
{

    Push-Location -Path $RlwrapPath

    $env:CHERE_INVOKING = 1
    & $msys2Bash --login -c 'autoupdate; autoreconf --install; ./configure; make'

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
    -description 'Clones CBQN repository using Msys2 git' `
    -requiredVariables msys2Bash, CBQNRepository `
    -precondition { -not ( Test-Path -Path $CBQNPath ) } `
{

    $env:CHERE_INVOKING = 1
    & $msys2Bash --login -c "git clone $CBQNRepository"
}

Task CloneRlwrap `
    -description 'Clones rlwrap repository using Msys2 git' `
    -requiredVariables msys2Bash, rlwrapRepository `
    -precondition { -not ( Test-Path -Path $RlwrapPath ) } `
{

    $env:CHERE_INVOKING = 1
    & $msys2Bash --login -c "git clone $rlwrapRepository"
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
    -requiredVariables msys2Bash, CBQNPath `
    -precondition { Test-Path -Path $CBQNPath } `
{
    
    Push-Location -Path $CBQNPath

    $env:CHERE_INVOKING = 1
    & $msys2Bash --login -c "make clean"

    Pop-Location
}

Task CleanRlwrap `
    -requiredVariables msys2Bash, RlwrapPath `
    -precondition { Test-Path -Path $RlwrapPath } `
{
    
    Push-Location -Path $RlwrapPath

    $env:CHERE_INVOKING = 1
    & $msys2Bash --login -c "make clean"

    Pop-Location
}