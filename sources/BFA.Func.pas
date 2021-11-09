unit BFA.Func;

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
  FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  FMX.Objects, System.IniFiles, System.IOUtils;


function fnReplaceStr(strSource, strReplaceFrom, strReplaceWith: string;
         goTrim: Boolean = true): string;

procedure fnSQLAdd(Query: TFDQuery; SQL: string; ClearPrior: Boolean = False); overload;
procedure fnSQLOpen(Query: TFDQuery); overload;
procedure fnExecSQL(Query: TFDQuery); overload;
procedure fnSQLParamByName(Query: TFDQuery; ParamStr: string; Value: Variant); overload;
procedure prExplodeStr(SourceStr: string; Delimiter: char; var List: TStringList);

procedure fnCreateDir;
function fnGetLoc : String;
function fnLoadFile(AFileName : String) : String;
procedure fnDownloadFile(FURL, ASaveFile : String);
procedure fnSetImage(AControl : TControl; ASaveFile : String);

procedure fnLog(FMessage : String); overload;
procedure fnLog(FKey, FMessage : String); overload;
procedure SaveSettingString(Section, Name, Value: string);
function LoadSettingString(Section, Name, Value: string): string;

procedure LoadImageCenter(ABitmap : TBitmap; FLokasi : String);

implementation

function fnReplaceStr(strSource, strReplaceFrom, strReplaceWith: string; goTrim: Boolean = true): string;
begin
  if goTrim then strSource := Trim(strSource);
  Result := StringReplace(strSource, StrReplaceFrom, StrReplaceWith, [rfReplaceAll, rfIgnoreCase])
end;

procedure prExplodeStr(SourceStr: string; Delimiter: char; var List: TStringList);
var
  i: integer;
begin
  List.Clear;
  while Length(SourceStr) > 0 do
  begin
    i := Pos(Delimiter, SourceStr);
    if (i > 0) then
    begin
      List.Add(Copy(SourceStr, 1, i - 1));
      SourceStr := Copy(SourceStr, i + 1, Length(SourceStr) - i);
    end // if (i > 0) then
    else if Length(SourceStr) > 0 then
    begin
      List.Add(SourceStr);
      SourceStr := '';
    end // if Length(SourceStr) > 0 then
  end; //while Length(SourceStr) > 0 do
end;

procedure fnSQLAdd(Query: TFDQuery; SQL: string; ClearPrior: Boolean = False); overload;
var s: string;
begin
  if ClearPrior then
    Query.SQL.Clear;

  s := fnReplaceStr(SQL, 'GETDATE', 'CURRENT_DATE');
  s := fnReplaceStr(s, 'ISNULL', 'IFNULL');

  Query.SQL.Add(S);
end;

procedure fnSQLOpen(Query: TFDQuery); overload;
var L: TStringList;
  s: string;
  s1: string;
  TempS: string;
  x1: integer;
  x2: integer;
begin
  L := TStringList.Create;

  s := Query.SQL.Text;
  x1 := Pos('SELECT TOP', UpperCase(s));
  if x1 > 0 then
  begin
    if s[x1 - 1] = '(' then // --> berarti ada Sub Query di dalam Query, perlu diparse lagi
    begin
      x2 := Pos(')', s); // ambil akhir dari sub query
      s1 := UpperCase(Copy(s, x1, x2 - x1));
      prExplodeStr(s1, ' ', L);

      TempS := L[1] + ' ' + L[2];

      Insert(' LIMIT ' + L[2], s, x2);
      s := fnReplaceStr(s, TempS, '');
      Query.SQL.Text := s;
    end
    else
    begin
      // ambil jumlahnya
      prExplodeStr(UpperCase(s), ' ', L);

      TempS := L[1] + ' ' + L[2];

      s := fnReplaceStr(s, TempS, '');
      s := s + ' LIMIT ' + L[2];
      Query.SQL.Text := s;
    end
  end;

  FreeAndNil(L);

  Query.Prepared;
//  fnWriteQueryLog(Format('DATE: %s | QUERY: %s', [fnFormatDateTimeDB(Now), Query.SQL.Text]));
  Query.Open;
end;

procedure fnExecSQL(Query: TFDQuery); overload;
var L: TStringList;
  s: string;
  s1: string;
  TempS: string;
  x1: integer;
  x2: integer;
begin
  L := TStringList.Create;

  s := Query.SQL.Text;
  x1 := Pos('SELECT TOP', UpperCase(s));
  if x1 > 0 then
  begin
    if s[x1 - 1] = '(' then // --> berarti ada Sub Query di dalam Query, perlu diparse lagi
    begin
      x2 := Pos(')', s); // ambil akhir dari sub query
      s1 := UpperCase(Copy(s, x1, x2 - x1));
      prExplodeStr(s1, ' ', L);

      TempS := L[1] + ' ' + L[2];

      Insert(' LIMIT ' + L[2], s, x2);
      s := fnReplaceStr(s, TempS, '');
      Query.SQL.Text := s;
    end
    else
    begin
      // ambil jumlahnya
      prExplodeStr(UpperCase(s), ' ', L);

      TempS := L[1] + ' ' + L[2];

      s := fnReplaceStr(s, TempS, '');
      s := s + ' LIMIT ' + L[2];
      Query.SQL.Text := s;
    end
  end;

  FreeAndNil(L);

  Query.Prepared;

  Query.ExecSQL;
end;

procedure fnSQLParamByName(Query: TFDQuery; ParamStr: string; Value: Variant); overload;
begin
  Query.Params.ParamByName(ParamStr).Value := Value
end;

procedure fnCreateDir;
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
  {$ENDIF}
end;

function fnGetLoc : String;
begin
  fnCreateDir;

  {$IF DEFINED(IOS) or DEFINED(ANDROID)}
    Result := TPath.GetDocumentsPath + PathDelim;
  {$ELSEIF DEFINED(MSWINDOWS)}
    Result := ExpandFileName(GetCurrentDir) + PathDelim;
  {$ENDIF}
end;

function fnLoadFile(AFileName : String) : String;
var
  ext : String;
begin
  ext := LowerCase(ExtractFileExt(AFileName));
  {$IF DEFINED(IOS) or DEFINED(ANDROID)}
    Result := fnGetLoc + AFileName;
  {$ELSEIF DEFINED(MSWINDOWS)}
    if (ext = '.jpg') or (ext = '.jpeg') or (ext = '.png') or (ext = '.bmp') then
      Result := fnGetLoc + 'assets' + PathDelim + 'image' + PathDelim + AFileName;

    if (ext = '.doc') or (ext = '.pdf') or (ext = '.csv') or (ext = '.txt') or (ext = '.xls') then
      Result := fnGetLoc + 'assets' + PathDelim + 'doc' + PathDelim + AFileName;

    if (ext = '.mp4') or (ext = '.avi') or (ext = '.wmv') or (ext = '.flv') or (ext = '.mov') or (ext = '.mkv') or (ext = '.3gp') then
      Result := fnGetLoc + 'assets' + PathDelim + 'video' + PathDelim + AFileName;

    if (ext = '.mp3') or (ext = '.wav') or (ext = '.wma') or (ext = '.aac') or (ext = '.flac') or (ext = '.m4a') then
      Result := fnGetLoc + 'assets' + PathDelim + 'music' + PathDelim + AFileName;
  {$ENDIF}
end;

procedure fnDownloadFile(FURL, ASaveFile : String);
var
  HTTP : TNetHTTPClient;
  Stream : TMemoryStream;
begin
  HTTP := TNetHTTPClient.Create(nil);
  try
    Stream := TMemoryStream.Create;
    try
      HTTP.Get(FURL, Stream);
      Stream.SaveToFile(fnLoadFile(ASaveFile));
    finally
      Stream.DisposeOf;
    end;
  finally
    HTTP.DisposeOf;
  end;
end;

procedure fnSetImage(AControl : TControl; ASaveFile : String);
var
  L: TLabel;
  isAvail: Boolean;
  AText: String;
begin
  L := TLabel(AControl.FindStyleResource('caption'));
  if Assigned(L) then
    L.DisposeOf;

  isAvail := True;
  if FileExists(fnLoadFile(ASaveFile)) then begin
    try
      if AControl is TRectangle then begin
        TRectangle(AControl).Fill.Bitmap.Bitmap.LoadFromFile(fnLoadFile(ASaveFile));
        TRectangle(AControl).Fill.Kind := TBrushKind.Bitmap;
        TRectangle(AControl).Fill.Bitmap.WrapMode := TWrapMode.TileStretch;
      end else if AControl is TCircle then begin
        TCircle(AControl).Fill.Bitmap.Bitmap.LoadFromFile(fnLoadFile(ASaveFile));
        TCircle(AControl).Fill.Kind := TBrushKind.Bitmap;
        TCircle(AControl).Fill.Bitmap.WrapMode := TWrapMode.TileStretch;
      end else if AControl is TImage then begin
        TImage(AControl).Bitmap.LoadFromFile(fnLoadFile(ASaveFile));
        TImage(AControl).WrapMode := TImageWrapMode.Stretch;
      end else begin
        isAvail := False;
        AText := 'This component not support';
      end;
    except
      isAvail := False;
      AText := 'File Image Corrupt';
      DeleteFile(fnLoadFile(ASaveFile));
    end;
  end else begin
    isAvail := False;
    AText := 'File Image Not Found';
  end;

  if not isAvail then begin
    L := TLabel.Create(AControl);
    L.Width := AControl.Width;
    L.Height := AControl.Height;
    L.Position.X := 0;
    L.Position.Y := 0;
    L.StyleName := 'caption';
    L.Text := AText;
    L.TextAlign := TTextAlign.Center;
    L.Font.Size := 12.5;

    AControl.AddObject(L);
  end;
end;

procedure fnLog(FMessage : String);
var
  ini: TIniFile;
begin
  ini := TIniFile.Create(fnGetLoc + 'log.ini');
  try
    ini.WriteString('Log', FormatDateTime('yyyy-mm-dd hh:nn:ss', Now) + ' ', ' ' + FMessage);
  finally
    ini.DisposeOf;
  end;
end;

procedure fnLog(FKey, FMessage : String);
var
  ini: TIniFile;
begin
  ini := TIniFile.Create(fnGetLoc + 'log.ini');
  try
    ini.WriteString('Log', FormatDateTime('yyyy-mm-dd hh:nn:ss', Now) + ' ', ' [' + FKey + '] - ' + FMessage);
  finally
    ini.DisposeOf;
  end;
end;

function LoadSettingString(Section, Name, Value: string): string;
var
  ini: TIniFile;
begin
  {$IF DEFINED (ANDROID)}
  ini := TIniFile.Create(TPath.GetDocumentsPath + PathDelim + 'config.ini');
  {$ELSEIF DEFINED (MSWINDOWS)}
  if not DirectoryExists(TPath.GetPublicPath + PathDelim + 'BFA') then
    CreateDir(TPath.GetPublicPath + PathDelim + 'BFA');
  ini := TIniFile.Create(TPath.GetPublicPath + PathDelim + 'BFA' + PathDelim + 'config.ini');
  {$ENDIF}
  try
    Result := ini.ReadString(Section, Name, Value);
  finally
    ini.DisposeOf;
  end;
end;

procedure SaveSettingString(Section, Name, Value: string);
var
  ini: TIniFile;
begin
  {$IF DEFINED (ANDROID)}
  ini := TIniFile.Create(TPath.GetDocumentsPath + PathDelim + 'config.ini');
  {$ELSEIF DEFINED (MSWINDOWS)}
  if not DirectoryExists(TPath.GetPublicPath + PathDelim + 'BFA') then
    CreateDir(TPath.GetPublicPath + PathDelim + 'BFA');

  ini := TIniFile.Create(TPath.GetPublicPath + PathDelim + 'BFA' + PathDelim + 'config.ini');
  {$ENDIF}
  try
    ini.WriteString(Section, Name, Value);
  finally
    ini.DisposeOf;
  end;
end;

procedure LoadImageCenter(ABitmap : TBitmap; FLokasi : String);
var
  AFrom, ACrop : TBitmap;
  xScale, yScale: extended;
  iRect, ARect: TRect;
  sc : Integer;
begin
  sc := 150;
  AFrom := TBitmap.Create;
  try
    AFrom.LoadFromFile(FLokasi);
    //ABitmap := TBitmap.Create;
    try
      ARect.Width := sc;
      ARect.Height := sc;
      xScale := AFrom.Width / sc;
      yScale := AFrom.Height / sc;

      if AFrom.Width > AFrom.Height then begin
        ABitmap.Width := round(ARect.Width * yScale);
        ABitmap.Height := round(ARect.Height * yScale);
        iRect.Left := Round((AFrom.Width - AFrom.Height) / 2);
        iRect.Top := 0;
      end else begin
        ABitmap.Width := round(ARect.Width * xScale);
        ABitmap.Height := round(ARect.Height * xScale);
        iRect.Left := 0;
        iRect.Top := Round((AFrom.Height - AFrom.Width) / 2);
      end;

      iRect.Width := round(ARect.Width * xScale);
      iRect.Height := round(ARect.Height * yScale);
      ABitmap.CopyFromBitmap(AFrom, iRect, 0, 0);
    finally
      //ABitmap.DisposeOf;
    end;
  finally
    AFrom.DisposeOf;
  end;
end;

end.
