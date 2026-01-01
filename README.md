# Windows Endpoint Security Baseline Tool

A PowerShell-based security baseline tool that assesses and optionally enforces essential Windows endpoint security controls.
The tool is designed to provide visibility into system security posture and support informed hardening decisions.

## Scope

This tool focuses on validating and improving core security controls commonly expected on Windows endpoints, including:

- Windows Firewall configuration
- Remote Desktop Protocol (RDP) exposure
- Microsoft Defender Antivirus status
- Defender Real-Time Protection
- Microsoft Defender Attack Surface Reduction (ASR) rules

The goal is not to replace enterprise security products, but to provide a lightweight and transparent baseline assessment.

## Limitations

- This tool does not cover all CIS or NIST benchmark controls.
- It is intended for educational, lab, and small-scale environments.
- Administrative privileges may be required for certain checks or enforcement actions.
- Users should review findings carefully before applying changes to production systems.
