unit BFA.Helper.APIRequest;

interface

uses
  System.Classes,
  System.IOUtils,
  System.NetEncoding,
  System.Net.HttpClient,
  System.Net.HttpClientComponent,
  System.Net.URLClient,
  System.SysUtils,
  Data.DBJson,
  REST.Client,
  REST.Response.Adapter,
  REST.Types;

type
  TNetHTTPClientHelper = class helper for TNetHTTPClient
  public
    function DownloadFile(const AURL, ATargetFileName: string): Boolean;
  end;

  TAPIRequest = class
  private
    FAdapter: TRESTResponseDataSetAdapter;
    FClient: TRESTClient;
    FContent: string;
    FMethod: TRESTRequestMethod;
    FRequest: TRESTRequest;
    FResponse: TRESTResponse;
    FStatusCode: Integer;
    FURL: string;
  public
    constructor Create;
    destructor Destroy; override;

    procedure AddBody(const ABodyContent: string;
      AContentType: TRESTContentType = TRESTContentType.ctNone);
    procedure AddParameter(const AName, AValue: string); overload;
    procedure AddParameter(const AName, AValue: string;
      const AKind: TRESTRequestParameterKind); overload;
    procedure Clear;
    procedure Execute(AClearRootElement: Boolean = False);

    property Adapter: TRESTResponseDataSetAdapter read FAdapter;
    property Client: TRESTClient read FClient;
    property Content: string read FContent;
    property Method: TRESTRequestMethod read FMethod write FMethod;
    property Request: TRESTRequest read FRequest;
    property Response: TRESTResponse read FResponse;
    property StatusCode: Integer read FStatusCode;
    property URL: string read FURL write FURL;
  end;

  TNetAPIRequest = class
  private
    FBody: string;
    FClient: TNetHTTPClient;
    FContent: string;
    FContentType: string;
    FHeaders: TNetHeaders;
    FMethod: TRESTRequestMethod;
    FParameters: TStringList;
    FResponse: IHTTPResponse;
    FStatusCode: Integer;
    FURL: string;

    function BuildURL: string;
    function CreateBodyStream: TStringStream;
    function HeadersWithContentType: TNetHeaders;
    class function EncodeURLValue(const AValue: string): string; static;
  public
    constructor Create;
    destructor Destroy; override;

    class function DownloadFile(const AURL, ATargetFileName: string): Boolean; static;

    procedure AddBody(const ABodyContent: string;
      const AContentType: string = 'application/json');
    procedure AddHeader(const AName, AValue: string);
    procedure AddParameter(const AName, AValue: string);
    procedure Clear;
    procedure Execute;

    property Body: string read FBody write FBody;
    property Client: TNetHTTPClient read FClient;
    property Content: string read FContent;
    property ContentType: string read FContentType write FContentType;
    property Method: TRESTRequestMethod read FMethod write FMethod;
    property Response: IHTTPResponse read FResponse;
    property StatusCode: Integer read FStatusCode;
    property URL: string read FURL write FURL;
  end;

  TAPIRequestNetHTTP = TNetAPIRequest;

implementation

{ TNetHTTPClientHelper }

function TNetHTTPClientHelper.DownloadFile(const AURL,
  ATargetFileName: string): Boolean;
var
  LResponse: IHTTPResponse;
  LStream: TMemoryStream;
  LTargetDirectory: string;
begin
  Result := False;

  if AURL.Trim.IsEmpty then exit;
  if ATargetFileName.Trim.IsEmpty then exit;

  LTargetDirectory := ExtractFilePath(ATargetFileName);
  if (not LTargetDirectory.Trim.IsEmpty) and (not TDirectory.Exists(LTargetDirectory)) then begin
    TDirectory.CreateDirectory(LTargetDirectory);
  end;

  LStream := TMemoryStream.Create;
  try
    LResponse := Get(AURL, LStream);
    if Assigned(LResponse) and (LResponse.StatusCode >= 200) and
      (LResponse.StatusCode <= 299) then begin
      LStream.Position := 0;
      LStream.SaveToFile(ATargetFileName);
      Result := True;
    end;
  finally
    FreeAndNil(LStream);
  end;
end;

{ TAPIRequest }

procedure TAPIRequest.AddBody(const ABodyContent: string;
  AContentType: TRESTContentType);
begin
  FRequest.AddBody(ABodyContent, AContentType);
end;

procedure TAPIRequest.AddParameter(const AName, AValue: string;
  const AKind: TRESTRequestParameterKind);
begin
  FRequest.AddParameter(AName, AValue, AKind);
end;

procedure TAPIRequest.AddParameter(const AName, AValue: string);
begin
  FRequest.AddParameter(AName, AValue);
end;

procedure TAPIRequest.Clear;
begin
  FContent := '';
  FStatusCode := 0;
  FRequest.Body.ClearBody;
  FRequest.Params.Clear;
  FResponse.RootElement := '';
end;

constructor TAPIRequest.Create;
begin
  inherited Create;

  FRequest := TRESTRequest.Create(nil);
  FResponse := TRESTResponse.Create(nil);
  FClient := TRESTClient.Create(nil);
  FAdapter := TRESTResponseDataSetAdapter.Create(nil);

  FRequest.Client := FClient;
  FRequest.Response := FResponse;
  FAdapter.Response := FResponse;
  FAdapter.TypesMode := TJSONTypesMode.StringOnly;

  FMethod := TRESTRequestMethod.rmGET;
end;

destructor TAPIRequest.Destroy;
begin
  FreeAndNil(FAdapter);
  FreeAndNil(FRequest);
  FreeAndNil(FResponse);
  FreeAndNil(FClient);
  inherited;
end;

procedure TAPIRequest.Execute(AClearRootElement: Boolean);
begin
  if AClearRootElement then begin
    FResponse.RootElement := '';
  end;

  FClient.BaseURL := FURL;
  FRequest.Method := FMethod;
  FRequest.Execute;

  FStatusCode := FResponse.StatusCode;
  FContent := FResponse.Content;
end;

{ TNetAPIRequest }

procedure TNetAPIRequest.AddBody(const ABodyContent, AContentType: string);
begin
  FBody := ABodyContent;
  FContentType := AContentType;
end;

procedure TNetAPIRequest.AddHeader(const AName, AValue: string);
var
  LIndex: Integer;
begin
  LIndex := Length(FHeaders);
  SetLength(FHeaders, LIndex + 1);
  FHeaders[LIndex] := TNetHeader.Create(AName, AValue);
end;

procedure TNetAPIRequest.AddParameter(const AName, AValue: string);
begin
  FParameters.Values[AName] := AValue;
end;

function TNetAPIRequest.BuildURL: string;
var
  I: Integer;
  LDelimiter: string;
  LName: string;
  LQuery: string;
begin
  Result := FURL;
  LQuery := '';

  for I := 0 to FParameters.Count - 1 do begin
    LName := FParameters.Names[I];
    if LName.Trim.IsEmpty then continue;

    if LQuery.Trim.IsEmpty then
      LDelimiter := ''
    else
      LDelimiter := '&';

    LQuery := LQuery + LDelimiter + EncodeURLValue(LName) + '=' +
      EncodeURLValue(FParameters.ValueFromIndex[I]);
  end;

  if LQuery.Trim.IsEmpty then exit;

  if Result.Contains('?') then
    Result := Result + '&' + LQuery
  else
    Result := Result + '?' + LQuery;
end;

procedure TNetAPIRequest.Clear;
begin
  FBody := '';
  FContent := '';
  FContentType := 'application/json';
  FResponse := nil;
  FStatusCode := 0;
  FParameters.Clear;
  SetLength(FHeaders, 0);
end;

constructor TNetAPIRequest.Create;
begin
  inherited Create;

  FClient := TNetHTTPClient.Create(nil);
  FParameters := TStringList.Create;
  FParameters.NameValueSeparator := '=';
  FMethod := TRESTRequestMethod.rmGET;
  FContentType := 'application/json';
end;

function TNetAPIRequest.CreateBodyStream: TStringStream;
begin
  Result := nil;
  if FBody.Trim.IsEmpty then exit;

  Result := TStringStream.Create(FBody, TEncoding.UTF8);
end;

destructor TNetAPIRequest.Destroy;
begin
  FreeAndNil(FParameters);
  FreeAndNil(FClient);
  inherited;
end;

class function TNetAPIRequest.DownloadFile(const AURL,
  ATargetFileName: string): Boolean;
var
  LClient: TNetHTTPClient;
begin
  LClient := TNetHTTPClient.Create(nil);
  try
    Result := LClient.DownloadFile(AURL, ATargetFileName);
  finally
    FreeAndNil(LClient);
  end;
end;

class function TNetAPIRequest.EncodeURLValue(const AValue: string): string;
begin
  Result := TNetEncoding.URL.Encode(AValue);
end;

procedure TNetAPIRequest.Execute;
var
  LBodyStream: TStringStream;
  LResponseStream: TStringStream;
  LURL: string;
begin
  LURL := BuildURL;
  LBodyStream := CreateBodyStream;
  LResponseStream := TStringStream.Create('', TEncoding.UTF8);
  try
    case FMethod of
      TRESTRequestMethod.rmGET:
        FResponse := FClient.Get(LURL, LResponseStream, FHeaders);
      TRESTRequestMethod.rmPOST:
        FResponse := FClient.Post(LURL, LBodyStream, LResponseStream,
          HeadersWithContentType);
      TRESTRequestMethod.rmPUT:
        FResponse := FClient.Put(LURL, LBodyStream, LResponseStream,
          HeadersWithContentType);
      TRESTRequestMethod.rmDELETE:
        FResponse := FClient.Delete(LURL, LResponseStream, FHeaders);
      TRESTRequestMethod.rmPATCH:
        FResponse := FClient.Patch(LURL, LBodyStream, LResponseStream,
          HeadersWithContentType);
    else
      raise ENetHTTPClientException.Create('Unsupported HTTP method.');
    end;

    if Assigned(FResponse) then
      FStatusCode := FResponse.StatusCode
    else
      FStatusCode := 0;

    FContent := LResponseStream.DataString;
  finally
    FreeAndNil(LResponseStream);
    FreeAndNil(LBodyStream);
  end;
end;

function TNetAPIRequest.HeadersWithContentType: TNetHeaders;
var
  LIndex: Integer;
begin
  Result := Copy(FHeaders);

  if FContentType.Trim.IsEmpty then exit;

  for LIndex := 0 to High(Result) do begin
    if SameText(Result[LIndex].Name, 'Content-Type') then exit;
  end;

  LIndex := Length(Result);
  SetLength(Result, LIndex + 1);
  Result[LIndex] := TNetHeader.Create('Content-Type', FContentType);
end;

end.
