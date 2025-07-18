<#
.SYNOPSIS
    Deploys a captured application by copying its files and importing registry changes.
.DESCRIPTION
    This script is the "replayer" for an application captured using a snapshot tool like Regshot.
    It assumes a specific folder structure created during the packaging phase.
    
    Expected Structure:
    - / (Root of this script)
    - /Program Files/AppName/... (Files for C:\Program Files)
    - /AppData/Roaming/AppName/... (Files for %APPDATA%)
    - /AppData/Local/AppName/... (Files for %LOCALAPPDATA%)
    - /ProgramData/AppName/... (Files for C:\ProgramData)
    - changes.reg (The registry changes to import)

    RUN AS ADMINISTRATOR to ensure permissions for Program Files and registry.
.EXAMPLE
    .\Deploy-App.ps1
    Runs the script from its directory.
#>

# --- Configuration ---
# Get the directory where the script itself is located.
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

# Define source paths within your package
$SourceProgramFiles = Join-Path $ScriptRoot "Program Files"
$SourceAppDataRoaming = Join-Path $ScriptRoot "AppData\Roaming"
$SourceAppDataLocal = Join-Path $ScriptRoot "AppData\Local"
$SourceProgramData = Join-Path $ScriptRoot "ProgramData"
$SourceRegFile = Join-Path $ScriptRoot "changes.reg"

# Define target paths on the system using environment variables for robustness
$TargetProgramFiles = $env:ProgramFiles
$TargetAppDataRoaming = $env:APPDATA
$TargetAppDataLocal = $env:LOCALAPPDATA
$TargetProgramData = $env:ProgramData

# --- Functions ---

# A helper function to write colored output to the console
function Write-Log {
    param (
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] $Message" -ForegroundColor $Color
}

# A function to safely copy directory contents
function Copy-DirectoryContents {
    param (
        [string]$Source,
        [string]$Destination
    )
    if (Test-Path -Path $Source) {
        Write-Log "Source found: $Source" -Color Cyan
        Write-Log "Copying contents to: $Destination" -Color Cyan
        
        # Ensure the destination directory exists
        if (-not (Test-Path -Path $Destination)) {
            Write-Log "Destination directory does not exist. Creating it."
            New-Item -ItemType Directory -Path $Destination -Force | Out-Null
        }

        try {
            Copy-Item -Path "$Source\*" -Destination $Destination -Recurse -Force -ErrorAction Stop
            Write-Log "Successfully copied contents from `"$Source`" to `"$Destination`"." -Color Green
        }
        catch {
            Write-Log "ERROR: Failed to copy from `"$Source`". Error: $_" -Color Red
        }
    }
    else {
        Write-Log "Source directory not found in package, skipping: $Source" -Color Yellow
    }
}


# --- Main Execution ---

Write-Log "Starting Application Deployment..." -Color Magenta
Write-Log "Script running from: $ScriptRoot" -Color Magenta

# Step 1: Copy Files
Write-Log "--- Phase 1: Copying Files ---" -Color White

# Copy Program Files
Copy-DirectoryContents -Source $SourceProgramFiles -Destination $TargetProgramFiles

# Copy AppData (Roaming)
Copy-DirectoryContents -Source $SourceAppDataRoaming -Destination $TargetAppDataRoaming

# Copy AppData (Local)
Copy-DirectoryContents -Source $SourceAppDataLocal -Destination $TargetAppDataLocal

# Copy ProgramData
Copy-DirectoryContents -Source $SourceProgramData -Destination $TargetProgramData


# Step 2: Import Registry Changes
Write-Log "`n--- Phase 2: Importing Registry Changes ---" -Color White

if (Test-Path -Path $SourceRegFile) {
    Write-Log "Registry file found: $SourceRegFile" -Color Cyan
    try {
        # Using the classic reg.exe is reliable and provides good feedback.
        # The /s switch makes it silent (no confirmation prompt).
        Start-Process reg.exe -ArgumentList "import `"$SourceRegFile`"" -Wait -Verb RunAs
        Write-Log "Successfully imported registry file." -Color Green
    }
    catch {
        Write-Log "ERROR: Failed to import registry file. Error: $_" -Color Red
        Write-Log "Please ensure you are running this script as an Administrator." -Color Yellow
    }
}
else {
    Write-Log "No 'changes.reg' file found in package. Skipping registry import." -Color Yellow
}

Write-Log "`nDeployment script finished." -Color Magenta

