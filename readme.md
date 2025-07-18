Phase 1: Capture the Installation ("The Recorder")

This process is performed on your source machine (e.g., the Windows 11 PC).

    Prepare a Clean State: For the best results, use a clean system or a virtual machine. Close all other applications.

    Download Regshot: Get the latest version of Regshot and extract it.

    Take the "Before" Snapshot:

        Run Regshot.exe.

        Click the "1st shot" button and then "Shot and Save". This will scan your entire registry and (optionally) specified directories. It will save a .hiv file. This can take a minute.

        Make sure to include the C:\Users and C:\ProgramData directories in the scan, as many programs write here.

    Install Your Program:

        DO NOT CLOSE REGSHOT.

        Run the installer for the program you want to capture (e.g., 7-Zip, Notepad++, etc.).

        Complete the installation as you normally would. Configure any initial settings you want to be part of the package.

    Take the "After" Snapshot:

        Go back to Regshot.

        Click the "2nd shot" button and then "Shot and Save". This takes the "after" snapshot.

    Compare and Generate the Report:

        Click the "Compare" button.

        Regshot will generate a txt report detailing every single change:

            Registry keys and values added/modified.

            Files and folders created/modified.

            A summary at the top.

Phase 2: Package the Application ("The Migration File")

Now you have the report and the installed files on your system. You need to bundle them for transfer.

    Create a Root Folder: Create a new folder on your desktop, for example, MyAwesomeMigration.

    Copy Program Files:

        Look at the Regshot report under "Folders added" and "Files added".

        Find the main installation directory (e.g., C:\Program Files\MyAwesomeApp).

        Copy this entire folder into your MyAwesomeMigration folder.

    Copy AppData/Other Files:

        Check the report for files added to C:\Users\YourUser\AppData\Local, ...\Roaming, or C:\ProgramData.

        Recreate that folder structure inside MyAwesomeMigration. For example, if a file was added to AppData\Roaming\MyAwesomeApp, you would create MyAwesomeMigration\AppData\Roaming\MyAwesomeApp and place the file there.

    Create a Registry File:

        Open the Regshot txt report.

        Scroll down to the "Keys added" and "Values added/modified" sections.

        Carefully copy all of these registry entries into a new text file.

        Save this file as changes.reg inside your MyAwesomeMigration folder.

        Crucially, you must format it as a valid .reg file. It needs Windows Registry Editor Version 5.00 at the top, and each key must be enclosed in square brackets.

    Example changes.reg format:

    Windows Registry Editor Version 5.00

    [HKEY_CURRENT_USER\Software\MyAwesomeCompany]

    [HKEY_CURRENT_USER\Software\MyAwesomeCompany\MyAwesomeApp]
    "InstallPath"="C:\\Program Files\\MyAwesomeApp"
    "Version"="1.2.3"

    [HKEY_CLASSES_ROOT\.awesome]
    @="MyAwesomeApp.File"

    Get the Deployment Script:

        Copy the PowerShell script I've provided below and save it as Deploy-App.ps1 in the root of your MyAwesomeMigration folder.

At the end of this phase, your MyAwesomeMigration folder should look something like this:

```text
MyAwesomeMigration/
├── Program Files/
│   └── MyAwesomeApp/
│       ├── AwesomeApp.exe
│       └── ...other files...
├── AppData/
│   └── Roaming/
│       └── MyAwesomeApp/
│           └── settings.xml
├── changes.reg
└── Deploy-App.ps1
```

Phase 3: Deploy the Application ("The Replayer")

Take the entire MyAwesomeMigration folder (e.g., on a USB stick) to the target machine (e.g., the Windows 10 PC).

    Open PowerShell as Administrator: Right-click the Start button and select "Windows PowerShell (Admin)" or "Terminal (Admin)".

    Allow Script Execution (if needed): If you've never run PowerShell scripts before, you may need to change the execution policy.

    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process

    Navigate to the Folder:

    cd "D:\Path\To\MyAwesomeMigration"

    Run the Deployment Script:

    .\Deploy-App.ps1

The script will automatically copy the files to the correct locations (C:\Program Files, C:\Users\CurrentUser\AppData, etc.) and import the registry changes. If all goes well, the application will appear "installed" on the target machine.