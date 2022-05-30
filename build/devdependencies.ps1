$ProgressPreference = 'SilentlyContinue'

properties {

    $cygwinSetupName = 'setup-x86_64.exe'
    $cygwinSha512Url = 'https://cygwin.com/sha512.sum'
    $cygwinUrl = "https://cygwin.org/$cygwinSetupName"
    $cygwinSetup = ".\$cygwinSetupName"
    $cygwinMirror = 'https://mirrors.kernel.org/sourceware/cygwin'
    $cygwinRoot = 'C:\Cygwin'
    $cygwinBash = "$cygwinRoot\bin\bash.exe"
    $cygwinDownloads = "$($env:USERPROFILE)\cygwin-package-downloads"
    $cygwinPackages = 'automake,clang,libncurses-devel,libreadline-devel,libffi-devel,make,git'
    $cygwinSetupArguments =
        '--no-admin',
        '--site',
        $cygwinMirror,
        '--root',
        $cygwinRoot,
        '--local-package-dir',
        $cygwinDownloads,
        '--no-shortcuts',
        '--delete-orphans',
        '--upgrade-also',
        '--no-replaceonreboot',
        '--quiet-mode',
        '--force-current',
        '--packages',
        $cygwinPackages

    $msys2SetupName = 'msys2-x86_64-20220503.exe'
    $msys2Setup = ".\$msys2SetupName"
    $msys2SetupArguments = 'install --root C:\MSYS2 --confirm-command'
    $msys2SetupUrl = "https://github.com/msys2/msys2-installer/releases/download/2022-05-03/$msys2SetupName"
    $msys2Sha256 = '7076511052806bd48199790265fdad719f0877bbd75ad2d5305835d3f54d138b'

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

Task DevDependencies -depends InstallCygwin, InstallMsys2, InstallGit {


}

Task InstallCygwin `
    -depends GetCygwin `
    -description 'Installs Cygwin with CBQN and rlwrap build dependencies' `
    -requiredVariables cygwinSetup, cygwinSetupArguments, cygwinBash `
    -precondition { -not ( Test-Path -Path $cygwinBash ) } `
{

    Start-Process -FilePath $cygwinSetup -ArgumentList $cygwinSetupArguments -Wait
    # The Cygwin setup always has an exit code of 0, and /var/log/setup.log.full does not explicitly state if an install was successful.
    # For now I'm making no attempt to detect failure. This will need to be sorted out for CI/CD later.

    Assert ( Test-Path -Path $cygwinBash ) "`"$cygwinBash`" does not exist!"

    & $cygwinBash --login -c "echo cygwin first run"
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

Task GetCygwin `
    -description 'Downloads Cygwin installer' `
    -requiredVariables cygwinSha512Url, cygwinSetupName, cygwinUrl, cygwinSetup `
    -precondition { -not ( Test-Path -Path $cygwinSetup ) } `
{
    $shaContentBytes = Invoke-WebRequest -Uri $cygwinSha512Url -UseBasicParsing | Select-Object -ExpandProperty Content
    $shaContent = [System.Text.Encoding]::UTF8.GetString($shaContentBytes)
    
    $shaList = $shaContent.Split("`n") | ForEach-Object {

        if ( $_ -match "(?<sha512>[^ ]+)( )+(?<Filename>setup-x86(_64)?\.exe)" ) {

            [PSCustomObject]@{
                Filename = $Matches.Filename
                sha512 = $Matches.sha512
            }
        }
    }

    $sha512Expected = $shaList | Where-Object { $_.Filename -eq $cygwinSetupName } | Select-Object -ExpandProperty sha512

    Invoke-WebRequest -Uri $cygwinUrl -OutFile $cygwinSetup -UseBasicParsing

    Assert ( Test-Path -Path $cygwinSetup ) "`"$cygwinSetup`" does not exist!"

    $sha512Actual = Get-FileHash -Path $cygwinSetup -Algorithm SHA512 | Select-Object -ExpandProperty Hash

    Assert ( $sha512Expected -eq $sha512Actual ) "`"$cygwinSetup`"'s hash `"$sha512Actual`" does not match expected `"$sha512Expected`"!"
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