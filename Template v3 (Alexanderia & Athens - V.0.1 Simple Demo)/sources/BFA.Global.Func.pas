unit BFA.Global.Func;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, System.Generics.Collections, System.Net.URLClient, System.Net.HttpClient,
  System.Net.HttpClientComponent, FireDAC.Stan.Intf, FireDAC.Stan.Option, System.Json, System.NetEncoding, Data.DBXJsonCommon,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs, FireDAC.FMXUI.Wait,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, FMX.ListView.Types,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, System.DateUtils, System.StrUtils,
  FMX.Objects, System.IniFiles, System.IOUtils, FMX.Grid.Style, FMX.Grid, REST.Json, FMX.ListBox, System.RegularExpressions,
  IdHashMessageDigest, idHash, IdGlobal, System.Hash;

type
  GlobalFunction = class
    class procedure CreateBaseDirectory;
    class function GetBaseDirectory : String;
    class function LoadFile(AFileName : String) : String;
    class procedure ClearStringGrid(FStringGrid : TStringGrid; FRow : Integer = 0);

    class procedure SaveSettingString(Section, Name, Value: string);
    class function LoadSettingString(Section, Name, Value: string): string;
    class function ReplaceStr(strSource, strReplaceFrom, strReplaceWith: string; goTrim: Boolean = true): string;

    class function HashHMAC256(AText : String) : String;

    class function EncodeBase64 (AString : String) : String;
    class function DecodeBase64 (AString : String) : String;

    class function DownloadFile(AURL, AFileName : String) : Boolean;

    class function ConvertToRoman(ANumber: Integer): string;

    class procedure SetFontCombobox(ACombobox : TComboBox; ASize : Single = 12.5);
    class procedure SetIndexCombobox(ACombobox : TCombobox; AValue : String);
  end;

const
  SIGNATUREAPPS = '';

implementation

{ GlobalFunction }

class procedure GlobalFunction.ClearStringGrid(FStringGrid: TStringGrid;
  FRow: Integer);
begin
  for var i := 0 to FStringGrid.RowCount - 1 do
    for var ii := 0 to FStringGrid.ColumnCount - 1 do
      FStringGrid.Cells[ii, i] := '';

  FStringGrid.RowCount := FRow;
end;

class function GlobalFunction.ConvertToRoman(ANumber: Integer): string;
const
  RomanNumerals: array[1..13] of string = ('M', 'CM', 'D', 'CD', 'C', 'XC', 'L', 'XL', 'X', 'IX', 'V', 'IV', 'I');
  RomanValues: array[1..13] of Integer = (1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1);
var
  i: Integer;
begin
  Result := '';
  if (ANumber <= 0) or (ANumber > 3999) then
  begin
    Result := 'Invalid input';
    Exit;
  end;

  for i := 1 to 13 do
  begin
    while ANumber >= RomanValues[i] do
    begin
      Result := Result + RomanNumerals[i];
      ANumber := ANumber - RomanValues[i];
    end;
  end;
end;

class procedure GlobalFunction.CreateBaseDirectory;
begin
  {$IF DEFINED(MSWINDOWS)}
    if not DirectoryExists(ExpandFileName(GetCurrentDir) + PathDelim + 'assets') then
      CreateDir(ExpandFileName(GetCurrentDir) + PathDelim + 'assets');

    if not DirectoryExists(ExpandFileName(GetCurrentDir) + PathDelim + 'assets' + PathDelim + 'image') then
      CreateDir(ExpandFileName(GetCurrentDir) + PathDelim + 'assets' + PathDelim + 'image');

    if not DirectoryExists(ExpandFileName(GetCurrentDir) + PathDelim + 'assets' + PathDelim + 'doc') then
      CreateDir(ExpandFileName(GetCurrentDir) + PathDelim + 'assets' + PathDelim + 'doc');

    if not DirectoryExists(ExpandFileName(GetCurrentDir) + PathDelim + 'assets' + PathDelim + 'video') then
      CreateDir(ExpandFileName(GetCurrentDir) + PathDelim + 'assets' + PathDelim + 'video');

    if not DirectoryExists(ExpandFileName(GetCurrentDir) + PathDelim + 'assets' + PathDelim + 'music') then
      CreateDir(ExpandFileName(GetCurrentDir) + PathDelim + 'assets' + PathDelim + 'music');

    if not DirectoryExists(ExpandFileName(GetCurrentDir) + PathDelim + 'assets' + PathDelim + 'other') then
      CreateDir(ExpandFileName(GetCurrentDir) + PathDelim + 'assets' + PathDelim + 'other');
  {$ENDIF}
end;

class function GlobalFunction.DecodeBase64(AString: String): String;
begin
  Result := TNetEncoding.Base64.Decode(AString);
end;

class function GlobalFunction.DownloadFile(AURL, AFileName: String): Boolean;
var
  HTTP : TNetHTTPClient;
  IHTTPResponses : IHTTPResponse;
  Stream : TMemoryStream;
begin
  Result := False;

  HTTP := TNetHTTPClient.Create(nil);
  try
    Stream := TMemoryStream.Create;
    try
      IHTTPResponses := HTTP.Get(AURL, Stream);
      if IHTTPResponses.StatusCode = 200 then begin
        Stream.SaveToFile(LoadFile(AFileName));

        Result := True;
      end;
    finally
      Stream.DisposeOf;
    end;
  finally
    HTTP.DisposeOf;
  end;
end;

class function GlobalFunction.EncodeBase64(AString: String): String;
begin
  Result := TNetEncoding.Base64.Encode(AString);
end;

class function GlobalFunction.GetBaseDirectory: String;
begin
  CreateBaseDirectory;

  {$IF DEFINED(IOS) or DEFINED(ANDROID)}
    Result := TPath.GetDocumentsPath + PathDelim;
  {$ELSEIF DEFINED(MSWINDOWS)}
    Result := ExpandFileName(GetCurrentDir) + PathDelim;
  {$ENDIF}
end;

class function GlobalFunction.HashHMAC256(AText: String): String;
begin
  Result := THashSHA2.GetHMAC(AText, SIGNATUREAPPS, SHA256);
end;

class function GlobalFunction.LoadFile(AFileName: String): String;
var
  FExtension : String;
begin
  FExtension := LowerCase(ExtractFileExt(AFileName));
  {$IF DEFINED(IOS) or DEFINED(ANDROID)}
//    Result := GetBaseDirectory + AFileName;
    Result := TPath.Combine(TPath.GetDocumentsPath, AFileName);
  {$ELSEIF DEFINED(MSWINDOWS)}
    if (FExtension = '.jpg') or (FExtension = '.jpeg') or (FExtension = '.png') or (FExtension = '.bmp') then
      Result := GetBaseDirectory + 'assets' + PathDelim + 'image' + PathDelim + AFileName

    else if (FExtension = '.doc') or (FExtension = '.pdf') or (FExtension = '.csv') or (FExtension = '.txt') or (FExtension = '.xls') or (FExtension = '.rtf') then
      Result := GetBaseDirectory + 'assets' + PathDelim + 'doc' + PathDelim + AFileName

    else if (FExtension = '.mp4') or (FExtension = '.avi') or (FExtension = '.wmv') or (FExtension = '.flv') or (FExtension = '.mov') or (FExtension = '.mkv') or (FExtension = '.3gp') then
      Result := GetBaseDirectory + 'assets' + PathDelim + 'video' + PathDelim + AFileName

    else if (FExtension = '.mp3') or (FExtension = '.wav') or (FExtension = '.wma') or (FExtension = '.aac') or (FExtension = '.flac') or (FExtension = '.m4a') then
      Result := GetBaseDirectory + 'assets' + PathDelim + 'music' + PathDelim + AFileName

    else
      Result := GetBaseDirectory + 'assets' + PathDelim + 'other' + PathDelim + AFileName
  {$ENDIF}
end;

class function GlobalFunction.LoadSettingString(Section, Name,
  Value: string): string;
var
  ini: TIniFile;
begin
  {$IF DEFINED (ANDROID)}
  ini := TIniFile.Create(TPath.GetDocumentsPath + PathDelim + 'config.ini');
  {$ELSEIF DEFINED (MSWINDOWS)}
  var FAppName := ExtractFilename(ParamStr(0));
  ReplaceStr(FAppName, '.exe', '');

  if not DirectoryExists(TPath.GetPublicPath + PathDelim + 'BFA') then
    CreateDir(TPath.GetPublicPath + PathDelim + 'BFA');
  ini := TIniFile.Create(TPath.GetPublicPath + PathDelim + 'BFA' + PathDelim + 'config_'+ FAppName +'.ini');
  {$ENDIF}
  try
    Result := ini.ReadString(Section, Name, Value);
  finally
    ini.DisposeOf;
  end;
end;

class function GlobalFunction.ReplaceStr(strSource, strReplaceFrom,
  strReplaceWith: string; goTrim: Boolean): string;
begin
  if goTrim then strSource := Trim(strSource);
  Result := StringReplace(strSource, StrReplaceFrom, StrReplaceWith, [rfReplaceAll, rfIgnoreCase]);
end;

class procedure GlobalFunction.SaveSettingString(Section, Name, Value: string);
var
  ini: TIniFile;
begin
  {$IF DEFINED (ANDROID)}
  ini := TIniFile.Create(TPath.GetDocumentsPath + PathDelim + 'config.ini');
  {$ELSEIF DEFINED (MSWINDOWS)}
  var FAppName := ExtractFilename(ParamStr(0));
  ReplaceStr(FAppName, '.exe', '');

  if not DirectoryExists(TPath.GetPublicPath + PathDelim + 'BFA') then
    CreateDir(TPath.GetPublicPath + PathDelim + 'BFA');

  ini := TIniFile.Create(TPath.GetPublicPath + PathDelim + 'BFA' + PathDelim + 'config_'+ FAppName +'.ini');
  {$ENDIF}
  try
    ini.WriteString(Section, Name, Value);
  finally
    ini.DisposeOf;
  end;
end;

class procedure GlobalFunction.SetFontCombobox(ACombobox: TComboBox;
  ASize: Single);
begin
  for var i := 0 to ACombobox.Items.Count - 1 do begin
    ACombobox.ListItems[i].StyledSettings := [];
    ACombobox.ListItems[i].Font.Size := ASize;
  end;

  ACombobox.ItemIndex := 0;
end;

class procedure GlobalFunction.SetIndexCombobox(ACombobox: TCombobox;
  AValue: String);
begin
  var AEventChange := ACombobox.OnChange;
  ACombobox.OnChange := Nil;
  try
    for var i := 0 to ACombobox.Items.Count - 1 do begin
      if LowerCase(AValue) = LowerCase(ACombobox.ListItems[i].Text) then begin
        ACombobox.ItemIndex := i;
        Break;
      end;
    end;
  finally
    ACombobox.OnChange := AEventChange;
  end;
end;

end.

