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
  end;

implementation

{ TFDMemTableHelper }

function TFDMemTableHelper.FillDataFromString(FJSON: String): Boolean;
var
  JObjectData : TJSONObject;
  JArrayJSON : TJSONArray;
  isArray : Boolean;
begin
  try
    Self.Active := False;
    Self.Close;
    Self.FieldDefs.Clear;

    if TJSONObject.ParseJSONValue(FJSON) is TJSONObject then begin
      JObjectData := TJSONObject.ParseJSONValue(FJSON) as TJSONObject;
    end else if TJSONObject.ParseJSONValue(FJSON) is TJSONArray then begin
      isArray := True;
      JArrayJSON := TJSONObject.ParseJSONValue(FJSON) as TJSONArray;
      JObjectData := TJSONObject(JArrayJSON.Get(0));
    end else begin
      Result := False;
      Self.FillError('Gagal Parsing JSON', 'Ini Bukan JSON');
      Exit;
    end;

    for var i := 0 to JObjectData.Size - 1 do
      Self.FieldDefs.Add(
        StringReplace(JObjectData.Get(i).JsonString.ToString, '"', '', [rfReplaceAll, rfIgnoreCase]),
        ftString,
        10000,
        False
      );

    Self.CreateDataSet;
    Self.Active := True;
    Self.Open;

    try
      if isArray then begin
        for var i := 0 to JArrayJSON.Size - 1 do begin
          JObjectData := TJSONObject(JArrayJSON.Get(i));

          Self.Append;
          for var ii := 0 to JObjectData.Size - 1 do begin
            if TJSONObject.ParseJSONValue(JObjectData.GetValue(Self.FieldDefs[ii].Name).ToJSON) is TJSONObject then
              Self.Fields[ii].AsString := JObjectData.GetValue(Self.FieldDefs[ii].Name).ToJSON
            else if TJSONObject.ParseJSONValue(JObjectData.GetValue(Self.FieldDefs[ii].Name).ToJSON) is TJSONArray then
              Self.Fields[ii].AsString := JObjectData.GetValue(Self.FieldDefs[ii].Name).ToJSON
            else
              Self.Fields[ii].AsString := JObjectData.Values[Self.FieldDefs[ii].Name].Value;
          end;
          Self.Post;
        end;
      end else begin
        Self.Append;
        for var ii := 0 to JObjectData.Size - 1 do begin
          if TJSONObject.ParseJSONValue(JObjectData.GetValue(Self.FieldDefs[ii].Name).ToJSON) is TJSONObject then
            Self.Fields[ii].AsString := JObjectData.GetValue(Self.FieldDefs[ii].Name).ToJSON
          else if TJSONObject.ParseJSONValue(JObjectData.GetValue(Self.FieldDefs[ii].Name).ToJSON) is TJSONArray then
            Self.Fields[ii].AsString := JObjectData.GetValue(Self.FieldDefs[ii].Name).ToJSON
          else
            Self.Fields[ii].AsString := JObjectData.Values[Self.FieldDefs[ii].Name].Value;
        end;
        Self.Post;
      end;

      Result := True;

      for var i := 0 to Self.FieldCount - 1 do begin
        if Self.FieldDefs[i].Name = 'result' then begin
          if Self.FieldByName('result').AsString = 'null' then begin
            Result := False;
            Break;
          end;
        end;
      end;

    except
      on E : Exception do begin
        Result := False;
        Self.FillError('Error Parsing JSON', E.Message);
      end;
    end;
  finally
    Self.First;
    if isArray then
      JArrayJSON.DisposeOf;
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

  Self.FieldDefs.Add('message', ftString, 200, False);
  Self.FieldDefs.Add('error', ftString, 200, False);

  Self.CreateDataSet;
  Self.Active := True;
  Self.Open;

  Self.Append;
  Self.Fields[0].AsString := FMessage;
  Self.Fields[1].AsString := FError;
  Self.Post;
end;

end.
