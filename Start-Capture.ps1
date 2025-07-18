<#
.SYNOPSIS
    Automates the preparation for capturing an application installation.
.DESCRIPTION
    This script downloads and extracts Regshot, the snapshotting tool, to a specified directory.
    It then launches Regshot and provides instructions for the user to begin the capture process.
    This is the FIRST step in the migration workflow and should be run on the SOURCE machine.
.EXAMPLE
    .\Start-Capture.ps1
    Downloads and runs Regshot in the current user's Downloads folder.
#>

# --- Configuration ---
# The folder where Regshot will be downloaded and extracted.
$WorkingDir = Join-Path $env:USERPROFILE "Downloads\AppCapture"
$RegshotZipFile = Join-Path $WorkingDir "regshot.zip"
$RegshotUrl = "https://downloads.sourceforge.net/project/regshot/regshot/1.9.0/regshot-1.9.0-x64.zip" # URL for the 64-bit version

# --- Functions ---
function Write-Log {
    param (
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] $Message" -ForegroundColor $Color
}

# --- Main Execution ---

# Check if running as Administrator, which is not required but good practice for installs.
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Log "INFO: This script doesn't require Admin rights, but you will need them to install most software." -Color Yellow
}

Write-Log "Starting Capture Preparation..." -Color Magenta

# Create the working directory if it doesn't exist
if (-not (Test-Path -Path $WorkingDir)) {
    Write-Log "Creating working directory at: $WorkingDir"
    New-Item -ItemType Directory -Path $WorkingDir -Force | Out-Null
}

# Determine the path to the Regshot executable
$RegshotExePath = Join-Path $WorkingDir "regshot-1.9.0-x64\Regshot-x64.exe"

# Check if Regshot is already downloaded and extracted
if (Test-Path -Path $RegshotExePath) {
    Write-Log "Regshot already exists. Skipping download." -Color Green
}
else {
    Write-Log "Regshot not found. Starting download from: $RegshotUrl" -Color Cyan
    try {
        # Download the file
        Invoke-WebRequest -Uri $RegshotUrl -OutFile $RegshotZipFile -ErrorAction Stop
        Write-Log "Download complete." -Color Green

        # Extract the archive
        Write-Log "Extracting Regshot archive..."
        Expand-Archive -Path $RegshotZipFile -DestinationPath $WorkingDir -Force -ErrorAction Stop
        Write-Log "Extraction complete." -Color Green
    }
    catch {
        Write-Log "ERROR: Failed to download or extract Regshot. Error: $_" -Color Red
        Write-Log "Please check the URL and your internet connection." -Color Yellow
        # Stop the script if the download fails
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
Write-Log "------------------------------------------------------------------" -Color Magenta

