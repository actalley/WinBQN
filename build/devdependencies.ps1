$ProgressPreference = 'SilentlyContinue'

properties {

    $msys2SetupName = 'msys2-x86_64-20221028.exe'
    $msys2Setup = ".\$msys2SetupName"
    $msys2SetupArguments = 'install --root C:\MSYS2 --confirm-command'
    $msys2SetupUrl = "https://github.com/msys2/msys2-installer/releases/download/2022-10-28/$msys2SetupName"
    $msys2Sha256 = '9ab223bee2610196ae8e9c9e0a2951a043cac962692e4118ad4d1e411506cd04'

    $gitSetupName = 'Git-2.36.0-64-bit.exe'
    $gitSetup = ".\$gitSetupName"
    $gitSetupArguments = '/VERYSILENT', '/GitOnlyOnPath', '/NoAutoCrlf', '/Editor:Notepad'
    $gitSetupUrl = "https://github.com/git-for-windows/git/releases/download/v2.36.0.windows.1/$gitSetupName"
    $gitSetupSha256 = '5196563ba07031257d972c0b3c2ebd3227d98a40587278e11930dbc2f78d4e69'
}

Task default -depends Usage

Task Usage {

    #TODO: warning
}

Task DevDependencies -depends InstallMsys2, InstallGit {


}

Task InstallMsys2 `
    -depends GetMsys2 `
    -description 'Installs Msys2 with CBQN and rlwrap build dependencies' `
    -requiredVariables msys2Setup `
    -precondition { -not ( Test-Path -Path 'C:\MSYS2\usr\bin\bash.exe' ) } `
{

    & $msys2Setup install --root C:\MSYS2 --confirm-command

    Assert ( Test-Path -Path 'C:\MSYS2\usr\bin\bash.exe' ) "`"C:\MSYS2\usr\bin\bash.exe`" does not exist!"

    & 'C:\MSYS2\usr\bin\bash.exe' --login -c "pacman -Sy --noconfirm git make clang automake ncurses-devel libreadline-devel libffi-devel autotools"
}

Task InstallGit `
    -depends GetGit `
    -description 'Installs Git' `
    -requiredVariables gitSetup, gitSetupArguments `
    -precondition { -not ( Test-Path -Path 'C:\Program Files\Git' ) } `
{

    Start-Process -FilePath $gitSetup -ArgumentList $gitSetupArguments -Wait
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine")
	
	& 'git.exe' config --global core.autocrlf false
}

Task GetMsys2 `
    -description 'Downloads Msys2 installer' `
    -requiredVariables msys2SetupName, msys2SetupUrl, msys2Sha256, msys2Setup `
    -precondition { -not ( Test-Path -Path $msys2Setup ) } `
{

    Invoke-WebRequest -Uri $msys2SetupUrl -OutFile $msys2Setup -UseBasicParsing

    Assert ( Test-Path -Path $msys2Setup ) "`"$msys2Setup`" does not exist!"

    $sha256Actual = Get-FileHash -Path $msys2Setup -Algorithm SHA256 | Select-Object -ExpandProperty Hash

    Assert ( $msys2Sha256 -eq $sha256Actual ) "`"$msys2Setup`"'s hash `"$sha256Actual`" does not match expected `"$msys2Sha256`"!"
}

Task GetGit `
    -description 'Downloads Git installer' `
    -requiredVariables gitSetupName, gitSetup, gitSetupUrl, gitSetupSha256 `
    -precondition { -not ( Test-Path -Path $gitSetup ) } `
{

    Invoke-WebRequest -Uri $gitSetupUrl -OutFile $gitSetup -UseBasicParsing

    Assert ( Test-Path -Path $gitSetup ) "`"$gitSetup`" does not exist!"

    $sha256Actual = Get-FileHash -Path $gitSetup -Algorithm SHA256 | Select-Object -ExpandProperty Hash

    Assert ( $gitSetupSha256 -eq $sha256Actual ) "`"$gitSetup`"'s hash `"$sha256Actual`" does not match expected `"$gitSetupSha256`"!"
}