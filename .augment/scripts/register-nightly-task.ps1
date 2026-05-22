# register-nightly-task.ps1 - install the Windows Scheduled Task that
# runs cold-path-distill.ps1 every night at 02:00 local.
#
# Idempotent: if "AugmentColdPathDistill" already exists it is replaced.
# Runs under the current user (no admin needed for user-scope tasks).
#
# Usage:
#   .\register-nightly-task.ps1
#   .\register-nightly-task.ps1 -Time 03:30
#   .\register-nightly-task.ps1 -Unregister
#
[CmdletBinding()]
param(
    [string]$TaskName = 'AugmentColdPathDistill',
    [string]$Time = '02:00',
    [switch]$Unregister
)

$ErrorActionPreference = 'Stop'

$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$target = Resolve-Path (Join-Path $scriptDir 'cold-path-distill.ps1')

if (Get-ScheduledTask -TaskName $TaskName -EA SilentlyContinue) {
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
    Write-Host "removed existing task '$TaskName'" -ForegroundColor Yellow
}
if ($Unregister) { exit 0 }

$action = New-ScheduledTaskAction `
    -Execute 'powershell.exe' `
    -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$target`""

$trigger = New-ScheduledTaskTrigger -Daily -At $Time

$settings = New-ScheduledTaskSettingsSet `
    -WakeToRun `
    -StartWhenAvailable `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -ExecutionTimeLimit (New-TimeSpan -Hours 4) `
    -MultipleInstances IgnoreNew

$principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType Interactive -RunLevel Limited

Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Description "Augment cold-path memory distillation (raw -> distilled -> embedded -> git)" | Out-Null

Write-Host "registered '$TaskName' -> daily $Time -> $target" -ForegroundColor Green
Get-ScheduledTask -TaskName $TaskName | Get-ScheduledTaskInfo | Select-Object NextRunTime, LastRunTime, LastTaskResult | Format-List
