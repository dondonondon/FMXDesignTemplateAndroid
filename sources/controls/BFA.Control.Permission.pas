unit BFA.Control.Permission;

interface

uses
  System.Permissions, System.SysUtils, System.Types, System.UITypes,
  FMX.DialogService;

type
  TPermissionDeniedProc = reference to procedure(const APermissions: TArray<string>);

  TPermissionName = class
  public const
    READ_CALENDAR = 'android.permission.READ_CALENDAR';
    WRITE_CALENDAR = 'android.permission.WRITE_CALENDAR';
    CAMERA = 'android.permission.CAMERA';
    READ_CONTACTS = 'android.permission.READ_CONTACTS';
    WRITE_CONTACTS = 'android.permission.WRITE_CONTACTS';
    GET_ACCOUNTS = 'android.permission.GET_ACCOUNTS';
    ACCESS_FINE_LOCATION = 'android.permission.ACCESS_FINE_LOCATION';
    ACCESS_COARSE_LOCATION = 'android.permission.ACCESS_COARSE_LOCATION';
    RECORD_AUDIO = 'android.permission.RECORD_AUDIO';
    READ_PHONE_STATE = 'android.permission.READ_PHONE_STATE';
    READ_PHONE_NUMBERS = 'android.permission.READ_PHONE_NUMBERS';
    CALL_PHONE = 'android.permission.CALL_PHONE';
    ANSWER_PHONE_CALLS = 'android.permission.ANSWER_PHONE_CALLS';
    READ_CALL_LOG = 'android.permission.READ_CALL_LOG';
    WRITE_CALL_LOG = 'android.permission.WRITE_CALL_LOG';
    ADD_VOICEMAIL = 'android.permission.ADD_VOICEMAIL';
    USE_SIP = 'android.permission.USE_SIP';
    PROCESS_OUTGOING_CALLS = 'android.permission.PROCESS_OUTGOING_CALLS';
    BODY_SENSORS = 'android.permission.BODY_SENSORS';
    SEND_SMS = 'android.permission.SEND_SMS';
    RECEIVE_SMS = 'android.permission.RECEIVE_SMS';
    READ_SMS = 'android.permission.READ_SMS';
    RECEIVE_WAP_PUSH = 'android.permission.RECEIVE_WAP_PUSH';
    RECEIVE_MMS = 'android.permission.RECEIVE_MMS';
    READ_EXTERNAL_STORAGE = 'android.permission.READ_EXTERNAL_STORAGE';
    WRITE_EXTERNAL_STORAGE = 'android.permission.WRITE_EXTERNAL_STORAGE';
    ACCESS_MEDIA_LOCATION = 'android.permission.ACCESS_MEDIA_LOCATION';
    ACCEPT_HANDOVER = 'android.permission.ACCEPT_HANDOVER';
    ACCESS_BACKGROUND_LOCATION = 'android.permission.ACCESS_BACKGROUND_LOCATION';
    ACTIVITY_RECOGNITION = 'android.permission.ACTIVITY_RECOGNITION';
    POST_NOTIFICATIONS = 'android.permission.POST_NOTIFICATIONS';
    BLUETOOTH_SCAN = 'android.permission.BLUETOOTH_SCAN';
    BLUETOOTH_CONNECT = 'android.permission.BLUETOOTH_CONNECT';
    READ_MEDIA_IMAGES = 'android.permission.READ_MEDIA_IMAGES';
    READ_MEDIA_VIDEO = 'android.permission.READ_MEDIA_VIDEO';
    READ_MEDIA_AUDIO = 'android.permission.READ_MEDIA_AUDIO';
  end;

  TPermissionGroup = class
  public
    class function Bluetooth: TArray<string>; static;
    class function Camera: TArray<string>; static;
    class function Location: TArray<string>; static;
    class function Microphone: TArray<string>; static;
    class function Notifications: TArray<string>; static;
    class function PhotoLibrary: TArray<string>; static;
    class function Storage: TArray<string>; static;
  end;

  THelperPermission = class
  private
    class var FOnDenied: TPermissionDeniedProc;
    class var FOnGranted: TProc;

    class procedure ExecuteGranted; static;
    {$IF DEFINED(ANDROID)}
    class function AllGranted(
      const AGrantResults: TClassicPermissionStatusDynArray): Boolean; static;
    class function ToStringArray(
      const APermissions: TClassicStringDynArray): TArray<string>; static;
    class procedure ExecuteDenied(
      const APermissions: TClassicStringDynArray); static;
    class procedure ShowDeniedMessage(
      const APermissions: TClassicStringDynArray); static;
    class function ToClassicStringArray(
      const APermissions: TArray<string>): TClassicStringDynArray; static;
    class procedure ShowRationale(Sender: TObject;
      const APermissions: TClassicStringDynArray;
      const APostRationaleProc: TProc); static;
    class procedure RequestResult(Sender: TObject;
      const APermissions: TClassicStringDynArray;
      const AGrantResults: TClassicPermissionStatusDynArray); static;
    {$ENDIF}
  public
    class function IsEveryPermissionGranted(
      const APermissions: TArray<string>): Boolean; static;
    class procedure RequestPermissions(const APermissions: TArray<string>;
      AOnGranted: TProc = nil; AOnDenied: TPermissionDeniedProc = nil); static;

    class procedure RequireBluetooth(AOnGranted: TProc = nil;
      AOnDenied: TPermissionDeniedProc = nil); static;
    class procedure RequireCamera(AOnGranted: TProc = nil;
      AOnDenied: TPermissionDeniedProc = nil); static;
    class procedure RequireLocation(AOnGranted: TProc = nil;
      AOnDenied: TPermissionDeniedProc = nil); static;
    class procedure RequireMicrophone(AOnGranted: TProc = nil;
      AOnDenied: TPermissionDeniedProc = nil); static;
    class procedure RequireNotifications(AOnGranted: TProc = nil;
      AOnDenied: TPermissionDeniedProc = nil); static;
    class procedure RequirePhotoLibrary(AOnGranted: TProc = nil;
      AOnDenied: TPermissionDeniedProc = nil); static;
    class procedure RequireStorage(AOnGranted: TProc = nil;
      AOnDenied: TPermissionDeniedProc = nil); static;

    class procedure setPermission(const APermissions: TArray<string>;
      FProc: TProc = nil); static; deprecated 'Use RequestPermissions.';
  end;

  getPermission = TPermissionName deprecated 'Use TPermissionName.';
  HelperPermission = THelperPermission deprecated 'Use THelperPermission.';

implementation

{ TPermissionGroup }

class function TPermissionGroup.Bluetooth: TArray<string>;
begin
  {$IF DEFINED(ANDROID)}
  Result := [TPermissionName.BLUETOOTH_SCAN, TPermissionName.BLUETOOTH_CONNECT];
  {$ELSE}
  Result := [];
  {$ENDIF}
end;

class function TPermissionGroup.Camera: TArray<string>;
begin
  {$IF DEFINED(ANDROID)}
  Result := [TPermissionName.CAMERA];
  {$ELSE}
  Result := [];
  {$ENDIF}
end;

class function TPermissionGroup.Location: TArray<string>;
begin
  {$IF DEFINED(ANDROID)}
  Result := [TPermissionName.ACCESS_FINE_LOCATION,
    TPermissionName.ACCESS_COARSE_LOCATION];
  {$ELSE}
  Result := [];
  {$ENDIF}
end;

class function TPermissionGroup.Microphone: TArray<string>;
begin
  {$IF DEFINED(ANDROID)}
  Result := [TPermissionName.RECORD_AUDIO];
  {$ELSE}
  Result := [];
  {$ENDIF}
end;

class function TPermissionGroup.Notifications: TArray<string>;
begin
  {$IF DEFINED(ANDROID)}
  Result := [TPermissionName.POST_NOTIFICATIONS];
  {$ELSE}
  Result := [];
  {$ENDIF}
end;

class function TPermissionGroup.PhotoLibrary: TArray<string>;
begin
  {$IF DEFINED(ANDROID)}
  Result := [TPermissionName.READ_MEDIA_IMAGES, TPermissionName.READ_MEDIA_VIDEO];
  {$ELSE}
  Result := [];
  {$ENDIF}
end;

class function TPermissionGroup.Storage: TArray<string>;
begin
  {$IF DEFINED(ANDROID)}
  Result := [TPermissionName.READ_EXTERNAL_STORAGE,
    TPermissionName.WRITE_EXTERNAL_STORAGE];
  {$ELSE}
  Result := [];
  {$ENDIF}
end;

{ THelperPermission }

{$IF DEFINED(ANDROID)}
class function THelperPermission.AllGranted(
  const AGrantResults: TClassicPermissionStatusDynArray): Boolean;
var
  LGrantResult: TPermissionStatus;
begin
  Result := Length(AGrantResults) > 0;

  for LGrantResult in AGrantResults do begin
    if LGrantResult <> TPermissionStatus.Granted then begin
      Result := False;
      Exit;
    end;
  end;
end;
{$ENDIF}

{$IF DEFINED(ANDROID)}
class procedure THelperPermission.ExecuteDenied(
  const APermissions: TClassicStringDynArray);
begin
  if Assigned(FOnDenied) then
    FOnDenied(ToStringArray(APermissions))
  else
    ShowDeniedMessage(APermissions);
end;
{$ENDIF}

class procedure THelperPermission.ExecuteGranted;
begin
  if Assigned(FOnGranted) then
    FOnGranted;
end;

class function THelperPermission.IsEveryPermissionGranted(
  const APermissions: TArray<string>): Boolean;
begin
  {$IF DEFINED(ANDROID)}
  if Length(APermissions) = 0 then
    Exit(True);

  Result := PermissionsService.IsEveryPermissionGranted(APermissions);
  {$ELSE}
  Result := True;
  {$ENDIF}
end;

class procedure THelperPermission.RequestPermissions(
  const APermissions: TArray<string>; AOnGranted: TProc;
  AOnDenied: TPermissionDeniedProc);
begin
  FOnGranted := AOnGranted;
  FOnDenied := AOnDenied;

  if Length(APermissions) = 0 then begin
    ExecuteGranted;
    Exit;
  end;

  {$IF DEFINED(ANDROID)}
  PermissionsService.RequestPermissions(ToClassicStringArray(APermissions),
    RequestResult, ShowRationale);
  {$ELSE}
  ExecuteGranted;
  {$ENDIF}
end;

{$IF DEFINED(ANDROID)}
class procedure THelperPermission.RequestResult(Sender: TObject;
  const APermissions: TClassicStringDynArray;
  const AGrantResults: TClassicPermissionStatusDynArray);
begin
  if AllGranted(AGrantResults) then
    ExecuteGranted
  else
    ExecuteDenied(APermissions);
end;
{$ENDIF}

class procedure THelperPermission.RequireBluetooth(AOnGranted: TProc;
  AOnDenied: TPermissionDeniedProc);
begin
  RequestPermissions(TPermissionGroup.Bluetooth, AOnGranted, AOnDenied);
end;

class procedure THelperPermission.RequireCamera(AOnGranted: TProc;
  AOnDenied: TPermissionDeniedProc);
begin
  RequestPermissions(TPermissionGroup.Camera, AOnGranted, AOnDenied);
end;

class procedure THelperPermission.RequireLocation(AOnGranted: TProc;
  AOnDenied: TPermissionDeniedProc);
begin
  RequestPermissions(TPermissionGroup.Location, AOnGranted, AOnDenied);
end;

class procedure THelperPermission.RequireMicrophone(AOnGranted: TProc;
  AOnDenied: TPermissionDeniedProc);
begin
  RequestPermissions(TPermissionGroup.Microphone, AOnGranted, AOnDenied);
end;

class procedure THelperPermission.RequireNotifications(AOnGranted: TProc;
  AOnDenied: TPermissionDeniedProc);
begin
  RequestPermissions(TPermissionGroup.Notifications, AOnGranted, AOnDenied);
end;

class procedure THelperPermission.RequirePhotoLibrary(AOnGranted: TProc;
  AOnDenied: TPermissionDeniedProc);
begin
  RequestPermissions(TPermissionGroup.PhotoLibrary, AOnGranted, AOnDenied);
end;

class procedure THelperPermission.RequireStorage(AOnGranted: TProc;
  AOnDenied: TPermissionDeniedProc);
begin
  RequestPermissions(TPermissionGroup.Storage, AOnGranted, AOnDenied);
end;

class procedure THelperPermission.setPermission(
  const APermissions: TArray<string>; FProc: TProc);
begin
  RequestPermissions(APermissions, FProc);
end;

{$IF DEFINED(ANDROID)}
class procedure THelperPermission.ShowDeniedMessage(
  const APermissions: TClassicStringDynArray);
var
  LMessage: string;
  LPermission: string;
begin
  LMessage := 'Permission request was denied.';
  if Length(APermissions) > 0 then begin
    LMessage := LMessage + sLineBreak + sLineBreak;
    for LPermission in APermissions do
      LMessage := LMessage + '- ' + LPermission + sLineBreak;
  end;

  TDialogService.ShowMessage(LMessage);
end;
{$ENDIF}

{$IF DEFINED(ANDROID)}
class procedure THelperPermission.ShowRationale(Sender: TObject;
  const APermissions: TClassicStringDynArray;
  const APostRationaleProc: TProc);
var
  LMessage: string;
  LPermission: string;
begin
  LMessage := 'The application needs these permissions to continue:';
  for LPermission in APermissions do
    LMessage := LMessage + sLineBreak + '- ' + LPermission;

  TDialogService.ShowMessage(LMessage,
    procedure(const AResult: TModalResult) begin
      if Assigned(APostRationaleProc) then
        APostRationaleProc;
    end);
end;
{$ENDIF}

{$IF DEFINED(ANDROID)}
class function THelperPermission.ToClassicStringArray(
  const APermissions: TArray<string>): TClassicStringDynArray;
var
  LIndex: Integer;
begin
  SetLength(Result, Length(APermissions));
  for LIndex := 0 to High(APermissions) do
    Result[LIndex] := APermissions[LIndex];
end;
{$ENDIF}

{$IF DEFINED(ANDROID)}
class function THelperPermission.ToStringArray(
  const APermissions: TClassicStringDynArray): TArray<string>;
var
  LIndex: Integer;
begin
  SetLength(Result, Length(APermissions));
  for LIndex := 0 to High(APermissions) do
    Result[LIndex] := APermissions[LIndex];
end;
{$ENDIF}

end.
