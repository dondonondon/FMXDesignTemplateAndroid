unit BFA.Helper.Dataset;

interface

uses
  System.Classes, System.Generics.Collections, System.JSON, System.SysUtils,
  Data.DB,
  Datasnap.DBClient,
  FireDAC.Comp.Client, FireDAC.Comp.DataSet;

type
  TTypeJSON = (ArrayData, ObjectData, None);
  TJSONDataType = (jtArray, jtObject, jtNone);

  THelperDataset = class
  private
    class function CreateJSONValue(const AJSON: string): TJSONValue; static;
    class function GetFieldSize(const AValue: TJSONValue): Integer; static;
    class function GetFieldType(const AValue: TJSONValue): TFieldType; static;
    class function IsNestedJSONValue(AValue: TJSONValue): Boolean; static;
    class procedure AddFieldDef(ADataset: TFDMemTable; const AName: string;
      AFieldType: TFieldType; ASize: Integer = 0); static;
    class procedure AddJSONPair(AObject: TJSONObject; const AName: string;
      const AValue: string); static;
    class procedure AppendJSONObject(ADataset: TFDMemTable;
      AJSONData: TJSONObject); static;
    class procedure CloseAndClear(ADataset: TFDMemTable); static;
    class procedure CopyDatasetToClientDataSet(ADataset: TDataSet;
      AClientDataSet: TClientDataSet); static;
    class procedure CreateDatasetFromArray(ADataset: TFDMemTable;
      AJSONData: TJSONArray); static;
    class procedure CreateDatasetFromObject(ADataset: TFDMemTable;
      AJSONData: TJSONObject); static;
    class procedure FillDatasetFromArray(ADataset: TFDMemTable;
      AJSONData: TJSONArray); static;
    class procedure FillDatasetFromObject(ADataset: TFDMemTable;
      AJSONData: TJSONObject); static;
    class function NormalizeJSONValue(AValue: TJSONValue): TJSONValue; static;
    class function TryParseNestedJSON(const AText: string;
      out AValue: TJSONValue): Boolean; static;
    class procedure WriteJSONValue(AField: TField; AValue: TJSONValue); static;
  public
    class function CleanJSON(const AJSON: string): string; static;
    class function DatasetToJSON(ADataset: TDataSet): string; static;
    class function DetectJSONType(const AJSON: string): TJSONDataType; static;
    class function GetType(const AJSON: string): TTypeJSON; static;
    class function FormatJSON(const AJSON: string): string; static;
    class function IsFloat(const AValue: string): Boolean; static;
    class function IsInteger(const AValue: string): Boolean; static;
    class function IsNumber(const AValue: string): Boolean; static;
    class function IsStringListEmpty(AStringList: TStringList): Boolean; static;
    class function StringListToJSON(AStringList: TStringList): string; static;
    class function ToXML(ADataset: TDataSet): string; static;

    class procedure FillErrorData(ADataset: TFDMemTable;
      const AMessage: string; AAppendData: Boolean = False); static;
    class procedure LoadJSON(ADataset: TFDMemTable; const AJSON: string); static;

    class function IsEmpty(ADataset: TFDMemTable; const AJSON: string;
      AFillDataIfFail: Boolean = True): Boolean; static;
    class function toJSON(ADataset: TDataSet): string; overload; static;
      deprecated 'Use DatasetToJSON.';
    class function toJSON(AStringList: TStringList): string; overload; static;
      deprecated 'Use StringListToJSON.';
    class procedure CreateDataset(ADataset: TFDMemTable;
      AJSONData: TJSONObject); overload; static; deprecated 'Use LoadJSON.';
    class procedure CreateDataset(ADataset: TFDMemTable;
      AJSONData: TJSONArray); overload; static; deprecated 'Use LoadJSON.';
    class procedure FillDataset(ADataset: TFDMemTable;
      AJSONData: TJSONObject); overload; static; deprecated 'Use LoadJSON.';
    class procedure FillDataset(ADataset: TFDMemTable;
      AJSONData: TJSONArray); overload; static; deprecated 'Use LoadJSON.';
  end;

  HelperCheck = class(THelperDataset)
  end deprecated 'Use THelperDataset.';

  HelperFunctionMemoryTable = class(THelperDataset)
  end deprecated 'Use THelperDataset.';

  HelperJSONRequest = class(THelperDataset)
  end deprecated 'Use THelperDataset.';

  TFDMemTableHelper = class helper for TFDMemTable
    function FormatJSON: string;
    function LoadFromJSON(const AJSON: string;
      AFillDataIfFail: Boolean = True): Boolean;
    function ToJSON: string;
    function ToXML: string;
  end;

  TFDQueryHelper = class helper for TFDQuery
    function ToXML: string;
  end;

  TClientDataSetHelper = class helper for TClientDataSet
    function LoadFromXML(const AXML: string): Boolean;
  end;

  TDatasetHelper = TClientDataSetHelper deprecated 'Use TClientDataSetHelper.';

implementation

const
  DEFAULT_STRING_FIELD_SIZE = 250;
  MAX_STRING_FIELD_SIZE = 250000;

{ THelperDataset }

class procedure THelperDataset.AddFieldDef(ADataset: TFDMemTable;
  const AName: string; AFieldType: TFieldType; ASize: Integer);
var
  LFieldDef: TFieldDef;
begin
  LFieldDef := ADataset.FieldDefs.AddFieldDef;
  LFieldDef.Name := AName;
  LFieldDef.DataType := AFieldType;

  if AFieldType = ftString then begin
    if ASize <= 0 then
      ASize := DEFAULT_STRING_FIELD_SIZE;

    LFieldDef.Size := ASize;
  end;
end;

class procedure THelperDataset.AddJSONPair(AObject: TJSONObject;
  const AName, AValue: string);
var
  LJSONValue: TJSONValue;
begin
  if not Assigned(AObject) then
    raise EArgumentNilException.Create('JSON object is required.');

  if TryParseNestedJSON(AValue, LJSONValue) then
    AObject.AddPair(AName, LJSONValue)
  else
    AObject.AddPair(AName, AValue);
end;

class procedure THelperDataset.AppendJSONObject(ADataset: TFDMemTable;
  AJSONData: TJSONObject);
var
  LField: TField;
  LPair: TJSONPair;
begin
  if not Assigned(ADataset) then
    raise EArgumentNilException.Create('Dataset is required.');

  if not Assigned(AJSONData) then
    raise EArgumentNilException.Create('JSON object is required.');

  ADataset.Append;
  try
    for LPair in AJSONData do begin
      LField := ADataset.FindField(LPair.JsonString.Value);
      if Assigned(LField) then
        WriteJSONValue(LField, LPair.JsonValue);
    end;

    ADataset.Post;
  except
    if ADataset.State in dsEditModes then
      ADataset.Cancel;
    raise;
  end;
end;

class procedure THelperDataset.CloseAndClear(ADataset: TFDMemTable);
begin
  if not Assigned(ADataset) then
    raise EArgumentNilException.Create('Dataset is required.');

  ADataset.Close;
  ADataset.FieldDefs.Clear;
end;

class procedure THelperDataset.CopyDatasetToClientDataSet(ADataset: TDataSet;
  AClientDataSet: TClientDataSet);
var
  LField: TField;
begin
  for LField in ADataset.Fields do begin
    if LField.DataType = ftString then
      AClientDataSet.FieldDefs.Add(LField.FieldName, LField.DataType,
        LField.Size)
    else
      AClientDataSet.FieldDefs.Add(LField.FieldName, LField.DataType);
  end;

  AClientDataSet.CreateDataSet;
  ADataset.First;
  while not ADataset.Eof do begin
    AClientDataSet.Append;
    for LField in ADataset.Fields do
      AClientDataSet.FieldByName(LField.FieldName).Value := LField.Value;
    AClientDataSet.Post;
    ADataset.Next;
  end;

  AClientDataSet.First;
end;

class function THelperDataset.CreateJSONValue(const AJSON: string): TJSONValue;
begin
  Result := TJSONObject.ParseJSONValue(AJSON);
end;

class procedure THelperDataset.CreateDatasetFromArray(ADataset: TFDMemTable;
  AJSONData: TJSONArray);
var
  LFieldSize: Integer;
  LFieldSizes: TDictionary<string, Integer>;
  LFieldTypes: TDictionary<string, TFieldType>;
  LItem: TJSONValue;
  LObject: TJSONObject;
  LPair: TJSONPair;
  LType: TFieldType;
begin
  CloseAndClear(ADataset);

  if not Assigned(AJSONData) then
    raise EArgumentNilException.Create('JSON array is required.');

  LFieldSizes := TDictionary<string, Integer>.Create;
  LFieldTypes := TDictionary<string, TFieldType>.Create;
  try
    for LItem in AJSONData do begin
      if not (LItem is TJSONObject) then
        raise EInvalidOperation.Create('JSON array must contain objects.');

      LObject := TJSONObject(LItem);
      for LPair in LObject do begin
        LType := GetFieldType(LPair.JsonValue);
        if not LFieldTypes.ContainsKey(LPair.JsonString.Value) then begin
          LFieldTypes.Add(LPair.JsonString.Value, LType);
          LFieldSizes.Add(LPair.JsonString.Value, GetFieldSize(LPair.JsonValue));
          Continue;
        end;

        if (LFieldTypes[LPair.JsonString.Value] <> LType) or
          (LType = ftString) then begin
          LFieldTypes[LPair.JsonString.Value] := ftString;
          LFieldSize := GetFieldSize(LPair.JsonValue);
          if LFieldSizes[LPair.JsonString.Value] < LFieldSize then
            LFieldSizes[LPair.JsonString.Value] := LFieldSize;
        end;
      end;
    end;

    for var LName in LFieldTypes.Keys do
      AddFieldDef(ADataset, LName, LFieldTypes[LName], LFieldSizes[LName]);
  finally
    FreeAndNil(LFieldTypes);
    FreeAndNil(LFieldSizes);
  end;

  ADataset.CreateDataSet;
end;

class procedure THelperDataset.CreateDatasetFromObject(ADataset: TFDMemTable;
  AJSONData: TJSONObject);
var
  LPair: TJSONPair;
begin
  CloseAndClear(ADataset);

  if not Assigned(AJSONData) then
    raise EArgumentNilException.Create('JSON object is required.');

  for LPair in AJSONData do
    AddFieldDef(ADataset, LPair.JsonString.Value,
      GetFieldType(LPair.JsonValue), GetFieldSize(LPair.JsonValue));

  ADataset.CreateDataSet;
end;

class function THelperDataset.CleanJSON(const AJSON: string): string;
var
  LNormalized: TJSONValue;
  LRoot: TJSONValue;
begin
  Result := AJSON;
  LRoot := CreateJSONValue(AJSON);
  try
    if not Assigned(LRoot) then
      Exit;

    LNormalized := NormalizeJSONValue(LRoot);
    try
      if Assigned(LNormalized) then
        Result := LNormalized.ToJSON;
    finally
      FreeAndNil(LNormalized);
    end;
  finally
    FreeAndNil(LRoot);
  end;
end;

class function THelperDataset.DatasetToJSON(ADataset: TDataSet): string;
var
  LArray: TJSONArray;
  LBookmark: TBookmark;
  LItem: TJSONObject;
  LField: TField;
begin
  Result := '[]';
  if not Assigned(ADataset) then
    raise EArgumentNilException.Create('Dataset is required.');

  if not ADataset.Active then
    Exit;

  LArray := TJSONArray.Create;
  try
    ADataset.DisableControls;
    try
      LBookmark := ADataset.GetBookmark;
      try
        ADataset.First;
        while not ADataset.Eof do begin
          LItem := TJSONObject.Create;
          for LField in ADataset.Fields do begin
            if LField.IsNull then
              LItem.AddPair(LField.FieldName, TJSONNull.Create)
            else if LField.DataType = ftBoolean then
              LItem.AddPair(LField.FieldName, TJSONBool.Create(
                LField.AsBoolean))
            else if LField.DataType in [ftSmallint, ftInteger, ftWord,
              ftFloat, ftCurrency, ftBCD, ftLargeint, ftShortint, ftByte,
              ftExtended, ftLongWord, ftSingle] then
              LItem.AddPair(LField.FieldName, TJSONNumber.Create(
                LField.AsString))
            else
              AddJSONPair(LItem, LField.FieldName, LField.AsString);
          end;

          LArray.AddElement(LItem);
          ADataset.Next;
        end;

        Result := LArray.ToJSON;
      finally
        if ADataset.BookmarkValid(LBookmark) then
          ADataset.GotoBookmark(LBookmark);
        ADataset.FreeBookmark(LBookmark);
      end;
    finally
      ADataset.EnableControls;
    end;
  finally
    FreeAndNil(LArray);
  end;
end;

class function THelperDataset.DetectJSONType(const AJSON: string): TJSONDataType;
var
  LValue: TJSONValue;
begin
  Result := jtNone;
  LValue := CreateJSONValue(AJSON);
  try
    if LValue is TJSONObject then
      Result := jtObject
    else if LValue is TJSONArray then
      Result := jtArray;
  finally
    FreeAndNil(LValue);
  end;
end;

class procedure THelperDataset.CreateDataset(ADataset: TFDMemTable;
  AJSONData: TJSONObject);
begin
  CreateDatasetFromObject(ADataset, AJSONData);
end;

class procedure THelperDataset.CreateDataset(ADataset: TFDMemTable;
  AJSONData: TJSONArray);
begin
  CreateDatasetFromArray(ADataset, AJSONData);
end;

class procedure THelperDataset.FillDatasetFromArray(ADataset: TFDMemTable;
  AJSONData: TJSONArray);
var
  LItem: TJSONValue;
begin
  if not Assigned(AJSONData) then
    raise EArgumentNilException.Create('JSON array is required.');

  for LItem in AJSONData do begin
    if not (LItem is TJSONObject) then
      raise EInvalidOperation.Create('JSON array must contain objects.');

    AppendJSONObject(ADataset, TJSONObject(LItem));
  end;
end;

class procedure THelperDataset.FillDatasetFromObject(ADataset: TFDMemTable;
  AJSONData: TJSONObject);
begin
  AppendJSONObject(ADataset, AJSONData);
end;

class procedure THelperDataset.FillDataset(ADataset: TFDMemTable;
  AJSONData: TJSONObject);
begin
  FillDatasetFromObject(ADataset, AJSONData);
end;

class procedure THelperDataset.FillDataset(ADataset: TFDMemTable;
  AJSONData: TJSONArray);
begin
  FillDatasetFromArray(ADataset, AJSONData);
end;

class procedure THelperDataset.FillErrorData(ADataset: TFDMemTable;
  const AMessage: string; AAppendData: Boolean);
begin
  CloseAndClear(ADataset);
  ADataset.FieldDefs.Add('status', ftInteger);
  ADataset.FieldDefs.Add('messages', ftString, Length(AMessage) + 10, False);
  ADataset.CreateDataSet;

  if AAppendData then begin
    ADataset.Append;
    ADataset.FieldByName('status').AsInteger := 400;
    ADataset.FieldByName('messages').AsString := AMessage;
    ADataset.Post;
  end;
end;

class function THelperDataset.NormalizeJSONValue(AValue: TJSONValue): TJSONValue;
var
  LArray: TJSONArray;
  LIndex: Integer;
  LObject: TJSONObject;
  LParsed: TJSONValue;
  LText: string;
begin
  Result := nil;
  if not Assigned(AValue) then
    Exit;

  if AValue is TJSONObject then begin
    LObject := TJSONObject.Create;
    try
      for LIndex := 0 to TJSONObject(AValue).Count - 1 do
        LObject.AddPair(TJSONObject(AValue).Pairs[LIndex].JsonString.Value,
          NormalizeJSONValue(TJSONObject(AValue).Pairs[LIndex].JsonValue));
      Result := LObject;
    except
      FreeAndNil(LObject);
      raise;
    end;
  end else if AValue is TJSONArray then begin
    LArray := TJSONArray.Create;
    try
      for LIndex := 0 to TJSONArray(AValue).Count - 1 do
        LArray.AddElement(NormalizeJSONValue(TJSONArray(AValue).Items[LIndex]));
      Result := LArray;
    except
      FreeAndNil(LArray);
      raise;
    end;
  end else if AValue is TJSONString then begin
    LText := TJSONString(AValue).Value;
    if TryParseNestedJSON(LText, LParsed) then begin
      try
        Result := NormalizeJSONValue(LParsed);
      finally
        FreeAndNil(LParsed);
      end;
    end else
      Result := TJSONString.Create(LText);
  end else
    Result := CreateJSONValue(AValue.ToJSON);
end;

class function THelperDataset.FormatJSON(const AJSON: string): string;
var
  LValue: TJSONValue;
begin
  Result := AJSON;
  LValue := CreateJSONValue(AJSON);
  try
    if Assigned(LValue) then
      Result := LValue.Format;
  finally
    FreeAndNil(LValue);
  end;
end;

class function THelperDataset.GetType(const AJSON: string): TTypeJSON;
begin
  case DetectJSONType(AJSON) of
    jtArray:
      Result := ArrayData;
    jtObject:
      Result := ObjectData;
  else
    Result := None;
  end;
end;

class function THelperDataset.GetFieldSize(const AValue: TJSONValue): Integer;
begin
  Result := DEFAULT_STRING_FIELD_SIZE;

  if not Assigned(AValue) or (AValue is TJSONNull) then
    Exit;

  Result := Length(AValue.Value);
  Result := Result + Round(Result * 0.25);

  if Result <= 0 then
    Result := DEFAULT_STRING_FIELD_SIZE
  else if Result > MAX_STRING_FIELD_SIZE then
    Result := MAX_STRING_FIELD_SIZE;
end;

class function THelperDataset.GetFieldType(const AValue: TJSONValue): TFieldType;
begin
  Result := ftString;

  if not Assigned(AValue) or (AValue is TJSONNull) then
    Exit;

  if AValue is TJSONNumber then
    Result := ftFloat
  else if (AValue is TJSONTrue) or (AValue is TJSONFalse) then
    Result := ftBoolean;
end;

class function THelperDataset.IsFloat(const AValue: string): Boolean;
var
  LValue: Extended;
begin
  Result := TryStrToFloat(AValue, LValue);
end;

class function THelperDataset.IsInteger(const AValue: string): Boolean;
var
  LValue: Integer;
begin
  Result := TryStrToInt(AValue, LValue);
end;

class function THelperDataset.IsNestedJSONValue(AValue: TJSONValue): Boolean;
begin
  Result := (AValue is TJSONObject) or (AValue is TJSONArray);
end;

class function THelperDataset.IsNumber(const AValue: string): Boolean;
begin
  Result := IsFloat(AValue);
end;

class function THelperDataset.IsStringListEmpty(AStringList: TStringList): Boolean;
begin
  Result := not Assigned(AStringList) or (AStringList.Count = 0);
end;

class function THelperDataset.IsEmpty(ADataset: TFDMemTable;
  const AJSON: string; AFillDataIfFail: Boolean): Boolean;
var
  LJSON: string;
begin
  LJSON := Trim(AJSON);
  Result := (LJSON = '') or SameText(LJSON, '[]') or SameText(LJSON, '{}');

  if Result then
    FillErrorData(ADataset, 'No data found', AFillDataIfFail);
end;

class procedure THelperDataset.LoadJSON(ADataset: TFDMemTable;
  const AJSON: string);
var
  LJSONType: TJSONDataType;
  LValue: TJSONValue;
begin
  if not Assigned(ADataset) then
    raise EArgumentNilException.Create('Dataset is required.');

  LValue := CreateJSONValue(AJSON);
  try
    LJSONType := jtNone;
    if LValue is TJSONObject then
      LJSONType := jtObject
    else if LValue is TJSONArray then
      LJSONType := jtArray;

    case LJSONType of
      jtObject: begin
        CreateDatasetFromObject(ADataset, TJSONObject(LValue));
        FillDatasetFromObject(ADataset, TJSONObject(LValue));
      end;
      jtArray: begin
        CreateDatasetFromArray(ADataset, TJSONArray(LValue));
        FillDatasetFromArray(ADataset, TJSONArray(LValue));
      end;
    else
      raise EInvalidOperation.Create('Invalid JSON data.');
    end;

    if not ADataset.IsEmpty then
      ADataset.First;
  finally
    FreeAndNil(LValue);
  end;
end;

class function THelperDataset.toJSON(ADataset: TDataSet): string;
begin
  Result := DatasetToJSON(ADataset);
end;

class function THelperDataset.toJSON(AStringList: TStringList): string;
begin
  Result := StringListToJSON(AStringList);
end;

class function THelperDataset.StringListToJSON(AStringList: TStringList): string;
var
  LIndex: Integer;
  LObject: TJSONObject;
begin
  Result := '{}';
  if IsStringListEmpty(AStringList) then
    Exit;

  LObject := TJSONObject.Create;
  try
    for LIndex := 0 to AStringList.Count - 1 do
      if AStringList.Names[LIndex] <> '' then
        AddJSONPair(LObject, AStringList.Names[LIndex],
          AStringList.ValueFromIndex[LIndex]);

    Result := LObject.ToJSON;
  finally
    FreeAndNil(LObject);
  end;
end;

class function THelperDataset.TryParseNestedJSON(const AText: string;
  out AValue: TJSONValue): Boolean;
var
  LParsed: TJSONValue;
  LText: string;
begin
  Result := False;
  AValue := nil;

  LText := Trim(AText);
  if LText = '' then
    Exit;

  if not (((LText.StartsWith('{')) and (LText.EndsWith('}'))) or
    ((LText.StartsWith('[')) and (LText.EndsWith(']')))) then
    Exit;

  LParsed := CreateJSONValue(LText);
  if not Assigned(LParsed) then
    Exit;

  try
    try
      AValue := NormalizeJSONValue(LParsed);
      Result := Assigned(AValue);
    except
      FreeAndNil(AValue);
      raise;
    end;
  finally
    FreeAndNil(LParsed);
  end;
end;

class function THelperDataset.ToXML(ADataset: TDataSet): string;
var
  LClientDataSet: TClientDataSet;
  LStream: TStringStream;
begin
  Result := '';
  if not Assigned(ADataset) then
    raise EArgumentNilException.Create('Dataset is required.');

  if not ADataset.Active then
    Exit;

  LClientDataSet := TClientDataSet.Create(nil);
  LStream := TStringStream.Create('', TEncoding.UTF8);
  try
    ADataset.DisableControls;
    try
      CopyDatasetToClientDataSet(ADataset, LClientDataSet);
      LClientDataSet.SaveToStream(LStream, dfXMLUTF8);
      Result := LStream.DataString;
    finally
      ADataset.EnableControls;
    end;
  finally
    FreeAndNil(LStream);
    FreeAndNil(LClientDataSet);
  end;
end;

class procedure THelperDataset.WriteJSONValue(AField: TField;
  AValue: TJSONValue);
begin
  if not Assigned(AField) then
    Exit;

  if not Assigned(AValue) or (AValue is TJSONNull) then begin
    AField.Clear;
    Exit;
  end;

  if IsNestedJSONValue(AValue) then
    AField.AsString := AValue.ToJSON
  else if AField.DataType = ftBoolean then
    AField.AsBoolean := SameText(AValue.Value, 'true')
  else if AField.DataType in [ftSmallint, ftInteger, ftWord, ftFloat,
    ftCurrency, ftBCD, ftLargeint, ftShortint, ftByte, ftExtended, ftLongWord,
    ftSingle] then
    AField.AsString := AValue.Value
  else
    AField.AsString := AValue.Value;
end;

{ TFDMemTableHelper }

function TFDMemTableHelper.FormatJSON: string;
begin
  Result := THelperDataset.FormatJSON(ToJSON);
end;

function TFDMemTableHelper.LoadFromJSON(const AJSON: string;
  AFillDataIfFail: Boolean): Boolean;
var
  LJSON: string;
begin
  Result := False;
  LJSON := Trim(AJSON);

  if (LJSON = '') or SameText(LJSON, '[]') or SameText(LJSON, '{}') then begin
    if AFillDataIfFail then
      THelperDataset.FillErrorData(Self, 'No data found', True)
    else
      THelperDataset.FillErrorData(Self, 'No data found', False);
    Exit;
  end;

  try
    THelperDataset.LoadJSON(Self, LJSON);
    Result := True;
  except
    on E: Exception do begin
      THelperDataset.FillErrorData(Self, 'Error parse JSON : ' + E.Message,
        AFillDataIfFail);
    end;
  end;
end;

function TFDMemTableHelper.ToJSON: string;
begin
  Result := THelperDataset.DatasetToJSON(Self);
end;

function TFDMemTableHelper.ToXML: string;
begin
  Result := THelperDataset.ToXML(Self);
end;

{ TFDQueryHelper }

function TFDQueryHelper.ToXML: string;
begin
  Result := THelperDataset.ToXML(Self);
end;

{ TClientDataSetHelper }

function TClientDataSetHelper.LoadFromXML(const AXML: string): Boolean;  //standart xml dari delphi
var
  LStream: TStringStream;
begin
  Result := False;
  if Trim(AXML) = '' then
    Exit;

  LStream := TStringStream.Create(AXML, TEncoding.UTF8);
  try
    LStream.Position := 0;
    Self.LoadFromStream(LStream);
    Result := Self.Active;
  finally
    FreeAndNil(LStream);
  end;
end;

end.
