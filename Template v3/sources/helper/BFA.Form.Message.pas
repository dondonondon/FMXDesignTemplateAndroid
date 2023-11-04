unit BFA.Form.Message;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, System.Generics.Collections, System.Net.URLClient, System.Net.HttpClient,
  System.Net.HttpClientComponent,
  FMX.Objects, FMX.Ani, System.Permissions, FMX.DialogService
  {$IF DEFINED (ANDROID)}
  , Androidapi.Helpers, Androidapi.Jni.Os
  {$ENDIF}
  ;



type
  TTypeMessage = (Error, Success, Information);

  TFormLoading = class helper for TForm
    procedure heLoading(isStat : Boolean);
    procedure ShowPopUpMessage(FMessage : String; FJenis : TTypeMessage; FProc : TProc = nil);
    procedure ShowToastMessage(FMessage : String; FJenis : TTypeMessage);
  end;


  HelperClick = class
    class procedure defClickPopUp(Sender : TObject);
    class procedure defClickToast(Sender : TObject);
    class procedure flFinish(Sender : TObject);
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

procedure TFormLoading.ShowPopUpMessage(FMessage: String; FJenis: TTypeMessage;
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
  if FJenis = TTypeMessage.Success then begin
    FStatus := 'Success!';
    FColor := $FF4BC961;
  end else if FJenis = TTypeMessage.Error then begin
    FStatus := 'Error...';
    FColor := $FFFF6969;
  end else if FJenis = TTypeMessage.Information then begin
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

procedure TFormLoading.ShowToastMessage(FMessage: String; FJenis: TTypeMessage);
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
  if FJenis = TTypeMessage.Success then begin
    FStatus := 'Success!';
    FColor := $FF4BC961;
  end else if FJenis = TTypeMessage.Error then begin
    FStatus := 'Error...';
    FColor := $FFFF6969;
  end else if FJenis = TTypeMessage.Information then begin
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

  reBackground.HitTest := False;

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

  reSide.HitTest := False;

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

  loPop.HitTest := False;

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

end.
