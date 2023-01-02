
Task default -depends Dist

Task Dist {

    throw "Not implemented!"
}

Task SandboxDist {

    Invoke-psake .\build\sandbox.ps1 Sandbox
}

Task Clean {

    Remove-Item -Path .\build\* -Include *.exe -ErrorAction SilentlyContinue -Force
    Invoke-psake .\build\sandbox.ps1 Clean
}