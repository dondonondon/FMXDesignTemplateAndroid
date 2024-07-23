unit BFA.OpenUrl;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants, System.Messaging, System.StrUtils,
{$IF Defined(IOS)}
  macapi.helpers, iOSapi.Foundation, FMX.helpers.iOS;
{$ELSEIF Defined(ANDROID)}
  Androidapi.Helpers, Androidapi.JNI.Net,
  Androidapi.JNI.GraphicsContentViewText,
  Androidapi.JNI.Os, Androidapi.JNI.App, FMX.Objects, System.IOUtils,
  Androidapi.JNI.Widget,
  Androidapi.JNI.JavaTypes, FMX.TabControl, Androidapi.JNI.Provider,
  FMX.Platform.Android,
  Androidapi.JNIBridge, FMX.Surfaces, FMX.Helpers.Android, Androidapi.JNI.Media,
  Androidapi.JNI.Webkit, Androidapi.JNI, Posix.Unistd, Androidapi.JNI.Support;
{$ELSEIF Defined(MACOS)}
  Posix.Stdlib;
{$ELSEIF Defined(MSWINDOWS)}
  Winapi.ShellAPI, Winapi.Windows;
{$ENDIF}

type
  TRequestCode = class
    const
      GET_FILE_OPEN_DIRECTORY = 77;
      SAVEFILE = 88;
  end;

  TURLOpen = class
  private
    class procedure OpenIntent(ARequestCode : Integer);
    class procedure CopyFileToExternal(AFileName : String);
    class procedure CopyFileToInternal(AFileName : String);
    {$IF Defined(ANDROID)}
    class procedure OnActivityResult(RequestCode, ResultCode: Integer; Data: JIntent);
    {$ENDIF}
  public
    class function GetContentType(AFileName: String): String;
    class procedure InitSubsribeMessage;
    {$IF Defined(ANDROID)}
    class procedure ListenerMessage(const Sender: TObject; const M: TMessage);
    {$ENDIF}

    class procedure SaveFileToStorage(AFileName : String);

    class procedure OpenUrl(URL: string);
    class procedure OpenPDF(AFileName : String);
  end;

{$IF Defined(ANDROID)}
var
  FILE_FROM_OPENDIALOG : JNet_Uri;
  PERMISSION_JNETURI : JNet_Uri;
  TRANSFILEOPENURL : String;
{$ENDIF}

implementation

{ tUrlOpen }

class procedure TURLOpen.CopyFileToExternal(AFileName: String);
{$IF Defined(ANDROID)}
const
  bufferSize = 4096 * 2;
var
  noOfBytes: Integer;
  b: TJavaArray<Byte>;
  DosyaOku: JInputStream;
  DosyaYaz: JFileOutputStream;
  pfd: JParcelFileDescriptor;
{$ENDIF}
begin
{$IF Defined(ANDROID)}
  if not FileExists(AFileName) then begin
    Exit;
  end;

  try
    DosyaOku := TAndroidHelper.Context.getContentResolver.openInputStream
      (TJnet_Uri.JavaClass.fromFile(TJFile.JavaClass.init
      (StringToJString(AFileName))));
    pfd := TAndroidHelper.Activity.getContentResolver.openFileDescriptor(FILE_FROM_OPENDIALOG,
      StringToJString('w'));
    DosyaYaz := TJFileOutputStream.JavaClass.init(pfd.getFileDescriptor);
    b := TJavaArray<Byte>.Create(bufferSize);
    noOfBytes := DosyaOku.read(b);
    while (noOfBytes > 0) do
    begin
      DosyaYaz.write(b, 0, noOfBytes);
      noOfBytes := DosyaOku.read(b);
    end;
    DosyaYaz.close;
    DosyaOku.close;
  except on E: Exception do

  end;
{$ENDIF}
end;

class procedure TURLOpen.CopyFileToInternal(AFileName: String);
begin

end;

class function TURLOpen.GetContentType(AFileName: String): String;
begin
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


class procedure TURLOpen.InitSubsribeMessage;
const
  Authority: string = 'com.android.externalstorage.documents';
begin
{$IF Defined(ANDROID)}
  TMessageManager.DefaultManager.SubscribeToMessage(TMessageResultNotification,
    ListenerMessage);

  PERMISSION_JNETURI := TJDocumentsContract.JavaClass.buildTreeDocumentUri
      (StringToJString(Authority), StringToJString('primary:'));
{$ENDIF}
end;

{$IF Defined(ANDROID)}
class procedure TURLOpen.ListenerMessage(const Sender: TObject;
  const M: TMessage);
begin
  if M is TMessageResultNotification then
    OnActivityResult(TMessageResultNotification(M).RequestCode,
      TMessageResultNotification(M).ResultCode,
      TMessageResultNotification(M).Value);
end;

class procedure TURLOpen.OnActivityResult(RequestCode, ResultCode: Integer;
  Data: JIntent);
begin
  if ResultCode = TJActivity.JavaClass.RESULT_OK then begin
    FILE_FROM_OPENDIALOG := nil;
    if Assigned(Data) then begin
      FILE_FROM_OPENDIALOG := Data.getData;
      if RequestCode = TRequestCode.SAVEFILE then
        CopyFileToExternal(TRANSFILEOPENURL);
    end;
  end;
end;
{$ENDIF}

class procedure TURLOpen.OpenIntent(ARequestCode: Integer);
{$IF Defined(ANDROID)}
var
  Intent : JIntent;
{$ENDIF}
begin
{$IF Defined(ANDROID)}
  Intent := TJIntent.Create;
  Intent.setAction(TJIntent.JavaClass.ACTION_OPEN_DOCUMENT);
  Intent.addCategory(TJIntent.JavaClass.CATEGORY_OPENABLE);
  Intent.setType(StringToJString('*/*'));
  TAndroidHelper.Activity.startActivityForResult(Intent, ARequestCode);
{$ENDIF}
end;

class procedure TURLOpen.OpenPDF(AFileName: String);
{$IF Defined(ANDROID)}
var
  Intent: JIntent;
  URIFile : JNet_Uri;
  FPDF: JParcelFileDescriptor;
{$ENDIF}
begin
{$IF Defined(ANDROID)}
  FPDF := TAndroidHelper.Activity.getContentResolver.openFileDescriptor(URIFile,
      StringToJString('w'));

  Intent := TJIntent.Create;
  Intent := TJIntent.JavaClass.init(TJIntent.JavaClass.ACTION_VIEW);
  Intent.setDataAndType(URIFile, StringToJString('application/pdf'));
  Intent.putExtra(TJIntent.JavaClass.EXTRA_STREAM, JParcelable(URIFile));
  Intent.addFlags(TJIntent.JavaClass.FLAG_GRANT_READ_URI_PERMISSION);
  TAndroidHelper.Activity.startActivity(Intent);
{$ENDIF}
end;

class procedure tUrlOpen.OpenUrl(URL: string);
{$IF Defined(ANDROID)}
var
  Intent: JIntent;
{$ENDIF}
begin
{$IF Defined(ANDROID)}
  Intent := TJIntent.Create;
  Intent.setAction(TJIntent.JavaClass.ACTION_VIEW);
  Intent.setData(StrToJURI(URL));
//  Intent.setType(StringToJString(GetContentType(URL)));
  TAndroidHelper.Activity.startActivity(Intent);
  // SharedActivity.startActivity(Intent);
{$ELSEIF Defined(MSWINDOWS)}
  ShellExecute(0, 'OPEN', PWideChar(URL), nil, nil, SW_SHOWNORMAL);
{$ELSEIF Defined(IOS)}
  SharedApplication.OpenURL(StrToNSUrl(URL));
{$ELSEIF Defined(MACOS)}
  _system(PAnsiChar('open ' + AnsiString(URL)));
{$ENDIF}
end;

class procedure TURLOpen.SaveFileToStorage(AFileName: String);
{$IF Defined(ANDROID)}
var
  Intent: JIntent;
{$ENDIF}
begin
{$IF Defined(ANDROID)}
  TRANSFILEOPENURL := AFileName;

  Intent := TJIntent.Create;
  Intent.setAction(TJIntent.JavaClass.ACTION_CREATE_DOCUMENT);
  Intent.addCategory(TJIntent.JavaClass.CATEGORY_OPENABLE);
  Intent.setType(StringToJString('application/pdf'));
  Intent.putExtra(TJIntent.JavaClass.EXTRA_TITLE,
    StringToJString(TPath.GetFileName(AFileName)));
  Intent.putExtra(TJDocumentsContract.JavaClass.EXTRA_INITIAL_URI,
    JParcelable(nil));
  MainActivity.startActivityForResult(Intent, TRequestCode.SAVEFILE);
{$ENDIF}
end;

end.
