#define MyAppName "WinGCC"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "ShiWildy"
#define MyAppURL "https://github.com/shiwildy/WinGCC.git"

[Setup]
AppId={{517E0221-B3E6-4C74-861C-3A64C85AF534}
AppName="WinGCC"
AppVersion="1.0.0"
AppPublisher="ShiWildy"
AppPublisherURL="https://github.com/shiwildy/WinGCC.git"
AppSupportURL="https://github.com/shiwildy/WinGCC.git"
AppUpdatesURL="https://github.com/shiwildy/WinGCC.git"
DefaultDirName="C:\WinGCC"
DisableDirPage=yes
DisableProgramGroupPage=yes
OutputDir=output\
OutputBaseFilename="wingcc-1.0.0"
Compression=lzma
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "README.txt"; DestDir: "C:\WinGCC\"; Flags: ignoreversion
Source: "bin\*"; DestDir: "C:\WinGCC\bin\"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "include\*"; DestDir: "C:\WinGCC\include\"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "lib\*"; DestDir: "C:\WinGCC\lib\"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "libexec\*"; DestDir: "C:\WinGCC\libexec\"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "x86_64-w64-mingw32\*"; DestDir: "C:\WinGCC\x86_64-w64-mingw32\"; Flags: ignoreversion recursesubdirs createallsubdirs

[Registry]
Root: HKLM; Subkey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"; \
    ValueType: expandsz; ValueName: "Path"; ValueData: "{olddata};C:\WinGCC\bin\;C:\WinGCC\x86_64-w64-mingw32\bin\"; \
    Check: NeedsAddPath(ExpandConstant('C:\WinGCC\bin\')); Flags: preservestringtype

[Code]
function NeedsAddPath(NewPath: string): boolean;
var
  OrigPath: string;
begin
  if not RegQueryStringValue(HKEY_LOCAL_MACHINE,
    'SYSTEM\CurrentControlSet\Control\Session Manager\Environment',
    'Path', OrigPath)
  then begin
    Result := True;
    exit;
  end;
  Result := Pos(';' + UpperCase(NewPath) + ';', ';' + UpperCase(OrigPath) + ';') = 0;
end;
