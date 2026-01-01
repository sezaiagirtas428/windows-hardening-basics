$AuditMode = $false

$LogPath = Join-Path $PSScriptRoot "hardening.log"
Start-Transcript -Path $LogPath -Append

Write-Output "=== Windows Hardening Basics ==="

Write-Output ""
Write-Output "[1/6] Checking Windows Firewall status..."
$firewallProfiles = Get-NetFirewallProfile
foreach ($profile in $firewallProfiles) {
    if ($profile.Enabled -eq $false) {
        Write-Output "Firewall is disabled for $($profile.Name)."
        if (-not $AuditMode) {
            Set-NetFirewallProfile -Name $profile.Name -Enabled True
        } else {
            Write-Output "Audit mode: Firewall would be enabled for $($profile.Name)."
        }
    } else {
        Write-Output "Firewall is already enabled for $($profile.Name)."
    }
}

Write-Output ""
Write-Output "[2/6] Checking RDP status..."
$rdpStatus = Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections"
if ($rdpStatus.fDenyTSConnections -eq 1) {
    Write-Output "RDP is currently DISABLED."
} else {
    Write-Output "RDP is ENABLED. Consider restricting or disabling it."
}

Write-Output ""
Write-Output "[3/6] Checking Windows Defender status..."
$defenderStatus = Get-MpComputerStatus
if ($defenderStatus.AntivirusEnabled) {
    Write-Output "Windows Defender Antivirus is ENABLED."
} else {
    Write-Output "Windows Defender Antivirus is DISABLED."
}

Write-Output ""
Write-Output "[4/6] Checking Defender Real-Time Protection..."
if ($defenderStatus.RealTimeProtectionEnabled) {
    Write-Output "Defender Real-Time Protection is ENABLED."
} else {
    Write-Output "Defender Real-Time Protection is DISABLED."
}

Write-Output ""
Write-Output "[5/6] Checking Microsoft Defender ASR rules..."
try {
    $pref = Get-MpPreference
    if (-not $pref.AttackSurfaceReductionRules_Ids) {
        Write-Output "No ASR rules are configured."
    } else {
        for ($i = 0; $i -lt $pref.AttackSurfaceReductionRules_Ids.Count; $i++) {
            $id = $pref.AttackSurfaceReductionRules_Ids[$i]
            $action = $pref.AttackSurfaceReductionRules_Actions[$i]
            Write-Output " - $id : $action"
        }
    }
} catch {
    Write-Output "ASR check failed."
}

Write-Output ""
Write-Output "[6/6] Applying ASR rule in WARN mode..."
$asrRuleId = "D4F940AB-401B-4EFC-AADC-AD5F3C50688A"

if ($AuditMode) {
    Write-Output "Audit mode: ASR rule would be set to WARN."
} else {
    Add-MpPreference -AttackSurfaceReductionRules_Ids $asrRuleId `
                     -AttackSurfaceReductionRules_Actions 6
    Write-Output "ASR rule set to WARN mode."
}

Write-Output ""
Write-Output "Done."
Stop-Transcript
