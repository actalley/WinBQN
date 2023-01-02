
properties {

    $sandboxNested = $SANDBOX
}

Task default -depends Dist

Task Dist `
    -depends UpdateEnvironment, CheckClang, CheckGit `
    -description 'Builds a WinBQN distributon' `
{

    throw "Not implemented!"
}

Task SandboxDist `
    -depends CheckSandbox `
    -description 'Builds a WinBQN distributon using Windows Sandbox' `
{

    Invoke-psake .\build\sandbox.ps1 Sandbox
}

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

Task UpdateEnvironment -requiredVariables sandboxNested {

    $gitEnv = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') -split ';' | Where-Object{ $_ -match 'Git' }

    if ( $sandboxNested -and $gitEnv -and -not $env:PATH.ToUpper().Contains('GIT') ) { $env:PATH += ";$gitEnv" }
}

Task Clean {

    Remove-Item -Path .\build\* -Include *.exe -ErrorAction SilentlyContinue -Force
    Invoke-psake .\build\sandbox.ps1 Clean
}