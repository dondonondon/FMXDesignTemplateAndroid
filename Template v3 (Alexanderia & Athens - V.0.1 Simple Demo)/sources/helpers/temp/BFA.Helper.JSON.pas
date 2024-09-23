unit BFA.Helper.JSON;

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
  HelperJSON = class
    class function toJSON(AStringList : TStringList) : String; overload;
    class function toJSON(AMemTable : TFDMemTable) : String; overload;
  end;

implementation

{ HelperJSON }

uses BFA.Global.Variable;

class function HelperJSON.toJSON(AMemTable: TFDMemTable): String;
begin
  var FResult, FData : TJSONObject;
  var FTemp : TJsonArray;
  FResult := TJSONObject.Create;
  try
    AMemTable.First;

    FData := TJSONObject.Create;
    FData.AddPair('apiversion', '1');
    FData.AddPair('refreshtoken', '');
    FData.AddPair('token', '');
    FData.AddPair('user', '');
    FData.AddPair('levelaccess', '');

    FResult.AddPair('apiaccess', FData);

    FTemp := TJSONArray.Create;
    for var i := 0 to AMemTable.RecordCount - 1 do begin
      FData := TJSONObject.Create;
      for var ii := 0 to AMemTable.FieldDefs.Count - 1 do begin
        FData.AddPair(AMemTable.FieldDefs[ii].Name, AMemTable.FieldByName(AMemTable.FieldDefs[ii].Name).AsString);
      end;
      FTemp.AddElement(FData);
      AMemTable.Next;
    end;

    FResult.AddPair('data', FTemp);

    Result := (FResult.ToJSON);
  finally
    FResult.DisposeOf;
  end;
end;

class function HelperJSON.toJSON(AStringList: TStringList): String;
begin
  var FResult, FData : TJSONObject;
  var FTemp : TJsonArray;
  FResult := TJSONObject.Create;
  try
    FData := TJSONObject.Create;
    FData.AddPair('apiversion', '1');
    FData.AddPair('refreshtoken', '');
    FData.AddPair('token', '');
    FData.AddPair('user', '');
    FData.AddPair('levelaccess', '');

    FResult.AddPair('apiaccess', FData);

    FTemp := TJSONArray.Create;
    FData := TJSONObject.Create;
    for var i := 0 to AStringList.Count - 1 do begin

      FData.AddPair(AStringList.KeyNames[i], AStringList.Values[AStringList.KeyNames[i]]);

    end;
    FTemp.AddElement(FData);

    FResult.AddPair('data', FTemp);

    Result := (FResult.ToJSON);
  finally
    FResult.DisposeOf;
  end;
end;

end.
