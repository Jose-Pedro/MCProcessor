# register-auto-checkpoint-task.ps1 - register auto-checkpoint as a
# Windows Scheduled Task on this host. Runs every 30 minutes, all day.
# Idempotent: re-running replaces the existing definition.
#
[CmdletBinding()]
param(
    [string]$TaskName       = 'AugmentAutoCheckpoint',
    [int]   $IntervalMinutes = 30
)

$ErrorActionPreference = 'Stop'
$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$target    = Join-Path $scriptDir 'auto-checkpoint.ps1'
if (-not (Test-Path $target)) { throw "missing $target" }

$action    = New-ScheduledTaskAction -Execute 'powershell.exe' `
              -Argument ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $target)
$trigger   = New-ScheduledTaskTrigger -Once -At (Get-Date).Date.AddMinutes(1) `
              -RepetitionInterval (New-TimeSpan -Minutes $IntervalMinutes) `
              -RepetitionDuration ([TimeSpan]::FromDays(365))
$settings  = New-ScheduledTaskSettingsSet -StartWhenAvailable `
              -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
              -ExecutionTimeLimit (New-TimeSpan -Minutes 5) `
              -MultipleInstances IgnoreNew
$principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType Interactive -RunLevel Limited

Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -EA 0 | Out-Null
Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger `
    -Settings $settings -Principal $principal `
    -Description "Auto-checkpoints active agent activity into SESSION_LOG.md every $IntervalMinutes minutes. Skips when no activity detected." | Out-Null

Write-Host "Registered: $TaskName (every $IntervalMinutes min)" -ForegroundColor Green
Get-ScheduledTask -TaskName $TaskName | Select-Object TaskName, State, @{n='NextRun';e={(Get-ScheduledTaskInfo $_).NextRunTime}} | Format-Table -AutoSize
