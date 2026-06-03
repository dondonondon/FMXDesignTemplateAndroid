unit BFA.Helper.SAF;

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  System.Generics.Collections
  {$IFDEF ANDROID}
  , Androidapi.JNI.Net
  , BFA.Android.SAF.Modern
  {$ENDIF}
  {$IFDEF IOS}
  , iOSapi.Foundation
  , BFA.iOS.SAF.Modern
  {$ENDIF}
  {$IFDEF MSWINDOWS}
  , Winapi.ActiveX
  , Winapi.ShlObj
  , Winapi.ShellAPI
  , Winapi.Windows
  , FMX.Dialogs
  {$ENDIF}
  ;

type
  TBFASAFPickMode = (safPickFile, safPickFolder, safSaveAs);
  TBFASAFItemType = (safItemUnknown, safItemFile, safItemFolder);

  TBFASAFUriEvent = procedure(Sender: TObject; const AUri: string) of object;
  TBFASAFErrorEvent = procedure(Sender: TObject; const AMessage: string) of object;
  TBFASAFCancelEvent = procedure(Sender: TObject; APickMode: TBFASAFPickMode) of object;

  TBFASAFItem = record
    Uri: string;
    DisplayName: string;
    MimeType: string;
    ItemType: TBFASAFItemType;
    Size: Int64;
    LastModified: Int64;
    Flags: Integer;
    function IsFolder: Boolean;
    function IsFile: Boolean;
  end;

  TBFASAFItems = TArray<TBFASAFItem>;

  TBFASAF = class
  private
    FCurrentUri: string;
    FOnFilePicked: TBFASAFUriEvent;
    FOnFolderPicked: TBFASAFUriEvent;
    FOnSaveAsPicked: TBFASAFUriEvent;
    FOnError: TBFASAFErrorEvent;
    FOnCancel: TBFASAFCancelEvent;

    {$IFDEF ANDROID}
    FAndroidSAF: TAndroidSAF;
    {$ENDIF}
    {$IFDEF IOS}
    FiOSSAF: TiOSSAF;
    {$ENDIF}

    procedure DoError(const AMessage: string);
    procedure DoCancel(APickMode: TBFASAFPickMode);
    class function UnsupportedMessage: string; static;

    {$IFDEF ANDROID}
    function FromAndroidUri(const AUri: JNet_Uri): string;
    function ToAndroidUri(const AUriText: string): JNet_Uri;
    function ConvertItemType(AItemType: BFA.Android.SAF.Modern.TSAFItemType): TBFASAFItemType;
    function ConvertPickMode(APickMode: BFA.Android.SAF.Modern.TSAFPickMode): TBFASAFPickMode;

    procedure AndroidFilePicked(Sender: TObject; const AUri: JNet_Uri);
    procedure AndroidFolderPicked(Sender: TObject; const AUri: JNet_Uri);
    procedure AndroidSaveAsPicked(Sender: TObject; const AUri: JNet_Uri);
    procedure AndroidError(Sender: TObject; const AMessage: string);
    procedure AndroidCancel(Sender: TObject; APickMode: BFA.Android.SAF.Modern.TSAFPickMode);
    {$ENDIF}

    {$IFDEF IOS}
    function FromiOSUri(const AUri: NSURL): string;
    function ToiOSUri(const AUriText: string): NSURL;
    function ConvertiOSItemType(AItemType: BFA.iOS.SAF.Modern.TiOSSAFItemType): TBFASAFItemType;
    function ConvertiOSPickMode(APickMode: BFA.iOS.SAF.Modern.TiOSSAFPickMode): TBFASAFPickMode;

    procedure iOSFilePicked(Sender: TObject; const AUri: NSURL);
    procedure iOSFolderPicked(Sender: TObject; const AUri: NSURL);
    procedure iOSSaveAsPicked(Sender: TObject; const AUri: NSURL);
    procedure iOSError(Sender: TObject; const AMessage: string);
    procedure iOSCancel(Sender: TObject; APickMode: BFA.iOS.SAF.Modern.TiOSSAFPickMode);
    {$ENDIF}

    {$IFDEF MSWINDOWS}
    function BuildWindowsItem(const APath: string): TBFASAFItem;
    function GetWindowsDownloadsPath: string;
    function MimeTypeToWindowsFilter(const AMimeType: string): string;
    function MimeTypesToWindowsFilter(const AMimeTypes: TArray<string>): string;
    function SelectWindowsFolder(out AFolderName: string): Boolean;
    function WindowsMimeTypeFromFileName(const AFileName: string): string;
    {$ENDIF}
  public
    constructor Create;
    destructor Destroy; override;

    class function IsSupported: Boolean; static;

    class function ImagePdfMimeTypes: TArray<string>; static;

    procedure PickFile(const AMimeType: string = '*/*'); overload;
    procedure PickFile(const AMimeTypes: TArray<string>); overload;
    procedure PickFolder;
    procedure SaveAs(const AFileName, AMimeType: string);

    function ReadText(const AUri: string; const AEncoding: TEncoding = nil): string;
    procedure WriteText(const AUri, AText: string; const AEncoding: TEncoding = nil; const AAppend: Boolean = False);

    function ReadBytes(const AUri: string): TBytes;
    procedure WriteBytes(const AUri: string; const AData: TBytes; const AAppend: Boolean = False);

    function CreateFileInFolder(const AFolderTreeUri, AFileName, AMimeType: string): string;
    function CreateFolderInFolder(const AFolderTreeUri, AFolderName: string): string;
    function ListFiles(const AFolderTreeUri: string): TBFASAFItems;
    function DeleteUri(const AUri: string): Boolean;
    function Exists(const AUri: string): Boolean;

    function HasPersistedPermission(const AUri: string): Boolean;
    function CanAccessFolder(const AFolderTreeUri: string): Boolean;
    function RestoreFolderPermission(const AUriText: string; out AUri: string): Boolean; overload;
    function RestoreFolderPermission(const AUriText: string): string; overload;

    function FindFileInFolder(const AFolderTreeUri, AFileName: string): string;

    function CopyToSharedDownloads(const AUri: string; const ATargetFileName: string = ''): string;
    function CopyToLocalFile(const ASourceUri, ATargetFileName: string): Boolean;

    procedure ShareUri(const AUri: string; const AChooserTitle: string = 'Share file');
    procedure TakePersistablePermission(const AUri: string; ARead, AWrite: Boolean);

    function GetDisplayName(const AUri: string): string;
    function GetMimeType(const AUri: string): string;

    property CurrentUri: string read FCurrentUri;

    property OnFilePicked: TBFASAFUriEvent read FOnFilePicked write FOnFilePicked;
    property OnFolderPicked: TBFASAFUriEvent read FOnFolderPicked write FOnFolderPicked;
    property OnSaveAsPicked: TBFASAFUriEvent read FOnSaveAsPicked write FOnSaveAsPicked;
    property OnError: TBFASAFErrorEvent read FOnError write FOnError;
    property OnCancel: TBFASAFCancelEvent read FOnCancel write FOnCancel;
  end;

implementation

{ TBFASAFItem }

function TBFASAFItem.IsFile: Boolean;
begin
  Result := ItemType = safItemFile;
end;

function TBFASAFItem.IsFolder: Boolean;
begin
  Result := ItemType = safItemFolder;
end;

{ TBFASAF }

constructor TBFASAF.Create;
begin
  inherited Create;

  {$IFDEF ANDROID}
  FAndroidSAF := TAndroidSAF.Create;
  FAndroidSAF.OnFilePicked := AndroidFilePicked;
  FAndroidSAF.OnFolderPicked := AndroidFolderPicked;
  FAndroidSAF.OnSaveAsPicked := AndroidSaveAsPicked;
  FAndroidSAF.OnError := AndroidError;
  FAndroidSAF.OnCancel := AndroidCancel;
  {$ENDIF}

  {$IFDEF IOS}
  FiOSSAF := TiOSSAF.Create;
  FiOSSAF.OnFilePicked := iOSFilePicked;
  FiOSSAF.OnFolderPicked := iOSFolderPicked;
  FiOSSAF.OnSaveAsPicked := iOSSaveAsPicked;
  FiOSSAF.OnError := iOSError;
  FiOSSAF.OnCancel := iOSCancel;
  {$ENDIF}
end;

destructor TBFASAF.Destroy;
begin
  {$IFDEF ANDROID}
  FAndroidSAF.Free;
  {$ENDIF}

  {$IFDEF IOS}
  FiOSSAF.Free;
  {$ENDIF}

  inherited;
end;

class function TBFASAF.IsSupported: Boolean;
begin
  {$IF DEFINED(ANDROID) OR DEFINED(MSWINDOWS) OR DEFINED(IOS)}
  Result := True;
  {$ELSE}
  Result := False;
  {$ENDIF}
end;

class function TBFASAF.ImagePdfMimeTypes: TArray<string>;
begin
  Result := TArray<string>.Create(
    'image/png',
    'image/jpeg',
    'application/pdf'
  );
end;

class function TBFASAF.UnsupportedMessage: string;
begin
  Result := 'File picker hanya didukung di Android, iOS, dan Windows.';
end;

procedure TBFASAF.DoCancel(APickMode: TBFASAFPickMode);
begin
  if Assigned(FOnCancel) then
    FOnCancel(Self, APickMode);
end;

procedure TBFASAF.DoError(const AMessage: string);
begin
  if Assigned(FOnError) then
    FOnError(Self, AMessage);
end;

procedure TBFASAF.PickFile(const AMimeType: string);
{$IFDEF MSWINDOWS}
var
  LDialog: TOpenDialog;
{$ENDIF}
begin
  {$IFDEF ANDROID}
  FAndroidSAF.PickFile(AMimeType);
  {$ELSEIF DEFINED(IOS)}
  FiOSSAF.PickFile(AMimeType);
  {$ELSEIF DEFINED(MSWINDOWS)}
  LDialog := TOpenDialog.Create(nil);
  try
    LDialog.Filter := MimeTypeToWindowsFilter(AMimeType);
    if LDialog.Execute then
    begin
      FCurrentUri := LDialog.FileName;
      if Assigned(FOnFilePicked) then
        FOnFilePicked(Self, FCurrentUri);
    end
    else
      DoCancel(safPickFile);
  finally
    LDialog.Free;
  end;
  {$ELSE}
  DoError(UnsupportedMessage);
  {$ENDIF}
end;

procedure TBFASAF.PickFile(const AMimeTypes: TArray<string>);
{$IFDEF MSWINDOWS}
var
  LDialog: TOpenDialog;
{$ENDIF}
begin
  {$IFDEF ANDROID}
  FAndroidSAF.PickFile(AMimeTypes);
  {$ELSEIF DEFINED(IOS)}
  FiOSSAF.PickFile(AMimeTypes);
  {$ELSEIF DEFINED(MSWINDOWS)}
  LDialog := TOpenDialog.Create(nil);
  try
    LDialog.Filter := MimeTypesToWindowsFilter(AMimeTypes);
    if LDialog.Execute then
    begin
      FCurrentUri := LDialog.FileName;
      if Assigned(FOnFilePicked) then
        FOnFilePicked(Self, FCurrentUri);
    end
    else
      DoCancel(safPickFile);
  finally
    LDialog.Free;
  end;
  {$ELSE}
  DoError(UnsupportedMessage);
  {$ENDIF}
end;

procedure TBFASAF.PickFolder;
{$IFDEF MSWINDOWS}
var
  LFolderName: string;
{$ENDIF}
begin
  {$IFDEF ANDROID}
  FAndroidSAF.PickFolder;
  {$ELSEIF DEFINED(IOS)}
  FiOSSAF.PickFolder;
  {$ELSEIF DEFINED(MSWINDOWS)}
  if SelectWindowsFolder(LFolderName) then
  begin
    FCurrentUri := LFolderName;
    if Assigned(FOnFolderPicked) then
      FOnFolderPicked(Self, FCurrentUri);
  end
  else
    DoCancel(safPickFolder);
  {$ELSE}
  DoError(UnsupportedMessage);
  {$ENDIF}
end;

procedure TBFASAF.SaveAs(const AFileName, AMimeType: string);
{$IFDEF MSWINDOWS}
var
  LDialog: TSaveDialog;
{$ENDIF}
begin
  {$IFDEF ANDROID}
  FAndroidSAF.SaveAs(AFileName, AMimeType);
  {$ELSEIF DEFINED(IOS)}
  FiOSSAF.SaveAs(AFileName, AMimeType);
  {$ELSEIF DEFINED(MSWINDOWS)}
  LDialog := TSaveDialog.Create(nil);
  try
    LDialog.FileName := AFileName;
    LDialog.Filter := MimeTypeToWindowsFilter(AMimeType);
    if LDialog.Execute then
    begin
      FCurrentUri := LDialog.FileName;
      if Assigned(FOnSaveAsPicked) then
        FOnSaveAsPicked(Self, FCurrentUri);
    end
    else
      DoCancel(safSaveAs);
  finally
    LDialog.Free;
  end;
  {$ELSE}
  DoError(UnsupportedMessage);
  {$ENDIF}
end;

function TBFASAF.ReadText(const AUri: string; const AEncoding: TEncoding): string;
{$IFDEF MSWINDOWS}
var
  LEncoding: TEncoding;
{$ENDIF}
begin
  {$IFDEF ANDROID}
  Result := FAndroidSAF.ReadText(ToAndroidUri(AUri), AEncoding);
  {$ELSEIF DEFINED(IOS)}
  Result := FiOSSAF.ReadText(ToiOSUri(AUri), AEncoding);
  {$ELSEIF DEFINED(MSWINDOWS)}
  if AEncoding <> nil then
    LEncoding := AEncoding
  else
    LEncoding := TEncoding.UTF8;

  Result := TFile.ReadAllText(AUri, LEncoding);
  {$ELSE}
  Result := '';
  DoError(UnsupportedMessage);
  {$ENDIF}
end;

procedure TBFASAF.WriteText(const AUri, AText: string; const AEncoding: TEncoding; const AAppend: Boolean);
{$IFDEF MSWINDOWS}
var
  LEncoding: TEncoding;
  LPath: string;
  LWriter: TStreamWriter;
{$ENDIF}
begin
  {$IFDEF ANDROID}
  FAndroidSAF.WriteText(ToAndroidUri(AUri), AText, AEncoding, AAppend);
  {$ELSEIF DEFINED(IOS)}
  FiOSSAF.WriteText(ToiOSUri(AUri), AText, AEncoding, AAppend);
  {$ELSEIF DEFINED(MSWINDOWS)}
  LPath := ExtractFilePath(AUri);
  if LPath <> '' then
    ForceDirectories(LPath);

  if AEncoding <> nil then
    LEncoding := AEncoding
  else
    LEncoding := TEncoding.UTF8;

  LWriter := TStreamWriter.Create(AUri, AAppend, LEncoding);
  try
    LWriter.Write(AText);
  finally
    LWriter.Free;
  end;
  {$ELSE}
  DoError(UnsupportedMessage);
  {$ENDIF}
end;

function TBFASAF.ReadBytes(const AUri: string): TBytes;
begin
  {$IFDEF ANDROID}
  Result := FAndroidSAF.ReadBytes(ToAndroidUri(AUri));
  {$ELSEIF DEFINED(IOS)}
  Result := FiOSSAF.ReadBytes(ToiOSUri(AUri));
  {$ELSEIF DEFINED(MSWINDOWS)}
  Result := TFile.ReadAllBytes(AUri);
  {$ELSE}
  SetLength(Result, 0);
  DoError(UnsupportedMessage);
  {$ENDIF}
end;

procedure TBFASAF.WriteBytes(const AUri: string; const AData: TBytes; const AAppend: Boolean);
{$IFDEF MSWINDOWS}
var
  LMode: Word;
  LPath: string;
  LStream: TFileStream;
{$ENDIF}
begin
  {$IFDEF ANDROID}
  FAndroidSAF.WriteBytes(ToAndroidUri(AUri), AData, AAppend);
  {$ELSEIF DEFINED(IOS)}
  FiOSSAF.WriteBytes(ToiOSUri(AUri), AData, AAppend);
  {$ELSEIF DEFINED(MSWINDOWS)}
  LPath := ExtractFilePath(AUri);
  if LPath <> '' then
    ForceDirectories(LPath);

  if AAppend and TFile.Exists(AUri) then
    LMode := fmOpenReadWrite
  else
    LMode := fmCreate;

  LStream := TFileStream.Create(AUri, LMode);
  try
    if AAppend then
      LStream.Position := LStream.Size;

    if Length(AData) > 0 then
      LStream.WriteBuffer(AData[0], Length(AData));
  finally
    LStream.Free;
  end;
  {$ELSE}
  DoError(UnsupportedMessage);
  {$ENDIF}
end;

function TBFASAF.CreateFileInFolder(const AFolderTreeUri, AFileName, AMimeType: string): string;
{$IFDEF MSWINDOWS}
var
  LEmpty: TBytes;
{$ENDIF}
begin
  {$IFDEF ANDROID}
  Result := FromAndroidUri(FAndroidSAF.CreateFileInFolder(ToAndroidUri(AFolderTreeUri), AFileName, AMimeType));
  {$ELSEIF DEFINED(IOS)}
  Result := FromiOSUri(FiOSSAF.CreateFileInFolder(ToiOSUri(AFolderTreeUri), AFileName, AMimeType));
  {$ELSEIF DEFINED(MSWINDOWS)}
  Result := TPath.Combine(AFolderTreeUri, AFileName);
  ForceDirectories(AFolderTreeUri);
  if not TFile.Exists(Result) then
  begin
    SetLength(LEmpty, 0);
    TFile.WriteAllBytes(Result, LEmpty);
  end;
  {$ELSE}
  Result := '';
  DoError(UnsupportedMessage);
  {$ENDIF}
end;

function TBFASAF.CreateFolderInFolder(const AFolderTreeUri, AFolderName: string): string;
begin
  {$IFDEF ANDROID}
  Result := FromAndroidUri(FAndroidSAF.CreateFolderInFolder(ToAndroidUri(AFolderTreeUri), AFolderName));
  {$ELSEIF DEFINED(IOS)}
  Result := FromiOSUri(FiOSSAF.CreateFolderInFolder(ToiOSUri(AFolderTreeUri), AFolderName));
  {$ELSEIF DEFINED(MSWINDOWS)}
  Result := TPath.Combine(AFolderTreeUri, AFolderName);
  ForceDirectories(Result);
  {$ELSE}
  Result := '';
  DoError(UnsupportedMessage);
  {$ENDIF}
end;

function TBFASAF.ListFiles(const AFolderTreeUri: string): TBFASAFItems;
{$IFDEF ANDROID}
var
  LItems: BFA.Android.SAF.Modern.TSAFItems;
  I: Integer;
{$ENDIF}
{$IFDEF IOS}
var
  LItems: BFA.iOS.SAF.Modern.TiOSSAFItems;
  I: Integer;
{$ENDIF}
{$IFDEF MSWINDOWS}
var
  LItemPath: string;
  LList: TList<TBFASAFItem>;
{$ENDIF}
begin
  SetLength(Result, 0);

  {$IFDEF ANDROID}
  LItems := FAndroidSAF.ListFiles(ToAndroidUri(AFolderTreeUri));
  SetLength(Result, Length(LItems));
  for I := 0 to High(LItems) do
  begin
    Result[I].Uri := FromAndroidUri(LItems[I].Uri);
    Result[I].DisplayName := LItems[I].DisplayName;
    Result[I].MimeType := LItems[I].MimeType;
    Result[I].ItemType := ConvertItemType(LItems[I].ItemType);
    Result[I].Size := LItems[I].Size;
    Result[I].LastModified := LItems[I].LastModified;
    Result[I].Flags := LItems[I].Flags;
  end;
  {$ELSEIF DEFINED(IOS)}
  LItems := FiOSSAF.ListFiles(ToiOSUri(AFolderTreeUri));
  SetLength(Result, Length(LItems));
  for I := 0 to High(LItems) do
  begin
    Result[I].Uri := FromiOSUri(LItems[I].Uri);
    Result[I].DisplayName := LItems[I].DisplayName;
    Result[I].MimeType := LItems[I].MimeType;
    Result[I].ItemType := ConvertiOSItemType(LItems[I].ItemType);
    Result[I].Size := LItems[I].Size;
    Result[I].LastModified := LItems[I].LastModified;
    Result[I].Flags := LItems[I].Flags;
  end;
  {$ELSEIF DEFINED(MSWINDOWS)}
  if not TDirectory.Exists(AFolderTreeUri) then
    Exit;

  LList := TList<TBFASAFItem>.Create;
  try
    for LItemPath in TDirectory.GetDirectories(AFolderTreeUri) do
      LList.Add(BuildWindowsItem(LItemPath));

    for LItemPath in TDirectory.GetFiles(AFolderTreeUri) do
      LList.Add(BuildWindowsItem(LItemPath));

    Result := LList.ToArray;
  finally
    LList.Free;
  end;
  {$ELSE}
  DoError(UnsupportedMessage);
  {$ENDIF}
end;

function TBFASAF.DeleteUri(const AUri: string): Boolean;
begin
  {$IFDEF ANDROID}
  Result := FAndroidSAF.DeleteUri(ToAndroidUri(AUri));
  {$ELSEIF DEFINED(IOS)}
  Result := FiOSSAF.DeleteUri(ToiOSUri(AUri));
  {$ELSEIF DEFINED(MSWINDOWS)}
  Result := True;
  try
    if TDirectory.Exists(AUri) then
      TDirectory.Delete(AUri, True)
    else if TFile.Exists(AUri) then
      TFile.Delete(AUri)
    else
      Result := False;
  except
    Result := False;
  end;
  {$ELSE}
  Result := False;
  DoError(UnsupportedMessage);
  {$ENDIF}
end;

function TBFASAF.Exists(const AUri: string): Boolean;
begin
  {$IFDEF ANDROID}
  Result := FAndroidSAF.Exists(ToAndroidUri(AUri));
  {$ELSEIF DEFINED(IOS)}
  Result := FiOSSAF.Exists(ToiOSUri(AUri));
  {$ELSEIF DEFINED(MSWINDOWS)}
  Result := TFile.Exists(AUri) or TDirectory.Exists(AUri);
  {$ELSE}
  Result := False;
  {$ENDIF}
end;

function TBFASAF.HasPersistedPermission(const AUri: string): Boolean;
begin
  {$IFDEF ANDROID}
  Result := FAndroidSAF.HasPersistedPermission(ToAndroidUri(AUri));
  {$ELSEIF DEFINED(IOS)}
  Result := FiOSSAF.HasPersistedPermission(ToiOSUri(AUri));
  {$ELSEIF DEFINED(MSWINDOWS)}
  Result := Exists(AUri);
  {$ELSE}
  Result := False;
  {$ENDIF}
end;

function TBFASAF.CanAccessFolder(const AFolderTreeUri: string): Boolean;
begin
  {$IFDEF ANDROID}
  Result := FAndroidSAF.CanAccessFolder(ToAndroidUri(AFolderTreeUri));
  {$ELSEIF DEFINED(IOS)}
  Result := FiOSSAF.CanAccessFolder(ToiOSUri(AFolderTreeUri));
  {$ELSEIF DEFINED(MSWINDOWS)}
  Result := False;
  if not TDirectory.Exists(AFolderTreeUri) then
    Exit;

  try
    TDirectory.GetFileSystemEntries(AFolderTreeUri);
    Result := True;
  except
    Result := False;
  end;
  {$ELSE}
  Result := False;
  {$ENDIF}
end;

function TBFASAF.RestoreFolderPermission(const AUriText: string; out AUri: string): Boolean;
{$IFDEF ANDROID}
var
  LUri: JNet_Uri;
{$ENDIF}
{$IFDEF IOS}
var
  LUri: NSURL;
{$ENDIF}
begin
  AUri := '';

  {$IFDEF ANDROID}
  Result := FAndroidSAF.RestoreFolderPermission(AUriText, LUri);
  if Result then
    AUri := FromAndroidUri(LUri);
  {$ELSEIF DEFINED(IOS)}
  Result := FiOSSAF.RestoreFolderPermission(AUriText, LUri);
  if Result then
    AUri := FromiOSUri(LUri);
  {$ELSEIF DEFINED(MSWINDOWS)}
  Result := TDirectory.Exists(AUriText);
  if Result then
    AUri := AUriText;
  {$ELSE}
  Result := False;
  {$ENDIF}
end;

function TBFASAF.RestoreFolderPermission(const AUriText: string): string;
begin
  if not RestoreFolderPermission(AUriText, Result) then
    Result := '';
end;

function TBFASAF.FindFileInFolder(const AFolderTreeUri, AFileName: string): string;
begin
  {$IFDEF ANDROID}
  Result := FromAndroidUri(FAndroidSAF.FindFileInFolder(ToAndroidUri(AFolderTreeUri), AFileName));
  {$ELSEIF DEFINED(IOS)}
  Result := FromiOSUri(FiOSSAF.FindFileInFolder(ToiOSUri(AFolderTreeUri), AFileName));
  {$ELSEIF DEFINED(MSWINDOWS)}
  Result := TPath.Combine(AFolderTreeUri, AFileName);
  if not Exists(Result) then
    Result := '';
  {$ELSE}
  Result := '';
  {$ENDIF}
end;

function TBFASAF.CopyToSharedDownloads(const AUri, ATargetFileName: string): string;
{$IFDEF MSWINDOWS}
var
  LTargetName: string;
{$ENDIF}
begin
  {$IFDEF ANDROID}
  Result := FAndroidSAF.CopyToSharedDownloads(ToAndroidUri(AUri), ATargetFileName);
  {$ELSEIF DEFINED(IOS)}
  Result := FiOSSAF.CopyToSharedDownloads(ToiOSUri(AUri), ATargetFileName);
  {$ELSEIF DEFINED(MSWINDOWS)}
  if ATargetFileName.Trim <> '' then
    LTargetName := ATargetFileName
  else
    LTargetName := TPath.GetFileName(AUri);

  Result := TPath.Combine(GetWindowsDownloadsPath, LTargetName);
  ForceDirectories(ExtractFilePath(Result));
  TFile.Copy(AUri, Result, True);
  {$ELSE}
  Result := '';
  DoError(UnsupportedMessage);
  {$ENDIF}
end;

function TBFASAF.CopyToLocalFile(const ASourceUri, ATargetFileName: string): Boolean;
begin
  {$IFDEF ANDROID}
  Result := FAndroidSAF.CopyToLocalFile(ToAndroidUri(ASourceUri), ATargetFileName);
  {$ELSEIF DEFINED(IOS)}
  Result := FiOSSAF.CopyToLocalFile(ToiOSUri(ASourceUri), ATargetFileName);
  {$ELSEIF DEFINED(MSWINDOWS)}
  Result := False;
  if (ASourceUri.Trim = '') or (ATargetFileName.Trim = '') or (not TFile.Exists(ASourceUri)) then
    Exit;

  if ExtractFilePath(ATargetFileName) <> '' then
    ForceDirectories(ExtractFilePath(ATargetFileName));
  TFile.Copy(ASourceUri, ATargetFileName, True);
  Result := True;
  {$ELSE}
  Result := False;
  DoError(UnsupportedMessage);
  {$ENDIF}
end;

procedure TBFASAF.ShareUri(const AUri, AChooserTitle: string);
begin
  {$IFDEF ANDROID}
  FAndroidSAF.ShareUri(ToAndroidUri(AUri), AChooserTitle);
  {$ELSEIF DEFINED(IOS)}
  FiOSSAF.ShareUri(ToiOSUri(AUri), AChooserTitle);
  {$ELSEIF DEFINED(MSWINDOWS)}
  ShellExecute(0, 'open', PChar(AUri), nil, nil, SW_SHOWNORMAL);
  {$ELSE}
  DoError(UnsupportedMessage);
  {$ENDIF}
end;

procedure TBFASAF.TakePersistablePermission(const AUri: string; ARead, AWrite: Boolean);
begin
  {$IFDEF ANDROID}
  FAndroidSAF.TakePersistablePermission(ToAndroidUri(AUri), ARead, AWrite);
  {$ELSEIF DEFINED(IOS)}
  { iOS uses security-scoped URLs while each operation is running. }
  {$ENDIF}
end;

function TBFASAF.GetDisplayName(const AUri: string): string;
begin
  {$IFDEF ANDROID}
  Result := FAndroidSAF.GetDisplayName(ToAndroidUri(AUri));
  {$ELSEIF DEFINED(IOS)}
  Result := FiOSSAF.GetDisplayName(ToiOSUri(AUri));
  {$ELSEIF DEFINED(MSWINDOWS)}
  Result := TPath.GetFileName(AUri);
  if Result = '' then
    Result := TPath.GetFileName(ExcludeTrailingPathDelimiter(AUri));
  {$ELSE}
  Result := '';
  {$ENDIF}
end;

function TBFASAF.GetMimeType(const AUri: string): string;
begin
  {$IFDEF ANDROID}
  Result := FAndroidSAF.GetMimeType(ToAndroidUri(AUri));
  {$ELSEIF DEFINED(IOS)}
  Result := FiOSSAF.GetMimeType(ToiOSUri(AUri));
  {$ELSEIF DEFINED(MSWINDOWS)}
  Result := WindowsMimeTypeFromFileName(AUri);
  {$ELSE}
  Result := '';
  {$ENDIF}
end;

{$IFDEF ANDROID}
function TBFASAF.FromAndroidUri(const AUri: JNet_Uri): string;
begin
  Result := FAndroidSAF.UriToString(AUri);
end;

function TBFASAF.ToAndroidUri(const AUriText: string): JNet_Uri;
begin
  Result := FAndroidSAF.StringToUri(AUriText);
end;

function TBFASAF.ConvertItemType(AItemType: BFA.Android.SAF.Modern.TSAFItemType): TBFASAFItemType;
begin
  case Ord(AItemType) of
    1: Result := safItemFile;
    2: Result := safItemFolder;
  else
    Result := safItemUnknown;
  end;
end;

function TBFASAF.ConvertPickMode(APickMode: BFA.Android.SAF.Modern.TSAFPickMode): TBFASAFPickMode;
begin
  case Ord(APickMode) of
    1: Result := safPickFolder;
    2: Result := safSaveAs;
  else
    Result := safPickFile;
  end;
end;

procedure TBFASAF.AndroidFilePicked(Sender: TObject; const AUri: JNet_Uri);
begin
  FCurrentUri := FromAndroidUri(AUri);
  if Assigned(FOnFilePicked) then
    FOnFilePicked(Self, FCurrentUri);
end;

procedure TBFASAF.AndroidFolderPicked(Sender: TObject; const AUri: JNet_Uri);
begin
  FCurrentUri := FromAndroidUri(AUri);
  if Assigned(FOnFolderPicked) then
    FOnFolderPicked(Self, FCurrentUri);
end;

procedure TBFASAF.AndroidSaveAsPicked(Sender: TObject; const AUri: JNet_Uri);
begin
  FCurrentUri := FromAndroidUri(AUri);
  if Assigned(FOnSaveAsPicked) then
    FOnSaveAsPicked(Self, FCurrentUri);
end;

procedure TBFASAF.AndroidError(Sender: TObject; const AMessage: string);
begin
  DoError(AMessage);
end;

procedure TBFASAF.AndroidCancel(Sender: TObject; APickMode: BFA.Android.SAF.Modern.TSAFPickMode);
begin
  DoCancel(ConvertPickMode(APickMode));
end;
{$ENDIF}

{$IFDEF IOS}
function TBFASAF.FromiOSUri(const AUri: NSURL): string;
begin
  Result := FiOSSAF.UriToString(AUri);
end;

function TBFASAF.ToiOSUri(const AUriText: string): NSURL;
begin
  Result := FiOSSAF.StringToUri(AUriText);
end;

function TBFASAF.ConvertiOSItemType(AItemType: BFA.iOS.SAF.Modern.TiOSSAFItemType): TBFASAFItemType;
begin
  case Ord(AItemType) of
    1: Result := safItemFile;
    2: Result := safItemFolder;
  else
    Result := safItemUnknown;
  end;
end;

function TBFASAF.ConvertiOSPickMode(APickMode: BFA.iOS.SAF.Modern.TiOSSAFPickMode): TBFASAFPickMode;
begin
  case Ord(APickMode) of
    1: Result := safPickFolder;
    2: Result := safSaveAs;
  else
    Result := safPickFile;
  end;
end;

procedure TBFASAF.iOSFilePicked(Sender: TObject; const AUri: NSURL);
begin
  FCurrentUri := FromiOSUri(AUri);
  if Assigned(FOnFilePicked) then
    FOnFilePicked(Self, FCurrentUri);
end;

procedure TBFASAF.iOSFolderPicked(Sender: TObject; const AUri: NSURL);
begin
  FCurrentUri := FromiOSUri(AUri);
  if Assigned(FOnFolderPicked) then
    FOnFolderPicked(Self, FCurrentUri);
end;

procedure TBFASAF.iOSSaveAsPicked(Sender: TObject; const AUri: NSURL);
begin
  FCurrentUri := FromiOSUri(AUri);
  if Assigned(FOnSaveAsPicked) then
    FOnSaveAsPicked(Self, FCurrentUri);
end;

procedure TBFASAF.iOSError(Sender: TObject; const AMessage: string);
begin
  DoError(AMessage);
end;

procedure TBFASAF.iOSCancel(Sender: TObject; APickMode: BFA.iOS.SAF.Modern.TiOSSAFPickMode);
begin
  DoCancel(ConvertiOSPickMode(APickMode));
end;
{$ENDIF}

{$IFDEF MSWINDOWS}
function TBFASAF.BuildWindowsItem(const APath: string): TBFASAFItem;
var
  LModified: TDateTime;
begin
  Result.Uri := APath;
  Result.DisplayName := GetDisplayName(APath);
  Result.MimeType := WindowsMimeTypeFromFileName(APath);
  Result.Size := -1;
  Result.LastModified := -1;
  Result.Flags := 0;

  if TDirectory.Exists(APath) then
  begin
    Result.ItemType := safItemFolder;
    LModified := TDirectory.GetLastWriteTime(APath);
  end
  else if TFile.Exists(APath) then
  begin
    Result.ItemType := safItemFile;
    Result.Size := TFile.GetSize(APath);
    LModified := TFile.GetLastWriteTime(APath);
  end
  else
  begin
    Result.ItemType := safItemUnknown;
    LModified := 0;
  end;

  if LModified > 0 then
    Result.LastModified := Round((LModified - 25569) * 86400000);
end;

function TBFASAF.GetWindowsDownloadsPath: string;
begin
  Result := TPath.Combine(TPath.GetHomePath, 'Downloads');
  if not TDirectory.Exists(Result) then
    Result := TPath.GetDocumentsPath;
end;

function TBFASAF.MimeTypeToWindowsFilter(const AMimeType: string): string;
begin
  if SameText(AMimeType, 'text/plain') then
    Result := 'Text files (*.txt)|*.txt|All files (*.*)|*.*'
  else if SameText(AMimeType, 'application/json') then
    Result := 'JSON files (*.json)|*.json|All files (*.*)|*.*'
  else if SameText(AMimeType, 'application/pdf') then
    Result := 'PDF files (*.pdf)|*.pdf|All files (*.*)|*.*'
  else if SameText(AMimeType, 'image/*') then
    Result := 'Image files (*.bmp;*.gif;*.jpg;*.jpeg;*.png;*.webp)|*.bmp;*.gif;*.jpg;*.jpeg;*.png;*.webp|All files (*.*)|*.*'
  else if SameText(AMimeType, 'application/vnd.ms-excel') or
          SameText(AMimeType, 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet') then
    Result := 'Excel files (*.xls;*.xlsx)|*.xls;*.xlsx|All files (*.*)|*.*'
  else
    Result := 'All files (*.*)|*.*';
end;

function TBFASAF.MimeTypesToWindowsFilter(const AMimeTypes: TArray<string>): string;
var
  LHasPng: Boolean;
  LHasJpeg: Boolean;
  LHasPdf: Boolean;
  LMimeType: string;
begin
  LHasPng := False;
  LHasJpeg := False;
  LHasPdf := False;

  for LMimeType in AMimeTypes do
  begin
    LHasPng := LHasPng or SameText(LMimeType, 'image/png');
    LHasJpeg := LHasJpeg or SameText(LMimeType, 'image/jpeg') or SameText(LMimeType, 'image/jpg');
    LHasPdf := LHasPdf or SameText(LMimeType, 'application/pdf');
  end;

  if LHasPng and LHasJpeg and LHasPdf then
    Result := 'Images and PDF (*.png;*.jpg;*.jpeg;*.pdf)|*.png;*.jpg;*.jpeg;*.pdf|Image files (*.png;*.jpg;*.jpeg)|*.png;*.jpg;*.jpeg|PDF files (*.pdf)|*.pdf'
  else if LHasPng and LHasJpeg then
    Result := 'Image files (*.png;*.jpg;*.jpeg)|*.png;*.jpg;*.jpeg'
  else if LHasPdf then
    Result := 'PDF files (*.pdf)|*.pdf'
  else if Length(AMimeTypes) = 1 then
    Result := MimeTypeToWindowsFilter(AMimeTypes[0])
  else
    Result := 'All files (*.*)|*.*';
end;

function TBFASAF.SelectWindowsFolder(out AFolderName: string): Boolean;
var
  LBrowseInfo: TBrowseInfo;
  LCoInit: HRESULT;
  LItemIdList: PItemIDList;
  LMalloc: IMalloc;
  LPath: array[0..MAX_PATH] of Char;
begin
  Result := False;
  AFolderName := '';
  FillChar(LBrowseInfo, SizeOf(LBrowseInfo), 0);
  FillChar(LPath, SizeOf(LPath), 0);

  LCoInit := CoInitializeEx(nil, COINIT_APARTMENTTHREADED);
  try
    LBrowseInfo.ulFlags := BIF_RETURNONLYFSDIRS or BIF_NEWDIALOGSTYLE or BIF_EDITBOX;
    LBrowseInfo.lpszTitle := 'Pilih folder';

    LItemIdList := SHBrowseForFolder(LBrowseInfo);
    if LItemIdList = nil then
      Exit;

    try
      if SHGetPathFromIDList(LItemIdList, LPath) then
      begin
        AFolderName := LPath;
        Result := AFolderName <> '';
      end;
    finally
      if Succeeded(SHGetMalloc(LMalloc)) and (LMalloc <> nil) then
        LMalloc.Free(LItemIdList);
    end;
  finally
    if Succeeded(LCoInit) then
      CoUninitialize;
  end;
end;

function TBFASAF.WindowsMimeTypeFromFileName(const AFileName: string): string;
var
  LExt: string;
begin
  if TDirectory.Exists(AFileName) then
    Exit('vnd.android.document/directory');

  LExt := AnsiLowerCase(TPath.GetExtension(AFileName));
  if LExt = '.txt' then
    Result := 'text/plain'
  else if LExt = '.json' then
    Result := 'application/json'
  else if LExt = '.pdf' then
    Result := 'application/pdf'
  else if (LExt = '.jpg') or (LExt = '.jpeg') then
    Result := 'image/jpeg'
  else if LExt = '.png' then
    Result := 'image/png'
  else if LExt = '.bmp' then
    Result := 'image/bmp'
  else if LExt = '.gif' then
    Result := 'image/gif'
  else if LExt = '.csv' then
    Result := 'text/csv'
  else if LExt = '.xls' then
    Result := 'application/vnd.ms-excel'
  else if LExt = '.xlsx' then
    Result := 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
  else
    Result := 'application/octet-stream';
end;
{$ENDIF}

end.
