
Task default -depends Packages

Task Dist {

    Invoke-psake .\src\psakefile.ps1 Dist
}

Task SandboxDist {

    Invoke-psake .\build\sandbox.ps1 Sandbox
}

Task Clean {

    Remove-Item -Path .\build\* -Include *.exe -ErrorAction SilentlyContinue -Force
    Invoke-psake .\build\sandbox.ps1 Clean
    Invoke-psake .\src\psakefile.ps1 Clean
}