; Inno Setup script - Windows setup wizard for Khmer Calendar.
; Built in CI by scripts/build-installer.ps1:  iscc /DAppVersion=1.0.3 /DSourceDir=... /DOutDir=... khmer_calendar.iss
#ifndef AppVersion
  #define AppVersion "0.0.0"
#endif
#ifndef SourceDir
  #error SourceDir is required (the signed Release folder)
#endif
#ifndef OutDir
  #define OutDir "Output"
#endif

[Setup]
AppId={{6E1B7E55-2C0F-4B8D-9B7A-3D5F0A7C41E9}
AppName=Khmer Calendar
AppVersion={#AppVersion}
AppPublisher=Dara Sok Moun
AppPublisherURL=https://github.com/mounsokdara/Khmer-Calendar
AppSupportURL=https://github.com/mounsokdara/Khmer-Calendar/issues
AppUpdatesURL=https://github.com/mounsokdara/Khmer-Calendar/releases/latest
; Per-user by default (no admin prompt); the wizard offers "all users" as an option.
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
DefaultDirName={autopf}\Khmer Calendar
DefaultGroupName=Khmer Calendar
DisableProgramGroupPage=yes
LicenseFile={#SourcePath}\..\LICENSE
InfoBeforeFile={#SourcePath}\PRIVACY.txt
SetupIconFile={#SourcePath}\..\khmer_calendar\windows\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\khmer_calendar.exe
OutputDir={#OutDir}
OutputBaseFilename=KhmerCalendar-windows-setup
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
CloseApplications=yes
RestartApplications=no

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#SourceDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\Khmer Calendar"; Filename: "{app}\khmer_calendar.exe"
Name: "{group}\{cm:UninstallProgram,Khmer Calendar}"; Filename: "{uninstallexe}"
Name: "{group}\Privacy Policy"; Filename: "{app}\Privacy Policy.url"
Name: "{autodesktop}\Khmer Calendar"; Filename: "{app}\khmer_calendar.exe"; Tasks: desktopicon

[INI]
Filename: "{app}\Privacy Policy.url"; Section: "InternetShortcut"; Key: "URL"; String: "https://github.com/mounsokdara/Khmer-Calendar/blob/main/PRIVACY.md"

[UninstallDelete]
Type: files; Name: "{app}\Privacy Policy.url"

[Run]
Filename: "{app}\khmer_calendar.exe"; Description: "{cm:LaunchProgram,Khmer Calendar}"; Flags: nowait postinstall skipifsilent
