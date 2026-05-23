# inbox-notifier.ps1 - polls this host's agent inbox and pops a Windows
# toast for any newly-arrived pending task. Does NOT execute anything;
# purely an alerter so the receiving architect knows to nudge their
# Augment session to pick the task up. Honors R2 (human-mediated
# pickup, no auto-execute).
#
# State is kept in .augment/.inbox-notifier.state.json (gitignored,
# host-local). On first run it silently absorbs the current pending
# set without notifying, then alerts only for new IDs after that.
#
[CmdletBinding()]
param(
    [int]$MinPriorityRank = 0,  # 0=all, 1=normal+, 2=high only
    [switch]$Force              # ignore state, re-notify everything pending
)

$ErrorActionPreference = 'Stop'
$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$root      = Resolve-Path (Join-Path $scriptDir '..\..')
$augDir    = Join-Path $root '.augment'
$state     = Join-Path $augDir '.inbox-notifier.state.json'
$worklog   = Join-Path $augDir '.inbox-notifier.log'

$self = if ($env:AUGMENT_AGENT_HOST) { $env:AUGMENT_AGENT_HOST }
        elseif ($env:COMPUTERNAME -match 'CHOST|WORK') { 'chost' }
        else { 'laptop' }

$inboxPath = Join-Path $augDir "agent-tasks\inbox-$self.jsonl"
$donePath  = Join-Path $augDir 'agent-tasks\done.jsonl'

function Log($m) { Add-Content -Path $worklog -Value ("{0}  {1}" -f (Get-Date -Format s), $m) -Encoding UTF8 }

# 1. Build pending set (id -> task object)
if (-not (Test-Path $inboxPath)) { Log "no inbox file ($self), exit"; return }
$doneIds = @{}
if (Test-Path $donePath) {
    Get-Content $donePath -EA 0 | ForEach-Object {
        try { $o = $_ | ConvertFrom-Json; if ($o.id) { $doneIds[$o.id] = $o.status } } catch {}
    }
}
$priRank = @{ 'low' = 0; 'normal' = 1; 'high' = 2 }
$pending = @{}
Get-Content $inboxPath -EA 0 | ForEach-Object {
    try {
        $o = $_ | ConvertFrom-Json
        if (-not $o.id) { return }
        if ($doneIds.ContainsKey($o.id)) { return }
        $r = if ($priRank.ContainsKey($o.priority)) { $priRank[$o.priority] } else { 1 }
        if ($r -lt $MinPriorityRank) { return }
        $pending[$o.id] = $o
    } catch {}
}

# 2. Diff against state
$known = @{}
$firstRun = $false
if (Test-Path $state) {
    try {
        $s = Get-Content $state -Raw | ConvertFrom-Json
        foreach ($id in $s.knownIds) { $known[$id] = $true }
    } catch { $firstRun = $true }
} else { $firstRun = $true }

$new = @()
foreach ($id in $pending.Keys) {
    if (-not $known.ContainsKey($id)) { $new += $pending[$id] }
}

# 3. Persist new state (always)
$payload = @{
    knownIds = @($pending.Keys)
    updated  = (Get-Date -Format s)
    self     = $self
} | ConvertTo-Json -Compress
Set-Content -Path $state -Value $payload -Encoding UTF8

if ($firstRun -and -not $Force) {
    Log "first-run absorb: $($pending.Count) pending (no toast)"
    return
}
if (-not $new.Count -and -not $Force) {
    Log "no new pending"
    return
}
$toShow = if ($Force) { @($pending.Values) } else { $new }

# 4. Pop toast(s). NotifyIcon balloons render as native Action Center
# toasts on Windows 10/11 without needing the BurntToast module.
try {
    Add-Type -AssemblyName System.Windows.Forms -EA Stop
    Add-Type -AssemblyName System.Drawing -EA Stop
    foreach ($t in $toShow) {
        $title = "Augment inbox ($self): $($t.priority)"
        $body  = "$($t.id)  $($t.title)`nfrom: $($t.from)"
        $bal = New-Object System.Windows.Forms.NotifyIcon
        $bal.Icon = [System.Drawing.SystemIcons]::Information
        $bal.BalloonTipTitle = $title
        $bal.BalloonTipText  = $body
        $bal.Visible = $true
        $bal.ShowBalloonTip(15000)
        Start-Sleep -Milliseconds 800
        $bal.Dispose()
        Log "notified: $($t.id) [$($t.priority)] $($t.title)"
    }
} catch {
    Log "toast failed: $($_.Exception.Message)"
}
