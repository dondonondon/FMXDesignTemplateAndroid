unit BFA.Helper.MemoryTable;

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
  TFDMemTableHelperFunction = class
    class function isCheck(FJSON : String) : Integer;
    class procedure FillErrorParse(ADataset : TFDMemTable; AMessage, AError : String; IsEmptyData : Boolean = True);
  end;

  TFDMemTableHelper = class helper for TFDMemTable
    function FillDataFromString(FJSON : String; FillDataWhenFailParse : Boolean = True) : Boolean;
  end;

const
  RESULT_CHECK_ARRAY  = 0;
  RESULT_CHECK_OBJECT = 1;
  RESULT_CHECK_NONE   = 2;

implementation

{ TFDMemTableHelper }

function TFDMemTableHelper.FillDataFromString(FJSON: String; FillDataWhenFailParse : Boolean): Boolean;
const
  MAX_SIZE_STRING = 90000000;  // if have sub json / nested json
var
  JObjectData : TJSONObject;
  JArrayJSON : TJSONArray;
  JSONCheck : TJSONValue;
  LJSONPair: TJSONPair;
  LFieldDef: TFieldDef;
begin
  Result := False;

  if (Trim(FJSON) = '[]') or (Trim(FJSON) = '{}') or (Trim(FJSON) = '') then begin
    if not FillDataWhenFailParse then begin
      TFDMemTableHelperFunction.FillErrorParse(Self, '', '');
      Result := True;
    end else TFDMemTableHelperFunction.FillErrorParse(Self, 'Data Empty', 'No Data Found', False);

    Exit;
  end;

  var FResult := TFDMemTableHelperFunction.isCheck(FJSON);
  try
    if FResult = RESULT_CHECK_OBJECT then begin
      JObjectData := TJSONObject.ParseJSONValue(FJSON) as TJSONObject;
    end else if FResult = RESULT_CHECK_ARRAY then begin
      JArrayJSON := TJSONObject.ParseJSONValue(FJSON) as TJSONArray;

      if JArrayJSON.Size = 0 then begin
        if not FillDataWhenFailParse then begin
          TFDMemTableHelperFunction.FillErrorParse(Self, '', '');
          Result := True;
        end else TFDMemTableHelperFunction.FillErrorParse(Self, 'Data Empty', 'No Data Found', False);

        Exit;
      end else JObjectData := TJSONObject(JArrayJSON.Get(0));
    end else begin
      TFDMemTableHelperFunction.FillErrorParse(Self, 'Fail Parse JSON', 'This is not JSON', False);
      Exit;
    end;

    if JObjectData.Size > 0 then begin
      Self.Active := False;
      Self.Close;
      Self.FieldDefs.Clear;

      for LJSONPair in JObjectData do begin
        LFieldDef := Self.FieldDefs.AddFieldDef;
        LFieldDef.Name := LJSONPair.JsonString.Value;
        if LJSONPair.JsonValue is TJSONNumber then begin
          LFieldDef.DataType := ftFloat;
        end else if (LJSONPair.JsonValue is TJSONTrue) or (LJSONPair.JsonValue is TJSONFalse) then begin
          LFieldDef.DataType := ftBoolean;
        end else begin
          LFieldDef.DataType := ftString;
          LFieldDef.Size := MAX_SIZE_STRING;
        end;
      end;

      Self.Open;
    end else begin
      if not FillDataWhenFailParse then begin
        TFDMemTableHelperFunction.FillErrorParse(Self, '', '');
        Result := True;
      end else TFDMemTableHelperFunction.FillErrorParse(Self, 'Data Empty', 'No Data Found', False);

      Exit;
    end;

    try
      if FResult = RESULT_CHECK_ARRAY then begin
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
      on E : Exception do TFDMemTableHelperFunction.FillErrorParse(Self, 'Error Parsing JSON', E.Message, False);
    end;
  finally
    if FResult = RESULT_CHECK_OBJECT then
      JObjectData.DisposeOf;

    if FResult = RESULT_CHECK_ARRAY then
      JArrayJSON.DisposeOf;

    if not Self.IsEmpty then
      Self.First;
  end;
end;

{ TFDMemTableHelperFunction }

class procedure TFDMemTableHelperFunction.FillErrorParse(ADataset: TFDMemTable;
  AMessage, AError: String; IsEmptyData : Boolean);
begin
  ADataset.Active := False;
  ADataset.Close;
  ADataset.FieldDefs.Clear;

  ADataset.FieldDefs.Add('status', ftString, 3, False);
  ADataset.FieldDefs.Add('messages', ftString, 200, False);
  ADataset.FieldDefs.Add('error', ftString, 200, False);

  ADataset.CreateDataSet;
  ADataset.Active := True;
  ADataset.Open;

  if not IsEmptyData then begin
    ADataset.Append;
    ADataset.Fields[0].AsString := '400';
    ADataset.Fields[1].AsString := AMessage;
    ADataset.Fields[2].AsString := AError;
    ADataset.Post;
  end;
end;

class function TFDMemTableHelperFunction.isCheck(FJSON: String): Integer;
begin
  Result := RESULT_CHECK_NONE;
  var FCheck := TJSONObject.ParseJSONValue(FJSON);
  if FCheck is TJSONObject then
    Result := RESULT_CHECK_OBJECT
  else if FCheck is TJSONArray then
    Result := RESULT_CHECK_ARRAY;

  FCheck.DisposeOf;
end;

end.
