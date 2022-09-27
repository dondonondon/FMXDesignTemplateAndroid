unit BFA.Helper.MemTable;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Memo.Types,
  System.Rtti, FMX.Grid.Style, FMX.Grid, FMX.ScrollBox, FMX.Memo, FMX.Edit,
  FMX.Controls.Presentation, FMX.StdCtrls, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, System.Net.URLClient,
  System.Net.HttpClient, System.Net.HttpClientComponent, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, System.JSON, System.Net.Mime;


type
  TFDMemTableHelper = class helper for TFDMemTable
    procedure FillError(FMessage, FError : String);
    function FillDataFromString(FJSON : String) : Boolean; //ctrl + shift + C
    function FillDataFromURL(FURL : String; FMultiPart : TMultipartFormData = nil) : Boolean;  //ctrl + shift + C

    function toJSON(FStatus : Integer; FMessages : String = '') : String;
  end;

implementation

{ TFDMemTableHelper }

function TFDMemTableHelper.FillDataFromString(FJSON: String): Boolean; //fix memory leak JSONObject / JSONArray 2022-06-03
const
  FArr = 0;
  FObj = 1;
  FEls = 2;

  function isCheck(FString : String) : Integer; begin
    Result := FEls;
    var FCheck := TJSONObject.ParseJSONValue(FJSON);
    if FCheck is TJSONObject then
      Result := FObj
    else if FCheck is TJSONArray then
      Result := FArr;

    FCheck.DisposeOf;
  end;

var
  JObjectData : TJSONObject;
  JArrayJSON : TJSONArray;
  JSONCheck : TJSONValue;
begin
  var FResult := isCheck(FJSON);
  try
    Self.Active := False;
    Self.Close;
    Self.FieldDefs.Clear;

    if FResult = FObj then begin
      JObjectData := TJSONObject.ParseJSONValue(FJSON) as TJSONObject;
    end else if FResult = FArr then begin
      JArrayJSON := TJSONObject.ParseJSONValue(FJSON) as TJSONArray;
      JObjectData := TJSONObject(JArrayJSON.Get(0));
    end else begin
      Self.FillError('Gagal Parsing JSON', 'Ini Bukan JSON');
      Result := False;
      Exit;
    end;

    for var i := 0 to JObjectData.Size - 1 do begin
      Self.FieldDefs.Add(
        StringReplace(JObjectData.Get(i).JsonString.ToString, '"', '', [rfReplaceAll, rfIgnoreCase]),
        ftString,
        100000,
        False
      );
    end;

    Self.CreateDataSet;
    Self.Active := True;
    Self.Open;

    try
      if FResult = FArr then begin
        for var i := 0 to JArrayJSON.Size - 1 do begin
          JObjectData := TJSONObject(JArrayJSON.Get(i));
          Self.Append;
          for var ii := 0 to JObjectData.Size - 1 do begin
            JSONCheck := TJSONObject.ParseJSONValue(JObjectData.GetValue(Self.FieldDefs[ii].Name).ToJSON);

            if JSONCheck is TJSONObject then
              Self.Fields[ii].AsString := JObjectData.GetValue(Self.FieldDefs[ii].Name).ToJSON
            else if JSONCheck is TJSONArray then
              Self.Fields[ii].AsString := JObjectData.GetValue(Self.FieldDefs[ii].Name).ToJSON
            else
              Self.Fields[ii].AsString := JObjectData.Values[Self.FieldDefs[ii].Name].Value;

            JSONCheck.DisposeOf;
          end;
          Self.Post;
        end;
      end else begin
        Self.Append;
        for var ii := 0 to JObjectData.Size - 1 do begin
          JSONCheck := TJSONObject.ParseJSONValue(JObjectData.GetValue(Self.FieldDefs[ii].Name).ToJSON);

          if JSONCheck is TJSONObject then
            Self.Fields[ii].AsString := JObjectData.GetValue(Self.FieldDefs[ii].Name).ToJSON
          else if JSONCheck is TJSONArray then
            Self.Fields[ii].AsString := JObjectData.GetValue(Self.FieldDefs[ii].Name).ToJSON
          else
            Self.Fields[ii].AsString := JObjectData.Values[Self.FieldDefs[ii].Name].Value;

          JSONCheck.DisposeOf;
        end;
        Self.Post;
      end;

      Result := True;
    except
      on E : Exception do begin
        Result := False;
        Self.FillError('Error Parsing JSON', E.Message);
      end;
    end;
  finally
    if FResult = FObj then
      JObjectData.DisposeOf;

    if FResult = FArr then
      JArrayJSON.DisposeOf;

    Self.First;
  end;
end;

function TFDMemTableHelper.FillDataFromURL(FURL: String; FMultiPart : TMultipartFormData = nil): Boolean;
var
  FNetHTTP : TNetHTTPClient;
  FNetRespon : IHTTPResponse;
begin
  FNetHTTP := TNetHTTPClient.Create(nil);
  try
    try
      if Assigned(FMultiPart) then
        FNetRespon := FNetHTTP.Post(FURL, FMultiPart)
      else
        FNetRespon := FNetHTTP.Get(FURL);

      Result := Self.FillDataFromString(FNetRespon.ContentAsString());
      if FNetRespon.StatusCode = 200 then
        Result := Self.FillDataFromString(Self.FieldByName('data').AsString)
      else
        Result := False;

    except
      on E : Exception do begin
        Result := False;
        Self.FillError('Gagal Load JSON From URL', E.Message);
      end;
    end;
  finally
    FNetHTTP.DisposeOf;
  end;
end;

procedure TFDMemTableHelper.FillError(FMessage, FError : String);
begin
  Self.Active := False;
  Self.Close;
  Self.FieldDefs.Clear;

  Self.FieldDefs.Add('status', ftString, 200, False);
  Self.FieldDefs.Add('messages', ftString, 200, False);
  Self.FieldDefs.Add('data', ftString, 200, False);

  Self.CreateDataSet;
  Self.Active := True;
  Self.Open;

  Self.Append;
  Self.Fields[0].AsString := FError;
  Self.Fields[1].AsString := FMessage;
  Self.Post;
end;

function TFDMemTableHelper.toJSON(FStatus: Integer; FMessages: String): String;
var
  FResult, FData : TJSONObject;
  FTemp : TJsonArray;
begin
  Self.First;

  FResult := TJSONObject.Create;
  try
    FResult.AddPair('status', TJSONNumber.Create(FStatus));
    FResult.AddPair('messages', FMessages);

    FTemp := TJSONArray.Create;
    for var i := 0 to Self.RecordCount - 1 do begin
      FData := TJSONObject.Create;
      for var ii := 0 to Self.FieldDefs.Count - 1 do begin
        FData.AddPair(Self.FieldDefs[ii].Name, Self.FieldByName(Self.FieldDefs[ii].Name).AsString);
      end;
      FTemp.AddElement(FData);
      Self.Next;
    end;
    FResult.AddPair('data', FTemp);

    Result := FResult.ToJSON;

    Self.First;

  finally
    FResult.DisposeOf;
  end;
end;

end.
