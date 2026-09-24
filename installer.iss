#define MyAppName "Missions Log"

#ifndef MyAppVersion
#define MyAppVersion "1.0.0"
#endif

#define MyAppPublisher "Taaheer Labbe"
#define MyAppURL "https://github.com/taaheer/Missions-Log"
#define MyAppExeName "MissionsLog.exe"

#define MyAppExePath "bin\" + MyAppExeName

[Setup]
AppId={{EF1CAEDF-BC60-4258-95DE-0E9C04C2F9A8}
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
LicenseFile=LICENSE

OutputDir=Output
OutputBaseFilename=MissionsLog-Installer

PrivilegesRequiredOverridesAllowed=commandline
SetupIconFile=app.ico
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "stage\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExePath}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExePath}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExePath}"; Description: "{cm:LaunchProgram,{#MyAppName}}"; Flags: nowait postinstall skipifsilent

