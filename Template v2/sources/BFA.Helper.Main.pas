unit BFA.Helper.Main;

interface

uses
  BFA.Func, System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, System.Generics.Collections, System.Net.URLClient, System.Net.HttpClient,
  System.Net.HttpClientComponent,
  FMX.Objects, BFA.Env, FMX.Ani, System.Permissions, FMX.DialogService
  {$IF DEFINED (ANDROID)}
  , Androidapi.Helpers, Androidapi.Jni.Os
  {$ENDIF}
  ;


const
  C_ERROR = 0;
  C_SUKSES = 1;
  C_INFO  = 2;

type
  TFormLoading = class helper for TForm
    procedure heLoading(isStat : Boolean);
    procedure ShowPopUpMessage(FMessage : String; FJenis : Integer; FProc : TProc = nil);
    procedure ShowToastMessage(FMessage : String; FJenis : Integer);
  end;

  HelperClick = class
    class procedure defClickPopUp(Sender : TObject);
    class procedure defClickToast(Sender : TObject);
    class procedure flFinish(Sender : TObject);
  end;

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

{ TLoadingForm }

procedure TFormLoading.heLoading(isStat: Boolean);
var
  FLayout : TLayout;
  FAni : TAniIndicator;
begin
  if not isStat then begin
    FLayout := TLayout(Self.FindStyleResource('FLayout'));
    if Assigned(FLayout) then
      FLayout.DisposeOf;

    Exit;
  end;

  FLayout := TLayout(Self.FindStyleResource('FLayout'));
  if not Assigned(FLayout) then begin
    FLayout := TLayout.Create(Self);
    FLayout.Align := TAlignLayout.Contents;
    FLayout.HitTest := True;
    FLayout.StyleName := 'FLayout';

    FAni := TAniIndicator.Create(FLayout);
    FAni.Align := TAlignLayout.Center;
    FAni.Enabled := isStat;
    FAni.StyleName := 'FAni';

    FLayout.AddObject(FAni);
    Self.AddObject(FLayout);
    FLayout.BringToFront;
  end else begin
    FLayout.Visible := isStat;
    FAni := TAniIndicator(FLayout.FindStyleResource('FAni'));
    if Assigned(FAni) then
      FAni.Enabled := isStat;
    FLayout.BringToFront;
  end;
end;

{ Helper }

class procedure HelperClick.defClickPopUp(Sender: TObject);
begin
  //TLayout(TControl(Sender).Parent).Visible := False;
  TLayout(TControl(Sender).Parent).DisposeOf;
end;

procedure TFormLoading.ShowPopUpMessage(FMessage: String; FJenis: Integer;
  FProc: TProc);
var
  lo : TLayout;
  reBlack : TRectangle;
  reSide : TRectangle;
  reBackground : TRectangle;
  LStatus : TLabel;
  LMessage : TText;
  LClick : TLabel;
  FStatus : String;
  FColor : Cardinal;
begin
  if FJenis = C_SUKSES then begin
    FStatus := 'Success!';
    FColor := $FF4BC961;
  end else if FJenis = C_ERROR then begin
    FStatus := 'Error...';
    FColor := $FFFF6969;
  end else if FJenis = C_INFO then begin
    FStatus := 'Information';
    FColor := $FF36414A;
  end;

  if not Assigned(TLayout(Self.FindStyleResource('loPopUp'))) then begin
    lo := TLayout.Create(Self);
    lo.StyleName := 'loPopUp';
    lo.HitTest := True;
    lo.Align := TAlignLayout.Contents;

    Self.AddObject(lo);

      reBlack := TRectangle.Create(lo);
      reBlack.Align := TAlignLayout.Contents;
      reBlack.Stroke.Kind := TBrushKind.None;
      reBlack.Fill.Color := TAlphaColorRec.Black;
      reBlack.Opacity := 0.20;
      lo.AddObject(reBlack);

        reBackground := TRectangle.Create(lo);
        reBackground.Fill.Color := TAlphaColorRec.White;
        reBackground.Stroke.Kind := TBrushKind.None;
        reBackground.Width := lo.Width - 32;
        reBackground.Position.X := 16;
        reBackground.Position.Y := 32;
        reBackground.XRadius := 8;
        reBackground.YRadius := reBackground.XRadius;
        reBackground.Anchors := [TAnchorKind.akLeft, TAnchorKind.akRight, TAnchorKind.akTop];
        lo.AddObject(reBackground);

        reSide := TRectangle.Create(lo);
        reSide.Fill.Color := FColor;
        reSide.Stroke.Kind := TBrushKind.None;
        reSide.Width := 10;
        reSide.Position.X := 16;
        reSide.Position.Y := 32;
        reSide.XRadius := reBackground.XRadius;
        reSide.YRadius := reBackground.XRadius;
        reSide.Corners := [TCorner.TopLeft, TCorner.BottomLeft];
        lo.AddObject(reSide);

        LClick := TLabel.Create(lo);
        LClick.Text := 'Close';
        LClick.Font.Size := 12.5;
        LClick.Width := 60;
        LClick.FontColor := $FFBCBFC2;
        LClick.Position.X := lo.Width - (LClick.Width + 16);
        LClick.TextSettings.HorzAlign := TTextAlign.Center;
        LClick.HitTest := True;
        LClick.StyledSettings := [];
        lo.AddObject(LClick);

        LStatus := TLabel.Create(lo);
        LStatus.Font.Size := 15;
        LStatus.Text := FStatus;
        LStatus.Height := 20;
        LStatus.Width := reBackground.Width - (LClick.Width + reSide.Width + 16);;
        LStatus.FontColor := FColor;
        LStatus.Position.X := reSide.Position.X + reSide.Width + 8;
        LStatus.Position.Y := reBackground.Position.Y + 8;
        LStatus.StyledSettings := [];
        lo.AddObject(LStatus);

        LMessage := TText.Create(lo);
        LMessage.Font.Size := 12.5;
        LMessage.Text := FMessage;
        LMessage.AutoSize := True;
        LMessage.WordWrap := True;
        LMessage.Width := reBackground.Width - (LClick.Width + reSide.Width + 16);
        LMessage.TextSettings.FontColor := $FF36414A;
        LMessage.Position.X := reSide.Position.X + reSide.Width + 8;
        LMessage.Position.Y := LStatus.Position.Y + LStatus.Height + 4;
        LMessage.TextSettings.HorzAlign := TTextAlign.Leading;
        lo.AddObject(LMessage);

        reBackground.Height := LStatus.Height + LMessage.Height + 20;
        reSide.Height := reBackground.Height;
        LClick.Height := reBackground.Height;
        LClick.Position.Y := reBackground.Position.Y;

        LClick.OnClick := HelperClick.defClickPopUp;
  end;
end;

procedure TFormLoading.ShowToastMessage(FMessage: String; FJenis: Integer);
var
  lo : TLayout;
  loPop : TLayout;
  reBlack : TRectangle;
  reSide : TRectangle;
  reBackground : TRectangle;
  LStatus : TLabel;
  LMessage : TText;
  LClick : TLabel;
  FStatus : String;
  FColor : Cardinal;
begin
  if FJenis = C_SUKSES then begin
    FStatus := 'Success!';
    FColor := $FF4BC961;
  end else if FJenis = C_ERROR then begin
    FStatus := 'Error...';
    FColor := $FFFF6969;
  end else if FJenis = C_INFO then begin
    FStatus := 'Information';
    FColor := $FF36414A;
  end;

  if not Assigned(TLayout(Self.FindStyleResource('loToast'))) then begin
    lo := TLayout.Create(Self);
    lo.StyleName := 'loToast';
    lo.Align := TAlignLayout.Contents;
    Self.AddObject(lo);
  end else begin
    lo := TLayout(Self.FindStyleResource('loToast'));
  end;

  loPop := TLayout.Create(lo);
  loPop.Align := TAlignLayout.Top;
  loPop.Margins.Top := 12;
  loPop.Margins.Left := 16;
  if Self.Width < 400 then
    loPop.Margins.Right := 16
  else
    loPop.Margins.Right := Self.Width - 400;

  loPop.Position.Y := 1000;
  lo.AddObject(loPop);

  reBackground := TRectangle.Create(loPop);
  reBackground.Fill.Color := TAlphaColorRec.White;
  reBackground.Stroke.Color := $FFBCBFC2;
  reBackground.Width := loPop.Width;
  reBackground.Position.X := 0;
  reBackground.Position.Y := 0;
  reBackground.XRadius := 8;
  reBackground.YRadius := reBackground.XRadius;
  reBackground.Align := TAlignLayout.Contents;
  //reBackground.Anchors := [TAnchorKind.akLeft, TAnchorKind.akRight, TAnchorKind.akTop, TAnchorKind.akBottom];
  loPop.AddObject(reBackground);

  reSide := TRectangle.Create(loPop);
  reSide.Fill.Color := FColor;
  reSide.Stroke.Kind := TBrushKind.None;
  reSide.Width := 10;
  reSide.Position.X := 0;
  reSide.Position.Y := 0;
  reSide.XRadius := reBackground.XRadius;
  reSide.YRadius := reBackground.XRadius;
  reSide.Corners := [TCorner.TopLeft, TCorner.BottomLeft];
  reSide.Align := TAlignLayout.Left;
  //reSide.Anchors := [TAnchorKind.akLeft, TAnchorKind.akTop, TAnchorKind.akBottom];
  loPop.AddObject(reSide);

  LClick := TLabel.Create(loPop);
  LClick.Text := 'Close';
  LClick.Font.Size := 12.5;
  LClick.Width := 60;
  LClick.Height := loPop.Height;
  LClick.FontColor := $FFBCBFC2;
  LClick.Position.X := loPop.Width - LClick.Width;
  LClick.Position.Y := 0;
  LClick.TextSettings.HorzAlign := TTextAlign.Center;
  LClick.HitTest := True;
  LClick.StyledSettings := [];
  LClick.Align := TAlignLayout.Right;
  //LClick.Anchors := [TAnchorKind.akRight, TAnchorKind.akTop, TAnchorKind.akBottom];
  loPop.AddObject(LClick);

  LStatus := TLabel.Create(loPop);
  LStatus.Font.Size := 15;
  LStatus.Text := FStatus;
  LStatus.Height := 20;
  LStatus.Width := reBackground.Width - (LClick.Width + reSide.Width + 16);;
  LStatus.FontColor := FColor;
  LStatus.Position.X := reSide.Position.X + reSide.Width + 8;
  LStatus.Position.Y := 8;
  LStatus.StyledSettings := [];
  loPop.AddObject(LStatus);

  LMessage := TText.Create(loPop);
  LMessage.Font.Size := 12.5;
  LMessage.Text := FMessage;
  LMessage.AutoSize := True;
  LMessage.WordWrap := True;
  LMessage.Width := reBackground.Width - (LClick.Width + reSide.Width + 16);
  LMessage.TextSettings.FontColor := $FF36414A;
  LMessage.Position.X := reSide.Position.X + reSide.Width + 8;
  LMessage.Position.Y := LStatus.Position.Y + LStatus.Height + 4;
  LMessage.TextSettings.HorzAlign := TTextAlign.Leading;
  loPop.AddObject(LMessage);

  loPop.Height := LStatus.Height + LMessage.Height + 20;

  LClick.OnClick := HelperClick.defClickToast;

  var FLOpa : TFloatAnimation;
  FLOpa := TFloatAnimation.Create(loPop);
  FLOpa.Parent := loPop;
  FLOpa.PropertyName := 'Opacity';
  FLOpa.StartValue := 1;
  FLOpa.StopValue := 0;
  FLOpa.Delay := 1;
  FLOpa.Duration := 0.75;

  FLOpa.OnFinish := HelperClick.flFinish;

  FLOpa.Enabled := True;
end;

class procedure HelperClick.defClickToast(Sender: TObject);
var
  lo : TLayout;
  loToast : TLayout;
begin
  loToast := TLayout(TControl(Sender).Parent);
  if Assigned(loToast) then begin
    lo := TLayout(loToast.FindStyleResource('loToast'));

    loToast.DisposeOf;

    if Assigned(lo) then
      if lo.ControlsCount = 0 then
        lo.DisposeOf;
  end;
end;

class procedure HelperClick.flFinish(Sender: TObject);
var
  lo : TLayout;
  loToast : TLayout;
begin
  TFloatAnimation(Sender).Enabled := False;

  loToast := TLayout(TFloatAnimation(Sender).Parent);
  if Assigned(loToast) then begin
    lo := TLayout(loToast.FindStyleResource('loToast'));

    loToast.DisposeOf;

    if Assigned(lo) then
      if lo.ControlsCount = 0 then
        lo.DisposeOf;
  end;
end;

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
