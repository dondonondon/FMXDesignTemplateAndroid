unit BFA.Helper.Main;

interface

uses
  System.Classes, System.SysUtils,
  Data.DB,
  BFA.App.Types,
  BFA.App.Services,
  BFA.Control.Form.Message,

  Rest.Types,
  FireDAC.Comp.Client,
  BFA.Helper.APIRequest;

type
  TAppHelper = class
  private
    class procedure ExecuteOnMainThread(const AProc: TProc); static;
    class function MainHelper: TMainHelper; static;
    class function Services: TAppServices; static;
  public
    class procedure Back;
    class procedure NavigateTo(const AView: string);
    class procedure StartLoading(AMessage: string = '');
    class procedure StopLoading;
    class procedure ToastMessage(AMessage: string; AJenis: TTypeMessage = Information);
  end;

  TRESTRequestHelper = class
  private
    class procedure ConfigureRequest(ARequest: TAPIRequest; const ATimeout: Integer = 15000); static;
  public
    class function Request(AData : TFDMemTable; AURL : String; ABodyJSON : String; AMethod : TRESTRequestMethod = rmGET) : Boolean; overload;
    class function Request(AData : TFDMemTable; AURL : String) : Boolean; overload;
    class function Request(AFormData: TAPIRequest; AData: TFDMemTable; AURL: String): Boolean; overload;
    class function Request(AFormData: TAPIRequest; AData: TFDMemTable; AURL, ABodyJSON: String): Boolean; overload;
    class function Request(AData : TFDMemTable; AURL, ABodyJSON : String; AFormData : TAPIRequest) : Boolean; overload;
    class function Request(AData : TFDMemTable; AURL : String; AFormData : TAPIRequest) : Boolean; overload;
  end;

  THttpRequestHelper = class
  private
    class procedure ConfigureRequest(ARequest: TNetAPIRequest; const ATimeout: Integer = 15000); static;
  public
    class function DownloadFile(const AURL, ATargetFileName: string): Boolean; static;
    class function Request(AData: TFDMemTable; AURL: string): Boolean; overload;
    class function Request(AData: TFDMemTable; AURL, ABodyJSON: string; AMethod: TRESTRequestMethod = TRESTRequestMethod.rmGET): Boolean; overload;
    class function Request(AFormData: TNetAPIRequest; AData: TFDMemTable; AURL: string): Boolean; overload;
    class function Request(AFormData: TNetAPIRequest; AData: TFDMemTable; AURL, ABodyJSON: string): Boolean; overload;
    class function Request(AData: TFDMemTable; AURL: string; AFormData: TNetAPIRequest): Boolean; overload;
    class function Request(AData: TFDMemTable; AURL, ABodyJSON: string; AFormData: TNetAPIRequest): Boolean; overload;
  end;

implementation

uses
  BFA.App.Context, BFA.Helper.Dataset;

{ TAppHelper }

class procedure TAppHelper.Back;
begin
  ExecuteOnMainThread(procedure begin
    if Assigned(Services.Router) then
      Services.Router.Back;
  end);
end;

class procedure TAppHelper.ExecuteOnMainThread(const AProc: TProc);
begin
  if TThread.CurrentThread.ThreadID = MainThreadID then
    AProc()
  else
    TThread.Queue(nil, procedure begin
      AProc();
    end);
end;

class function TAppHelper.MainHelper: TMainHelper;
begin
  Result := Services.MainHelper;
  if not Assigned(Result) then
    raise EInvalidOperation.Create('Main helper is not initialized.');
end;

class procedure TAppHelper.NavigateTo(const AView: string);
begin
  ExecuteOnMainThread(procedure begin
    if Assigned(Services.Router) then
      Services.Router.NavigateTo(AView);
  end);
end;

class function TAppHelper.Services: TAppServices;
begin
  if not Assigned(AppContext) then
    raise EInvalidOperation.Create('Application context is not initialized.');

  Result := AppContext.Services;
  if not Assigned(Result) then
    raise EInvalidOperation.Create('Application services are not initialized.');
end;

class procedure TAppHelper.StartLoading(AMessage: string);
begin
  MainHelper.StartLoading(AMessage);
end;

class procedure TAppHelper.StopLoading;
begin
  MainHelper.StopLoading;
end;

class procedure TAppHelper.ToastMessage(AMessage: string; AJenis: TTypeMessage);
begin
  ExecuteOnMainThread(procedure begin
    MainHelper.ShowToastMessage(AMessage, AJenis);
  end);
end;

function IsHTTPStatusSuccess(const AStatusCode: Integer): Boolean;
begin
  Result := (AStatusCode >= 200) and (AStatusCode < 300);
end;

function LoadAPIResponse(AData: TFDMemTable; const AContent: string;
  const AStatusCode: Integer): Boolean;
var
  LDataField: TField;
  LStatusField: TField;
begin
  Result := False;

  if not Assigned(AData) then
    raise EArgumentNilException.Create('Response dataset is required.');

  if not AData.LoadFromJSON(AContent, False) then begin
    THelperDataset.FillErrorData(AData, 'Invalid response JSON.', False);
    exit;
  end;

  if not IsHTTPStatusSuccess(AStatusCode) then exit;

  LStatusField := AData.FindField('status');
  if Assigned(LStatusField) and (not IsHTTPStatusSuccess(LStatusField.AsInteger)) then exit;

  LDataField := AData.FindField('data');
  if Assigned(LDataField) and (not LDataField.AsString.Trim.IsEmpty) then begin
    Result := AData.LoadFromJSON(LDataField.AsString, False);
    exit;
  end;

  Result := True;
end;

procedure FillRequestError(AData: TFDMemTable; const AMessage, AContent: string);
begin
  if not Assigned(AData) then exit;

  if AContent.Trim.IsEmpty or (not AData.LoadFromJSON(AContent, False)) then begin
    THelperDataset.FillErrorData(AData, AMessage, False);
  end;
end;

{ TRESTRequestHelper }

class procedure TRESTRequestHelper.ConfigureRequest(ARequest: TAPIRequest;
  const ATimeout: Integer);
begin
  if not Assigned(ARequest) then
    raise EArgumentNilException.Create('REST request is required.');

  ARequest.Request.Timeout := ATimeout;
  ARequest.Request.ConnectTimeout := ATimeout;
end;

class function TRESTRequestHelper.Request(AData: TFDMemTable; AURL,
  ABodyJSON: String; AMethod: TRESTRequestMethod): Boolean;
var
  LRequest: TAPIRequest;
begin
  LRequest := TAPIRequest.Create;
  try
    try
      LRequest.Method := AMethod;
      ConfigureRequest(LRequest);
      LRequest.URL := AURL;
      if AMethod <> TRESTRequestMethod.rmGET then begin
        LRequest.AddBody(ABodyJSON, TRESTContentType.ctAPPLICATION_JSON);
      end;

      LRequest.Execute(True);
      Result := LoadAPIResponse(AData, LRequest.Content, LRequest.StatusCode);
    except
      on E: Exception do begin
        FillRequestError(AData, E.Message + ' | ' + E.ClassName, LRequest.Content);
        Result := False;
      end;
    end;
  finally
    FreeAndNil(LRequest);
  end;
end;

class function TRESTRequestHelper.Request(AData: TFDMemTable; AURL: String): Boolean;
begin
  Result := Request(AData, AURL, '', TRESTRequestMethod.rmGET);
end;

class function TRESTRequestHelper.Request(AFormData: TAPIRequest;
  AData: TFDMemTable; AURL: String): Boolean;
begin
  Result := False;
  try
    ConfigureRequest(AFormData);
    AFormData.URL := AURL;
    if AFormData.Method = TRESTRequestMethod.rmGET then begin
      AFormData.Method := TRESTRequestMethod.rmPOST;
    end;

    AFormData.Execute(True);
    Result := LoadAPIResponse(AData, AFormData.Content, AFormData.StatusCode);
  except
    on E: Exception do begin
      FillRequestError(AData, E.Message + ' | ' + E.ClassName, AFormData.Content);
    end;
  end;
end;

class function TRESTRequestHelper.Request(AFormData: TAPIRequest;
  AData: TFDMemTable; AURL, ABodyJSON: String): Boolean;
begin
  Result := False;
  try
    ConfigureRequest(AFormData, 35000);
    AFormData.URL := AURL;
    AFormData.Method := TRESTRequestMethod.rmPOST;
    AFormData.AddBody(ABodyJSON, TRESTContentType.ctAPPLICATION_JSON);
    AFormData.Execute(True);

    Result := LoadAPIResponse(AData, AFormData.Content, AFormData.StatusCode);
  except
    on E: Exception do begin
      FillRequestError(AData, E.Message + ' | ' + E.ClassName, AFormData.Content);
    end;
  end;
end;

class function TRESTRequestHelper.Request(AData: TFDMemTable; AURL: String;
  AFormData: TAPIRequest): Boolean;
begin
  Result := Request(AFormData, AData, AURL);
end;

class function TRESTRequestHelper.Request(AData: TFDMemTable; AURL,
  ABodyJSON: String; AFormData: TAPIRequest): Boolean;
begin
  Result := Request(AFormData, AData, AURL, ABodyJSON);
end;

{ THttpRequestHelper }

class procedure THttpRequestHelper.ConfigureRequest(ARequest: TNetAPIRequest;
  const ATimeout: Integer);
begin
  if not Assigned(ARequest) then
    raise EArgumentNilException.Create('HTTP request is required.');

  ARequest.Client.ConnectionTimeout := ATimeout;
  ARequest.Client.SendTimeout := ATimeout;
  ARequest.Client.ResponseTimeout := ATimeout;
end;

class function THttpRequestHelper.DownloadFile(const AURL,
  ATargetFileName: string): Boolean;
begin
  Result := TNetAPIRequest.DownloadFile(AURL, ATargetFileName);
end;

class function THttpRequestHelper.Request(AData: TFDMemTable;
  AURL: string): Boolean;
begin
  Result := Request(AData, AURL, '', TRESTRequestMethod.rmGET);
end;

class function THttpRequestHelper.Request(AData: TFDMemTable; AURL,
  ABodyJSON: string; AMethod: TRESTRequestMethod): Boolean;
var
  LRequest: TNetAPIRequest;
begin
  LRequest := TNetAPIRequest.Create;
  try
    LRequest.Method := AMethod;
    Result := Request(LRequest, AData, AURL, ABodyJSON);
  finally
    FreeAndNil(LRequest);
  end;
end;

class function THttpRequestHelper.Request(AFormData: TNetAPIRequest;
  AData: TFDMemTable; AURL: string): Boolean;
begin
  Result := False;
  try
    ConfigureRequest(AFormData);
    AFormData.URL := AURL;
    if AFormData.Method = TRESTRequestMethod.rmGET then begin
      AFormData.Method := TRESTRequestMethod.rmPOST;
    end;

    AFormData.Execute;
    Result := LoadAPIResponse(AData, AFormData.Content, AFormData.StatusCode);
  except
    on E: Exception do begin
      FillRequestError(AData, E.Message + ' | ' + E.ClassName, AFormData.Content);
    end;
  end;
end;

class function THttpRequestHelper.Request(AFormData: TNetAPIRequest;
  AData: TFDMemTable; AURL, ABodyJSON: string): Boolean;
begin
  Result := False;
  try
    ConfigureRequest(AFormData, 35000);
    AFormData.URL := AURL;
    AFormData.Method := TRESTRequestMethod.rmPOST;
    AFormData.AddBody(ABodyJSON);
    AFormData.Execute;

    Result := LoadAPIResponse(AData, AFormData.Content, AFormData.StatusCode);
  except
    on E: Exception do begin
      FillRequestError(AData, E.Message + ' | ' + E.ClassName, AFormData.Content);
    end;
  end;
end;

class function THttpRequestHelper.Request(AData: TFDMemTable; AURL: string;
  AFormData: TNetAPIRequest): Boolean;
begin
  Result := Request(AFormData, AData, AURL);
end;

class function THttpRequestHelper.Request(AData: TFDMemTable; AURL,
  ABodyJSON: string; AFormData: TNetAPIRequest): Boolean;
begin
  Result := Request(AFormData, AData, AURL, ABodyJSON);
end;

end.

