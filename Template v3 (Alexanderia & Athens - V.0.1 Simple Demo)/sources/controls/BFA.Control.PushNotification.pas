unit BFA.Control.PushNotification;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Platform,
  System.Notification, System.PushNotification, System.Permissions
  {$IF Defined(ANDROID)}
  , Androidapi.Helpers, FMX.Platform.Android, Androidapi.JNI.Net,
  Androidapi.JNI.GraphicsContentViewText, Androidapi.JNI.Provider,
  Androidapi.JNI.JavaTypes, Androidapi.JNIBridge, FMX.PushNotification.Android;
  {$ELSEIF Defined(MSWINDOWS)}
      ;
  {$ENDIF}

type
  TPushNotif = class
  private
    PushService: TPushService;
    ServiceConnection: TPushServiceConnection;
    FDeviceId: string;
    FDeviceToken: string;
    FJSONFirebase : String;
    NotificationCenter : TNotificationCenter;

    {$IF DEFINED (ANDROID) OR DEFINED(IOS)}
    procedure DoServiceConnectionChange(Sender: TObject;
      PushChanges: TPushService.TChanges);
    procedure DoReceiveNotificationEvent(Sender: TObject;
      const ServiceNotification: TPushServiceNotification);
    {$ENDIF}

    procedure CancelNotification(Name: string);
  public
    property DeviceID : String read FDeviceId;
    property DeviceToken : String read FDeviceToken;
    property JSONFirebase : String read FJSONFirebase;
    function AppEventProc(AAppEvent: TApplicationEvent;
      AContext: TObject): Boolean;

    procedure ServiceConnectionStatus(Active : Boolean);
    procedure OpenPermissionSetting;

    constructor Create(AAppEvent : TApplicationEventHandler = nil);
    destructor Destroy; override;
  end;

implementation

{ TPushNotif }

function TPushNotif.AppEventProc(AAppEvent: TApplicationEvent;
  AContext: TObject): Boolean;
begin
  if (AAppEvent = TApplicationEvent.BecameActive) then
    CancelNotification('');
end;

procedure TPushNotif.CancelNotification(Name: string);
begin
  if Name = '' then
    NotificationCenter.CancelAll
  else
    NotificationCenter.CancelNotification(Name);
end;

{$IF DEFINED (ANDROID) OR DEFINED(IOS)}

procedure TPushNotif.DoReceiveNotificationEvent(Sender: TObject;
  const ServiceNotification: TPushServiceNotification);
var
  MessageText, MessageTitle: string;
  x: Integer;
  Notification: TNotification;
begin
  FJSONFirebase := ServiceNotification.DataObject.ToJSON;

  MessageText := '';
  try
    for x := 0 to ServiceNotification.DataObject.Count - 1 do begin
      //IOS
      if ServiceNotification.DataKey = 'aps' then begin
        if ServiceNotification.DataObject.Pairs[x].JsonString.Value = 'alert' then
          MessageText := ServiceNotification.DataObject.Pairs[x].JsonValue.Value;
      end;

      // Android...
      if ServiceNotification.DataKey = 'fcm' then begin
        if ServiceNotification.DataObject.Pairs[x].JsonString.Value = 'gcm.notification.body' then
          MessageText := ServiceNotification.DataObject.Pairs[x].JsonValue.Value;

        if ServiceNotification.DataObject.Pairs[x].JsonString.Value = 'gcm.notification.title' then
          MessageTitle := ServiceNotification.DataObject.Pairs[x].JsonValue.Value;
      end;
    end;

  except
    on E : Exception do begin
      MessageText := 'Invalid PushNotification JSON';
      MessageTitle := 'PushNotification';
    end;
  end;

  Notification := NotificationCenter.CreateNotification;
  try
    Notification.Name := MessageText;
    Notification.AlertBody := MessageText;
    Notification.Title := MessageTitle;
    Notification.EnableSound := False;
    NotificationCenter.PresentNotification(Notification);
  finally
    Notification.DisposeOf;
  end;
end;

procedure TPushNotif.DoServiceConnectionChange(Sender: TObject;
  PushChanges: TPushService.TChanges);
begin
  if TPushService.TChange.DeviceToken in PushChanges then begin
    FDeviceId := PushService.DeviceIDValue[TPushService.TDeviceIDNames.DeviceId];
    FDeviceToken := PushService.DeviceTokenValue[TPushService.TDeviceTokenNames.DeviceToken];
  end;
end;

{$ENDIF}

constructor TPushNotif.Create(AAppEvent : TApplicationEventHandler);
var
  AppEvent : IFMXApplicationEventService;
begin
  NotificationCenter := TNotificationCenter.Create(nil);

  if Assigned(AAppEvent) then begin
    if TPlatformServices.Current.SupportsPlatformService(IFMXApplicationEventService, IInterface(AppEvent)) then
      AppEvent.SetApplicationEventHandler(AAppEvent);
  end else begin
    if TPlatformServices.Current.SupportsPlatformService(IFMXApplicationEventService, IInterface(AppEvent)) then
      AppEvent.SetApplicationEventHandler(AppEventProc);
  end;

  {$IF DEFINED(IOS) or DEFINED(ANDROID)}

  {$IFDEF IOS}
    PushService := TPushServiceManager.Instance.GetServiceByName(TPushService.TServiceNames.APS);
  {$ELSE}
    PushService := TPushServiceManager.Instance.GetServiceByName(TPushService.TServiceNames.FCM);
  {$ENDIF}

  ServiceConnection := TPushServiceConnection.Create(PushService);
  ServiceConnection.OnChange := DoServiceConnectionChange;
  ServiceConnection.OnReceiveNotification := DoReceiveNotificationEvent;
  {$ENDIF}
end;

destructor TPushNotif.Destroy;
begin
  if Assigned(ServiceConnection) then
    ServiceConnection.DisposeOf;

  if Assigned(NotificationCenter) then
    NotificationCenter.DisposeOf;

  inherited;
end;

procedure TPushNotif.OpenPermissionSetting;
begin
  {$IF DEFINED(ANDROID)}

  var Intent: JIntent;

  Intent := TJIntent.Create;
  Intent.setAction(TJSettings.JavaClass.ACTION_APPLICATION_DETAILS_SETTINGS);
//  Intent.setData(TJnet_Uri.JavaClass.parse(StringToJString('package:').concat(TAndroidHelper.Context.getPackageName)));
  Intent.setData(StrToJURI('package:' + JStringToString(TAndroidHelper.Context.getPackageName)));
  TAndroidHelper.Activity.startActivity(Intent);
  {$ENDIF}
end;

procedure TPushNotif.ServiceConnectionStatus(Active: Boolean);
var
  AppEvent : IFMXApplicationEventService;
begin
  {$IF DEFINED(IOS) or DEFINED(ANDROID)}
  ServiceConnection.Active := Active;
  {$ENDIF}
end;

end.
