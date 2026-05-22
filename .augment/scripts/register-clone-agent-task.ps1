# register-clone-agent-task.ps1 - install the Windows Scheduled Task that
# runs clone-agent-worker.ps1 every 10 minutes on CHost.
#
# Idempotent: if "AugmentCloneAgentWorker" already exists it is replaced.
# Runs under the current user (no admin needed for user-scope tasks).
#
# Usage:
#   .\register-clone-agent-task.ps1
#   .\register-clone-agent-task.ps1 -Minutes 5
#   .\register-clone-agent-task.ps1 -Unregister
#
[CmdletBinding()]
param(
    [string]$TaskName = 'AugmentCloneAgentWorker',
    [int]$Minutes = 10,
    [switch]$Unregister
)

$ErrorActionPreference = 'Stop'

$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$target = Resolve-Path (Join-Path $scriptDir 'clone-agent-worker.ps1')

if (Get-ScheduledTask -TaskName $TaskName -EA SilentlyContinue) {
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
    Write-Host "removed existing task '$TaskName'" -ForegroundColor Yellow
}
if ($Unregister) { exit 0 }

$action = New-ScheduledTaskAction `
    -Execute 'powershell.exe' `
    -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$target`""

$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1) `
    -RepetitionInterval (New-TimeSpan -Minutes $Minutes) `
    -RepetitionDuration (New-TimeSpan -Days 3650)

$settings = New-ScheduledTaskSettingsSet `
    -StartWhenAvailable `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -ExecutionTimeLimit (New-TimeSpan -Minutes 30) `
    -MultipleInstances IgnoreNew

$principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType Interactive -RunLevel Limited

Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Description "Augment clone-agent worker (drains airouter task queue every $Minutes min)" | Out-Null

Write-Host "registered '$TaskName' -> every $Minutes min -> $target" -ForegroundColor Green
Get-ScheduledTask -TaskName $TaskName | Get-ScheduledTaskInfo | Select-Object NextRunTime, LastRunTime, LastTaskResult | Format-List
