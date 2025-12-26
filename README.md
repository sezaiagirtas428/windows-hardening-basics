# Windows Hardening Basics

This repository contains a basic Windows hardening script written in PowerShell.  
It focuses on demonstrating fundamental security-hardening concepts in a clear and structured way.

## Project Goals
- Showcase a beginner-friendly Windows hardening approach
- Provide a foundation for security automation using PowerShell
- Encourage secure-by-default system configuration

## What the Script Does
- Applies basic security-related system configurations
- Demonstrates how hardening tasks can be automated
- Uses readable and modular PowerShell structure

## Disclaimer
This project is intended for **educational purposes only**.  
Always test security scripts in a controlled environment before using them in production systems.

## Security Controls Covered
- Windows Firewall: Verified enabled for Domain/Private/Public profiles
- RDP: Verified disabled
- Microsoft Defender: Verified enabled (Real-time protection enabled)
- Defender ASR: Enabled rule in Warn mode
  - D4F940AB-401B-4EFC-AADC-AD5F3C50688A — Block Office applications from creating child processes (Warn)
