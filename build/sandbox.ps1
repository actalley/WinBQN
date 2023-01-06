$ProgressPreference = 'SilentlyContinue'

properties {

    $projectFolderName = $PSScriptRoot | Split-Path -Parent | Split-Path -Leaf
    $logonScriptName = 'logonscript.ps1'
    $wsbName = 'config.wsb'

    $sandboxDocumentsPath = 'C:\Users\WDAGUtilityAccount\Documents'
    $sandboxProjectPath = "$sandboxDocumentsPath\$projectFolderName"
    $sandboxHostFolderPath = "C:\Users\WDAGUtilityAccount\Desktop\$projectFolderName"
    $sandboxLogonScriptPath = "$sandboxHostFolderPath\build\$logonScriptName"
    
    $sandboxLogonCommand = "cmd.exe /c start powershell.exe -Command `"& 'powershell.exe' -NoExit -ExecutionPolicy RemoteSigned -File '$sandboxLogonScriptPath'`""

    $setEnv = "$($env:USERPROFILE)\.winbqn\SetEnv.bat"

    $filesToClean =
        ".\$logonScriptName",
        ".\$wsbName"

$sandboxLogonScript = @"
`$ErrorActionPreference = 'Stop'
`$VerbosePreference = '$VerbosePreference'
`$PSDefaultParameterValues['*:Verbose'] = '$VerbosePreference' -eq 'Continue'

`$ProgressPreference = 'SilentlyContinue'

Write-Host "Installing psake" -ForegroundColor Cyan

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force | Out-Null
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module -Name psake

Copy-Item -Path $sandboxHostFolderPath -Destination $sandboxProjectPath -Recurse -Force

Set-Location -Path '$sandboxProjectPath'

Write-Host "Starting psake" -ForegroundColor Cyan

Invoke-psake .\build\sandbox.ps1 SandboxBuild
"@

}

Task default -depends Usage

Task Usage {
   
}

Task Sandbox `
    -description 'Starts a Windows Sandbox with development dependencies and builds all packages' `
{

    [Reflection.Assembly]::LoadWithPartialName("System.Xml.Linq") | Out-Null

    $wsb = [System.Xml.Linq.XDocument]::new(
        [System.Xml.Linq.XElement]::new(
            'Configuration',
            [System.Xml.Linq.XElement]::new(
                'MappedFolders',
                [System.Xml.Linq.XElement]::new(
                    'MappedFolder',
                    [System.Xml.Linq.XElement]::new('HostFolder', ($PSScriptRoot | Split-Path -Parent)),
                    [System.Xml.Linq.XElement]::new('ReadOnly', 'false')
                )
            ),
            [System.Xml.Linq.XElement]::new('ClipboardRedirection', 'true'),
            [System.Xml.Linq.XElement]::new('MemoryInMB', '8192'),
            [System.Xml.Linq.XElement]::new(
                'LogonCommand',
                [System.Xml.Linq.XElement]::new('Command', $sandboxLogonCommand)
            )
        )
    )

    $wsb.Save("$PSScriptRoot\$wsbName")
    $sandboxLogonScript | Out-File -FilePath ".\$logonScriptName" -Force

    Start-Process -FilePath 'C:\Windows\System32\WindowsSandbox.exe' -ArgumentList ".\$wsbName" -Wait
}

Task SandboxBuild -depends Build {

}

Task Clean -requiredVariables filesToClean {

    $filesToClean |
        Where-Object { Test-Path -Path $_ } |
        ForEach-Object { Remove-Item -Path $_ -Force -Recurse }
}

Task Build -depends DevDependencies {

    Push-Location -Path ..

    exec {

        & cmd.exe /c $setEnv -NoExit -Command "Invoke-psake Dist -parameters @{ 'SANDBOX' = `$true }; Exit !`$psake.build_success"
    }

    Copy-Item -Path dist\ -Destination "C:\Users\WDAGUtilityAccount\Desktop\$projectFolderName\" -Force -Recurse

    Pop-Location
}

Task DevDependencies {

    Invoke-psake .\devdependencies.ps1 DevDependencies
}