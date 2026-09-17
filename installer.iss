#define MyAppName "Missions Log"
#define MyAppVersion "1.0.1"
#define MyAppPublisher "Taaheer Labbe"
#define MyAppURL "https://github.com/taaheer/Missions-Log"
#define MyAppExeName "MissionsLog.exe"
; CMake installs executables into a "bin" folder by default
#define MyAppExePath "bin\MissionsLog.exe" 

[Setup]
AppId={{9A54C23A-2376-48A3-A7AF-0F662F010731}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
UninstallDisplayIcon={app}\{#MyAppExePath}

ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
DisableProgramGroupPage=yes

; Set output to a relative folder so GitHub Actions can find it
OutputDir=Output
OutputBaseFilename=MissionsLog-Installer

; Ensure app.ico is committed to the root of your repository
SetupIconFile=app.ico 
SolidCompression=yes
WizardStyle=modern dynamic

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; This tells Inno to grab everything CMake dumped into the "stage" folder
Source: "stage\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExePath}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExePath}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExePath}"; Description: "{cm:LaunchProgram,{#MyAppName}}"; Flags: nowait postinstall skipifsilent