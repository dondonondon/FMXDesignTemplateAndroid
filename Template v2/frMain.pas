unit frMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  System.Math,
  FMX.Ani, FMX.Controls.Presentation, FMX.Layouts, FMX.Objects,
  FMX.DialogService,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.Platform,
  FMX.ListView.Adapters.Base, FMX.VirtualKeyboard,
  System.ImageList, FMX.ImgList, FMX.ScrollBox, FMX.Memo, FMX.TabControl,
  System.Notification, System.PushNotification, System.Threading,
  FMX.Memo.Types, FMX.ListBox, FMX.MultiView, System.Permissions
{$IF Defined(ANDROID)}
    , Androidapi.JNI.AdMob, Androidapi.Helpers, FMX.Platform.Android,
  FMX.Helpers.Android, Androidapi.JNI.PlayServices, Androidapi.JNI.Os,
  Androidapi.JNI.JavaTypes, Androidapi.JNIBridge, FMX.PushNotification.Android,
  Androidapi.JNI.Embarcadero;
{$ELSEIF Defined(MSWINDOWS)}
    ;
{$ENDIF}

type
  TFMain = class(TForm)
    loMain: TLayout;
    faFromX: TFloatAnimation;
    faGoX: TFloatAnimation;
    vsMain: TVertScrollBox;
    loFrame: TLayout;
    NotificationCenter: TNotificationCenter;
    SB: TStyleBook;
    procedure CornerButton4Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure faFromXFinish(Sender: TObject);
    procedure faGoXFinish(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormVirtualKeyboardHidden(Sender: TObject;
      KeyboardVisible: Boolean; const Bounds: TRect);
    procedure FormVirtualKeyboardShown(Sender: TObject;
      KeyboardVisible: Boolean; const Bounds: TRect);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
  private
    { Keyboard }
    FService1: IFMXVirtualKeyboardToolbarService;
    FKBBounds: TRectF;
    FNeedOffset: Boolean;
    { Keyboard }
{$IFDEF ANDROID}
    PushService: TPushService;
    ServiceConnection: TPushServiceConnection;
    DeviceId: string;
    DeviceToken: string;

    procedure DoServiceConnectionChange(Sender: TObject;
      PushChanges: TPushService.TChanges);
    procedure DoReceiveNotificationEvent(Sender: TObject;
      const ServiceNotification: TPushServiceNotification);
    function AppEventProc(AAppEvent: TApplicationEvent;
      AContext: TObject): Boolean;
    procedure CancelNotification(nome: string);
{$ENDIF}
    { Keyboard }
    procedure CalcContentBoundsProc(Sender: TObject; var ContentBounds: TRectF);
    procedure RestorePosition;
    procedure UpdateKBBounds;
    { Keyboard }
  public
  end;

var
  FMain: TFMain;

implementation

{$R *.fmx}

uses BFA.GoFrame, BFA.Env, frHome, frLogin, BFA.Main, frDetail,
  frLoading, BFA.Helper.Main;

{$IFDEF ANDROID}
function TFMain.AppEventProc(AAppEvent: TApplicationEvent;
  AContext: TObject): Boolean;
begin
  if (AAppEvent = TApplicationEvent.BecameActive) then
    CancelNotification('');
end;

procedure TFMain.DoReceiveNotificationEvent(Sender: TObject;
  const ServiceNotification: TPushServiceNotification);
var
  MessageText, MessageTitle: string;
  x: Integer;

  NotificationCenter: TNotificationCenter;
  Notification: TNotification;
begin
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

      if Length(MessageText) > 0 then
        break;

    end;

  except
    on E : Exception do begin

    end;
  end;

  NotificationCenter := TNotificationCenter.Create(nil);
  try
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
  finally
    NotificationCenter.DisposeOf;
  end;
end;

procedure TFMain.DoServiceConnectionChange(Sender: TObject;
  PushChanges: TPushService.TChanges);
begin
  if TPushService.TChange.DeviceToken in PushChanges then begin
    DeviceId := PushService.DeviceIDValue[TPushService.TDeviceIDNames.DeviceId];
    DeviceToken := PushService.DeviceTokenValue[TPushService.TDeviceTokenNames.DeviceToken];
    //MemLog.Lines.Add('DEVICE_ID = ' + DeviceId);
    //MemLog.Lines.Add('DEVICE_TOKEN = ' + DeviceToken);
    FToken := DeviceToken;
  end;
end;

procedure TFMain.CancelNotification(nome: string);
begin
  if nome = '' then
    NotificationCenter.CancelAll
  else
    NotificationCenter.CancelNotification(nome);
end;
{$ENDIF}

procedure TFMain.CalcContentBoundsProc(Sender: TObject;
  var ContentBounds: TRectF);
begin
  if FNeedOffset and (FKBBounds.Top > 0) then begin
    ContentBounds.Bottom := Max(ContentBounds.Bottom,
                                2 * ClientHeight - FKBBounds.Top);
  end;
end;

procedure TFMain.CornerButton4Click(Sender: TObject);
begin
  LListFrame.HideAll;
end;

procedure TFMain.faFromXFinish(Sender: TObject);
begin
  TFloatAnimation(Sender).Enabled := False;
end;

procedure TFMain.faGoXFinish(Sender: TObject);
begin
  TFloatAnimation(Sender).Enabled := False;
  if Assigned(LListFrame.getFrame(fromFrame)) then
    LListFrame.getFrame(fromFrame).Visible := False;
end;

procedure TFMain.FormCreate(Sender: TObject);
var
  FormatBr: TFormatSettings;
  AppEvent : IFMXApplicationEventService;
begin
  {$IF DEFINED(IOS) or DEFINED(ANDROID)}
    if TPlatformServices.Current.SupportsPlatformService(IFMXVirtualKeyboardToolbarService, IInterface(FService1)) then
    begin
      FService1.SetToolbarEnabled(True);
      FService1.SetHideKeyboardButtonVisibility(True);
    end;

    {START  ============ enable ini jika sudah mengisikan project > option > entlitemen list bagian push notif }
    {JANGAN LUPA ISIKAN JUGA PROFIL FIREBASE DI OPTION > PROJECT > SERVICES}

    {if TPlatformServices.Current.SupportsPlatformService(IFMXApplicationEventService, IInterface(AppEvent)) then
        AppEvent.SetApplicationEventHandler(AppEventProc);     }

    {$IFDEF IOS}
      //PushService := TPushServiceManager.Instance.GetServiceByName(TPushService.TServiceNames.APS);
    {$ELSE}
      //PushService := TPushServiceManager.Instance.GetServiceByName(TPushService.TServiceNames.FCM);
    {$ENDIF}

    {ServiceConnection := TPushServiceConnection.Create(PushService);
    ServiceConnection.OnChange := DoServiceConnectionChange;
    ServiceConnection.OnReceiveNotification := DoReceiveNotificationEvent; }

    {END ============ enable ini jika sudah mengisikan entlitemen list bagian push notif}


    {enable ini jika sudah mengisikan entlitemen list bagian push notif}

    //TAndroidHelper.Activity.getWindow.setStatusBarColor($FF0E4EB6);             //color navbar dan status bar
    //TAndroidHelper.Activity.getWindow.setNavigationBarColor($FF0E4EB6);
  {$ELSE}

  {$ENDIF}

  try
    FormatBr                     := TFormatSettings.Create;
    FormatBr.DecimalSeparator    := '.';
    FormatBr.ThousandSeparator   := ',';
    FormatBr.DateSeparator       := '-';
    FormatBr.ShortDateFormat     := 'yyyy-mm-dd';
    FormatBr.LongDateFormat      := 'yyyy-mm-dd hh:nn:ss';

    System.SysUtils.FormatSettings := FormatBr;
  except
  end;

  FListGo := TStringList.Create;

  vsMain.OnCalcContentBounds := CalcContentBoundsProc;
end;

procedure TFMain.FormDestroy(Sender: TObject);
begin
  LListFrame.DisposeOf;
  FListGo.DisposeOf;
end;

procedure TFMain.FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
  Shift: TShiftState);
var
  FService: IFMXVirtualKeyboardService;
  Routine : TMethod;
  Exec : TExec;
  LFrame : TControl;
begin
  if Key = vkHardwareBack  then
  begin
    TPlatformServices.Current.SupportsPlatformService(IFMXVirtualKeyboardService, IInterface(FService));
    if (FService <> nil) and (TVirtualKeyboardState.Visible in FService.VirtualKeyBoardState) then
    begin
      FService.HideVirtualKeyboard;
    end
    else
    begin
      Key := 0;

      {if goFrame = C_DETAIL then
        FDetail.fnGoBack
      else
        fnBack;}

      LFrame := LListFrame.getFrame(goFrame);

      if not Assigned(LFrame) then
        Exit;

      LFrame.Visible := True;

      Routine.Data := Pointer(LFrame);
      Routine.Code := LFrame.MethodAddress('fnGoBack');
      if NOT Assigned(Routine.Code) then
        Exit;

      Exec := TExec(Routine);
      Exec;

    end;
  end
  else
  if Key = vkReturn then
  begin
    if (FService <> nil) and (TVirtualKeyboardState.Visible in FService.VirtualKeyBoardState) then
    begin
      FService.HideVirtualKeyboard;
    end;
  end;
end;

procedure TFMain.FormShow(Sender: TObject);
begin
  {$IF DEFINED (ANDROID) OR DEFINED(IOS)}
  //ServiceConnection.Active := True;    //enable ini jika sudah mengisikan entlitemen list bagian push notif
   {JANGAN LUPA ISIKAN JUGA PROFIL FIREBASE DI OPTION > PROJECT > SERVICES}
  {$ENDIF}
  fnCreateFrame;
  fnGoFrame('', C_LOADING);
end;

procedure TFMain.FormVirtualKeyboardHidden(Sender: TObject;
  KeyboardVisible: Boolean; const Bounds: TRect);
begin
  FKBBounds.Create(0, 0, 0, 0);
  FNeedOffset := False;
  RestorePosition;
end;

procedure TFMain.FormVirtualKeyboardShown(Sender: TObject;
  KeyboardVisible: Boolean; const Bounds: TRect);
begin
  FKBBounds := TRectF.Create(Bounds);
  FKBBounds.TopLeft := ScreenToClient(FKBBounds.TopLeft);
  FKBBounds.BottomRight := ScreenToClient(FKBBounds.BottomRight);
  UpdateKBBounds;
end;

procedure TFMain.RestorePosition;
begin
  vsMain.ViewportPosition := PointF(vsMain.ViewportPosition.X, 0);
  loMain.Align := TAlignLayout.Contents;
  vsMain.Align := TAlignLayout.Contents;
  vsMain.RealignContent;
end;

procedure TFMain.UpdateKBBounds;
var
  LFocused : TControl;
  LFocusRect: TRectF;
begin
  FNeedOffset := False;
  if Assigned(Focused) then
  begin
    LFocused := TControl(Focused.GetObject);
    LFocusRect := LFocused.AbsoluteRect;
    LFocusRect.Offset(vsMain.ViewportPosition);
    if FullScreen = True then
      LFocusRect.Bottom := LFocusRect.Bottom + 50;
    if (LFocusRect.IntersectsWith(TRectF.Create(FKBBounds))) and
       (LFocusRect.Bottom > FKBBounds.Top) then
    begin
      FNeedOffset := True;
      loMain.Align := TAlignLayout.Horizontal;
      vsMain.RealignContent;
      Application.ProcessMessages;
      vsMain.ViewportPosition :=
        PointF(vsMain.ViewportPosition.X,
               LFocusRect.Bottom - FKBBounds.Top);
    end;
  end;
  if not FNeedOffset then
    RestorePosition;
end;

end.
