unit BFA.Log;

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
  TLog = class
  private
    FFileName : String;
    FStringList : TStringList;
  public
    procedure ClearLog;
    procedure AddLog(AMessage : String; IsClear : Boolean = False);
  published
    constructor Create(AFileName : String);
    destructor Destroy; override;
  end;

implementation

{ TLog }

uses BFA.Global.Func;

procedure TLog.AddLog(AMessage: String; IsClear: Boolean);
begin
  if IsClear then ClearLog;
  
  FStringList.Add('[' + FormatDateTime('yyyy-mm-dd hh:nn:ss', Now) + '] - ' + AMessage);
  FStringList.SaveToFile(GlobalFunction.LoadFile(FFileName));
end;

procedure TLog.ClearLog;
begin
  FStringList.Clear;
  FStringList.SaveToFile(GlobalFunction.LoadFile(FFileName));
end;

constructor TLog.Create(AFileName: String);
begin
  FFileName := AFileName;
  FStringList := TStringList.Create;
  if FileExists(GlobalFunction.LoadFile(FFileName)) then
    FStringList.LoadFromFile(GlobalFunction.LoadFile(FFileName));
end;

destructor TLog.Destroy;
begin
  FStringList.DisposeOf;
  inherited;
end;

end.
