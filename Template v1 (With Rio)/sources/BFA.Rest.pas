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
      AURL = 'https://www.blangkon.net/JSON/API.php?act=';
      AURLFile = 'https://www.blangkon.net/JSON/files/';
  {$ELSE}
      AURL = 'https://www.blangkon.net/JSON/API.php?act=';
      AURLFile = 'https://www.blangkon.net/JSON/files/';
  {$ENDIF}

type
  TStringArray = array of array of String;

procedure fnStoreNullData(mem : TFDMemTable);
function fnParseJSON(Cli : TRESTClient; Req : TRESTRequest; Resp :TRESTResponse; RespAdapter :
  TRESTResponseDataSetAdapter; act : String; mem : TFDMemTable; FMethod : TRESTRequestMethod) : Boolean;

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

function fnParseJSON(Cli : TRESTClient; Req : TRESTRequest; Resp :TRESTResponse; RespAdapter :
  TRESTResponseDataSetAdapter; act : String; mem : TFDMemTable; FMethod : TRESTRequestMethod) : Boolean;
var
  i: Integer;
begin
  try
    mem.Filtered := False;
    mem.Filter := '';
    mem.Filtered := True;


    Cli.Disconnect;
    Cli.BaseURL := AURL + act;

    Resp.RootElement := '';
    req.Method := FMethod;//TRESTRequestMethod.rmPOST;   //ctMULTIPART_FORM_DATA

    RespAdapter.Response := Resp;
    RespAdapter.Dataset := mem;

    Req.Execute;
    Req.Params.Clear;

    Result := True;

    if Resp.StatusCode <> 200 then begin
      Result := False;
    end else begin
      {for i := 0 to mem.FieldCount - 1 do begin
        if mem.FieldDefs[i].Name = 'result' then begin
          if mem.FieldByName('result').AsString = 'null' then begin
            Result := False;
            Break;
          end;
        end;
      end;}
      if mem.FieldByName('status').AsInteger <> 200 then
        Result := False
      else
        Resp.RootElement := 'data';

      mem.First;

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


end.

