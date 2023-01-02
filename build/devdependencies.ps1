$ProgressPreference = 'SilentlyContinue'

properties {

    $llvmMingwName = 'llvm-mingw-20220906-msvcrt-x86_64'
    $llvmMingwZip = "$llvmMingwName.zip"
    $winBqnPath = "$($env:USERPROFILE)\.winbqn"
    $llvmMingwInstallPath = "$winBqnPath\tools\llvm-mingw\$llvmMingwName"
    $llvmMingwUrl = 'https://github.com/mstorsjo/llvm-mingw/releases/download/20220906/llvm-mingw-20220906-msvcrt-x86_64.zip'
    $llvmMingwSha256 = '1B63120C346FF78A4E3DBA77101A535434A62122D3B44021438A77BDF1B4679A'
    $llvmMingwSetEnv = "SetEnv.bat"

    $gitSetupName = 'Git-2.36.0-64-bit.exe'
    $gitSetup = ".\$gitSetupName"
    $gitSetupArguments = '/VERYSILENT', '/GitOnlyOnPath', '/NoAutoCrlf', '/Editor:Notepad'
    $gitSetupUrl = 'https://github.com/git-for-windows/git/releases/download/v2.36.0.windows.1/Git-2.36.0-64-bit.exe'
    $gitSetupSha256 = '5196563ba07031257d972c0b3c2ebd3227d98a40587278e11930dbc2f78d4e69'

    $setEnvContent = @"
@echo off
set llvm-mingw=$llvmMingwName
set PATH=%~dp0tools\llvm-mingw\%llvm-mingw%\bin;%PATH%;
set LIBRARY_PATH=%~dp0tools\llvm-mingw\%llvm-mingw%\lib\clang\15.0.0\lib\windows
set CPATH=%~dp0tools\llvm-mingw\%llvm-mingw%\include;%~dp0tools\llvm-mingw\%llvm-mingw%lib\clang\15.0.0\include
%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -NoProfile %*
exit /b %errorlevel%
"@

}

Task default -depends Usage

Task Usage {

    #TODO: warning
}

Task DevDependencies -depends InstallGit, InstallLlvmMingw {


}

Task InstallLlvmMingw `
    -depends GetLlvmMingw `
    -description 'Installs llvm-mingw' `
    -requiredVariables llvmMingwZip, llvmMingwInstallPath, winbqnPath, llvmMingwSetEnv, setEnvContent `
    -precondition { -not ( Test-Path -Path $llvmMingwInstallPath ) } `
{

    if ( -not ( Test-Path -Path $llvmMingwInstallPath ) ) {

        [System.IO.Compression.ZipFile]::ExtractToDirectory("$PSScriptRoot\$llvmMingwZip", ($llvmMingwInstallPath | Split-Path -Parent))
    }

    Assert ( Test-Path -Path $llvmMingwInstallPath  ) "`"$llvmMingwInstallPath`" does not exist!"
    Assert ( Test-Path -Path "$llvmMingwInstallPath\bin\clang.exe"  ) "`"$llvmMingwInstallPath\bin\clang.exe`" does not exist!"

    if ( -not ( Test-Path "$winBqnPath\$llvmMingwSetEnv" ) ) {

        [System.IO.File]::WriteAllLines("$winBqnPath\$llvmMingwSetEnv", $setEnvContent, [System.Text.UTF8Encoding]::new($false))
    }

    Assert ( Test-Path -Path "$winBqnPath\$llvmMingwSetEnv" ) "`"$winBqnPath\$llvmMingwSetEnv`" does not exist!"
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

Task GetLlvmMingw `
    -description 'Downloads llvm-mingw' `
    -requiredVariables llvmMingwZip, llvmMingwUrl, llvmMingwSha256 `
    -precondition { -not ( Test-Path -Path $llvmMingwZip ) } `
{

    Invoke-WebRequest -Uri $llvmMingwUrl -OutFile $llvmMingwZip -UseBasicParsing

    Assert ( Test-Path -Path $llvmMingwZip ) "`"$llvmMingwZip`" does not exist!"

    $sha256Actual = Get-FileHash -Path $llvmMingwZip -Algorithm SHA256 | Select-Object -ExpandProperty Hash

    Assert ( $llvmMingwSha256 -eq $sha256Actual ) "`"$llvmMingwZip`"'s hash `"$sha256Actual`" does not match expected `"$llvmMingwSha256`"!"
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