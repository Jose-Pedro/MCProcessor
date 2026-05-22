# register-remote-master-review.ps1 - register the weekly airouter
# model review as a Windows Scheduled Task on this host.
#
# Runs every Sunday at 04:00 (after the nightly cold-path at 02:00).
# Wakes the computer to ensure the review happens even on idle.
#
# Idempotent: re-running replaces the existing definition.
#
[CmdletBinding()]
param(
    [string]$TaskName = 'AugmentRemoteMasterReview',
    [string]$Time     = '04:00'
)

$ErrorActionPreference = 'Stop'
$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$target    = Join-Path $scriptDir 'remote-master-review.ps1'
if (-not (Test-Path $target)) { throw "missing $target" }

$action    = New-ScheduledTaskAction -Execute 'powershell.exe' `
              -Argument ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $target)
$trigger   = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At $Time
$settings  = New-ScheduledTaskSettingsSet -WakeToRun -StartWhenAvailable `
              -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
              -ExecutionTimeLimit (New-TimeSpan -Minutes 30)
$principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType Interactive -RunLevel Limited

Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -EA 0 | Out-Null
Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger `
    -Settings $settings -Principal $principal `
    -Description 'Weekly review of airouter model catalog; smoke-tests any new candidates.' | Out-Null

Write-Host "Registered: $TaskName" -ForegroundColor Green
Get-ScheduledTask -TaskName $TaskName | Select-Object TaskName, State, @{n='NextRun';e={(Get-ScheduledTaskInfo $_).NextRunTime}} | Format-Table -AutoSize
