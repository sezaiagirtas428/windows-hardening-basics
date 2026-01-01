<#
.SYNOPSIS
  Windows Hardening Basics (Firewall + RDP check + Defender status + ASR rule in Warn mode)

.DESCRIPTION
  - Logs output to ..\logs\hardening.log (relative to this script)
  - Supports AuditMode (no changes) vs Apply mode (changes)

.PARAMETER AuditMode
  If set, the script only reports what it would change.

.NOTES
  Run in an elevated PowerShell for changes to apply.
#>

[CmdletBinding()]
param(
  [switch]$AuditMode
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Step($msg) { Write-Output $msg }

# --- Resolve paths reliably (PSScriptRoot can be empty in some contexts) ---
$ScriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }

$LogsDir = Join-Path $ScriptDir "..\logs"
if (-not (Test-Path $LogsDir)) {
  New-Item -ItemType Directory -Path $LogsDir | Out-Null
}

$LogPath = Join-Path $LogsDir "hardening.log"
Start-Transcript -Path $LogPath -Append | Out-Null

try {
  Write-Step "=== Windows Hardening Basics ==="
  Write-Step ("Mode: " + ($(if ($AuditMode) { "AUDIT (no changes)" } else { "APPLY (makes changes)" })))
  Write-Step ""

  # [1/6] Firewall
  Write-Step "[1/6] Checking Windows Firewall status..."
  $firewallProfiles = Get-NetFirewallProfile
  foreach ($profile in $firewallProfiles) {
    if (-not $profile.Enabled) {
      Write-Step "Firewall is disabled for $($profile.Name)."
      if (-not $AuditMode) {
        Set-NetFirewallProfile -Name $profile.Name -Enabled True
        Write-Step "Firewall enabled for $($profile.Name)."
      } else {
        Write-Step "Audit mode: Firewall would be enabled for $($profile.Name)."
      }
    } else {
      Write-Step "Firewall is already enabled for $($profile.Name)."
    }
  }

  # [2/6] RDP status (report only)
  Write-Step ""
  Write-Step "[2/6] Checking RDP status..."
  $rdpStatus = Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -ErrorAction Stop
  if ($rdpStatus.fDenyTSConnections -eq 1) {
    Write-Step "RDP is currently DISABLED."
  } else {
    Write-Step "RDP is ENABLED. Consider restricting (NLA, firewall scope) or disabling if not needed."
  }

  # [3/6] Defender status
  Write-Step ""
  Write-Step "[3/6] Checking Windows Defender status..."
  try {
    $defenderStatus = Get-MpComputerStatus -ErrorAction Stop
    if ($defenderStatus.AntivirusEnabled) {
      Write-Step "Windows Defender Antivirus is ENABLED."
    } else {
      Write-Step "Windows Defender Antivirus is DISABLED."
    }

    # [4/6] Real-time protection
    Write-Step ""
    Write-Step "[4/6] Checking Defender Real-Time Protection..."
    if ($defenderStatus.RealTimeProtectionEnabled) {
      Write-Step "Defender Real-Time Protection is ENABLED."
    } else {
      Write-Step "Defender Real-Time Protection is DISABLED."
    }
  } catch {
    Write-Step "Defender status check failed (Get-MpComputerStatus not available or insufficient permissions)."
  }

  # [5/6] ASR rules list
  Write-Step ""
  Write-Step "[5/6] Checking Microsoft Defender ASR rules..."
  try {
    $pref = Get-MpPreference -ErrorAction Stop
    if (-not $pref.AttackSurfaceReductionRules_Ids -or $pref.AttackSurfaceReductionRules_Ids.Count -eq 0) {
      Write-Step "No ASR rules are configured."
    } else {
      for ($i = 0; $i -lt $pref.AttackSurfaceReductionRules_Ids.Count; $i++) {
        $id = $pref.AttackSurfaceReductionRules_Ids[$i]
        $action = $pref.AttackSurfaceReductionRules_Actions[$i]
        Write-Step (" - {0} : {1}" -f $id, $action)
      }
    }
  } catch {
    Write-Step "ASR check failed (Get-MpPreference not available or insufficient permissions)."
  }

  # [6/6] Apply specific ASR rule in WARN mode (action=6)
  Write-Step ""
  Write-Step "[6/6] Applying ASR rule in WARN mode..."
  $asrRuleId = "D4F940AB-401B-4EFC-AADC-AD5F3C50688A"

  if ($AuditMode) {
    Write-Step "Audit mode: ASR rule would be set to WARN (action 6) for $asrRuleId."
  } else {
    try {
      Add-MpPreference -AttackSurfaceReductionRules_Ids $asrRuleId -AttackSurfaceReductionRules_Actions 6 -ErrorAction Stop
      Write-Step "ASR rule set to WARN mode (action 6) for $asrRuleId."
    } catch {
      Write-Step "Failed to set ASR rule (need admin, Defender present, and supported OS edition)."
      throw
    }
  }

  Write-Step ""
  Write-Step "Done."
}
finally {
  try { Stop-Transcript | Out-Null } catch {}
}
