
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

    throw "Not implemented!"

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

    Push-Location 'build\CBQN'

    exec {

        & git.exe submodule update --init build\bytecodeSubmodule
    }

    exec {

        & clang.exe -std=gnu11 -Wall -Wno-unused-function -fms-extensions -ffp-contract=off -fno-math-errno -Wno-microsoft-anon-tag -Wno-bitwise-instead-of-logical -Wno-unknown-warning-option -DBYTECODE_DIR=bytecodeSubmodule -DSINGELI=0 -DFFI=0 -fvisibility=hidden -DCBQN_EXPORT -DNO_MMAP -O3 -o bqn.exe src/opt/single.c -no-pie -lm -lpthread -rdynamic -v
    }

    Pop-Location

    Assert ( Test-Path -Path 'build\CBQN\BQN.exe' ) "BQN.exe does not exist!"
}

Task GetCBQN {

    exec {

        & git.exe submodule update --init build\CBQN
    }

    Assert ( Test-Path -Path 'build\CBQN\makefile' ) "CBQN makefile does not exist!"
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

    Assert ( [bool](Get-Command 'git.exe' -ErrorAction SilentlyContinue)  ) "Git must be in the Path!"
}

Task Clean {

    Remove-Item -Path .\build\* -Include *.exe -ErrorAction SilentlyContinue -Force
    Invoke-psake .\build\sandbox.ps1 Clean
}