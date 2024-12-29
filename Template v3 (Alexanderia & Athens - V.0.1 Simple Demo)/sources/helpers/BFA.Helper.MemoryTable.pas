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
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, System.JSON, System.Net.Mime,
  System.DateUtils, REST.Json;

type
  TTypeJSON = (ArrayData, ObjectData, None);

  HelperFunctionMemoryTable = class
    class function GetType(AJSON : String) : TTypeJSON;
    class function IsEmpty(ADataset : TFDMemTable; AJSON : String; AFillDataIfFail : Boolean = True) : Boolean;

    class procedure FillErrorData(ADataset : TFDMemTable; AMessage : String; IsEmptyData : Boolean = False);

    class procedure CreateDataset(ADataset : TFDMemTable; AJSONData : TJSONObject); overload;
    class procedure CreateDataset(ADataset : TFDMemTable; AJSONData : TJSONArray); overload;

    class procedure FillDataset(ADataset : TFDMemTable; AJSONData : TJSONObject); overload;
    class procedure FillDataset(ADataset : TFDMemTable; AJSONData : TJSONArray); overload;
  end;

  TMemoryTableHelper = class helper for TFDMemTable
//    function FillDataFromString(AJSON : String; AFillDataIfFail : Boolean = True) : Boolean;
    function LoadFromJSON(AJSON : String; AFillDataIfFail : Boolean = True) : Boolean;

    function toJSON(AStatusCode : Integer; AMessage : String) : String; overload;
    function toJSON(AStatusCode : Integer; AMessage : String; ADataRequest : TFDMemTable) : String; overload;
  end;

  HelperJSONRequest = class
    class function toJSON(AMemoryTable : TDataset) : String; overload;
    class function toJSON(AStringList : TStringList) : String; overload;
    class function FormatJSON(AJSON : String) : String;
  end;

implementation

{ TMemoryTableHelper }

uses BFA.Global.Func;

function TMemoryTableHelper.LoadFromJSON(AJSON: String;
  AFillDataIfFail: Boolean): Boolean;
var
  JObjectData : TJSONObject;
  JArrayData : TJSONArray;

  JSONType : TTypeJSON;
begin
  Result := False;

  if HelperFunctionMemoryTable.IsEmpty(Self, AJSON, AFillDataIfFail) then Exit;

  JSONType := HelperFunctionMemoryTable.GetType(AJSON);
  try
    if JSONType = None then begin
      HelperFunctionMemoryTable.FillErrorData(Self, 'Invalid JSON : ' + AJSON, AFillDataIfFail);
      Exit;
    end;

    if JSONType = ObjectData then begin
      JObjectData := TJSONObject.ParseJSONValue(AJSON) as TJSONObject;
      HelperFunctionMemoryTable.CreateDataset(Self, JObjectData);
    end;
    if JSONType = ArrayData then begin
      JArrayData := TJSONObject.ParseJSONValue(AJSON) as TJSONArray;
      HelperFunctionMemoryTable.CreateDataset(Self, JArrayData);
    end;

    try
      if JSONType = ArrayData then HelperFunctionMemoryTable.FillDataset(Self, JArrayData)
      else if JSONType = ObjectData then HelperFunctionMemoryTable.FillDataset(Self, JObjectData);

      Result := True;
    except on E: Exception do
      HelperFunctionMemoryTable.FillErrorData(Self, 'Error parse JSON : ' + E.Message, AFillDataIfFail);
    end;
  finally
//    if Assigned(JArrayData) then JArrayData.Free;
//    if Assigned(JObjectData) then JObjectData.Free;

    if JSONType = ArrayData then JArrayData.Free;
    if JSONType = ObjectData then JObjectData.Free;
    if not Self.IsEmpty then Self.First;
  end;
end;

function TMemoryTableHelper.toJSON(AStatusCode: Integer;
  AMessage: String): String;
begin
//  Result := HelperResponse.CreateResponse(AStatusCode, AMessage, Self);
end;

function TMemoryTableHelper.toJSON(AStatusCode: Integer; AMessage: String;
  ADataRequest: TFDMemTable): String;
begin
//  Result := HelperResponse.CreateResponse(AStatusCode, AMessage, Self, ADataRequest);
end;

{ HelperFunctionMemoryTable }

class procedure HelperFunctionMemoryTable.CreateDataset(ADataset: TFDMemTable;
  AJSONData: TJSONArray);
var
  ArrFields : array of record
    FieldType : TFieldType;
    Size : Integer;
    Name : String;
  end;

  JObjectData : TJSONObject;
  LJSONPair: TJSONPair;
  LFieldDef: TFieldDef;
  Index : Integer;
  LSize : Integer;

  TempMessage : String;
begin
  ADataset.Active := False;
  ADataset.Close;
  ADataset.FieldDefs.Clear;

  JObjectData := TJSONObject(AJSONData.Get(0));
  SetLength(ArrFields, JObjectData.Size);

  try
    for var i := 0 to AJSONData.Size - 1 do begin
      JObjectData := TJSONObject(AJSONData.Get(i));

      TempMessage := 'JObjectData := TJSONObject(AJSONData.Get(i));';

      Index := 0;
      for LJSONPair in JObjectData do begin
        ArrFields[Index].Name := LJSONPair.JsonString.Value;

        TempMessage := Length(ArrFields).ToString;

        if ArrFields[Index].FieldType <> ftString then begin
          if LJSONPair.JsonValue is TJSONNumber then begin
            ArrFields[Index].FieldType := ftFloat;
          end else if (LJSONPair.JsonValue is TJSONTrue) or (LJSONPair.JsonValue is TJSONFalse) then begin
            ArrFields[Index].FieldType := ftBoolean;
          end else begin
            ArrFields[Index].FieldType := ftString;
            ArrFields[Index].Size := Length(LJSONPair.JsonValue.Value);
          end;
        end else begin
          if ArrFields[Index].Size < Length(LJSONPair.JsonValue.Value) then ArrFields[Index].Size := Length(LJSONPair.JsonValue.Value);
        end;

        Inc(Index);
      end;
    end;

    for var i := 0 to Length(ArrFields) - 1 do begin
      TempMessage := 'for var i := 0 to Length(ArrFields) - 1 do begin';

      LFieldDef := ADataset.FieldDefs.AddFieldDef;
      LFieldDef.Name := ArrFields[i].Name;
      LFieldDef.DataType := ArrFields[i].FieldType;

      LSize := ArrFields[i].Size + Round(ArrFields[i].Size * 0.25);
      if LSize = 0 then LSize := 250000;

      if ArrFields[i].FieldType = ftString then
        LFieldDef.Size := LSize;
    end;
  except on E: Exception do
    ShowMessage(E.Message + sLineBreak + TempMessage);
  end;

  ADataset.Open;
end;

class procedure HelperFunctionMemoryTable.CreateDataset(ADataset: TFDMemTable;
  AJSONData: TJSONObject);
var
  LJSONPair: TJSONPair;
  LFieldDef: TFieldDef;
  LSize : Integer;
begin
  ADataset.Active := False;
  ADataset.Close;
  ADataset.FieldDefs.Clear;

  for LJSONPair in AJSONData do begin
    LFieldDef := ADataset.FieldDefs.AddFieldDef;
    LFieldDef.Name := LJSONPair.JsonString.Value;

    if LJSONPair.JsonValue is TJSONNumber then begin
      LFieldDef.DataType := ftFloat;
    end else if (LJSONPair.JsonValue is TJSONTrue) or (LJSONPair.JsonValue is TJSONFalse) then begin
      LFieldDef.DataType := ftBoolean;
    end else begin
      LFieldDef.DataType := ftString;
      LSize := Length(LJSONPair.JsonValue.Value) + Round(Length(LJSONPair.JsonValue.Value) * 0.25);
      if LSize = 0 then LSize := 250000;
      LFieldDef.Size := LSize;
    end;
  end;

  ADataset.Open;
end;

class procedure HelperFunctionMemoryTable.FillDataset(ADataset: TFDMemTable;
  AJSONData: TJSONArray);
var
  JObjectData : TJSONObject;
  LJSONPair: TJSONPair;
  LFieldDef: TFieldDef;
  JSONType : TTypeJSON;
begin
  for var i := 0 to AJSONData.Size - 1 do begin
    JObjectData := TJSONObject(AJSONData.Get(i));
    ADataset.Append;
    for var ii := 0 to JObjectData.Size - 1 do begin
      JSONType := GetType(JObjectData.GetValue(ADataset.FieldDefs[ii].Name).ToJSON);
      if JSONType = None then ADataset.Fields[ii].AsString := JObjectData.Values[ADataset.FieldDefs[ii].Name].Value
      else ADataset.Fields[ii].AsString := JObjectData.GetValue(ADataset.FieldDefs[ii].Name).ToJSON;
    end;
    ADataset.Post;
  end;
end;

class procedure HelperFunctionMemoryTable.FillDataset(ADataset: TFDMemTable;
  AJSONData: TJSONObject);
var
  LJSONPair: TJSONPair;
  LFieldDef: TFieldDef;
  JSONType : TTypeJSON;
begin
  ADataset.Append;
  for var ii := 0 to AJSONData.Size - 1 do begin
    JSONType := GetType(AJSONData.GetValue(ADataset.FieldDefs[ii].Name).ToJSON);
    if JSONType = None then ADataset.Fields[ii].AsString := AJSONData.Values[ADataset.FieldDefs[ii].Name].Value
    else ADataset.Fields[ii].AsString := AJSONData.GetValue(ADataset.FieldDefs[ii].Name).ToJSON;
  end;
  ADataset.Post;
end;

class procedure HelperFunctionMemoryTable.FillErrorData(ADataset: TFDMemTable;
  AMessage: String; IsEmptyData: Boolean);
begin
  ADataset.Active := False;
  ADataset.Close;
  ADataset.FieldDefs.Clear;

  ADataset.FieldDefs.Add('status', ftInteger);
  ADataset.FieldDefs.Add('messages', ftString, Length(AMessage) + 10, False);

  ADataset.CreateDataSet;
  ADataset.Active := True;
  ADataset.Open;

  if not IsEmptyData then begin
    ADataset.Append;
    ADataset.Fields[0].AsString := '400';
    ADataset.Fields[1].AsString := AMessage;
    ADataset.Post;
  end;
end;

class function HelperFunctionMemoryTable.GetType(AJSON: String): TTypeJSON;
begin
  Result := None;
  var FCheck := TJSONObject.ParseJSONValue(AJSON);
  try
    if FCheck is TJSONObject then Result := ObjectData
    else if FCheck is TJSONArray then Result := ArrayData;
  finally
    FCheck.DisposeOf;
  end;
end;

class function HelperFunctionMemoryTable.IsEmpty(ADataset: TFDMemTable;
  AJSON: String; AFillDataIfFail : Boolean = True): Boolean;
var
  TempJSON : String;
begin
  Result := False;

  TempJSON := Trim(AJSON);
  if (TempJSON = '') or (TempJSON = '[]') or (TempJSON = '{}') then Result := True;

  FillErrorData(ADataset, 'No data found', AFillDataIfFail);
end;

{ HelperJSONRequest }

class function HelperJSONRequest.FormatJSON(AJSON: String): String;
var
  JObjectData : TJSONObject;
  JArrayJSON : TJSONArray;
begin
  var FCheck := TJSONObject.ParseJSONValue(AJSON);
  try
    if FCheck is TJSONObject then begin
      JObjectData := TJSONObject.ParseJSONValue(AJSON) as TJSONObject;

      Result := TJson.Format(JObjectData);
      JObjectData.DisposeOf;
    end else if FCheck is TJSONArray then begin
      JArrayJSON := TJSONObject.ParseJSONValue(AJSON) as TJSONArray;

      Result := TJson.Format(JArrayJSON);
      JArrayJSON.DisposeOf;
    end;
  finally
    FCheck.DisposeOf;
  end;
end;

class function HelperJSONRequest.toJSON(AMemoryTable: TDataset): String;
var
  FResult, FData : TJSONObject;
  FTemp : TJsonArray;
  FValue : String;
begin
  if not AMemoryTable.IsEmpty then
    AMemoryTable.First;

  FResult := TJSONObject.Create;
  try
    FTemp := TJSONArray.Create;
    if not AMemoryTable.IsEmpty then begin
      for var i := 0 to AMemoryTable.RecordCount - 1 do begin
        FData := TJSONObject.Create;
        for var ii := 0 to AMemoryTable.FieldDefs.Count - 1 do begin
          FValue := AMemoryTable.FieldByName(AMemoryTable.FieldDefs[ii].Name).AsString;
          if HelperCheck.IsNumber(FValue) then begin
              if Length(FValue) > 1 then begin
                if Copy(FValue, 1, 1) = '0' then FData.AddPair(AMemoryTable.FieldDefs[ii].Name, FValue) else
                FData.AddPair(AMemoryTable.FieldDefs[ii].Name, TJSONNumber.Create(FValue));
              end else begin
                FData.AddPair(AMemoryTable.FieldDefs[ii].Name, TJSONNumber.Create(FValue));
              end;
//            FData.AddPair(AMemoryTable.FieldDefs[ii].Name, TJSONNumber.Create(FValue));
          end else if AMemoryTable.FieldDefs[ii].DataType = ftBoolean then begin
            FData.AddPair(AMemoryTable.FieldDefs[ii].Name, TJSONBool.Create(AMemoryTable.FieldByName(AMemoryTable.FieldDefs[ii].Name).AsBoolean))
          end else begin
            FData.AddPair(AMemoryTable.FieldDefs[ii].Name, FValue);
          end;
        end;
        FTemp.AddElement(FData);
        AMemoryTable.Next;
      end;
    end;
    FResult.AddPair('data', FTemp);

    Result := FResult.ToJSON;
  finally
    FResult.DisposeOf;
  end;
end;

class function HelperJSONRequest.toJSON(AStringList: TStringList): String;
var
  FResult : TJSONObject;
begin
  Result := '';
  if AStringList.Count = 0 then Exit;
  FResult := TJSONObject.Create;
  try
    for var i := 0 to AStringList.Count - 1 do
      FResult.AddPair(AStringList.KeyNames[i], AStringList.Values[AStringList.KeyNames[i]]);

    Result := FResult.ToJSON;
  finally
    FResult.Free;
  end;
end;

end.
