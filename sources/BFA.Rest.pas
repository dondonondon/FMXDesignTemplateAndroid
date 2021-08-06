unit BFA.Rest;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  REST.Client, Data.Bind.Components, Data.Bind.ObjectScope, System.Rtti,
  FMX.Controls.Presentation, FMX.StdCtrls, System.JSON, System.Net.URLClient,
  System.Net.HttpClient, System.Net.HttpClientComponent,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs, FireDAC.FMXUI.Wait,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, FMX.ListView.Types,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, REST.Response.Adapter, REST.Types, Data.DB,
  System.JSON.Types,System.JSON.Writers, System.Threading, System.Generics.Collections, System.Net.Mime;


const
  {$IF DEFINED(IOS) or DEFINED(ANDROID)}
      url = 'http://localhost/appru/API/APITamu/APITamu.php?key=apiapi&act=';
      assURL = 'http://localhost/appru/API/APITamu/files/';
      PDFURL = 'http://localhost/appru/API/APITamu/PrintPDF/';
  {$ELSE}
      url = 'http://localhost/appru/API/APITamu/APITamu.php?key=apiapi&act=';
      assURL = 'http://localhost/appru/API/APITamu/files/';
      PDFURL = 'http://localhost/appru/API/APITamu/PrintPDF/';
  {$ENDIF}

type
  TStringArray = array of array of String;

procedure fnStoreNullData(mem : TFDMemTable);
function fnParseJSON(Cli : TRESTClient; Req : TRESTRequest; Resp :TRESTResponse; RespAdapter : TRESTResponseDataSetAdapter; act : String; mem : TFDMemTable) : Boolean;
function JSONToArray(FJSON : String) : TStringArray;
function fnGetJSON(netHTTP : TNetHTTPClient; act : String):TStringArray;
function fnPostJSON(netHTTP : TNetHTTPClient; act : String; str : TStringList):TStringArray;  overload;
function fnPostJSON(netHTTP : TNetHTTPClient; act : String; str : TMultipartFormData; Stream: TStringStream):TStringArray; overload;

implementation

uses BFA.Func;

const
  CNull = 'null';
  CGagal = 'Maaf, gagal terhubung dengan server';

procedure fnStoreNullData(mem : TFDMemTable);
begin
  mem.Active := False;
  mem.Close;
  mem.FieldDefs.Clear;

  mem.FieldDefs.Add('result', ftString, 200, False);
  mem.FieldDefs.Add('pesan', ftString, 200, False);

  mem.CreateDataSet;
  mem.Active := True;
  mem.Open;

  mem.Append;
  mem.Fields[0].AsString := 'null';
  mem.Fields[1].AsString := 'MAAF, GAGAL TERHUBUNG DENGAN SERVER';
  mem.Post;
end;

function fnParseJSON(Cli : TRESTClient; Req : TRESTRequest; Resp :TRESTResponse; RespAdapter : TRESTResponseDataSetAdapter; act : String; mem : TFDMemTable) : Boolean;
var
  i: Integer;
begin
  try
    mem.Filtered := False;
    mem.Filter := '';
    mem.Filtered := True;


    Cli.Disconnect;
    Cli.BaseURL := url + act;

    Resp.RootElement := '';
    req.Method := TRESTRequestMethod.rmPOST;   //ctMULTIPART_FORM_DATA

    RespAdapter.Response := Resp;
    RespAdapter.Dataset := mem;

    Req.Execute;
    Req.Params.Clear;

    Result := True;

    for i := 0 to mem.FieldCount - 1 do begin
      if mem.FieldDefs[i].Name = 'result' then begin
        if mem.FieldByName('result').AsString = 'null' then begin
          Result := False;
          Break;
        end;
      end;
    end;

  except
    on E : Exception do begin
      fnLog('fnParseJSON, BFA.Rest, Message', E.Message);
      fnLog('fnParseJSON, BFA.Rest, ClassName', E.ClassName);
      fnStoreNullData(mem);
      Result := False;
    end;
  end;
end;

function JSONToArray(FJSON : String) : TStringArray;
var
  strjsn : string;
  jDataObject: TJSONObject;
  jDataArray : TJSONArray;
  value : String;
  index : String;
  kol, bar, i, obj : integer;
begin
  try
    strjsn := FJSON;

    jDataArray:= TJSONObject.ParseJSONValue(strjsn) as TJSONArray;
    jDataObject := TJSONObject(jDataArray.Get(0));

    try
      kol := Pred(jDataObject.Size);
      bar := Pred(jDataArray.Size);

      SetLength(Result, kol + 1, bar + 1);
      for i:= 0 to Pred(jDataArray.Size) do
      begin
        jDataObject := TJSONObject(jDataArray.Get(i));
        for obj := 0 to Pred(jDataObject.Size) do
        begin
          index := jDataObject.Pairs[obj].JsonString.ToString;
          value := jDataObject.Pairs[obj].JsonValue.ToString;

          Result[obj, i] := StringReplace(value, '"','', [rfReplaceAll, rfIgnoreCase]);
        end;
      end;
    finally
      jDataArray.DisposeOf;
      jDataArray := nil;
    end;
  except
    on E : Exception do begin
      SetLength(Result, 2, 1);
      Result[0,0] := CNull;
      Result[1,0] := CGagal;

      fnLog('JSONToArray, BFA.Rest, Message', E.Message);
      fnLog('JSONToArray, BFA.Rest, ClassName', E.ClassName);
    end;
  end;
end;
function fnGetJSON(netHTTP : TNetHTTPClient; act : String):TStringArray;
var
  strjsn : string;
  httpresult : IHTTPResponse;
begin
  netHTTP.ConnectionTimeout := 8000;
  netHTTP.ResponseTimeout := 8000;
  strjsn := '[ { "result": "'+CNull+'", "pesan": "'+CGagal+'" } ]';
  try
    httpresult := netHTTP.get(url + act);
    strjsn := httpresult.ContentAsString();
  finally
    Result := JSONToArray(strjsn);
  end;
end;

function fnPostJSON(netHTTP : TNetHTTPClient; act : String; str : TStringList):TStringArray;
var
  strjsn : string;
  httpresult : IHTTPResponse ;
begin
  strjsn := '[ { "result": "'+CNull+'", "pesan": "'+CGagal+'" } ]';
  try
    httpresult := netHTTP.Post(url + act, str);
    strjsn := httpresult.ContentAsString();
  finally
    Result := JSONToArray(strjsn);
  end;
end;

function fnPostJSON(netHTTP : TNetHTTPClient; act : String; str : TMultipartFormData; Stream: TStringStream):TStringArray;
var
  strjsn : string;
  httpresult : IHTTPResponse ;
begin
  strjsn := '[ { "result": "'+CNull+'", "pesan": "'+CGagal+'" } ]';
  try
    httpresult := netHTTP.Post(url + act, str, Stream);
    strjsn := httpresult.ContentAsString();
  finally
    Result := JSONToArray(strjsn);
  end;
end;


end.

