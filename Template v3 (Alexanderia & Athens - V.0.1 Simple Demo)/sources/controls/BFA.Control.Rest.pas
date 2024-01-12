unit BFA.Control.Rest;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, FMX.Dialogs,
  REST.Client, Data.Bind.Components, Data.Bind.ObjectScope, System.Rtti,
  FMX.Controls.Presentation, FMX.StdCtrls, System.JSON, System.Net.URLClient,
  System.Net.HttpClient, System.Net.HttpClientComponent,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs, FireDAC.FMXUI.Wait,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, FMX.ListView.Types,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, REST.Response.Adapter, REST.Types, Data.DB, Data.DBJson,
  System.JSON.Types,System.JSON.Writers, System.Threading, System.Generics.Collections, System.Net.Mime;

type
  TRequestAPI = class
  private
    FRequest: TRESTRequest;
    FResponse: TRESTResponse;
    FAdapter: TRESTResponseDataSetAdapter;
    FClient: TRESTClient;
    FURL: String;
    FMethod: TRESTRequestMethod;
    FData: TFDMemTable;
    FContent: String;
    FStatusCode: Integer;
  public
    property Request : TRESTRequest read FRequest write FRequest;
    property Response : TRESTResponse read FResponse write FResponse;
    property Client : TRESTClient read FClient write FClient;
    property Adapter : TRESTResponseDataSetAdapter read FAdapter write FAdapter;
    property Data : TFDMemTable read FData write FData;

    property Method : TRESTRequestMethod read FMethod write FMethod;
    property URL : String read FURL write FURL;

    property Content : String read FContent;
    property StatusCode : Integer read FStatusCode;

    procedure AddParameter(const AName, AValue: string); overload;
    procedure AddParameter(const AName, AValue: string; const AKind: TRESTRequestParameterKind); overload;
    procedure AddBody(const ABodyContent: string; AContentType: TRESTContentType = ctNone);

    procedure Execute(AClearRootElement : Boolean = False);

    constructor Create;
    destructor Destroy; override;
  end;

implementation

{ TRequestAPI }

procedure TRequestAPI.AddBody(const ABodyContent: string;
  AContentType: TRESTContentType);
begin
  Request.AddBody(ABodyContent, AContentType);
end;

procedure TRequestAPI.AddParameter(const AName, AValue: string;
  const AKind: TRESTRequestParameterKind);
begin
  Request.AddParameter(AName, AValue, AKind);
end;

procedure TRequestAPI.AddParameter(const AName, AValue: string);
begin
  Request.AddParameter(AName, AValue);
end;

constructor TRequestAPI.Create;
begin
  Request     := TRESTRequest.Create(nil);
  Response    := TRESTResponse.Create(nil);
  Client      := TRESTClient.Create(nil);
  Adapter     := TRESTResponseDataSetAdapter.Create(nil);

  Request.Client := Client;
  Request.Response := Response;
  Method := TRESTRequestMethod.rmGET;

  Adapter.TypesMode := TJSONTypesMode.StringOnly;

  Request.Params.Clear;

  Adapter.Response := Response;
end;

destructor TRequestAPI.Destroy;
begin
  Request.DisposeOf;
  Response.DisposeOf;
  Client.DisposeOf;
  Adapter.DisposeOf;
  inherited;
end;

procedure TRequestAPI.Execute(AClearRootElement : Boolean);
begin
  if not Assigned(Data) then
    raise Exception.Create('Dataset not set. Please assign Dataset first');

  if AClearRootElement then
    Response.RootElement := '';

  Client.BaseURL := URL;
  Request.Method := Method;

  Adapter.Dataset := Data;
  Request.Execute;

  FStatusCode := Response.StatusCode;
//  FContent := Response.JSONText;
  FContent := Response.Content;
end;

end.
