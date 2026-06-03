unit BFA.iOS.SAF.Modern;

interface

{$IFDEF IOS}

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  System.Generics.Collections,
  Macapi.Helpers,
  Macapi.ObjectiveC,
  iOSapi.CocoaTypes,
  iOSapi.Foundation,
  iOSapi.UIKit;

type
  TiOSSAFPickMode = (pmFile, pmFolder, pmSaveAs);

  TiOSSAFUriEvent = procedure(Sender: TObject; const AUri: NSURL) of object;
  TiOSSAFErrorEvent = procedure(Sender: TObject; const AMessage: string) of object;
  TiOSSAFCancelEvent = procedure(Sender: TObject; APickMode: TiOSSAFPickMode) of object;

  TiOSSAFItemType = (sitUnknown, sitFile, sitFolder);

  TiOSSAFItem = record
    Uri: NSURL;
    DisplayName: string;
    MimeType: string;
    ItemType: TiOSSAFItemType;
    Size: Int64;
    LastModified: Int64;
    Flags: Integer;
    function IsFolder: Boolean;
    function IsFile: Boolean;
  end;

  TiOSSAFItems = TArray<TiOSSAFItem>;

  TiOSSAF = class;

  TiOSSAFDocumentPickerDelegate = class(TOCLocal, UIDocumentPickerDelegate)
  private
    FOwner: TiOSSAF;
  public
    constructor Create(const AOwner: TiOSSAF);

    procedure documentPicker(controller: UIDocumentPickerViewController; didPickDocumentsAtURLs: NSArray); overload; cdecl;
    procedure documentPicker(controller: UIDocumentPickerViewController; didPickDocumentAtURL: NSURL); overload; cdecl;
    procedure documentPickerWasCancelled(controller: UIDocumentPickerViewController); cdecl;
  end;

  TiOSSAF = class
  private
    FCurrentUri: NSURL;
    FDocumentPicker: UIDocumentPickerViewController;
    FDocumentPickerDelegate: TiOSSAFDocumentPickerDelegate;
    FLastPickMode: TiOSSAFPickMode;
    FLastMimeType: string;
    FLastFileName: string;
    FLastExportFileName: string;

    FOnFilePicked: TiOSSAFUriEvent;
    FOnFolderPicked: TiOSSAFUriEvent;
    FOnSaveAsPicked: TiOSSAFUriEvent;
    FOnError: TiOSSAFErrorEvent;
    FOnCancel: TiOSSAFCancelEvent;

    procedure DoError(const AMessage: string);
    procedure DoCancel(APickMode: TiOSSAFPickMode);
    procedure DoPicked(const AUri: NSURL);

    function BeginAccess(const AUri: NSURL): Boolean;
    procedure EndAccess(const AUri: NSURL; AAccessing: Boolean);
    function BuildAllowedTypes(const AMimeType: string): NSArray; overload;
    function BuildAllowedTypes(const AMimeTypes: TArray<string>): NSArray; overload;
    function BuildOpenPicker(const AMimeType: string): UIDocumentPickerViewController; overload;
    function BuildOpenPicker(const AMimeTypes: TArray<string>): UIDocumentPickerViewController; overload;
    function BuildFolderPicker: UIDocumentPickerViewController;
    function BuildSaveAsPicker(const AFileName, AMimeType: string): UIDocumentPickerViewController;
    function BuildSingleStringArray(const AValue: string): NSArray;
    function BuildStringArray(const AValues: TArray<string>): NSArray;
    function BuildSingleUrlArray(const AUri: NSURL): NSArray;
    function CreateTempExportFile(const AFileName: string): NSURL;
    function FileURLToPath(const AUri: NSURL): string;
    function InternalReadBytes(const AUri: NSURL): TBytes;
    procedure InternalWriteBytes(const AUri: NSURL; const AData: TBytes; const AAppend: Boolean = False);
    function MimeTypeFromFileName(const AFileName: string): string;
    procedure PresentPicker(const APicker: UIDocumentPickerViewController);
    function QuerySingleItem(const AUri: NSURL): TiOSSAFItem;
    function UTIForMimeType(const AMimeType: string): string;
  public
    constructor Create;
    destructor Destroy; override;

    procedure PickFile(const AMimeType: string = '*/*'); overload;
    procedure PickFile(const AMimeTypes: TArray<string>); overload;
    procedure PickFolder;
    procedure SaveAs(const AFileName, AMimeType: string);

    function ReadText(const AUri: NSURL; const AEncoding: TEncoding = nil): string;
    procedure WriteText(const AUri: NSURL; const AText: string; const AEncoding: TEncoding = nil; const AAppend: Boolean = False);

    function ReadBytes(const AUri: NSURL): TBytes;
    procedure WriteBytes(const AUri: NSURL; const AData: TBytes; const AAppend: Boolean = False);

    function CreateFileInFolder(const AFolderUri: NSURL; const AFileName, AMimeType: string): NSURL;
    function CreateFolderInFolder(const AFolderUri: NSURL; const AFolderName: string): NSURL;
    function ListFiles(const AFolderUri: NSURL): TiOSSAFItems;
    function DeleteUri(const AUri: NSURL): Boolean;
    function Exists(const AUri: NSURL): Boolean;

    function HasPersistedPermission(const AUri: NSURL): Boolean;
    function CanAccessFolder(const AFolderUri: NSURL): Boolean;
    function RestoreFolderPermission(const AUriText: string; out AUri: NSURL): Boolean; overload;
    function RestoreFolderPermission(const AUriText: string): NSURL; overload;

    function FindFileInFolder(const AFolderUri: NSURL; const AFileName: string): NSURL;

    function CopyToSharedDownloads(const AUri: NSURL; const ATargetFileName: string = ''): string;
    function CopyToLocalFile(const ASourceUri: NSURL; const ATargetFileName: string): Boolean;

    procedure ShareUri(const AUri: NSURL; const AChooserTitle: string = 'Share file');

    function GetDisplayName(const AUri: NSURL): string;
    function GetMimeType(const AUri: NSURL): string;
    function UriToString(const AUri: NSURL): string;
    function StringToUri(const AValue: string): NSURL;

    property CurrentUri: NSURL read FCurrentUri;

    property OnFilePicked: TiOSSAFUriEvent read FOnFilePicked write FOnFilePicked;
    property OnFolderPicked: TiOSSAFUriEvent read FOnFolderPicked write FOnFolderPicked;
    property OnSaveAsPicked: TiOSSAFUriEvent read FOnSaveAsPicked write FOnSaveAsPicked;
    property OnError: TiOSSAFErrorEvent read FOnError write FOnError;
    property OnCancel: TiOSSAFCancelEvent read FOnCancel write FOnCancel;
  end;

{$ENDIF}

implementation

{$IFDEF IOS}

uses
  FMX.Helpers.iOS;

{ TiOSSAFItem }

function TiOSSAFItem.IsFile: Boolean;
begin
  Result := ItemType = sitFile;
end;

function TiOSSAFItem.IsFolder: Boolean;
begin
  Result := ItemType = sitFolder;
end;

{ TiOSSAFDocumentPickerDelegate }

constructor TiOSSAFDocumentPickerDelegate.Create(const AOwner: TiOSSAF);
begin
  inherited Create;
  FOwner := AOwner;
end;

procedure TiOSSAFDocumentPickerDelegate.documentPicker(controller: UIDocumentPickerViewController;
  didPickDocumentAtURL: NSURL);
begin
  if FOwner <> nil then
    FOwner.DoPicked(didPickDocumentAtURL);
end;

procedure TiOSSAFDocumentPickerDelegate.documentPicker(controller: UIDocumentPickerViewController;
  didPickDocumentsAtURLs: NSArray);
var
  LUrl: NSURL;
begin
  if (FOwner <> nil) and (didPickDocumentsAtURLs <> nil) and (didPickDocumentsAtURLs.count > 0) then
  begin
    LUrl := TNSURL.Wrap(didPickDocumentsAtURLs.objectAtIndex(0));
    FOwner.DoPicked(LUrl);
  end;
end;

procedure TiOSSAFDocumentPickerDelegate.documentPickerWasCancelled(controller: UIDocumentPickerViewController);
begin
  if FOwner <> nil then
    FOwner.DoCancel(FOwner.FLastPickMode);
end;

{ TiOSSAF }

constructor TiOSSAF.Create;
begin
  inherited Create;
  FDocumentPickerDelegate := TiOSSAFDocumentPickerDelegate.Create(Self);
end;

destructor TiOSSAF.Destroy;
begin
  if FDocumentPicker <> nil then
  begin
    FDocumentPicker.setDelegate(nil);
    FDocumentPicker.release;
  end;

  FDocumentPickerDelegate.Free;
  inherited;
end;

function TiOSSAF.BeginAccess(const AUri: NSURL): Boolean;
begin
  Result := False;
  if AUri <> nil then
    Result := AUri.startAccessingSecurityScopedResource;
end;

procedure TiOSSAF.EndAccess(const AUri: NSURL; AAccessing: Boolean);
begin
  if AAccessing and (AUri <> nil) then
    AUri.stopAccessingSecurityScopedResource;
end;

function TiOSSAF.BuildAllowedTypes(const AMimeType: string): NSArray;
begin
  Result := BuildSingleStringArray(UTIForMimeType(AMimeType));
end;

function TiOSSAF.BuildAllowedTypes(const AMimeTypes: TArray<string>): NSArray;
var
  LUTIs: TArray<string>;
  I: Integer;
begin
  if Length(AMimeTypes) = 0 then
    Exit(BuildAllowedTypes('*/*'));

  SetLength(LUTIs, Length(AMimeTypes));
  for I := 0 to High(AMimeTypes) do
    LUTIs[I] := UTIForMimeType(AMimeTypes[I]);

  Result := BuildStringArray(LUTIs);
end;

function TiOSSAF.BuildFolderPicker: UIDocumentPickerViewController;
begin
  Result := TUIDocumentPickerViewController.Wrap(
    TUIDocumentPickerViewController.Alloc.initWithDocumentTypes(
      BuildSingleStringArray('public.folder'),
      UIDocumentPickerModeOpen
    )
  );
end;

function TiOSSAF.BuildOpenPicker(const AMimeType: string): UIDocumentPickerViewController;
begin
  Result := TUIDocumentPickerViewController.Wrap(
    TUIDocumentPickerViewController.Alloc.initWithDocumentTypes(
      BuildAllowedTypes(AMimeType),
      UIDocumentPickerModeOpen
    )
  );
end;

function TiOSSAF.BuildOpenPicker(const AMimeTypes: TArray<string>): UIDocumentPickerViewController;
begin
  Result := TUIDocumentPickerViewController.Wrap(
    TUIDocumentPickerViewController.Alloc.initWithDocumentTypes(
      BuildAllowedTypes(AMimeTypes),
      UIDocumentPickerModeOpen
    )
  );
end;

function TiOSSAF.BuildSaveAsPicker(const AFileName, AMimeType: string): UIDocumentPickerViewController;
var
  LExportUrl: NSURL;
begin
  LExportUrl := CreateTempExportFile(AFileName);
  Result := TUIDocumentPickerViewController.Wrap(
    TUIDocumentPickerViewController.Alloc.initForExportingURLs(
      BuildSingleUrlArray(LExportUrl),
      True
    )
  );
end;

function TiOSSAF.BuildSingleStringArray(const AValue: string): NSArray;
begin
  Result := TNSArray.Wrap(TNSArray.OCClass.arrayWithObject(NSObjectToID(StrToNSStr(AValue))));
end;

function TiOSSAF.BuildStringArray(const AValues: TArray<string>): NSArray;
var
  LObjects: TArray<Pointer>;
  I: Integer;
begin
  if Length(AValues) = 0 then
    Exit(BuildSingleStringArray('public.item'));

  SetLength(LObjects, Length(AValues));
  for I := 0 to High(AValues) do
    LObjects[I] := NSObjectToID(StrToNSStr(AValues[I]));

  Result := TNSArray.Wrap(TNSArray.OCClass.arrayWithObjects(@LObjects[0], Length(LObjects)));
end;

function TiOSSAF.BuildSingleUrlArray(const AUri: NSURL): NSArray;
begin
  Result := TNSArray.Wrap(TNSArray.OCClass.arrayWithObject(NSObjectToID(AUri)));
end;

function TiOSSAF.CreateTempExportFile(const AFileName: string): NSURL;
var
  LPath: string;
  LBytes: TBytes;
begin
  if AFileName.Trim = '' then
    FLastExportFileName := 'Untitled'
  else
    FLastExportFileName := AFileName;

  LPath := TPath.Combine(TPath.GetTempPath, FLastExportFileName);
  ForceDirectories(ExtractFilePath(LPath));
  SetLength(LBytes, 0);
  if not TFile.Exists(LPath) then
    TFile.WriteAllBytes(LPath, LBytes);

  Result := TNSURL.OCClass.fileURLWithPath(StrToNSStr(LPath));
end;

procedure TiOSSAF.DoCancel(APickMode: TiOSSAFPickMode);
begin
  if Assigned(FOnCancel) then
    FOnCancel(Self, APickMode);
end;

procedure TiOSSAF.DoError(const AMessage: string);
begin
  if Assigned(FOnError) then
    FOnError(Self, AMessage);
end;

procedure TiOSSAF.DoPicked(const AUri: NSURL);
begin
  FCurrentUri := AUri;

  case FLastPickMode of
    pmFile:
      if Assigned(FOnFilePicked) then
        FOnFilePicked(Self, AUri);
    pmFolder:
      if Assigned(FOnFolderPicked) then
        FOnFolderPicked(Self, AUri);
    pmSaveAs:
      if Assigned(FOnSaveAsPicked) then
        FOnSaveAsPicked(Self, AUri);
  end;
end;

function TiOSSAF.FileURLToPath(const AUri: NSURL): string;
begin
  Result := '';
  if AUri = nil then
    Exit;

  if AUri.isFileURL then
    Result := NSStrToStr(AUri.path)
  else
    Result := NSStrToStr(AUri.absoluteString);
end;

function TiOSSAF.InternalReadBytes(const AUri: NSURL): TBytes;
var
  LAccessing: Boolean;
  LPath: string;
begin
  SetLength(Result, 0);
  if AUri = nil then
    Exit;

  LAccessing := BeginAccess(AUri);
  try
    LPath := FileURLToPath(AUri);
    if TFile.Exists(LPath) then
      Result := TFile.ReadAllBytes(LPath);
  finally
    EndAccess(AUri, LAccessing);
  end;
end;

procedure TiOSSAF.InternalWriteBytes(const AUri: NSURL; const AData: TBytes; const AAppend: Boolean);
var
  LAccessing: Boolean;
  LMode: Word;
  LPath: string;
  LStream: TFileStream;
begin
  if AUri = nil then
    Exit;

  LAccessing := BeginAccess(AUri);
  try
    LPath := FileURLToPath(AUri);
    ForceDirectories(ExtractFilePath(LPath));

    if AAppend and TFile.Exists(LPath) then
      LMode := fmOpenReadWrite
    else
      LMode := fmCreate;

    LStream := TFileStream.Create(LPath, LMode);
    try
      if AAppend then
        LStream.Position := LStream.Size;

      if Length(AData) > 0 then
        LStream.WriteBuffer(AData[0], Length(AData));
    finally
      LStream.Free;
    end;
  finally
    EndAccess(AUri, LAccessing);
  end;
end;

function TiOSSAF.MimeTypeFromFileName(const AFileName: string): string;
var
  LExt: string;
begin
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
  else if LExt = '.csv' then
    Result := 'text/csv'
  else if LExt = '.xlsx' then
    Result := 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
  else
    Result := 'application/octet-stream';
end;

procedure TiOSSAF.PickFile(const AMimeType: string);
begin
  FLastPickMode := pmFile;
  FLastMimeType := AMimeType;
  PresentPicker(BuildOpenPicker(AMimeType));
end;

procedure TiOSSAF.PickFile(const AMimeTypes: TArray<string>);
begin
  FLastPickMode := pmFile;
  if Length(AMimeTypes) > 0 then
    FLastMimeType := AMimeTypes[0]
  else
    FLastMimeType := '*/*';
  PresentPicker(BuildOpenPicker(AMimeTypes));
end;

procedure TiOSSAF.PickFolder;
begin
  FLastPickMode := pmFolder;
  PresentPicker(BuildFolderPicker);
end;

procedure TiOSSAF.PresentPicker(const APicker: UIDocumentPickerViewController);
var
  LWindow: UIWindow;
begin
  if FDocumentPicker <> nil then
  begin
    FDocumentPicker.setDelegate(nil);
    FDocumentPicker.release;
  end;

  FDocumentPicker := APicker;
  FDocumentPicker.retain;
  FDocumentPicker.setDelegate(FDocumentPickerDelegate.GetObjectID);

  LWindow := SharedApplication.keyWindow;
  if (LWindow <> nil) and (LWindow.rootViewController <> nil) then
    LWindow.rootViewController.presentModalViewController(FDocumentPicker, True)
  else
    DoError('Unable to present document picker.');
end;

function TiOSSAF.QuerySingleItem(const AUri: NSURL): TiOSSAFItem;
var
  LPath: string;
  LModified: TDateTime;
begin
  FillChar(Result, SizeOf(Result), 0);
  Result.Uri := AUri;
  Result.DisplayName := GetDisplayName(AUri);
  Result.MimeType := GetMimeType(AUri);
  Result.ItemType := sitUnknown;
  Result.Size := -1;
  Result.LastModified := -1;
  Result.Flags := 0;

  LPath := FileURLToPath(AUri);
  if TDirectory.Exists(LPath) then
  begin
    Result.ItemType := sitFolder;
    LModified := TDirectory.GetLastWriteTime(LPath);
  end
  else if TFile.Exists(LPath) then
  begin
    Result.ItemType := sitFile;
    Result.Size := TFile.GetSize(LPath);
    LModified := TFile.GetLastWriteTime(LPath);
  end
  else
    LModified := 0;

  if LModified > 0 then
    Result.LastModified := Round((LModified - 25569) * 86400000);
end;

function TiOSSAF.UTIForMimeType(const AMimeType: string): string;
begin
  if (AMimeType = '') or SameText(AMimeType, '*/*') then
    Result := 'public.item'
  else if SameText(AMimeType, 'text/plain') then
    Result := 'public.plain-text'
  else if SameText(AMimeType, 'application/json') then
    Result := 'public.json'
  else if SameText(AMimeType, 'application/pdf') then
    Result := 'com.adobe.pdf'
  else if SameText(AMimeType, 'image/png') then
    Result := 'public.png'
  else if SameText(AMimeType, 'image/jpeg') then
    Result := 'public.jpeg'
  else if SameText(AMimeType, 'image/*') then
    Result := 'public.image'
  else if SameText(AMimeType, 'audio/*') then
    Result := 'public.audio'
  else if SameText(AMimeType, 'video/*') then
    Result := 'public.movie'
  else if SameText(AMimeType, 'text/csv') then
    Result := 'public.comma-separated-values-text'
  else
    Result := 'public.data';
end;

procedure TiOSSAF.SaveAs(const AFileName, AMimeType: string);
begin
  FLastPickMode := pmSaveAs;
  FLastFileName := AFileName;
  FLastMimeType := AMimeType;
  PresentPicker(BuildSaveAsPicker(AFileName, AMimeType));
end;

function TiOSSAF.ReadText(const AUri: NSURL; const AEncoding: TEncoding): string;
var
  LBytes: TBytes;
  LEncoding: TEncoding;
begin
  Result := '';
  LBytes := InternalReadBytes(AUri);
  if Length(LBytes) = 0 then
    Exit;

  if AEncoding <> nil then
    LEncoding := AEncoding
  else
    LEncoding := TEncoding.UTF8;

  Result := LEncoding.GetString(LBytes);
end;

procedure TiOSSAF.WriteText(const AUri: NSURL; const AText: string; const AEncoding: TEncoding; const AAppend: Boolean);
var
  LEncoding: TEncoding;
begin
  if AEncoding <> nil then
    LEncoding := AEncoding
  else
    LEncoding := TEncoding.UTF8;

  InternalWriteBytes(AUri, LEncoding.GetBytes(AText), AAppend);
end;

function TiOSSAF.ReadBytes(const AUri: NSURL): TBytes;
begin
  Result := InternalReadBytes(AUri);
end;

procedure TiOSSAF.WriteBytes(const AUri: NSURL; const AData: TBytes; const AAppend: Boolean);
begin
  InternalWriteBytes(AUri, AData, AAppend);
end;

function TiOSSAF.CreateFileInFolder(const AFolderUri: NSURL; const AFileName, AMimeType: string): NSURL;
var
  LPath: string;
  LBytes: TBytes;
  LAccessing: Boolean;
begin
  Result := nil;
  if AFolderUri = nil then
    Exit;

  LAccessing := BeginAccess(AFolderUri);
  try
    LPath := TPath.Combine(FileURLToPath(AFolderUri), AFileName);
    ForceDirectories(ExtractFilePath(LPath));
    if not TFile.Exists(LPath) then
    begin
      SetLength(LBytes, 0);
      TFile.WriteAllBytes(LPath, LBytes);
    end;
    Result := TNSURL.OCClass.fileURLWithPath(StrToNSStr(LPath));
  finally
    EndAccess(AFolderUri, LAccessing);
  end;
end;

function TiOSSAF.CreateFolderInFolder(const AFolderUri: NSURL; const AFolderName: string): NSURL;
var
  LPath: string;
  LAccessing: Boolean;
begin
  Result := nil;
  if AFolderUri = nil then
    Exit;

  LAccessing := BeginAccess(AFolderUri);
  try
    LPath := TPath.Combine(FileURLToPath(AFolderUri), AFolderName);
    ForceDirectories(LPath);
    Result := TNSURL.OCClass.fileURLWithPath(StrToNSStr(LPath), True);
  finally
    EndAccess(AFolderUri, LAccessing);
  end;
end;

function TiOSSAF.ListFiles(const AFolderUri: NSURL): TiOSSAFItems;
var
  LAccessing: Boolean;
  LFolderPath: string;
  LItemPath: string;
  LList: TList<TiOSSAFItem>;
begin
  SetLength(Result, 0);
  if AFolderUri = nil then
    Exit;

  LAccessing := BeginAccess(AFolderUri);
  try
    LFolderPath := FileURLToPath(AFolderUri);
    if not TDirectory.Exists(LFolderPath) then
      Exit;

    LList := TList<TiOSSAFItem>.Create;
    try
      for LItemPath in TDirectory.GetDirectories(LFolderPath) do
        LList.Add(QuerySingleItem(TNSURL.OCClass.fileURLWithPath(StrToNSStr(LItemPath), True)));

      for LItemPath in TDirectory.GetFiles(LFolderPath) do
        LList.Add(QuerySingleItem(TNSURL.OCClass.fileURLWithPath(StrToNSStr(LItemPath))));

      Result := LList.ToArray;
    finally
      LList.Free;
    end;
  finally
    EndAccess(AFolderUri, LAccessing);
  end;
end;

function TiOSSAF.DeleteUri(const AUri: NSURL): Boolean;
var
  LAccessing: Boolean;
  LPath: string;
begin
  Result := False;
  if AUri = nil then
    Exit;

  LAccessing := BeginAccess(AUri);
  try
    LPath := FileURLToPath(AUri);
    if TDirectory.Exists(LPath) then
      TDirectory.Delete(LPath, True)
    else if TFile.Exists(LPath) then
      TFile.Delete(LPath)
    else
      Exit;

    Result := True;
  finally
    EndAccess(AUri, LAccessing);
  end;
end;

function TiOSSAF.Exists(const AUri: NSURL): Boolean;
var
  LAccessing: Boolean;
  LPath: string;
begin
  Result := False;
  if AUri = nil then
    Exit;

  LAccessing := BeginAccess(AUri);
  try
    LPath := FileURLToPath(AUri);
    Result := TFile.Exists(LPath) or TDirectory.Exists(LPath);
  finally
    EndAccess(AUri, LAccessing);
  end;
end;

function TiOSSAF.HasPersistedPermission(const AUri: NSURL): Boolean;
begin
  Result := Exists(AUri);
end;

function TiOSSAF.CanAccessFolder(const AFolderUri: NSURL): Boolean;
var
  LAccessing: Boolean;
begin
  Result := False;
  if AFolderUri = nil then
    Exit;

  LAccessing := BeginAccess(AFolderUri);
  try
    Result := TDirectory.Exists(FileURLToPath(AFolderUri));
    if Result then
      TDirectory.GetFileSystemEntries(FileURLToPath(AFolderUri));
  finally
    EndAccess(AFolderUri, LAccessing);
  end;
end;

function TiOSSAF.RestoreFolderPermission(const AUriText: string; out AUri: NSURL): Boolean;
begin
  AUri := StringToUri(AUriText);
  Result := (AUri <> nil) and CanAccessFolder(AUri);
  if not Result then
    AUri := nil;
end;

function TiOSSAF.RestoreFolderPermission(const AUriText: string): NSURL;
begin
  Result := nil;
  RestoreFolderPermission(AUriText, Result);
end;

function TiOSSAF.FindFileInFolder(const AFolderUri: NSURL; const AFileName: string): NSURL;
var
  LPath: string;
  LAccessing: Boolean;
begin
  Result := nil;
  if (AFolderUri = nil) or (AFileName.Trim = '') then
    Exit;

  LAccessing := BeginAccess(AFolderUri);
  try
    LPath := TPath.Combine(FileURLToPath(AFolderUri), AFileName);
    if TFile.Exists(LPath) or TDirectory.Exists(LPath) then
      Result := TNSURL.OCClass.fileURLWithPath(StrToNSStr(LPath), TDirectory.Exists(LPath));
  finally
    EndAccess(AFolderUri, LAccessing);
  end;
end;

function TiOSSAF.CopyToSharedDownloads(const AUri: NSURL; const ATargetFileName: string): string;
var
  LTargetName: string;
begin
  Result := '';
  if AUri = nil then
    Exit;

  if ATargetFileName.Trim <> '' then
    LTargetName := ATargetFileName
  else
    LTargetName := GetDisplayName(AUri);

  Result := TPath.Combine(TPath.GetDocumentsPath, LTargetName);
  CopyToLocalFile(AUri, Result);
end;

function TiOSSAF.CopyToLocalFile(const ASourceUri: NSURL; const ATargetFileName: string): Boolean;
var
  LBytes: TBytes;
begin
  Result := False;
  if (ASourceUri = nil) or (ATargetFileName.Trim = '') then
    Exit;

  LBytes := ReadBytes(ASourceUri);
  if ExtractFilePath(ATargetFileName) <> '' then
    ForceDirectories(ExtractFilePath(ATargetFileName));

  TFile.WriteAllBytes(ATargetFileName, LBytes);
  Result := True;
end;

procedure TiOSSAF.ShareUri(const AUri: NSURL; const AChooserTitle: string);
var
  LActivityItems: NSArray;
  LActivity: UIActivityViewController;
  LWindow: UIWindow;
begin
  if AUri = nil then
    Exit;

  LActivityItems := BuildSingleUrlArray(AUri);
  LActivity := TUIActivityViewController.Wrap(
    TUIActivityViewController.Alloc.initWithActivityItems(LActivityItems, nil)
  );

  LWindow := SharedApplication.keyWindow;
  if (LWindow <> nil) and (LWindow.rootViewController <> nil) then
    LWindow.rootViewController.presentModalViewController(LActivity, True)
  else
    DoError('Unable to present share sheet.');
end;

function TiOSSAF.GetDisplayName(const AUri: NSURL): string;
begin
  Result := '';
  if AUri <> nil then
    Result := NSStrToStr(AUri.lastPathComponent);
end;

function TiOSSAF.GetMimeType(const AUri: NSURL): string;
begin
  Result := MimeTypeFromFileName(GetDisplayName(AUri));
end;

function TiOSSAF.UriToString(const AUri: NSURL): string;
begin
  Result := '';
  if AUri <> nil then
    Result := NSStrToStr(AUri.absoluteString);
end;

function TiOSSAF.StringToUri(const AValue: string): NSURL;
begin
  Result := nil;
  if AValue.Trim <> '' then
    Result := TNSURL.Wrap(TNSURL.OCClass.URLWithString(StrToNSStr(AValue)));
end;

{$ENDIF}

end.
