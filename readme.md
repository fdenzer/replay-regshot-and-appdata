# AppMigrator

A tool to capture and migrate Windows application installations between machines without requiring traditional installers.

## Overview

AppMigrator captures registry changes and file system modifications during application installation and packages them for deployment on other machines. This allows migrating applications to machines where installers may be unavailable or unsuitable.

    ## Features

    - Automatic installation of Regshot using Chocolatey
    - Registry change capture and playback
    - File system modification tracking
    - Simple deployment to target machines

    ## Requirements

    - Source machine: Windows 7 SP1+, 8.1, 10, or 11 with PowerShell 5.1+
    - Target machine: Windows 7 SP1+, 8.1, 10, or 11 with PowerShell 5.1+
    - Administrative privileges on both machines
    - Windows 10/11 recommended for best experience and support

    ## Installation

    No installation required. Clone or download this repository to get started:

    ```bash
    git clone https://github.com/yourusername/appmigrator.git
    cd appmigrator
    ```

    Note: PowerShell 5.1 is built into Windows 10/11, but requires installation of Windows Management Framework 5.1 on Windows 7 SP1 and 8.1.

## Usage

### 1. Capture an Application (Source Machine)

1. Run the capture script with administrative privileges:

```powershell
.\Start-Capture.ps1
```

2. The script will:
   - Install Chocolatey if not present
   - Install Regshot via Chocolatey
   - Launch Regshot automatically

3. In Regshot:
   - Take first snapshot before installation
   - Install your application
   - Take second snapshot after installation
   - Generate comparison report

### 2. Package the Application

1. Create a new folder for your migration package
2. Using the Regshot report, copy relevant files:

   - Copy main program files from `C:\Program Files\*` or `C:\Program Files (x86)\*`
   - Copy AppData files from user profile if needed
   - Copy ProgramData files if needed

3. Create a registry file:
   - Extract registry keys from the Regshot report
   - Save as `changes.reg` with proper formatting:

```reg
Windows Registry Editor Version 5.00

[HKEY_CURRENT_USER\Software\YourApp]
"InstallPath"="C:\\Program Files\\YourApp"
```

4. Copy the `Deploy-App.ps1` script to your package

5. Package structure should look like:

```
AppPackage/
├── Program Files/
│   └── YourApp/
├── AppData/
│   └── Roaming/
│       └── YourApp/
├── changes.reg
└── Deploy-App.ps1
```

### 3. Deploy the Application (Target Machine)

1. Transfer the package folder to the target machine

2. Run PowerShell as Administrator

3. Navigate to the package folder:

```powershell
cd "C:\path\to\AppPackage"
```

4. Run the deployment script:

```powershell
.\Deploy-App.ps1
```

The script will copy all files to their proper locations and import the registry changes.

## How It Works

- **Start-Capture.ps1**: Installs and runs Regshot to capture before/after system states
- **Deploy-App.ps1**: Copies files and imports registry changes on the target machine

## License

EUPL-v1.2

## Contributions

Contributions are welcome! Please feel free to submit a Pull Request.
