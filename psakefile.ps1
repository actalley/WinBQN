
properties {

    $sandboxNested = $SANDBOX
    $distSuccessPath = 'dist\success'
}

BuildSetup {

    if ( Test-Path -Path $distSuccessPath ) { Remove-Item -Path $distSuccessPath -Force }

    $gitEnv = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') -split ';' | Where-Object{ $_ -match 'Git' }
    if ( $sandboxNested -and $gitEnv -and -not $env:PATH.ToUpper().Contains('GIT') ) { $env:PATH += ";$gitEnv" }
}

Task default -depends Dist

Task Dist `
    -depends CheckEnvironment, Build `
    -description 'Builds a WinBQN distributon' `
{
    $rev = & git.exe submodule status |
        Select-String -Pattern '^(-|\s)([\d\w]{7})[\d\w]+\sbuild/dzaima-CBQN-dev\s.+$' |
        ForEach-Object { $_.Matches.Groups[2].Value }

    Assert ( $rev ) 'Unable to retrieve submodule revision'

    $distName = "dzaima-cbqn-dev-$rev-llvm-mingw-x86_64"

    New-Item -Path dist\$distName -ItemType Directory | Out-Null

    $libwinpthread = "${env:llvm-mingw}\x86_64-w64-mingw32\bin\libwinpthread-1.dll"

    Assert ( Test-Path -Path $libwinpthread ) "`"$libwinpthread`" does not exist!"

    $distItems = @{
        $libwinpthread                                 = "dist\$distName\libwinpthread-1.dll"
        'build\dzaima-CBQN-dev\BQN.exe'                = "dist\$distName\BQN.exe"
        'build\dzaima-CBQN-dev\licenses\LICENSE-GPLv3' = "dist\$distName\licenses\CBQN_LICENSE"
        "${env:llvm-mingw}\LICENSE.TXT"                = "dist\$distName\licenses\LLVM-MINGW_LICENSE"
    }
    
    $distItems.GetEnumerator() | ForEach-Object {

        $destFolder = $_.Value | Split-Path -Parent

        if ( -not (Test-Path -Path $destFolder)  ) {

            New-Item -Path $destFolder -ItemType Directory -Force | Out-Null
        }

        Copy-Item -Path $_.Name -Destination $_.Value -Force 
    }

    $distItems.GetEnumerator() | ForEach-Object {

        Assert ( Test-Path -Path $_.Value ) "`"$($_.Value)`" does not exist!"
    }

    Compress-Archive -Path "dist\$distName" -DestinationPath "dist\$distName.zip" -CompressionLevel Optimal

    Assert ( Test-Path -Path "dist\$distName.zip" ) "`"dist\$distName.zip`" does not exist!"

    # if Dist is successful write dist\success file
    New-Item -Path $distSuccessPath -ItemType File -Force | Out-Null
}

Task SandboxDist `
    -depends CheckSandbox `
    -description 'Builds a WinBQN distributon using Windows Sandbox' `
    -requiredVariables distSuccessPath `
{

    Invoke-psake .\build\sandbox.ps1 Sandbox

    Assert ( Test-Path -Path $distSuccessPath ) "`"$distSuccessPath`" does not exist, Dist must have failed in the sandbox!"
}

Task Build -depends GetCBQN {

    # This is not necessarily how we want to build long term, this is just to get to a failing build so issues can be worked

    Push-Location 'build\dzaima-CBQN-dev'

    exec {

        & git.exe submodule update --init build\bytecodeSubmodule
    }

    exec {

        & clang.exe -std=gnu11 -Wall -Wno-unused-function -fms-extensions -ffp-contract=off -fno-math-errno -Wno-microsoft-anon-tag -Wno-bitwise-instead-of-logical -Wno-unknown-warning-option -DBYTECODE_DIR=bytecodeSubmodule -DSINGELI=0 -DFFI=0 -fvisibility=hidden -DCBQN_EXPORT -DNO_MMAP -O3 -o BQN.exe src/opt/single.c -lm -lpthread
    }

    Pop-Location

    Assert ( Test-Path -Path 'build\dzaima-CBQN-dev\BQN.exe' ) 'BQN.exe does not exist!'
}

Task GetCBQN {

    exec {

        & git.exe submodule update --init build\dzaima-CBQN-dev
    }

    Assert ( Test-Path -Path 'build\dzaima-CBQN-dev\makefile' ) 'CBQN makefile does not exist!'
}

Task CheckEnvironment -depends CheckClang, CheckGit

Task CheckSandbox {
    
    # If it is possible without elevation this should be replaced with a check for optional feature Containers-DisposableClientVM State=Enabled
    # Get-WindowsOptionalFeature requires elevation
    Assert ( [bool](Get-Command 'WindowsSandbox.exe') ) 'WindowsSandbox must be in the Path!'
}

Task CheckClang {

    Assert ( [bool](Get-Command 'clang.exe' -ErrorAction SilentlyContinue)  ) 'Clang must be in the Path!'
    Assert ( [bool](& clang.exe --version | Select-Object -First 1 | Where-Object { $_ -match "clang version 15.0.0" }) ) 'At least clang 15.0.0 required!'
}

Task CheckGit {

    Assert ( [bool](Get-Command 'git.exe' -ErrorAction SilentlyContinue)  ) 'Git must be in the Path!'
}

Task Clean {

    Remove-Item -Path .\dist\* -ErrorAction SilentlyContinue -Recurse -Force
    Remove-Item -Path .\build\dzaima-CBQN-dev\* -Include *.exe, *.o, *.d, *dll -ErrorAction SilentlyContinue -Force
    Invoke-psake .\build\sandbox.ps1 Clean
}