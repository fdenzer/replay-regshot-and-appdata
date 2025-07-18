<#
.SYNOPSIS
    Automates the preparation for capturing an application installation.
.DESCRIPTION
    This script installs Regshot using Chocolatey package manager, then launches it and provides instructions for the user to begin the capture process.
    This is the FIRST step in the migration workflow and should be run ONLY on the SOURCE machine where you want to capture software installation.
    No software installation is needed on the target machine.
.EXAMPLE
    .\Start-Capture.ps1
    Installs Regshot using Chocolatey and runs it.
.NOTES
    Requires administrative privileges to install Chocolatey and Regshot.
    The target machine will not require Regshot or Chocolatey - only the Deploy-App.ps1 script.
#>

# --- Configuration ---
# Path to Regshot executable after Chocolatey installation
$RegshotExePath = "C:\Program Files\Regshot-x86\Regshot-x86.exe"
if ([Environment]::Is64BitOperatingSystem) {
    $RegshotExePath = "C:\Program Files\Regshot-x64\Regshot-x64.exe"
}

# --- Functions ---
function Write-Log {
    param (
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] $Message" -ForegroundColor $Color
}

# --- Main Execution ---

# Check if running as Administrator and restart with elevation if needed
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Log "This script requires administrative privileges to install Chocolatey and Regshot." -Color Yellow
    Write-Log "Requesting elevation..." -Color Cyan

    # Restart script with admin rights
    $scriptPath = $MyInvocation.MyCommand.Path
    $argumentList = "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""

    try {
        Start-Process PowerShell -Verb RunAs -ArgumentList $argumentList -ErrorAction Stop
        exit
    }
    catch {
        Write-Log "ERROR: Failed to restart with administrative privileges. Error: $_" -Color Red
        Write-Log "Please run this script as an administrator." -Color Yellow
        pause
        exit
    }
}

Write-Log "Starting Capture Preparation..." -Color Magenta

# Check if Chocolatey is installed
if (-not (Get-Command choco.exe -ErrorAction SilentlyContinue)) {
    Write-Log "Chocolatey not found. Installing Chocolatey..." -Color Cyan
    try {
        # Install Chocolatey
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        Write-Log "Chocolatey installed successfully." -Color Green
    }
    catch {
        Write-Log "ERROR: Failed to install Chocolatey. Error: $_" -Color Red
        return
    }
}

# Check if Regshot is already installed
if (Test-Path -Path $RegshotExePath) {
    Write-Log "Regshot already installed. Skipping installation." -Color Green
}
else {
    Write-Log "Installing Regshot using Chocolatey..." -Color Cyan
    try {
        # Install Regshot using Chocolatey
        & choco install regshot -y
        Write-Log "Regshot installed successfully." -Color Green
    }
    catch {
        Write-Log "ERROR: Failed to install Regshot. Error: $_" -Color Red
        return
    }
}

# Launch Regshot
Write-Log "Launching Regshot..." -Color Cyan
try {
    Start-Process -FilePath $RegshotExePath -ErrorAction Stop
}
catch {
    Write-Log "ERROR: Could not start Regshot at '$RegshotExePath'. Error: $_" -Color Red
    return
}

# Provide clear instructions to the user
Write-Log "------------------------------------------------------------------" -Color Magenta
Write-Log "ACTION REQUIRED: Regshot is now running." -Color Yellow
Write-Log "1. In the Regshot window, click the '1st shot' button, then 'Shot and Save'."
Write-Log "2. WAIT for the scan to complete."
Write-Log "3. Install the application you want to capture."
Write-Log "4. Once installation is finished, return to Regshot."
Write-Log "5. Click the '2nd shot' button, then 'Shot and Save'."
Write-Log "6. Finally, click 'Compare' to generate the report of all changes."
Write-Log "7. Create a folder and package the files according to the readme instructions."
Write-Log "8. On the TARGET machine, you will NOT need Regshot - just run Deploy-App.ps1."
Write-Log "------------------------------------------------------------------" -Color Magenta
Write-Log "NOTE: Regshot was automatically installed using Chocolatey package manager." -Color Cyan
Write-Log "NOTE: This installation is ONLY needed on the source machine, not on the target." -Color Yellow

