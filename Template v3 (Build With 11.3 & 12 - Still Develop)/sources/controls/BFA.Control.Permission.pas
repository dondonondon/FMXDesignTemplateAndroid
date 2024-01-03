unit BFA.Control.Permission;   //belum kepake, males pindah nya dari BFA.Helper.Main

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, System.Permissions, FMX.DialogService
  {$IF DEFINED (ANDROID)}
  , Androidapi.Helpers, Androidapi.Jni.Os
  {$ENDIF}
  ;

type
  getPermission = class
    const
      READ_CALENDAR               = 'android.permission.READ_CALENDAR';
      WRITE_CALENDAR              = 'android.permission.WRITE_CALENDAR';
      CAMERA                      = 'android.permission.CAMERA';
      READ_CONTACTS               = 'android.permission.READ_CONTACTS';
      WRITE_CONTACTS              = 'android.permission.WRITE_CONTACTS';
      GET_ACCOUNTS                = 'android.permission.GET_ACCOUNTS';
      ACCESS_FINE_LOCATION        = 'android.permission.ACCESS_FINE_LOCATION';
      ACCESS_COARSE_LOCATION      = 'android.permission.ACCESS_COARSE_LOCATION';
      RECORD_AUDIO                = 'android.permission.RECORD_AUDIO';
      READ_PHONE_STATE            = 'android.permission.READ_PHONE_STATE';
      READ_PHONE_NUMBERS          = 'android.permission.READ_PHONE_NUMBERS ';
      CALL_PHONE                  = 'android.permission.CALL_PHONE';
      ANSWER_PHONE_CALLS          = 'android.permission.ANSWER_PHONE_CALLS ';
      READ_CALL_LOG               = 'android.permission.READ_CALL_LOG';
      WRITE_CALL_LOG              = 'android.permission.WRITE_CALL_LOG';
      ADD_VOICEMAIL               = 'android.permission.ADD_VOICEMAIL';
      USE_SIP                     = 'android.permission.USE_SIP';
      PROCESS_OUTGOING_CALLS      = 'android.permission.PROCESS_OUTGOING_CALLS';
      BODY_SENSORS                = 'android.permission.BODY_SENSORS';
      SEND_SMS                    = 'android.permission.SEND_SMS';
      RECEIVE_SMS                 = 'android.permission.RECEIVE_SMS';
      READ_SMS                    = 'android.permission.READ_SMS';
      RECEIVE_WAP_PUSH            = 'android.permission.RECEIVE_WAP_PUSH';
      RECEIVE_MMS                 = 'android.permission.RECEIVE_MMS';
      READ_EXTERNAL_STORAGE       = 'android.permission.READ_EXTERNAL_STORAGE';
      WRITE_EXTERNAL_STORAGE      = 'android.permission.WRITE_EXTERNAL_STORAGE';
      ACCESS_MEDIA_LOCATION       = 'android.permission.ACCESS_MEDIA_LOCATION';
      ACCEPT_HANDOVER             = 'android.permission.ACCEPT_HANDOVER';
      ACCESS_BACKGROUND_LOCATION  = 'android.permission.ACCESS_BACKGROUND_LOCATION';
      ACTIVITY_RECOGNITION        = 'android.permission.ACTIVITY_RECOGNITION';

      //POST NOTIF
      POST_NOTIFICATIONS          = 'android.permission.POST_NOTIFICATIONS';

      //BLUETOOTH
      BLUETOOTH_SCAN              = 'android.permission.BLUETOOTH_SCAN';
      BLUETOOTH_CONNECT           = 'android.permission.BLUETOOTH_CONNECT';

      //ANDROID 13
      READ_MEDIA_IMAGES           = 'android.permission.READ_MEDIA_IMAGES';
      READ_MEDIA_VIDEO            = 'android.permission.READ_MEDIA_VIDEO';
      READ_MEDIA_AUDIO            = 'android.permission.READ_MEDIA_AUDIO';
  end;

  HelperPermission = class
    class procedure setPermission(const APermissions: TArray<string>; FProc : TProc = nil);

    public
      class var AProc : TProc;
    private

    {$IF CompilerVersion <= 34.0}
      class procedure DisplayRationale(Sender: TObject; const APermissions: TArray<string>; const APostRationaleProc: TProc);
      class procedure RequestPermissionsResult(Sender: TObject; const APermissions: TArray<string>; const AGrantResults: TArray<TPermissionStatus>);
    {$ELSEIF CompilerVersion >= 35.0}
      class procedure DisplayRationale(Sender: TObject; const APermissions: TClassicStringDynArray; const APostRationaleProc: TProc);
      class procedure RequestPermissionsResult(Sender: TObject; const APermissions: TClassicStringDynArray; const AGrantResults: TClassicPermissionStatusDynArray);
    {$ENDIF}
  end;


implementation

{ HelperPermission }
{$IF CompilerVersion <= 34.0}
class procedure HelperPermission.DisplayRationale(Sender: TObject;
  const APermissions: TArray<string>; const APostRationaleProc: TProc);
{$ELSEIF CompilerVersion >= 35.0}
class procedure HelperPermission.DisplayRationale(Sender: TObject; const APermissions: TClassicStringDynArray; const APostRationaleProc: TProc);
{$ENDIF}
var
  i : Integer;
  RationaleMsg: String;
begin
  RationaleMsg := '';
  for i := 0 to High(APermissions) do begin
    RationaleMsg := RationaleMsg + 'Application asking permission ' + APermissions[i] + ''#13;
  end;

  TDialogService.ShowMessage(RationaleMsg,
  procedure(const AResult: TModalResult) begin
    APostRationaleProc;
  end)
end;

{$IF CompilerVersion <= 34.0}
class procedure HelperPermission.RequestPermissionsResult(Sender: TObject;
  const APermissions: TArray<string>;
  const AGrantResults: TArray<TPermissionStatus>);
{$ELSEIF CompilerVersion >= 35.0}
class procedure HelperPermission.RequestPermissionsResult(Sender: TObject;
  const APermissions: TClassicStringDynArray; const AGrantResults: TClassicPermissionStatusDynArray);
{$ENDIF}
begin
  var isAllGrant := True;
  for var i := 0 to Length(AGrantResults) - 1 do begin
    if AGrantResults[i] <> TPermissionStatus.Granted then begin
      isAllGrant := False;
      Break;
    end;
  end;

  if isAllGrant then begin
    if Assigned(AProc) then
      AProc;
  end else begin
    TDialogService.ShowMessage('Gagal mendapatkan akses storage');
  end;
end;

class procedure HelperPermission.setPermission(
  const APermissions: TArray<string>; FProc: TProc);
begin
  if Assigned(FProc) then
    AProc := FProc;

  PermissionsService.RequestPermissions(
    APermissions,
    HelperPermission.RequestPermissionsResult,
    HelperPermission.DisplayRationale);
end;

end.
