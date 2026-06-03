unit BFA.Android.SAF.Modern;

interface

{$IFDEF ANDROID}

uses
  System.SysUtils,
  System.Classes,
  System.Messaging,
  System.IOUtils,
  System.Generics.Collections,
  Androidapi.Helpers,
  Androidapi.JNI.App,
  Androidapi.JNI.GraphicsContentViewText,
  Androidapi.JNI.JavaTypes,
  Androidapi.JNI.Net,
  Androidapi.JNI.Provider,
  Androidapi.JNI.Os,
  Androidapi.JNI.Widget,
  Androidapi.JNIBridge,
  Androidapi.JNI.Webkit,
  FMX.Platform.Android;

type
  TSAFPickMode = (pmFile, pmFolder, pmSaveAs);

  TSAFUriEvent = procedure(Sender: TObject; const AUri: JNet_Uri) of object;
  TSAFErrorEvent = procedure(Sender: TObject; const AMessage: string) of object;
  TSAFCancelEvent = procedure(Sender: TObject; APickMode: TSAFPickMode) of object;

  TSAFItemType = (sitUnknown, sitFile, sitFolder);

  TSAFItem = record
    Uri: JNet_Uri;
    DisplayName: string;
    MimeType: string;
    ItemType: TSAFItemType;
    Size: Int64;
    LastModified: Int64;
    Flags: Integer;
    function IsFolder: Boolean;
    function IsFile: Boolean;
  end;

  TSAFItems = TArray<TSAFItem>;

  JDocumentsContractApi = interface;
  JDocumentsContractApiClass = interface(JObjectClass)
    ['{4A5DB52A-0AA6-4EB7-878B-9B64B855A0DD}']
    function buildChildDocumentsUriUsingTree(treeUri: JNet_Uri; parentDocumentId: JString): JNet_Uri; cdecl;
    function buildDocumentUriUsingTree(treeUri: JNet_Uri; documentId: JString): JNet_Uri; cdecl;
    function buildTreeDocumentUri(authority: JString; documentId: JString): JNet_Uri; cdecl;
    function createDocument(content: JContentResolver; parentDocumentUri: JNet_Uri; mimeType: JString; displayName: JString): JNet_Uri; cdecl;
    function deleteDocument(content: JContentResolver; documentUri: JNet_Uri): Boolean; cdecl;
    function getDocumentId(documentUri: JNet_Uri): JString; cdecl;
    function getTreeDocumentId(documentUri: JNet_Uri): JString; cdecl;
    function isDocumentUri(context: JContext; uri: JNet_Uri): Boolean; cdecl;
  end;

  [JavaSignature('android/provider/DocumentsContract')]
  JDocumentsContractApi = interface(JObject)
    ['{C57CB5FD-CB75-48F6-B1A9-A77D3198F1F5}']
  end;

  TJDocumentsContractApi = class(TJavaGenericImport<JDocumentsContractApiClass, JDocumentsContractApi>) end;

  TAndroidSAF = class
  private const
    RC_PICK_FILE   = 9001;
    RC_PICK_FOLDER = 9002;
    RC_SAVE_AS     = 9003;
  private
    FCurrentUri: JNet_Uri;
    FLastPickMode: TSAFPickMode;
    FLastMimeType: string;
    FLastFileName: string;

    FOnFilePicked: TSAFUriEvent;
    FOnFolderPicked: TSAFUriEvent;
    FOnSaveAsPicked: TSAFUriEvent;
    FOnError: TSAFErrorEvent;
    FOnCancel: TSAFCancelEvent;

    procedure ActivityResultHandler(const Sender: TObject; const M: TMessage);
    procedure HandleActivityResult(RequestCode, ResultCode: Integer; Data: JIntent);

    procedure DoError(const AMessage: string);
    procedure DoCancel(APickMode: TSAFPickMode);

    function BuildOpenFileIntent(const AMimeType: string): JIntent; overload;
    function BuildOpenFileIntent(const AMimeTypes: TArray<string>): JIntent; overload;
    function BuildOpenFolderIntent: JIntent;
    function BuildSaveAsIntent(const AFileName, AMimeType: string): JIntent;

    function InternalReadBytes(const AUri: JNet_Uri): TBytes;
    procedure InternalWriteBytes(const AUri: JNet_Uri; const AData: TBytes; const AAppend: Boolean = False);

    function ResolveDocumentUri(const AFolderTreeUri: JNet_Uri): JNet_Uri;
    function QuerySingleItem(const AUri: JNet_Uri): TSAFItem;
  public
    constructor Create;
    destructor Destroy; override;

    procedure PickFile(const AMimeType: string = '*/*'); overload;
    procedure PickFile(const AMimeTypes: TArray<string>); overload;
    procedure PickFolder;
    procedure SaveAs(const AFileName, AMimeType: string);

    function ReadText(const AUri: JNet_Uri; const AEncoding: TEncoding = nil): string;
    procedure WriteText(const AUri: JNet_Uri; const AText: string; const AEncoding: TEncoding = nil; const AAppend: Boolean = False);

    function ReadBytes(const AUri: JNet_Uri): TBytes;
    procedure WriteBytes(const AUri: JNet_Uri; const AData: TBytes; const AAppend: Boolean = False);

    function CreateFileInFolder(const AFolderTreeUri: JNet_Uri; const AFileName, AMimeType: string): JNet_Uri;
    function CreateFolderInFolder(const AFolderTreeUri: JNet_Uri; const AFolderName: string): JNet_Uri;
    function ListFiles(const AFolderTreeUri: JNet_Uri): TSAFItems;
    function DeleteUri(const AUri: JNet_Uri): Boolean;
    function Exists(const AUri: JNet_Uri): Boolean;

    function HasPersistedPermission(const AUri: JNet_Uri): Boolean;
    function CanAccessFolder(const AFolderTreeUri: JNet_Uri): Boolean;
    function RestoreFolderPermission(const AUriText: string; out AUri: JNet_Uri): Boolean; overload;
    function RestoreFolderPermission(const AUriText: string): JNet_Uri; overload;

    function FindFileInFolder(const AFolderTreeUri: JNet_Uri; const AFileName: string): JNet_Uri;

    function CopyToSharedDownloads(const AUri: JNet_Uri; const ATargetFileName: string = ''): string;
    function CopyToLocalFile(const ASourceUri: JNet_Uri; const ATargetFileName: string): Boolean;

    procedure ShareUri(const AUri: JNet_Uri; const AChooserTitle: string = 'Share file');

    procedure TakePersistablePermission(const AUri: JNet_Uri; ARead, AWrite: Boolean);
    function GetDisplayName(const AUri: JNet_Uri): string;
    function GetMimeType(const AUri: JNet_Uri): string;
    function UriToString(const AUri: JNet_Uri): string;
    function StringToUri(const AValue: string): JNet_Uri;

    property CurrentUri: JNet_Uri read FCurrentUri;

    property OnFilePicked: TSAFUriEvent read FOnFilePicked write FOnFilePicked;
    property OnFolderPicked: TSAFUriEvent read FOnFolderPicked write FOnFolderPicked;
    property OnSaveAsPicked: TSAFUriEvent read FOnSaveAsPicked write FOnSaveAsPicked;
    property OnError: TSAFErrorEvent read FOnError write FOnError;
    property OnCancel: TSAFCancelEvent read FOnCancel write FOnCancel;
  end;

{$ENDIF}

implementation

{$IFDEF ANDROID}

uses
  System.StrUtils,
  Androidapi.JNI.Media,
  Androidapi.JNI.Support;

{ TSAFItem }

function TSAFItem.IsFile: Boolean;
begin
  Result := ItemType = sitFile;
end;

function TSAFItem.IsFolder: Boolean;
begin
  Result := ItemType = sitFolder;
end;

{ TAndroidSAF }

constructor TAndroidSAF.Create;
begin
  inherited Create;
  TMessageManager.DefaultManager.SubscribeToMessage(
    TMessageResultNotification,
    ActivityResultHandler
  );
end;

destructor TAndroidSAF.Destroy;
begin
  TMessageManager.DefaultManager.Unsubscribe(
    TMessageResultNotification,
    ActivityResultHandler
  );
  inherited;
end;

procedure TAndroidSAF.DoError(const AMessage: string);
begin
  if Assigned(FOnError) then
    FOnError(Self, AMessage)
  else
    TJToast.JavaClass.makeText(
      TAndroidHelper.Context,
      StrToJCharSequence(AMessage),
      TJToast.JavaClass.LENGTH_LONG
    ).show;
end;

procedure TAndroidSAF.DoCancel(APickMode: TSAFPickMode);
begin
  if Assigned(FOnCancel) then
    FOnCancel(Self, APickMode);
end;

function TAndroidSAF.BuildOpenFileIntent(const AMimeType: string): JIntent;
begin
  Result := TJIntent.Create;
  Result.setAction(TJIntent.JavaClass.ACTION_OPEN_DOCUMENT);
  Result.addCategory(TJIntent.JavaClass.CATEGORY_OPENABLE);
  Result.setType(StringToJString(AMimeType));
  Result.addFlags(TJIntent.JavaClass.FLAG_GRANT_READ_URI_PERMISSION);
  Result.addFlags(TJIntent.JavaClass.FLAG_GRANT_PERSISTABLE_URI_PERMISSION);
end;

function TAndroidSAF.BuildOpenFileIntent(const AMimeTypes: TArray<string>): JIntent;
var
  LTypes: TJavaObjectArray<JString>;
  I: Integer;
begin
  Result := TJIntent.Create;
  Result.setAction(TJIntent.JavaClass.ACTION_OPEN_DOCUMENT);
  Result.addCategory(TJIntent.JavaClass.CATEGORY_OPENABLE);
  Result.addFlags(TJIntent.JavaClass.FLAG_GRANT_READ_URI_PERMISSION);
  Result.addFlags(TJIntent.JavaClass.FLAG_GRANT_PERSISTABLE_URI_PERMISSION);

  if Length(AMimeTypes) = 1 then
  begin
    Result.setType(StringToJString(AMimeTypes[0]));
    Exit;
  end;

  Result.setType(StringToJString('*/*'));

  if Length(AMimeTypes) > 1 then
  begin
    LTypes := TJavaObjectArray<JString>.Create(Length(AMimeTypes));
    for I := 0 to High(AMimeTypes) do
      LTypes.Items[I] := StringToJString(AMimeTypes[I]);
    Result.putExtra(TJIntent.JavaClass.EXTRA_MIME_TYPES, LTypes);
  end;
end;

function TAndroidSAF.BuildOpenFolderIntent: JIntent;
begin
  Result := TJIntent.Create;
  Result.setAction(TJIntent.JavaClass.ACTION_OPEN_DOCUMENT_TREE);
  Result.addFlags(TJIntent.JavaClass.FLAG_GRANT_READ_URI_PERMISSION);
  Result.addFlags(TJIntent.JavaClass.FLAG_GRANT_WRITE_URI_PERMISSION);
  Result.addFlags(TJIntent.JavaClass.FLAG_GRANT_PERSISTABLE_URI_PERMISSION);
end;

function TAndroidSAF.BuildSaveAsIntent(const AFileName, AMimeType: string): JIntent;
begin
  Result := TJIntent.Create;
  Result.setAction(TJIntent.JavaClass.ACTION_CREATE_DOCUMENT);
  Result.addCategory(TJIntent.JavaClass.CATEGORY_OPENABLE);
  Result.setType(StringToJString(AMimeType));
  Result.putExtra(TJIntent.JavaClass.EXTRA_TITLE, StringToJString(AFileName));
  Result.addFlags(TJIntent.JavaClass.FLAG_GRANT_READ_URI_PERMISSION);
  Result.addFlags(TJIntent.JavaClass.FLAG_GRANT_WRITE_URI_PERMISSION);
  Result.addFlags(TJIntent.JavaClass.FLAG_GRANT_PERSISTABLE_URI_PERMISSION);
end;

procedure TAndroidSAF.PickFile(const AMimeType: string);
var
  Intent: JIntent;
begin
  FLastPickMode := pmFile;
  FLastMimeType := AMimeType;
  Intent := BuildOpenFileIntent(AMimeType);
  MainActivity.startActivityForResult(Intent, RC_PICK_FILE);
end;

procedure TAndroidSAF.PickFile(const AMimeTypes: TArray<string>);
var
  Intent: JIntent;
begin
  FLastPickMode := pmFile;
  if Length(AMimeTypes) > 0 then
    FLastMimeType := AMimeTypes[0]
  else
    FLastMimeType := '*/*';
  Intent := BuildOpenFileIntent(AMimeTypes);
  MainActivity.startActivityForResult(Intent, RC_PICK_FILE);
end;

procedure TAndroidSAF.PickFolder;
var
  Intent: JIntent;
begin
  FLastPickMode := pmFolder;
  Intent := BuildOpenFolderIntent;
  MainActivity.startActivityForResult(Intent, RC_PICK_FOLDER);
end;

procedure TAndroidSAF.SaveAs(const AFileName, AMimeType: string);
var
  Intent: JIntent;
begin
  FLastPickMode := pmSaveAs;
  FLastFileName := AFileName;
  FLastMimeType := AMimeType;
  Intent := BuildSaveAsIntent(AFileName, AMimeType);
  MainActivity.startActivityForResult(Intent, RC_SAVE_AS);
end;

procedure TAndroidSAF.ActivityResultHandler(const Sender: TObject; const M: TMessage);
begin
  if M is TMessageResultNotification then
    HandleActivityResult(
      TMessageResultNotification(M).RequestCode,
      TMessageResultNotification(M).ResultCode,
      TMessageResultNotification(M).Value
    );
end;

procedure TAndroidSAF.HandleActivityResult(RequestCode, ResultCode: Integer; Data: JIntent);
var
  LUri: JNet_Uri;
begin
  case RequestCode of
    RC_PICK_FILE:   FLastPickMode := pmFile;
    RC_PICK_FOLDER: FLastPickMode := pmFolder;
    RC_SAVE_AS:     FLastPickMode := pmSaveAs;
  else
    Exit;
  end;

  if ResultCode = TJActivity.JavaClass.RESULT_CANCELED then
  begin
    DoCancel(FLastPickMode);
    Exit;
  end;

  if ResultCode <> TJActivity.JavaClass.RESULT_OK then
    Exit;

  LUri := nil;
  if Data <> nil then
    LUri := Data.getData;

  FCurrentUri := LUri;

  case RequestCode of
    RC_PICK_FILE:
      begin
        if LUri <> nil then
        begin
          TakePersistablePermission(LUri, True, False);
          if Assigned(FOnFilePicked) then
            FOnFilePicked(Self, LUri);
        end
        else
          DoError('File URI not returned.');
      end;

    RC_PICK_FOLDER:
      begin
        if LUri <> nil then
        begin
          TakePersistablePermission(LUri, True, True);
          if Assigned(FOnFolderPicked) then
            FOnFolderPicked(Self, LUri);
        end
        else
          DoError('Folder URI not returned.');
      end;

    RC_SAVE_AS:
      begin
        if LUri <> nil then
        begin
          TakePersistablePermission(LUri, True, True);
          if Assigned(FOnSaveAsPicked) then
            FOnSaveAsPicked(Self, LUri);
        end
        else
          DoError('Save URI not returned.');
      end;
  end;
end;

procedure TAndroidSAF.TakePersistablePermission(const AUri: JNet_Uri; ARead, AWrite: Boolean);
var
  Flags: Integer;
begin
  if AUri = nil then
    Exit;

  Flags := 0;
  if ARead then
    Flags := Flags or TJIntent.JavaClass.FLAG_GRANT_READ_URI_PERMISSION;
  if AWrite then
    Flags := Flags or TJIntent.JavaClass.FLAG_GRANT_WRITE_URI_PERMISSION;

  if Flags <> 0 then
    TAndroidHelper.Activity.getContentResolver.takePersistableUriPermission(AUri, Flags);
end;

function TAndroidSAF.InternalReadBytes(const AUri: JNet_Uri): TBytes;
const
  BUFFER_SIZE = 8192;
var
  LInput: JInputStream;
  LBuffer: TJavaArray<Byte>;
  LRead: Integer;
  LMS: TMemoryStream;
begin
  SetLength(Result, 0);

  if AUri = nil then
    Exit;

  LInput := nil;
  LMS := nil;
  try
    LInput := TAndroidHelper.Context.getContentResolver.openInputStream(AUri);
    if LInput = nil then
      Exit;

    LBuffer := TJavaArray<Byte>.Create(BUFFER_SIZE);
    LMS := TMemoryStream.Create;

    repeat
      LRead := LInput.read(LBuffer);
      if LRead > 0 then
        LMS.WriteBuffer(LBuffer.Data^, LRead);
    until LRead <= 0;

    SetLength(Result, LMS.Size);
    if LMS.Size > 0 then
    begin
      LMS.Position := 0;
      LMS.ReadBuffer(Result[0], LMS.Size);
    end;
  finally
    LMS.Free;
    if LInput <> nil then
      LInput.close;
  end;
end;

procedure TAndroidSAF.InternalWriteBytes(const AUri: JNet_Uri; const AData: TBytes; const AAppend: Boolean);
var
  LPFD: JParcelFileDescriptor;
  LOut: JFileOutputStream;
  LMode: JString;
  LArr: TJavaArray<Byte>;
  I: Integer;
begin
  if AUri = nil then
    Exit;

  LPFD := nil;
  LOut := nil;

  if AAppend then
    LMode := StringToJString('wa')
  else
    LMode := StringToJString('w');

  try
    LPFD := TAndroidHelper.Activity.getContentResolver.openFileDescriptor(AUri, LMode);
    if LPFD = nil then
      raise Exception.Create('Unable to open file descriptor.');

    LOut := TJFileOutputStream.JavaClass.init(LPFD.getFileDescriptor);

    if Length(AData) > 0 then
    begin
      LArr := TJavaArray<Byte>.Create(Length(AData));
      for I := 0 to High(AData) do
        LArr.Items[I] := AData[I];
      LOut.write(LArr, 0, Length(AData));
    end;

    LOut.flush;
  finally
    if LOut <> nil then
      LOut.close;
    if LPFD <> nil then
      LPFD.close;
  end;
end;

function TAndroidSAF.ReadText(const AUri: JNet_Uri; const AEncoding: TEncoding): string;
var
  LBytes: TBytes;
  LEnc: TEncoding;
begin
  Result := '';
  LBytes := InternalReadBytes(AUri);

  if Length(LBytes) = 0 then
    Exit;

  if AEncoding <> nil then
    LEnc := AEncoding
  else
    LEnc := TEncoding.UTF8;

  Result := LEnc.GetString(LBytes);
end;

procedure TAndroidSAF.WriteText(const AUri: JNet_Uri; const AText: string; const AEncoding: TEncoding; const AAppend: Boolean);
var
  LEnc: TEncoding;
  LBytes: TBytes;
begin
  if AUri = nil then
    Exit;

  if AEncoding <> nil then
    LEnc := AEncoding
  else
    LEnc := TEncoding.UTF8;

  LBytes := LEnc.GetBytes(AText);
  InternalWriteBytes(AUri, LBytes, AAppend);
end;

function TAndroidSAF.ReadBytes(const AUri: JNet_Uri): TBytes;
begin
  Result := InternalReadBytes(AUri);
end;

procedure TAndroidSAF.WriteBytes(const AUri: JNet_Uri; const AData: TBytes; const AAppend: Boolean);
begin
  InternalWriteBytes(AUri, AData, AAppend);
end;

function TAndroidSAF.ResolveDocumentUri(const AFolderTreeUri: JNet_Uri): JNet_Uri;
var
  LDocId: JString;
begin
  Result := nil;
  if AFolderTreeUri = nil then
    Exit;

  LDocId := TJDocumentsContractApi.JavaClass.getTreeDocumentId(AFolderTreeUri);
  Result := TJDocumentsContractApi.JavaClass.buildDocumentUriUsingTree(AFolderTreeUri, LDocId);
end;

function TAndroidSAF.CreateFileInFolder(const AFolderTreeUri: JNet_Uri; const AFileName, AMimeType: string): JNet_Uri;
var
  LParentDocUri: JNet_Uri;
begin
  Result := nil;

  if AFolderTreeUri = nil then
    Exit;

  LParentDocUri := ResolveDocumentUri(AFolderTreeUri);

  Result := TJDocumentsContractApi.JavaClass.createDocument(
    TAndroidHelper.Activity.getContentResolver,
    LParentDocUri,
    StringToJString(AMimeType),
    StringToJString(AFileName)
  );
end;

function TAndroidSAF.CreateFolderInFolder(const AFolderTreeUri: JNet_Uri; const AFolderName: string): JNet_Uri;
begin
  Result := CreateFileInFolder(AFolderTreeUri, AFolderName, 'vnd.android.document/directory');
end;

function TAndroidSAF.QuerySingleItem(const AUri: JNet_Uri): TSAFItem;
var
  C: JCursor;
  ColIndex: Integer;
  LMime: string;
begin
  FillChar(Result, SizeOf(Result), 0);
  Result.Uri := AUri;
  Result.DisplayName := '';
  Result.MimeType := '';
  Result.ItemType := sitUnknown;
  Result.Size := -1;
  Result.LastModified := -1;
  Result.Flags := 0;

  if AUri = nil then
    Exit;

  C := nil;
  try
    C := TAndroidHelper.Activity.getContentResolver.query(AUri, nil, nil, nil, nil, nil);
    if (C = nil) or (not C.moveToFirst) then
      Exit;

    ColIndex := C.getColumnIndex(TJOpenableColumns.JavaClass.DISPLAY_NAME);
    if ColIndex >= 0 then
      Result.DisplayName := JStringToString(C.getString(ColIndex));

    ColIndex := C.getColumnIndex(TJDocumentsContract_Document.JavaClass.COLUMN_MIME_TYPE);
    if ColIndex >= 0 then
      Result.MimeType := JStringToString(C.getString(ColIndex));

    ColIndex := C.getColumnIndex(TJOpenableColumns.JavaClass.SIZE);
    if (ColIndex >= 0) and (not C.isNull(ColIndex)) then
      Result.Size := C.getLong(ColIndex);

    ColIndex := C.getColumnIndex(TJDocumentsContract_Document.JavaClass.COLUMN_LAST_MODIFIED);
    if (ColIndex >= 0) and (not C.isNull(ColIndex)) then
      Result.LastModified := C.getLong(ColIndex);

    ColIndex := C.getColumnIndex(TJDocumentsContract_Document.JavaClass.COLUMN_FLAGS);
    if (ColIndex >= 0) and (not C.isNull(ColIndex)) then
      Result.Flags := C.getInt(ColIndex);

    LMime := Result.MimeType;
    if SameText(LMime, 'vnd.android.document/directory') then
      Result.ItemType := sitFolder
    else if LMime <> '' then
      Result.ItemType := sitFile;
  finally
    if C <> nil then
      C.close;
  end;
end;

function TAndroidSAF.ListFiles(const AFolderTreeUri: JNet_Uri): TSAFItems;
var
  LChildrenUri: JNet_Uri;
  LParentDocId: JString;
  C: JCursor;
  LList: TList<TSAFItem>;
  LChildDocId: string;
  LChildUri: JNet_Uri;
  LItem: TSAFItem;
  IdxDocId, IdxName, IdxMime, IdxSize, IdxModified, IdxFlags: Integer;
begin
  SetLength(Result, 0);

  if AFolderTreeUri = nil then
    Exit;

  LParentDocId := TJDocumentsContractApi.JavaClass.getTreeDocumentId(AFolderTreeUri);
  LChildrenUri := TJDocumentsContractApi.JavaClass.buildChildDocumentsUriUsingTree(AFolderTreeUri, LParentDocId);

  LList := TList<TSAFItem>.Create;
  C := nil;
  try
    C := TAndroidHelper.Activity.getContentResolver.query(LChildrenUri, nil, nil, nil, nil, nil);
    if C = nil then
      Exit;

    IdxDocId := C.getColumnIndex(TJDocumentsContract_Document.JavaClass.COLUMN_DOCUMENT_ID);
    IdxName := C.getColumnIndex(TJOpenableColumns.JavaClass.DISPLAY_NAME);
    IdxMime := C.getColumnIndex(TJDocumentsContract_Document.JavaClass.COLUMN_MIME_TYPE);
    IdxSize := C.getColumnIndex(TJOpenableColumns.JavaClass.SIZE);
    IdxModified := C.getColumnIndex(TJDocumentsContract_Document.JavaClass.COLUMN_LAST_MODIFIED);
    IdxFlags := C.getColumnIndex(TJDocumentsContract_Document.JavaClass.COLUMN_FLAGS);

    while C.moveToNext do
    begin
      FillChar(LItem, SizeOf(LItem), 0);
      LItem.Size := -1;
      LItem.LastModified := -1;
      LItem.Flags := 0;
      LItem.ItemType := sitUnknown;

      if IdxDocId >= 0 then
        LChildDocId := JStringToString(C.getString(IdxDocId))
      else
        LChildDocId := '';

      if LChildDocId <> '' then
        LChildUri := TJDocumentsContractApi.JavaClass.buildDocumentUriUsingTree(
          AFolderTreeUri,
          StringToJString(LChildDocId)
        )
      else
        LChildUri := nil;

      LItem.Uri := LChildUri;

      if IdxName >= 0 then
        LItem.DisplayName := JStringToString(C.getString(IdxName))
      else
        LItem.DisplayName := '';

      if IdxMime >= 0 then
        LItem.MimeType := JStringToString(C.getString(IdxMime))
      else
        LItem.MimeType := '';

      if (IdxSize >= 0) and (not C.isNull(IdxSize)) then
        LItem.Size := C.getLong(IdxSize);

      if (IdxModified >= 0) and (not C.isNull(IdxModified)) then
        LItem.LastModified := C.getLong(IdxModified);

      if (IdxFlags >= 0) and (not C.isNull(IdxFlags)) then
        LItem.Flags := C.getInt(IdxFlags);

      if SameText(LItem.MimeType, 'vnd.android.document/directory') then
        LItem.ItemType := sitFolder
      else if LItem.MimeType <> '' then
        LItem.ItemType := sitFile
      else
        LItem.ItemType := sitUnknown;

      LList.Add(LItem);
    end;

    Result := LList.ToArray;
  finally
    if C <> nil then
      C.close;
    LList.Free;
  end;
end;

function TAndroidSAF.DeleteUri(const AUri: JNet_Uri): Boolean;
begin
  Result := False;
  if AUri = nil then
    Exit;

  Result := TJDocumentsContractApi.JavaClass.deleteDocument(
    TAndroidHelper.Activity.getContentResolver,
    AUri
  );
end;

function TAndroidSAF.Exists(const AUri: JNet_Uri): Boolean;
var
  LItem: TSAFItem;
begin
  Result := False;
  if AUri = nil then
    Exit;

  try
    LItem := QuerySingleItem(AUri);
    Result := (LItem.Uri <> nil) and ((LItem.DisplayName <> '') or (LItem.MimeType <> ''));
  except
    Result := False;
  end;
end;

function TAndroidSAF.FindFileInFolder(const AFolderTreeUri: JNet_Uri;
  const AFileName: string): JNet_Uri;
var
  LItems: TSAFItems;
  I: Integer;
begin
  Result := nil;

  if (AFolderTreeUri = nil) or (AFileName.Trim = '') then
    Exit;

  LItems := ListFiles(AFolderTreeUri);
  for I := 0 to High(LItems) do
  begin
    if SameText(LItems[I].DisplayName, AFileName) then
      Exit(LItems[I].Uri);
  end;
end;

function TAndroidSAF.HasPersistedPermission(const AUri: JNet_Uri): Boolean;
var
  LList: JList;
  I: Integer;
  LPermObj: JObject;
  LPerm: JUriPermission;
  LTarget: string;
begin
  Result := False;

  if AUri = nil then
    Exit;

  LList := TAndroidHelper.Activity.getContentResolver.getPersistedUriPermissions;
  if LList = nil then
    Exit;

  LTarget := UriToString(AUri);

  for I := 0 to LList.size - 1 do
  begin
    LPermObj := TJObject.Wrap(LList.get(I));
    LPerm := TJUriPermission.Wrap((LPermObj as ILocalObject).GetObjectID);

    if SameText(JStringToString(LPerm.getUri.toString), LTarget) then
      Exit(True);
  end;
end;

function TAndroidSAF.CanAccessFolder(const AFolderTreeUri: JNet_Uri): Boolean;
var
  LItems: TSAFItems;
begin
  Result := False;

  if AFolderTreeUri = nil then
    Exit;

  try
    LItems := ListFiles(AFolderTreeUri);
    Result := True;
  except
    Result := False;
  end;
end;

function TAndroidSAF.RestoreFolderPermission(const AUriText: string; out AUri: JNet_Uri): Boolean;
begin
  Result := False;
  AUri := nil;

  if AUriText.Trim = '' then
    Exit;

  AUri := StringToUri(AUriText);
  if AUri = nil then
    Exit;

  if not HasPersistedPermission(AUri) then
  begin
    AUri := nil;
    Exit;
  end;

  if not CanAccessFolder(AUri) then
  begin
    AUri := nil;
    Exit;
  end;

  Result := True;
end;

function TAndroidSAF.RestoreFolderPermission(const AUriText: string): JNet_Uri;
begin
  Result := nil;
  if not RestoreFolderPermission(AUriText, Result) then
    Result := nil;
end;

function TAndroidSAF.CopyToLocalFile(const ASourceUri: JNet_Uri; const ATargetFileName: string): Boolean;
var
  LBytes: TBytes;
  LFS: TFileStream;
begin
  Result := False;

  if (ASourceUri = nil) or (ATargetFileName.Trim = '') then
    Exit;

  LBytes := ReadBytes(ASourceUri);
  if Length(LBytes) = 0 then
    Exit;

  ForceDirectories(ExtractFilePath(ATargetFileName));

  LFS := TFileStream.Create(ATargetFileName, fmCreate);
  try
    LFS.WriteBuffer(LBytes[0], Length(LBytes));
    Result := True;
  finally
    LFS.Free;
  end;
end;

function TAndroidSAF.CopyToSharedDownloads(const AUri: JNet_Uri; const ATargetFileName: string): string;
const
  BUFFER_SIZE = 8192;
var
  LIn: JInputStream;
  LOut: JFileOutputStream;
  LBuffer: TJavaArray<Byte>;
  LRead: Integer;
  LTargetName: string;
begin
  Result := '';

  if AUri = nil then
    Exit;

  if ATargetFileName.Trim <> '' then
    LTargetName := ATargetFileName
  else
    LTargetName := GetDisplayName(AUri);

  if LTargetName.Trim = '' then
    raise Exception.Create('Unable to resolve target file name.');

  Result := TPath.Combine(TPath.GetSharedDownloadsPath, LTargetName);

  LIn := nil;
  LOut := nil;
  try
    LIn := TAndroidHelper.Context.getContentResolver.openInputStream(AUri);
    if LIn = nil then
      raise Exception.Create('Unable to open source stream.');

    LOut := TJFileOutputStream.JavaClass.init(StringToJString(Result));
    LBuffer := TJavaArray<Byte>.Create(BUFFER_SIZE);

    repeat
      LRead := LIn.read(LBuffer);
      if LRead > 0 then
        LOut.write(LBuffer, 0, LRead);
    until LRead <= 0;

    LOut.flush;
  finally
    if LOut <> nil then
      LOut.close;
    if LIn <> nil then
      LIn.close;
  end;
end;

procedure TAndroidSAF.ShareUri(const AUri: JNet_Uri; const AChooserTitle: string);
var
  Intent: JIntent;
  MimeMap: JMimeTypeMap;
  ExtFile: string;
  FileName: string;
  MimeType: JString;
begin
  if AUri = nil then
    Exit;

  FileName := GetDisplayName(AUri);
  ExtFile := AnsiLowerCase(StringReplace(TPath.GetExtension(FileName), '.', '', []));

  MimeMap := TJMimeTypeMap.JavaClass.getSingleton;
  MimeType := nil;

  if ExtFile <> '' then
    MimeType := MimeMap.getMimeTypeFromExtension(StringToJString(ExtFile));

  if MimeType = nil then
    MimeType := StringToJString('*/*');

  Intent := TJIntent.Create;
  Intent.setAction(TJIntent.JavaClass.ACTION_SEND);
  Intent.setType(MimeType);
  Intent.putExtra(TJIntent.JavaClass.EXTRA_STREAM, JParcelable(AUri));
  Intent.addFlags(TJIntent.JavaClass.FLAG_GRANT_READ_URI_PERMISSION);

  TAndroidHelper.Activity.startActivity(
    TJIntent.JavaClass.createChooser(Intent, StrToJCharSequence(AChooserTitle))
  );
end;

function TAndroidSAF.GetDisplayName(const AUri: JNet_Uri): string;
begin
  Result := QuerySingleItem(AUri).DisplayName;
end;

function TAndroidSAF.GetMimeType(const AUri: JNet_Uri): string;
begin
  Result := QuerySingleItem(AUri).MimeType;
end;

function TAndroidSAF.UriToString(const AUri: JNet_Uri): string;
begin
  Result := '';
  if AUri <> nil then
    Result := JStringToString(AUri.toString);
end;

function TAndroidSAF.StringToUri(const AValue: string): JNet_Uri;
begin
  Result := nil;
  if AValue.Trim <> '' then
    Result := TJNet_Uri.JavaClass.parse(StringToJString(AValue));
end;

{$ENDIF}

end.
