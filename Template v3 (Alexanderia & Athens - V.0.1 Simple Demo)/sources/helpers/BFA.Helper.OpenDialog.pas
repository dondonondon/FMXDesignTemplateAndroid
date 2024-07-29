unit BFA.Helper.OpenDialog;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants, System.Messaging, System.StrUtils, FMX.Dialogs,
{$IF DEFINED(IOS)}
  macapi.helpers, iOSapi.Foundation, FMX.helpers.iOS;
{$ELSEIF DEFINED(ANDROID)}
  Androidapi.Helpers, Androidapi.JNI.Net,
  Androidapi.JNI.GraphicsContentViewText,
  Androidapi.JNI.Os, Androidapi.JNI.App, FMX.Objects, System.IOUtils,
  Androidapi.JNI.Widget,
  Androidapi.JNI.JavaTypes, FMX.TabControl, Androidapi.JNI.Provider,
  FMX.Platform.Android,
  Androidapi.JNIBridge, FMX.Surfaces, FMX.Helpers.Android, Androidapi.JNI.Media,
  Androidapi.JNI.Webkit, Androidapi.JNI, Posix.Unistd, Androidapi.JNI.Support;
{$ELSEIF DEFINED(MACOS)}
  Posix.Stdlib;
{$ELSEIF DEFINED(MSWINDOWS)}
  Winapi.ShellAPI, Winapi.Windows;
{$ENDIF}

type
  TBFAGetFileType = class
    class function GetContentType(AFileName: String): String;
  end;

  TBFAURLOpen = class
    class procedure OpenUrl(URL: string);
  end;

  TBFARequestCodeOpenDialog = class
    const
      SAVEFILE_TO_INTERNAL = 99;
      GET_FILE_OPEN_DIRECTORY = 77;
      SAVEFILE = 88;
  end;

  TBFAOpenDialog = class
  private
    {$IF DEFINED(ANDROID)}
    class var OD_FILE_FROM_OPENDIALOG : JNet_Uri;
    class var OD_PERMISSION_JNETURI : JNet_Uri;

    class procedure OnActivityResult(RequestCode, ResultCode: Integer; Data: JIntent);
    class function GetFileName(AUri : JNet_Uri) : String;
    {$ENDIF}

    class procedure ListenerMessage(const Sender: TObject; const M: TMessage);

    class procedure CopyFileToExternal(AFileName : String);
    class procedure CopyFileToInternal(AFileName : String);

    class procedure ConvertToNetUri(AFileName : String);
  public
    class var OD_TRANSFILENAME : String;

    class procedure OpenIntent(ARequestCode : Integer);
    class procedure InitSubsribeMessage;

    class procedure OpenFile(AFileName : String = '');

    class procedure ShareFile(AFileName : String = '');
    class procedure SaveFileInternalToExternal(AFileName : String);
  end;

implementation

{ TBFAURLOpen }

class procedure TBFAURLOpen.OpenUrl(URL: string);
{$IF DEFINED(ANDROID)}
var
  Intent: JIntent;
{$ENDIF}
begin
{$IF DEFINED(ANDROID)}
  Intent := TJIntent.Create;
  Intent.setAction(TJIntent.JavaClass.ACTION_VIEW);
  Intent.setData(StrToJURI(URL));
  TAndroidHelper.Activity.startActivity(Intent);
{$ELSEIF DEFINED(MSWINDOWS)}
  ShellExecute(0, 'OPEN', PWideChar(URL), nil, nil, SW_SHOWNORMAL);
{$ELSEIF DEFINED(IOS)}
  SharedApplication.OpenURL(StrToNSUrl(URL));
{$ELSEIF DEFINED(MACOS)}
  _system(PAnsiChar('open ' + AnsiString(URL)));
{$ENDIF}
end;

{ TBFAGetFileType }

class function TBFAGetFileType.GetContentType(AFileName: String): String;
begin

  {you can use ExtToMime := mime.getMimeTypeFromExtension(StringToJString(ExtFile));}

  var ContentType: String;
  ContentType := 'application/json';

  if ContainsStr(AFileName, '.aac') then
    ContentType := 'audio/aac'
  else if ContainsStr(AFileName, '.abw') then
    ContentType := 'application/x-abiword'
  else if ContainsStr(AFileName, '.arc') then
    ContentType := 'application/x-freearc'
  else if ContainsStr(AFileName, '.avif') then
    ContentType := 'image/avif'
  else if ContainsStr(AFileName, '.avi') then
    ContentType := 'video/x-msvideo'
  else if ContainsStr(AFileName, '.azw') then
    ContentType := 'application/vnd.amazon.ebook'
  else if ContainsStr(AFileName, '.bin') then
    ContentType := 'application/octet-stream'
  else if ContainsStr(AFileName, '.bmp') then
    ContentType := 'image/bmp'
  else if ContainsStr(AFileName, '.bz') then
    ContentType := 'application/x-bzip'
  else if ContainsStr(AFileName, '.bz2') then
    ContentType := 'application/x-bzip2'
  else if ContainsStr(AFileName, '.cda') then
    ContentType := 'application/x-cdf'
  else if ContainsStr(AFileName, '.csh') then
    ContentType := 'application/x-csh'
  else if ContainsStr(AFileName, '.css') then
    ContentType := 'text/css'
  else if ContainsStr(AFileName, '.csv') then
    ContentType := 'text/csv'
  else if ContainsStr(AFileName, '.doc') then
    ContentType := 'application/msword'
  else if ContainsStr(AFileName, '.docx') then
    ContentType :=
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
  else if ContainsStr(AFileName, '.eot') then
    ContentType := 'application/vnd.ms-fontobject'
  else if ContainsStr(AFileName, '.epub') then
    ContentType := 'application/epub+zip'
  else if ContainsStr(AFileName, '.gz') then
    ContentType := 'application/gzip'
  else if ContainsStr(AFileName, '.gif') then
    ContentType := 'image/gif'
  else if ContainsStr(AFileName, '.html') then
    ContentType := 'text/html'
  else if ContainsStr(AFileName, '.htm') then
    ContentType := 'text/html'
  else if ContainsStr(AFileName, '.ico') then
    ContentType := 'image/vnd.microsoft.icon'
  else if ContainsStr(AFileName, '.ics') then
    ContentType := 'text/calendar'
  else if ContainsStr(AFileName, '.jar') then
    ContentType := 'application/java-archive'
  else if ContainsStr(AFileName, '.jpeg') then
    ContentType := 'image/jpeg'
  else if ContainsStr(AFileName, '.jpg') then
    ContentType := 'image/jpeg'
  else if ContainsStr(AFileName, '.js') then
    ContentType := 'text/javascript'
  else if ContainsStr(AFileName, '.json') then
    ContentType := 'application/json'
  else if ContainsStr(AFileName, '.jsonld') then
    ContentType := 'application/ld+json'
  else if ContainsStr(AFileName, '.mid') then
    ContentType := 'audio/x-midi'
  else if ContainsStr(AFileName, '.midi') then
    ContentType := 'audio/midi'
  else if ContainsStr(AFileName, '.mjs') then
    ContentType := 'text/javascript'
  else if ContainsStr(AFileName, '.mp3') then
    ContentType := 'audio/mpeg'
  else if ContainsStr(AFileName, '.mp4') then
    ContentType := 'video/mp4'
  else if ContainsStr(AFileName, '.mpeg') then
    ContentType := 'video/mpeg'
  else if ContainsStr(AFileName, '.mpkg') then
    ContentType := 'application/vnd.apple.installer+xml'
  else if ContainsStr(AFileName, '.odp') then
    ContentType := 'application/vnd.oasis.opendocument.presentation'
  else if ContainsStr(AFileName, '.ods') then
    ContentType := 'application/vnd.oasis.opendocument.spreadsheet'
  else if ContainsStr(AFileName, '.odt') then
    ContentType := 'application/vnd.oasis.opendocument.text'
  else if ContainsStr(AFileName, '.oga') then
    ContentType := 'audio/ogg'
  else if ContainsStr(AFileName, '.ogv') then
    ContentType := 'video/ogg'
  else if ContainsStr(AFileName, '.ogx') then
    ContentType := 'application/ogg'
  else if ContainsStr(AFileName, '.opus') then
    ContentType := 'audio/opus'
  else if ContainsStr(AFileName, '.otf') then
    ContentType := 'font/otf'
  else if ContainsStr(AFileName, '.png') then
    ContentType := 'image/png'
  else if ContainsStr(AFileName, '.pdf') then
    ContentType := 'application/pdf'
  else if ContainsStr(AFileName, '.php') then
    ContentType := 'application/x-httpd-php'
  else if ContainsStr(AFileName, '.ppt') then
    ContentType := 'application/vnd.ms-powerpoint'
  else if ContainsStr(AFileName, '.pptx') then
    ContentType :=
      'application/vnd.openxmlformats-officedocument.presentationml.presentation'
  else if ContainsStr(AFileName, '.rar') then
    ContentType := 'application/vnd.rar'
  else if ContainsStr(AFileName, '.rtf') then
    ContentType := 'application/rtf'
  else if ContainsStr(AFileName, '.sh') then
    ContentType := 'application/x-sh'
  else if ContainsStr(AFileName, '.svg') then
    ContentType := 'image/svg+xml'
  else if ContainsStr(AFileName, '.tar') then
    ContentType := 'application/x-tar'
  else if ContainsStr(AFileName, '.tif') then
    ContentType := 'image/tiff'
  else if ContainsStr(AFileName, '.tiff') then
    ContentType := 'image/tiff'
  else if ContainsStr(AFileName, '.ts') then
    ContentType := 'video/mp2t'
  else if ContainsStr(AFileName, '.ttf') then
    ContentType := 'font/ttf'
  else if ContainsStr(AFileName, '.txt') then
    ContentType := 'text/plain'
  else if ContainsStr(AFileName, '.vsd') then
    ContentType := 'application/vnd.visio'
  else if ContainsStr(AFileName, '.wav') then
    ContentType := 'audio/wav'
  else if ContainsStr(AFileName, '.weba') then
    ContentType := 'audio/webm'
  else if ContainsStr(AFileName, '.webm') then
    ContentType := 'video/webm'
  else if ContainsStr(AFileName, '.webp') then
    ContentType := 'image/webp'
  else if ContainsStr(AFileName, '.woff') then
    ContentType := 'font/woff'
  else if ContainsStr(AFileName, '.woff2') then
    ContentType := 'font/woff2'
  else if ContainsStr(AFileName, '.xhtml') then
    ContentType := 'application/xhtml+xml'
  else if ContainsStr(AFileName, '.xls') then
    ContentType := 'application/vnd.ms-excel'
  else if ContainsStr(AFileName, '.xlsx') then
    ContentType :=
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
  else if ContainsStr(AFileName, '.xml') then
    ContentType := 'application/xml'
  else if ContainsStr(AFileName, '.xul') then
    ContentType := 'application/vnd.mozilla.xul+xml'
  else if ContainsStr(AFileName, '.zip') then
    ContentType := 'application/zip'
  else if ContainsStr(AFileName, '.3gp') then
    ContentType := 'video/3gpp'
  else if ContainsStr(AFileName, '.3g2') then
    ContentType := 'video/3gpp2'
  else if ContainsStr(AFileName, '.7z') then
    ContentType := 'application/x-7z-compressed';

  Result := ContentType;
end;

{ TBFAOpenDialog }

class procedure TBFAOpenDialog.ConvertToNetUri(AFileName: String);
{$IF DEFINED(ANDROID)}
var
  FFile: JFile;
  Context: JContext;
  FileProviderAuthority: JString;
{$ENDIF}
begin
{$IF DEFINED(ANDROID)}
  FFile := TJFile.JavaClass.init(StringToJString(AFileName));
  Context := TAndroidHelper.Context;
  FileProviderAuthority := Context.getApplicationContext.getPackageName.concat(StringToJString('.fileprovider'));
  OD_FILE_FROM_OPENDIALOG := TJcontent_FileProvider.JavaClass.getUriForFile(Context, FileProviderAuthority, FFile);
  OD_TRANSFILENAME := GetFileName(OD_FILE_FROM_OPENDIALOG);
{$ENDIF}
end;

class procedure TBFAOpenDialog.CopyFileToExternal(AFileName: String);
{$IF DEFINED(ANDROID)}
const
  FBufferSize = 4096 * 2;
var
  FFileOfByte: Integer;
  FArrayData: TJavaArray<Byte>;
  FInputFile: JInputStream;
  FOutputFile: JFileOutputStream;
  FFileDescriptor: JParcelFileDescriptor;
{$ENDIF}
begin
{$IF DEFINED(ANDROID)}
  if not FileExists(AFileName) then Exit;

  try
    FInputFile := TAndroidHelper.Context.getContentResolver.openInputStream
      (TJnet_Uri.JavaClass.fromFile(TJFile.JavaClass.init
      (StringToJString(AFileName))));
    FFileDescriptor := TAndroidHelper.Activity.getContentResolver.openFileDescriptor(OD_FILE_FROM_OPENDIALOG,
      StringToJString('w'));
    FOutputFile := TJFileOutputStream.JavaClass.init(FFileDescriptor.getFileDescriptor);
    FArrayData := TJavaArray<Byte>.Create(FBufferSize);
    FFileOfByte := FInputFile.read(FArrayData);

    while (FFileOfByte > 0) do begin
      FOutputFile.write(FArrayData, 0, FFileOfByte);
      FFileOfByte := FInputFile.read(FArrayData);
    end;

    FOutputFile.close;
    FInputFile.close;
  except on E: Exception do
    ShowMessage(E.Message);
  end;
{$ENDIF}
end;

class procedure TBFAOpenDialog.CopyFileToInternal(AFileName: String);
{$IF DEFINED(ANDROID)}
const
  FBufferSize = 4096 * 2;
var
  FFileOfBytes: Integer;
  FArrayData: TJavaArray<Byte>;
  FInputFile: JInputStream;
  FOutputFile: JFileOutputStream;
{$ENDIF}
begin
{$IF DEFINED(ANDROID)}
  try
    FOutputFile := TJFileOutputStream.JavaClass.init(StringToJString(AFileName));
    FInputFile := TAndroidHelper.Context.getContentResolver.
      openInputStream(OD_FILE_FROM_OPENDIALOG);
    FArrayData := TJavaArray<Byte>.Create(FBufferSize);
    FFileOfBytes := FInputFile.read(FArrayData);
    while (FFileOfBytes > 0) do
    begin
      FOutputFile.write(FArrayData, 0, FFileOfBytes);
      FFileOfBytes := FInputFile.read(FArrayData);
    end;
    FOutputFile.close;
    FInputFile.close;
  except on E: Exception do
    ShowMessage(E.Message);
  end;
{$ENDIF}
end;

{$IF DEFINED(ANDROID)}
class function TBFAOpenDialog.GetFileName(AUri: JNet_Uri): String;
var
  C: JCursor;
begin
  result := '';
  try
    C := TAndroidHelper.Activity.getContentResolver.query(AUri, nil, nil, nil,
      nil, nil);
    if (C = nil) then
      exit;
    C.moveToFirst;
    result := JStringToString
      (C.getString(C.getColumnIndex(TJOpenableColumns.JavaClass.DISPLAY_NAME)));
  finally
    C.close;
  end;
end;
{$ENDIF}

class procedure TBFAOpenDialog.InitSubsribeMessage;
const
  Authority: string = 'com.android.externalstorage.documents';
begin
{$IF DEFINED(ANDROID)}
  TMessageManager.DefaultManager.SubscribeToMessage(TMessageResultNotification,
    ListenerMessage);

  OD_PERMISSION_JNETURI := TJDocumentsContract.JavaClass.buildTreeDocumentUri
      (StringToJString(Authority), StringToJString('primary:'));
{$ENDIF}
end;

class procedure TBFAOpenDialog.ListenerMessage(const Sender: TObject;
  const M: TMessage);
begin
{$IF DEFINED(ANDROID)}
  if M is TMessageResultNotification then
    OnActivityResult(TMessageResultNotification(M).RequestCode,
      TMessageResultNotification(M).ResultCode,
      TMessageResultNotification(M).Value);
{$ENDIF}
end;

{$IF DEFINED(ANDROID)}
class procedure TBFAOpenDialog.OnActivityResult(RequestCode, ResultCode: Integer;
  Data: JIntent);
begin
  try
    if ResultCode = TJActivity.JavaClass.RESULT_OK then begin
      OD_FILE_FROM_OPENDIALOG := nil;
      if Assigned(Data) then begin
        OD_FILE_FROM_OPENDIALOG := Data.getData;
        if RequestCode = TBFARequestCodeOpenDialog.SAVEFILE then begin
          CopyFileToExternal(OD_TRANSFILENAME);
        end else if RequestCode = TBFARequestCodeOpenDialog.SAVEFILE_TO_INTERNAL then begin
          if OD_TRANSFILENAME = '' then begin
            ShowMessage('Filename "OD_TRANSFILENAME" not set!');
            Exit;
          end;

          CopyFileToInternal(OD_TRANSFILENAME);
        end else if RequestCode = TBFARequestCodeOpenDialog.GET_FILE_OPEN_DIRECTORY then begin
          OD_TRANSFILENAME := GetFileName(OD_FILE_FROM_OPENDIALOG);
        end;
      end;
    end;
  finally
    if RequestCode <> TBFARequestCodeOpenDialog.GET_FILE_OPEN_DIRECTORY then
      OD_TRANSFILENAME := '';
  end;
end;
{$ENDIF}

class procedure TBFAOpenDialog.OpenFile(AFileName: String);
{$IF DEFINED(ANDROID)}
var
  mime: JMimeTypeMap;
  ExtToMime: JString;
  Intent: JIntent;
  ExtFile : String;
  FFileName: string;
{$ENDIF}
begin
{$IF DEFINED(ANDROID)}
  if AFileName <> '' then
    ConvertToNetUri(AFileName);

  FFileName := ExtractFileName(OD_TRANSFILENAME);
  OD_TRANSFILENAME := '';

  ExtFile := AnsiLowerCase(StringReplace(TPath.GetExtension(FFileName),
    '.', '', []));
  mime := TJMimeTypeMap.JavaClass.getSingleton();
  ExtToMime := mime.getMimeTypeFromExtension(StringToJString(ExtFile));

  Intent := TJIntent.Create;
  Intent := TJIntent.JavaClass.init(TJIntent.JavaClass.ACTION_VIEW);
  Intent.setDataAndType(OD_FILE_FROM_OPENDIALOG, ExtToMime);
  Intent.putExtra(TJIntent.JavaClass.EXTRA_STREAM, JParcelable(OD_FILE_FROM_OPENDIALOG));
  Intent.addFlags(TJIntent.JavaClass.FLAG_GRANT_READ_URI_PERMISSION);
  TAndroidHelper.Activity.startActivity(Intent);
{$ENDIF}
end;

class procedure TBFAOpenDialog.OpenIntent(ARequestCode: Integer);
{$IF DEFINED(ANDROID)}
var
  Intent : JIntent;
{$ENDIF}
begin
{$IF DEFINED(ANDROID)}
  Intent := TJIntent.Create;
  Intent.setAction(TJIntent.JavaClass.ACTION_OPEN_DOCUMENT);
  Intent.addCategory(TJIntent.JavaClass.CATEGORY_OPENABLE);
  Intent.setType(StringToJString('*/*'));
  TAndroidHelper.Activity.startActivityForResult(Intent, ARequestCode);
{$ENDIF}
end;

class procedure TBFAOpenDialog.SaveFileInternalToExternal(AFileName: String);
{$IF DEFINED(ANDROID)}
var
  Intent: JIntent;
{$ENDIF}
begin
{$IF DEFINED(ANDROID)}
  OD_TRANSFILENAME := AFileName;

  Intent := TJIntent.Create;
  Intent.setAction(TJIntent.JavaClass.ACTION_CREATE_DOCUMENT);
  Intent.addCategory(TJIntent.JavaClass.CATEGORY_OPENABLE);
  Intent.setType(StringToJString(TBFAGetFileType.GetContentType(AFileName)));
  Intent.putExtra(TJIntent.JavaClass.EXTRA_TITLE,
    StringToJString(TPath.GetFileName(AFileName)));
  Intent.putExtra(TJDocumentsContract.JavaClass.EXTRA_INITIAL_URI,
    JParcelable(nil));
  MainActivity.startActivityForResult(Intent, TBFARequestCodeOpenDialog.SAVEFILE);
{$ENDIF}
end;

class procedure TBFAOpenDialog.ShareFile(AFileName : String);
{$IF DEFINED(ANDROID)}
var
  Intent: JIntent;
  mime: JMimeTypeMap;
  ExtToMime: JString;
  ExtFile: string;
  FFileName: string;
{$ENDIF}
begin
{$IF DEFINED(ANDROID)}
  if AFileName <> '' then
    ConvertToNetUri(AFileName);

  FFileName := ExtractFileName(OD_TRANSFILENAME);
  OD_TRANSFILENAME := '';

  ExtFile := AnsiLowerCase(StringReplace(TPath.GetExtension(FFileName),
    '.', '', []));
  mime := TJMimeTypeMap.JavaClass.getSingleton();
  ExtToMime := mime.getMimeTypeFromExtension(StringToJString(ExtFile));
  Intent := TJIntent.Create;
  Intent.setAction(TJIntent.JavaClass.ACTION_SEND);
  Intent.setDataAndType(OD_FILE_FROM_OPENDIALOG, ExtToMime);
  Intent.putExtra(TJIntent.JavaClass.EXTRA_STREAM, JParcelable(OD_FILE_FROM_OPENDIALOG));
  Intent.addFlags(TJIntent.JavaClass.FLAG_GRANT_READ_URI_PERMISSION);
  TAndroidHelper.Activity.startActivity(TJIntent.JavaClass.createChooser(Intent,
    StrToJCharSequence('Share File : ')));
{$ENDIF}
end;

end.
