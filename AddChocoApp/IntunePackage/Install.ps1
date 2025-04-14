[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $Packagename,

    [Parameter()]
    [switch]
    $InstallChoco,

    [Parameter()]
    [string]
    $CustomRepo,

    [Parameter()]
    [switch]
    $Trace
)

try {
    if ($Trace) { Start-Transcript -Path (Join-Path $env:windir "\temp\choco-$Packagename-trace.log") }
    $chocoPath = "$($ENV:SystemDrive)\ProgramData\chocolatey\bin\choco.exe"

    if ($InstallChoco) {
        if (-not (Test-Path $chocoPath)) {
            try {
                Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
                $chocoPath = "$($ENV:SystemDrive)\ProgramData\chocolatey\bin\choco.exe"
            }
            catch {
                Write-Host "InstallChoco Error: $($_.Exception.Message)"
            }
        }
    }

    try {
    $localprograms = & "$chocoPath" list --localonly
    $arguments = @()

    if ($localprograms -like "*$Packagename*") {
        Write-Host "Upgrading $Packagename"
        $arguments = @("upgrade", $Packagename, "-y")
    }
    else {
        Write-Host "Installing $Packagename"
        $arguments = @("install", $Packagename, "-y")
    }

    # Add custom repo source if provided
    if ($CustomRepo) { 
        $arguments += "--source"; 
        $arguments += $CustomRepo 
    }

    # Debugging output to see the full command before execution
    Write-Host "Executing: $chocoPath $($arguments -join ' ')"

    # Run Chocolatey with correct argument handling
    & "$chocoPath" @arguments

    Write-Host "Completed."
    }  
    catch {
        Write-Host "Install/upgrade error: $($_.Exception.Message)"
    }

}
catch {
    Write-Host "Install/upgrade error: $($_.Exception.Message)"
}
finally {
    if ($Trace) { Stop-Transcript }
}

exit $?
