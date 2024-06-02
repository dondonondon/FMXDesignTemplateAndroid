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
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, System.DateUtils,
  FMX.Objects, System.IniFiles, System.IOUtils, FMX.Grid.Style, FMX.Grid, REST.Json, FMX.ListBox, System.RegularExpressions;

type
  GlobalFunction = class
    class procedure CreateBaseDirectory;
    class function GetBaseDirectory : String;
    class function LoadFile(AFileName : String) : String;
    class procedure ClearStringGrid(FStringGrid : TStringGrid; FRow : Integer = 0);
  end;

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

class function GlobalFunction.GetBaseDirectory: String;
begin
  CreateBaseDirectory;

  {$IF DEFINED(IOS) or DEFINED(ANDROID)}
    Result := TPath.GetDocumentsPath + PathDelim;
  {$ELSEIF DEFINED(MSWINDOWS)}
    Result := ExpandFileName(GetCurrentDir) + PathDelim;
  {$ENDIF}
end;

class function GlobalFunction.LoadFile(AFileName: String): String;
var
  FExtension : String;
begin
  FExtension := LowerCase(ExtractFileExt(AFileName));
  {$IF DEFINED(IOS) or DEFINED(ANDROID)}
    Result := GetBaseDirectory + AFileName;
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

end.
