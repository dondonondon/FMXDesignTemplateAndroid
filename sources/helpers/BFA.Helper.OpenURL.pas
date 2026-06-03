unit BFA.Helper.OpenURL;

interface

uses
  System.SysUtils, System.IOUtils
  {$IF Defined(ANDROID)}
  , Androidapi.Helpers, Androidapi.JNI.App, Androidapi.JNI.GraphicsContentViewText,
  Androidapi.JNI.JavaTypes, Androidapi.JNI.Net
  {$ENDIF}
  {$IF Defined(IOS)}
  , Macapi.Helpers, iOSapi.Foundation, iOSapi.Helpers, iOSapi.UIKit
  {$ENDIF}
  {$IF Defined(MSWINDOWS)}
  , Winapi.ShellAPI, Winapi.Windows
  {$ENDIF}
  {$IF Defined(MACOS) OR Defined(OSX) OR Defined(LINUX)}
  , Posix.Stdlib
  {$ENDIF};

type
  TBFAOpenURLCompletion = procedure(ASuccess: Boolean) of object;

  THelperOpenURL = class
  private
    class function BuildGoogleMapsDirectionURL(const ALatitude, ALongitude: Double): string; static;
    class function BuildNativeMapsDirectionURL(const ALatitude, ALongitude: Double): string; static;
    class function FormatCoordinate(const AValue: Double): string; static;
    class function HasScheme(const AValue: string): Boolean; static;
    class function NormalizeFileURL(const AFileName: string): string; static;
    class function OpenURLInternal(const AURL: string; ACompletion: TBFAOpenURLCompletion): Boolean; static;

    {$IF Defined(ANDROID)}
    class function AndroidStartActivity(const AIntent: JIntent): Boolean; static;
    {$ENDIF}

    {$IF Defined(MACOS) OR Defined(OSX) OR Defined(LINUX)}
    class function PosixOpenCommand: string; static;
    class function PosixShellQuote(const AValue: string): string; static;
    {$ENDIF}
  public
    class function CanOpenURL(const AURL: string): Boolean; static;
    class function GetContentType(const AFileName: string): string; static;
    class function OpenFile(const AFileName: string): Boolean; static;
    class function OpenMapsDirection(const ALatitude, ALongitude: Double;
      const APreferNativeMaps: Boolean = True): Boolean; static;
    class function OpenPDF(const AFileName: string): Boolean; static;
    class function OpenURL(const AURL: string): Boolean; overload; static;
    class function OpenURL(const AURL: string;
      ACompletion: TBFAOpenURLCompletion): Boolean; overload; static;
  end;

  TURLOpen = THelperOpenURL;

implementation

{ THelperOpenURL }

{$IF Defined(ANDROID)}
class function THelperOpenURL.AndroidStartActivity(const AIntent: JIntent): Boolean;
begin
  Result := False;
  if not Assigned(AIntent) then exit;

  if AIntent.resolveActivity(TAndroidHelper.Context.getPackageManager) = nil then exit;

  if Assigned(TAndroidHelper.Activity) then
    TAndroidHelper.Activity.startActivity(AIntent)
  else begin
    AIntent.addFlags(TJIntent.JavaClass.FLAG_ACTIVITY_NEW_TASK);
    TAndroidHelper.Context.startActivity(AIntent);
  end;

  Result := True;
end;
{$ENDIF}

class function THelperOpenURL.BuildGoogleMapsDirectionURL(const ALatitude,
  ALongitude: Double): string;
begin
  Result := Format('https://www.google.com/maps/dir/?api=1&destination=%s,%s',
    [FormatCoordinate(ALatitude), FormatCoordinate(ALongitude)]);
end;

class function THelperOpenURL.BuildNativeMapsDirectionURL(const ALatitude,
  ALongitude: Double): string;
begin
  {$IF Defined(ANDROID)}
  Result := Format('google.navigation:q=%s,%s&mode=d',
    [FormatCoordinate(ALatitude), FormatCoordinate(ALongitude)]);
  {$ELSEIF Defined(IOS)}
  Result := Format('http://maps.apple.com/?daddr=%s,%s&dirflg=d',
    [FormatCoordinate(ALatitude), FormatCoordinate(ALongitude)]);
  {$ELSE}
  Result := BuildGoogleMapsDirectionURL(ALatitude, ALongitude);
  {$ENDIF}
end;

class function THelperOpenURL.CanOpenURL(const AURL: string): Boolean;
{$IF Defined(ANDROID)}
var
  LIntent: JIntent;
{$ENDIF}
{$IF Defined(IOS)}
var
  LURL: NSURL;
{$ENDIF}
begin
  Result := not AURL.Trim.IsEmpty;
  if not Result then exit;

  {$IF Defined(ANDROID)}
  LIntent := TJIntent.Create;
  LIntent.setAction(TJIntent.JavaClass.ACTION_VIEW);
  LIntent.setData(StrToJURI(AURL));
  Result := LIntent.resolveActivity(TAndroidHelper.Context.getPackageManager) <> nil;
  {$ENDIF}

  {$IF Defined(IOS)}
  LURL := StrToNSUrl(AURL);
  Result := Assigned(LURL) and TiOSHelper.SharedApplication.canOpenURL(LURL);
  {$ENDIF}
end;

class function THelperOpenURL.FormatCoordinate(const AValue: Double): string;
var
  LFormatSettings: TFormatSettings;
begin
  LFormatSettings := TFormatSettings.Create('en-US');
  Result := FormatFloat('0.######', AValue, LFormatSettings);
end;

class function THelperOpenURL.GetContentType(const AFileName: string): string;
var
  LExt: string;
begin
  LExt := TPath.GetExtension(AFileName).ToLower;

  if LExt = '.aac' then
    Result := 'audio/aac'
  else if LExt = '.abw' then
    Result := 'application/x-abiword'
  else if LExt = '.arc' then
    Result := 'application/x-freearc'
  else if LExt = '.avif' then
    Result := 'image/avif'
  else if LExt = '.avi' then
    Result := 'video/x-msvideo'
  else if LExt = '.azw' then
    Result := 'application/vnd.amazon.ebook'
  else if LExt = '.bin' then
    Result := 'application/octet-stream'
  else if LExt = '.bmp' then
    Result := 'image/bmp'
  else if LExt = '.bz' then
    Result := 'application/x-bzip'
  else if LExt = '.bz2' then
    Result := 'application/x-bzip2'
  else if LExt = '.cda' then
    Result := 'application/x-cdf'
  else if LExt = '.csh' then
    Result := 'application/x-csh'
  else if LExt = '.css' then
    Result := 'text/css'
  else if LExt = '.csv' then
    Result := 'text/csv'
  else if LExt = '.doc' then
    Result := 'application/msword'
  else if LExt = '.docx' then
    Result := 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
  else if LExt = '.eot' then
    Result := 'application/vnd.ms-fontobject'
  else if LExt = '.epub' then
    Result := 'application/epub+zip'
  else if LExt = '.gz' then
    Result := 'application/gzip'
  else if LExt = '.gif' then
    Result := 'image/gif'
  else if (LExt = '.htm') or (LExt = '.html') then
    Result := 'text/html'
  else if LExt = '.ico' then
    Result := 'image/vnd.microsoft.icon'
  else if LExt = '.ics' then
    Result := 'text/calendar'
  else if LExt = '.jar' then
    Result := 'application/java-archive'
  else if (LExt = '.jpg') or (LExt = '.jpeg') then
    Result := 'image/jpeg'
  else if (LExt = '.js') or (LExt = '.mjs') then
    Result := 'text/javascript'
  else if LExt = '.json' then
    Result := 'application/json'
  else if LExt = '.jsonld' then
    Result := 'application/ld+json'
  else if LExt = '.mid' then
    Result := 'audio/x-midi'
  else if LExt = '.midi' then
    Result := 'audio/midi'
  else if LExt = '.mp3' then
    Result := 'audio/mpeg'
  else if LExt = '.mp4' then
    Result := 'video/mp4'
  else if LExt = '.mpeg' then
    Result := 'video/mpeg'
  else if LExt = '.mpkg' then
    Result := 'application/vnd.apple.installer+xml'
  else if LExt = '.odp' then
    Result := 'application/vnd.oasis.opendocument.presentation'
  else if LExt = '.ods' then
    Result := 'application/vnd.oasis.opendocument.spreadsheet'
  else if LExt = '.odt' then
    Result := 'application/vnd.oasis.opendocument.text'
  else if LExt = '.oga' then
    Result := 'audio/ogg'
  else if LExt = '.ogv' then
    Result := 'video/ogg'
  else if LExt = '.ogx' then
    Result := 'application/ogg'
  else if LExt = '.opus' then
    Result := 'audio/opus'
  else if LExt = '.otf' then
    Result := 'font/otf'
  else if LExt = '.png' then
    Result := 'image/png'
  else if LExt = '.pdf' then
    Result := 'application/pdf'
  else if LExt = '.php' then
    Result := 'application/x-httpd-php'
  else if LExt = '.ppt' then
    Result := 'application/vnd.ms-powerpoint'
  else if LExt = '.pptx' then
    Result := 'application/vnd.openxmlformats-officedocument.presentationml.presentation'
  else if LExt = '.rar' then
    Result := 'application/vnd.rar'
  else if LExt = '.rtf' then
    Result := 'application/rtf'
  else if LExt = '.sh' then
    Result := 'application/x-sh'
  else if LExt = '.svg' then
    Result := 'image/svg+xml'
  else if LExt = '.tar' then
    Result := 'application/x-tar'
  else if (LExt = '.tif') or (LExt = '.tiff') then
    Result := 'image/tiff'
  else if LExt = '.ts' then
    Result := 'video/mp2t'
  else if LExt = '.ttf' then
    Result := 'font/ttf'
  else if LExt = '.txt' then
    Result := 'text/plain'
  else if LExt = '.vsd' then
    Result := 'application/vnd.visio'
  else if LExt = '.wav' then
    Result := 'audio/wav'
  else if LExt = '.weba' then
    Result := 'audio/webm'
  else if LExt = '.webm' then
    Result := 'video/webm'
  else if LExt = '.webp' then
    Result := 'image/webp'
  else if LExt = '.woff' then
    Result := 'font/woff'
  else if LExt = '.woff2' then
    Result := 'font/woff2'
  else if LExt = '.xhtml' then
    Result := 'application/xhtml+xml'
  else if LExt = '.xls' then
    Result := 'application/vnd.ms-excel'
  else if LExt = '.xlsx' then
    Result := 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
  else if LExt = '.xml' then
    Result := 'application/xml'
  else if LExt = '.xul' then
    Result := 'application/vnd.mozilla.xul+xml'
  else if LExt = '.zip' then
    Result := 'application/zip'
  else if LExt = '.3gp' then
    Result := 'video/3gpp'
  else if LExt = '.3g2' then
    Result := 'video/3gpp2'
  else if LExt = '.7z' then
    Result := 'application/x-7z-compressed'
  else
    Result := 'application/octet-stream';
end;

class function THelperOpenURL.HasScheme(const AValue: string): Boolean;
var
  LIndex: Integer;
begin
  Result := False;
  LIndex := AValue.IndexOf(':');
  if LIndex <= 0 then exit;

  {$IF Defined(MSWINDOWS)}
  if (LIndex = 1) and CharInSet(AValue[1], ['A'..'Z', 'a'..'z']) then exit;
  {$ENDIF}

  Result := True;
end;

class function THelperOpenURL.NormalizeFileURL(const AFileName: string): string;
begin
  Result := AFileName;
  if Result.Trim.IsEmpty then exit;

  if HasScheme(Result) then exit;

  Result := 'file://' + StringReplace(TPath.GetFullPath(Result), '\', '/', [rfReplaceAll]);
end;

class function THelperOpenURL.OpenFile(const AFileName: string): Boolean;
{$IF Defined(ANDROID)}
var
  LFile: JFile;
  LIntent: JIntent;
  LURI: JNet_Uri;
{$ENDIF}
{$IF Defined(IOS)}
var
  LURL: NSURL;
{$ENDIF}
begin
  Result := False;
  if AFileName.Trim.IsEmpty then exit;

  {$IF Defined(ANDROID)}
  if not TFile.Exists(AFileName) then exit;

  LFile := TJFile.JavaClass.init(StringToJString(AFileName));
  LURI := TAndroidHelper.JFileToJURI(LFile);
  LIntent := TJIntent.Create;
  LIntent.setAction(TJIntent.JavaClass.ACTION_VIEW);
  LIntent.setDataAndType(LURI, StringToJString(GetContentType(AFileName)));
  LIntent.addFlags(TJIntent.JavaClass.FLAG_GRANT_READ_URI_PERMISSION);
  Result := AndroidStartActivity(LIntent);
  {$ELSEIF Defined(IOS)}
  if not TFile.Exists(AFileName) then exit;

  LURL := TNSURL.Wrap(TNSURL.OCClass.fileURLWithPath(StrToNSStr(AFileName)));
  Result := Assigned(LURL) and TiOSHelper.SharedApplication.openURL(LURL);
  {$ELSE}
  Result := OpenURL(NormalizeFileURL(AFileName));
  {$ENDIF}
end;

class function THelperOpenURL.OpenMapsDirection(const ALatitude,
  ALongitude: Double; const APreferNativeMaps: Boolean): Boolean;
{$IF Defined(ANDROID)}
var
  LIntent: JIntent;
  LNativeURL: string;
{$ENDIF}
begin
  if APreferNativeMaps then begin
    {$IF Defined(ANDROID)}
    LNativeURL := BuildNativeMapsDirectionURL(ALatitude, ALongitude);
    LIntent := TJIntent.JavaClass.init(TJIntent.JavaClass.ACTION_VIEW, StrToJURI(LNativeURL));
    LIntent.setPackage(StringToJString('com.google.android.apps.maps'));
    Result := AndroidStartActivity(LIntent);
    if Result then exit;
    {$ELSE}
    Result := OpenURL(BuildNativeMapsDirectionURL(ALatitude, ALongitude));
    if Result then exit;
    {$ENDIF}
  end;

  Result := OpenURL(BuildGoogleMapsDirectionURL(ALatitude, ALongitude));
end;

class function THelperOpenURL.OpenPDF(const AFileName: string): Boolean;
begin
  Result := OpenFile(AFileName);
end;

class function THelperOpenURL.OpenURL(const AURL: string): Boolean;
begin
  Result := OpenURLInternal(AURL, nil);
end;

class function THelperOpenURL.OpenURL(const AURL: string;
  ACompletion: TBFAOpenURLCompletion): Boolean;
begin
  Result := OpenURLInternal(AURL, ACompletion);
end;

class function THelperOpenURL.OpenURLInternal(const AURL: string;
  ACompletion: TBFAOpenURLCompletion): Boolean;
{$IF Defined(ANDROID)}
var
  LIntent: JIntent;
{$ENDIF}
{$IF Defined(IOS)}
var
  LURL: NSURL;
{$ENDIF}
{$IF Defined(MSWINDOWS)}
var
  LResult: HINST;
{$ENDIF}
{$IF Defined(MACOS) OR Defined(OSX) OR Defined(LINUX)}
var
  LCommand: string;
{$ENDIF}
begin
  Result := False;
  if AURL.Trim.IsEmpty then exit;

  if (not HasScheme(AURL)) and TFile.Exists(AURL) then begin
    Result := OpenFile(AURL);
    if Assigned(ACompletion) then begin
      ACompletion(Result);
    end;
    exit;
  end;

  {$IF Defined(ANDROID)}
  LIntent := TJIntent.Create;
  LIntent.setAction(TJIntent.JavaClass.ACTION_VIEW);
  LIntent.setData(StrToJURI(AURL));
  Result := AndroidStartActivity(LIntent);
  if Assigned(ACompletion) then begin
    ACompletion(Result);
  end;
  {$ELSEIF Defined(IOS)}
  LURL := StrToNSUrl(AURL);
  if not Assigned(LURL) then begin
    if Assigned(ACompletion) then begin
      ACompletion(False);
    end;
    exit;
  end;

  if Assigned(ACompletion) then begin
    TiOSHelper.SharedApplication.openURL(LURL, nil, TUIApplicationBlockMethod1(ACompletion));
    Result := True;
  end else begin
    Result := TiOSHelper.SharedApplication.openURL(LURL);
  end;
  {$ELSEIF Defined(MSWINDOWS)}
  LResult := ShellExecute(0, 'open', PChar(AURL), nil, nil, SW_SHOWNORMAL);
  Result := LResult > 32;
  if Assigned(ACompletion) then begin
    ACompletion(Result);
  end;
  {$ELSEIF Defined(MACOS) OR Defined(OSX) OR Defined(LINUX)}
  LCommand := PosixOpenCommand + ' ' + PosixShellQuote(AURL) + ' >/dev/null 2>&1 &';
  Result := _system(PAnsiChar(UTF8String(LCommand))) = 0;
  if Assigned(ACompletion) then begin
    ACompletion(Result);
  end;
  {$ELSE}
  if Assigned(ACompletion) then begin
    ACompletion(False);
  end;
  {$ENDIF}
end;

{$IF Defined(MACOS) OR Defined(OSX) OR Defined(LINUX)}
class function THelperOpenURL.PosixOpenCommand: string;
begin
  {$IF Defined(LINUX)}
  Result := 'xdg-open';
  {$ELSE}
  Result := 'open';
  {$ENDIF}
end;

class function THelperOpenURL.PosixShellQuote(const AValue: string): string;
var
  LChar: Char;
begin
  Result := '''';
  for LChar in AValue do begin
    if LChar = '''' then
      Result := Result + #39 + '"' + #39 + '"' + #39
    else
      Result := Result + LChar;
  end;
  Result := Result + '''';
end;
{$ENDIF}

end.
