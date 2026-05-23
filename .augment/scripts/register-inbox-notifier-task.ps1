# register-inbox-notifier-task.ps1 - register inbox-notifier as a
# Windows Scheduled Task. Runs every N minutes, pops a toast when a
# new pending inbox task arrives. Idempotent.
#
[CmdletBinding()]
param(
    [string]$TaskName        = 'AugmentInboxNotifier',
    [int]   $IntervalMinutes = 2
)

$ErrorActionPreference = 'Stop'
$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$target    = Join-Path $scriptDir 'inbox-notifier.ps1'
if (-not (Test-Path $target)) { throw "missing $target" }

$action    = New-ScheduledTaskAction -Execute 'powershell.exe' `
              -Argument ("-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"{0}`"" -f $target)
$trigger   = New-ScheduledTaskTrigger -Once -At (Get-Date).Date.AddMinutes(2) `
              -RepetitionInterval (New-TimeSpan -Minutes $IntervalMinutes) `
              -RepetitionDuration ([TimeSpan]::FromDays(365))
$settings  = New-ScheduledTaskSettingsSet -StartWhenAvailable `
              -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
              -ExecutionTimeLimit (New-TimeSpan -Minutes 1) `
              -MultipleInstances IgnoreNew
$principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType Interactive -RunLevel Limited

Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -EA 0 | Out-Null
Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger `
    -Settings $settings -Principal $principal `
    -Description "Pops a Windows toast when a new pending task arrives in this host's agent inbox. Does NOT execute tasks. Runs every $IntervalMinutes minutes." | Out-Null

Write-Host "Registered: $TaskName (every $IntervalMinutes min)" -ForegroundColor Green
Get-ScheduledTask -TaskName $TaskName | Select-Object TaskName, State, @{n='NextRun';e={(Get-ScheduledTaskInfo $_).NextRunTime}} | Format-Table -AutoSize
