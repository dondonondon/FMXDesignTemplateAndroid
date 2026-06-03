unit BFA.Control.PushNotification;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, System.JSON,
  FMX.Platform,
  System.Notification, System.PushNotification
  {$IF Defined(ANDROID)}
  , Androidapi.Helpers, Androidapi.JNI.GraphicsContentViewText,
  Androidapi.JNI.Provider, Androidapi.JNI.JavaTypes,
  FMX.PushNotification.Android
  {$ENDIF}
  {$IF Defined(IOS)}
  , Macapi.Helpers, iOSapi.Foundation, iOSapi.Helpers, iOSapi.UIKit,
  FMX.PushNotification.iOS
    {$IF Defined(BFA_IOS_FCM)}
    , FMX.PushNotification.FCM.iOS
    {$ENDIF}
  {$ENDIF};

type
  TPushNotificationService = class
  private
    FPushService: TPushService;
    FServiceConnection: TPushServiceConnection;
    FNotificationCenter: TNotificationCenter;
    FDeviceID: string;
    FDeviceToken: string;
    FJSONFirebase: string;
    FPushServiceName: string;

    class function GetDefaultPushServiceName: string; static;

    procedure CancelNotification(const AName: string);
    procedure InitializeApplicationEventService(const AAppEvent: TApplicationEventHandler);
    procedure InitializeNotificationCenter;
    procedure InitializePushService;

    {$IF DEFINED(ANDROID) OR DEFINED(IOS)}
    class function FindJSONValue(const AObject: TJSONObject; const AName: string): TJSONValue; static;
    class function GetJSONText(const AObject: TJSONObject; const AName: string): string; static;
    class function GetJSONObject(const AObject: TJSONObject; const AName: string): TJSONObject; static;

    procedure DoReceiveNotificationEvent(Sender: TObject; const AServiceNotification: TPushServiceNotification);
    procedure DoServiceConnectionChange(Sender: TObject; APushChanges: TPushService.TChanges);
    procedure ExtractAndroidContent(const ADataObject: TJSONObject; out ATitle, ABody: string);
    procedure ExtractIOSContent(const ADataObject: TJSONObject; out ATitle, ABody: string);
    procedure ExtractNotificationContent(const AServiceNotification: TPushServiceNotification;
      out ATitle, ABody: string);
    procedure PresentLocalNotification(const ATitle, ABody: string);
    procedure RefreshDeviceIdentity;
    {$ENDIF}
  public
    constructor Create(AAppEvent: TApplicationEventHandler = nil); overload;
    constructor Create(const APushServiceName: string; AAppEvent: TApplicationEventHandler = nil); overload;
    destructor Destroy; override;

    function AppEventProc(AAppEvent: TApplicationEvent; AContext: TObject): Boolean;
    function IsSupported: Boolean;
    function NotificationAuthorizationStatus: TAuthorizationStatus;

    procedure OpenPermissionSetting;
    procedure RequestPermission;
    procedure ServiceConnectionStatus(const AActive: Boolean);

    property DeviceID: string read FDeviceID;
    property DeviceToken: string read FDeviceToken;
    property JSONFirebase: string read FJSONFirebase;
    property PushServiceName: string read FPushServiceName;
  end;

  TPushNotif = TPushNotificationService;

implementation

{ TPushNotificationService }

function TPushNotificationService.AppEventProc(AAppEvent: TApplicationEvent; AContext: TObject): Boolean;
begin
  Result := False;
  if AAppEvent = TApplicationEvent.BecameActive then begin
    CancelNotification('');
  end;
end;

procedure TPushNotificationService.CancelNotification(const AName: string);
begin
  if not Assigned(FNotificationCenter) then exit;

  if AName.Trim.IsEmpty then
    FNotificationCenter.CancelAll
  else
    FNotificationCenter.CancelNotification(AName);
end;

constructor TPushNotificationService.Create(AAppEvent: TApplicationEventHandler);
begin
  Create(GetDefaultPushServiceName, AAppEvent);
end;

constructor TPushNotificationService.Create(const APushServiceName: string; AAppEvent: TApplicationEventHandler);
begin
  inherited Create;

  FPushServiceName := APushServiceName;
  InitializeNotificationCenter;
  InitializeApplicationEventService(AAppEvent);
  InitializePushService;
  RequestPermission;
end;

destructor TPushNotificationService.Destroy;
begin
  if Assigned(FServiceConnection) then begin
    FServiceConnection.Active := False;
    FreeAndNil(FServiceConnection);
  end;

  FreeAndNil(FNotificationCenter);

  inherited;
end;

{$IF DEFINED(ANDROID) OR DEFINED(IOS)}
procedure TPushNotificationService.DoReceiveNotificationEvent(Sender: TObject;
  const AServiceNotification: TPushServiceNotification);
var
  LBody: string;
  LTitle: string;
begin
  if Assigned(AServiceNotification.DataObject) then
    FJSONFirebase := AServiceNotification.DataObject.ToJSON
  else
    FJSONFirebase := '';

  ExtractNotificationContent(AServiceNotification, LTitle, LBody);
  PresentLocalNotification(LTitle, LBody);
end;

procedure TPushNotificationService.DoServiceConnectionChange(Sender: TObject;
  APushChanges: TPushService.TChanges);
begin
  if TPushService.TChange.DeviceToken in APushChanges then begin
    RefreshDeviceIdentity;
  end;
end;
{$ENDIF}

{$IF DEFINED(ANDROID) OR DEFINED(IOS)}
procedure TPushNotificationService.ExtractAndroidContent(const ADataObject: TJSONObject;
  out ATitle, ABody: string);
var
  LNotificationObject: TJSONObject;
begin
  ATitle := GetJSONText(ADataObject, 'gcm.notification.title');
  ABody := GetJSONText(ADataObject, 'gcm.notification.body');

  if ATitle.Trim.IsEmpty then
    ATitle := GetJSONText(ADataObject, 'title');

  if ABody.Trim.IsEmpty then
    ABody := GetJSONText(ADataObject, 'body');

  if ABody.Trim.IsEmpty then
    ABody := GetJSONText(ADataObject, 'message');

  LNotificationObject := GetJSONObject(ADataObject, 'notification');
  if Assigned(LNotificationObject) then begin
    if ATitle.Trim.IsEmpty then
      ATitle := GetJSONText(LNotificationObject, 'title');

    if ABody.Trim.IsEmpty then
      ABody := GetJSONText(LNotificationObject, 'body');
  end;
end;

procedure TPushNotificationService.ExtractIOSContent(const ADataObject: TJSONObject;
  out ATitle, ABody: string);
var
  LAlerObject: TJSONObject;
  LAlertValue: TJSONValue;
  LApsObject: TJSONObject;
begin
  ATitle := '';
  ABody := '';

  LApsObject := GetJSONObject(ADataObject, 'aps');
  if not Assigned(LApsObject) then begin
    LApsObject := ADataObject;
  end;

  LAlertValue := FindJSONValue(LApsObject, 'alert');
  if not Assigned(LAlertValue) then exit;

  if LAlertValue is TJSONObject then begin
    LAlerObject := TJSONObject(LAlertValue);
    ATitle := GetJSONText(LAlerObject, 'title');
    ABody := GetJSONText(LAlerObject, 'body');
  end else begin
    ABody := LAlertValue.Value;
  end;
end;

procedure TPushNotificationService.ExtractNotificationContent(
  const AServiceNotification: TPushServiceNotification; out ATitle, ABody: string);
begin
  ATitle := '';
  ABody := '';

  if not Assigned(AServiceNotification.DataObject) then exit;

  if SameText(AServiceNotification.DataKey, TPushService.TServiceNames.APS) then begin
    ExtractIOSContent(AServiceNotification.DataObject, ATitle, ABody);
  end else begin
    ExtractAndroidContent(AServiceNotification.DataObject, ATitle, ABody);
  end;

  if ATitle.Trim.IsEmpty then
    ATitle := GetJSONText(AServiceNotification.DataObject, 'title');

  if ABody.Trim.IsEmpty then
    ABody := GetJSONText(AServiceNotification.DataObject, 'alert');
end;
{$ENDIF}

class function TPushNotificationService.GetDefaultPushServiceName: string;
begin
  Result := '';

  {$IF Defined(ANDROID)}
  Result := TPushService.TServiceNames.FCM;
  {$ENDIF}

  {$IF Defined(IOS)}
    {$IF Defined(BFA_IOS_FCM)}
    Result := TPushService.TServiceNames.FCM;
    {$ELSE}
    Result := TPushService.TServiceNames.APS;
    {$ENDIF}
  {$ENDIF}
end;

{$IF DEFINED(ANDROID) OR DEFINED(IOS)}
class function TPushNotificationService.FindJSONValue(const AObject: TJSONObject;
  const AName: string): TJSONValue;
var
  I: Integer;
  LPair: TJSONPair;
begin
  Result := nil;
  if not Assigned(AObject) then exit;

  for I := 0 to AObject.Count - 1 do begin
    LPair := AObject.Pairs[I];
    if Assigned(LPair) and Assigned(LPair.JsonString) and SameText(LPair.JsonString.Value, AName) then begin
      Result := LPair.JsonValue;
      exit;
    end;
  end;
end;

class function TPushNotificationService.GetJSONObject(const AObject: TJSONObject;
  const AName: string): TJSONObject;
var
  LValue: TJSONValue;
begin
  Result := nil;
  LValue := FindJSONValue(AObject, AName);
  if LValue is TJSONObject then begin
    Result := TJSONObject(LValue);
  end;
end;

class function TPushNotificationService.GetJSONText(const AObject: TJSONObject;
  const AName: string): string;
var
  LValue: TJSONValue;
begin
  Result := '';
  LValue := FindJSONValue(AObject, AName);
  if Assigned(LValue) then begin
    Result := LValue.Value;
  end;
end;
{$ENDIF}

procedure TPushNotificationService.InitializeApplicationEventService(
  const AAppEvent: TApplicationEventHandler);
var
  LAppEventService: IFMXApplicationEventService;
begin
  if not TPlatformServices.Current.SupportsPlatformService(IFMXApplicationEventService,
    IInterface(LAppEventService)) then exit;

  if Assigned(AAppEvent) then
    LAppEventService.SetApplicationEventHandler(AAppEvent)
  else
    LAppEventService.SetApplicationEventHandler(AppEventProc);
end;

procedure TPushNotificationService.InitializeNotificationCenter;
begin
  FNotificationCenter := TNotificationCenter.Create(nil);
end;

procedure TPushNotificationService.InitializePushService;
begin
  if FPushServiceName.Trim.IsEmpty then exit;

  {$IF DEFINED(ANDROID) OR DEFINED(IOS)}
  FPushService := TPushServiceManager.Instance.GetServiceByName(FPushServiceName);
  if not Assigned(FPushService) then exit;

  FServiceConnection := TPushServiceConnection.Create(FPushService);
  FServiceConnection.OnChange := DoServiceConnectionChange;
  FServiceConnection.OnReceiveNotification := DoReceiveNotificationEvent;
  {$ENDIF}
end;

function TPushNotificationService.IsSupported: Boolean;
begin
  Result := Assigned(FPushService) and Assigned(FServiceConnection);
end;

function TPushNotificationService.NotificationAuthorizationStatus: TAuthorizationStatus;
begin
  Result := TAuthorizationStatus.NotDetermined;
  if Assigned(FNotificationCenter) then begin
    Result := FNotificationCenter.AuthorizationStatus;
  end;
end;

procedure TPushNotificationService.OpenPermissionSetting;
begin
  {$IF Defined(ANDROID)}
  var LIntent: JIntent;

  LIntent := TJIntent.Create;
  LIntent.setAction(TJSettings.JavaClass.ACTION_APPLICATION_DETAILS_SETTINGS);
  LIntent.setData(StrToJURI('package:' + JStringToString(TAndroidHelper.Context.getPackageName)));
  TAndroidHelper.Activity.startActivity(LIntent);
  {$ENDIF}

  {$IF Defined(IOS)}
  var LURL: NSURL;

  LURL := TNSURL.Wrap(TNSURL.OCClass.URLWithString(UIApplicationOpenSettingsURLString));
  if Assigned(LURL) and TiOSHelper.SharedApplication.canOpenURL(LURL) then begin
    TiOSHelper.SharedApplication.openURL(LURL);
  end;
  {$ENDIF}
end;

{$IF DEFINED(ANDROID) OR DEFINED(IOS)}
procedure TPushNotificationService.PresentLocalNotification(const ATitle, ABody: string);
var
  LNotification: TNotification;
begin
  if not Assigned(FNotificationCenter) then exit;
  if ATitle.Trim.IsEmpty and ABody.Trim.IsEmpty then exit;

  LNotification := FNotificationCenter.CreateNotification;
  try
    LNotification.Name := TGUID.NewGuid.ToString;
    LNotification.Title := ATitle;
    LNotification.AlertBody := ABody;
    LNotification.EnableSound := False;
    FNotificationCenter.PresentNotification(LNotification);
  finally
    FreeAndNil(LNotification);
  end;
end;

procedure TPushNotificationService.RefreshDeviceIdentity;
begin
  FDeviceID := '';
  FDeviceToken := '';

  if not Assigned(FPushService) then exit;

  FDeviceID := FPushService.DeviceIDValue[TPushService.TDeviceIDNames.DeviceID];
  FDeviceToken := FPushService.DeviceTokenValue[TPushService.TDeviceTokenNames.DeviceToken];
end;
{$ENDIF}

procedure TPushNotificationService.RequestPermission;
begin
  if Assigned(FNotificationCenter) then begin
    FNotificationCenter.RequestPermission;
  end;
end;

procedure TPushNotificationService.ServiceConnectionStatus(const AActive: Boolean);
begin
  if not Assigned(FServiceConnection) then exit;

  {$IF DEFINED(ANDROID) OR DEFINED(IOS)}
  FServiceConnection.Active := AActive;
  if AActive then begin
    RefreshDeviceIdentity;
  end;
  {$ENDIF}
end;

end.
