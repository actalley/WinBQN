$ProgressPreference = 'SilentlyContinue'

properties {

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

Task DevDependencies -depends InstallGit {


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