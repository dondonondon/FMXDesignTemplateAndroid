unit BFA.Control.Keyboard;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.VirtualKeyboard, System.Math, FMX.Platform;

type
  TKeyboardShow = class
  private
    FServiceVirtualKeyboard: IFMXVirtualKeyboardToolbarService;
    FKBBounds: TRectF;
    FNeedOffset: Boolean;
    FForm: TForm;
    FVertScroll: TVertScrollBox;
    FLayout: TLayout;

    procedure FormFocusChanged(Sender: TObject);
    procedure FormVirtualKeyboardHidden(Sender: TObject;
      KeyboardVisible: Boolean; const Bounds: TRect);
    procedure FormVirtualKeyboardShown(Sender: TObject;
      KeyboardVisible: Boolean; const Bounds: TRect);
    procedure CalcContentBoundsProc(Sender: TObject; var ContentBounds: TRectF);

    function CheckControl : Boolean;

  public
    property Form : TForm read FForm write FForm;
    property VertScroll : TVertScrollBox read FVertScroll write FVertScroll;
    property Layout : TLayout read FLayout write FLayout;

    procedure RestorePosition;
    procedure UpdateKBBounds;

    procedure HideKeyboard;
    procedure KeyUp(var Key: Word; var KeyChar: Char; Shift: TShiftState);

    constructor Create(AForm : TForm; AVertScroll : TVertScrollBox; ALayout : TLayout; AutoSetEvent : Boolean = False); overload;
  end;

implementation

{ TKeyboardShow }

procedure TKeyboardShow.CalcContentBoundsProc(Sender: TObject;
  var ContentBounds: TRectF);
begin
  if not CheckControl then
    Exit;

  if FNeedOffset and (FKBBounds.Top > 0) then begin
    ContentBounds.Bottom := Max(ContentBounds.Bottom,
                                2 * FForm.ClientHeight - FKBBounds.Top);
  end;
end;

function TKeyboardShow.CheckControl: Boolean;
begin
  Result := False;

  if not Assigned(FForm) then
    raise Exception.Create('Form not set!');

  if not Assigned(FLayout) then
    raise Exception.Create('Layout not set!');

  if not Assigned(FVertScroll) then
    raise Exception.Create('VertScroll not set!');

  Result := True;
end;

constructor TKeyboardShow.Create(AForm: TForm; AVertScroll: TVertScrollBox;
  ALayout: TLayout; AutoSetEvent : Boolean);
begin
  FForm := AForm;
  FLayout := ALayout;
  FVertScroll := AVertScroll;

  if TPlatformServices.Current.SupportsPlatformService(IFMXVirtualKeyboardToolbarService, IInterface(FServiceVirtualKeyboard)) then begin
    FServiceVirtualKeyboard.SetToolbarEnabled(True);
    FServiceVirtualKeyboard.SetHideKeyboardButtonVisibility(True);
  end;


  if AutoSetEvent then begin
    FVertScroll.OnCalcContentBounds := CalcContentBoundsProc;

    FForm.OnFocusChanged := FormFocusChanged;
    FForm.OnVirtualKeyboardShown := FormVirtualKeyboardShown;
    FForm.OnVirtualKeyboardHidden := FormVirtualKeyboardHidden;
  end;

end;

procedure TKeyboardShow.FormFocusChanged(Sender: TObject);
begin
  UpdateKBBounds;
end;

procedure TKeyboardShow.FormVirtualKeyboardHidden(Sender: TObject;
  KeyboardVisible: Boolean; const Bounds: TRect);
begin
  if not CheckControl then
    Exit;

  FKBBounds.Create(0, 0, 0, 0);
  FNeedOffset := False;
  RestorePosition;
end;

procedure TKeyboardShow.FormVirtualKeyboardShown(Sender: TObject;
  KeyboardVisible: Boolean; const Bounds: TRect);
begin
  if not CheckControl then
    Exit;

  FKBBounds := TRectF.Create(Bounds);
  FKBBounds.TopLeft := FForm.ScreenToClient(FKBBounds.TopLeft);
  FKBBounds.BottomRight := FForm.ScreenToClient(FKBBounds.BottomRight);
  UpdateKBBounds;
end;

procedure TKeyboardShow.HideKeyboard;
begin
  if not CheckControl then
    Exit;

  FKBBounds.Create(0, 0, 0, 0);
  FNeedOffset := False;
  RestorePosition;
end;

procedure TKeyboardShow.KeyUp(var Key: Word; var KeyChar: Char;
  Shift: TShiftState);
var
  FService: IFMXVirtualKeyboardService;
begin
  if Key = vkHardwareBack  then begin
    TPlatformServices.Current.SupportsPlatformService(IFMXVirtualKeyboardService, IInterface(FService));
    if (FService <> nil) and (TVirtualKeyboardState.Visible in FService.VirtualKeyBoardState) then begin
      FService.HideVirtualKeyboard;
      HideKeyboard;
    end else begin
      HideKeyboard;
      Key := 0;
    end;
  end else if Key = vkReturn then begin
    if (FService <> nil) and (TVirtualKeyboardState.Visible in FService.VirtualKeyBoardState) then
    begin
      FService.HideVirtualKeyboard;
      HideKeyboard;
    end;
  end;
end;

procedure TKeyboardShow.RestorePosition;
begin
  if not CheckControl then
    Exit;

  FVertScroll.ViewportPosition := PointF(FVertScroll.ViewportPosition.X, 0);
  FLayout.Align := TAlignLayout.Contents;
  FVertScroll.Align := TAlignLayout.Contents;
  FVertScroll.RealignContent;
end;

procedure TKeyboardShow.UpdateKBBounds;
var
  LFocused : TControl;
  LFocusRect: TRectF;
begin
  if not CheckControl then
    Exit;

  FNeedOffset := False;
  if Assigned(FForm.Focused) then begin
    LFocused := TControl(FForm.Focused.GetObject);
    LFocusRect := LFocused.AbsoluteRect;
    LFocusRect.Offset(FVertScroll.ViewportPosition);

    if (LFocusRect.IntersectsWith(TRectF.Create(FKBBounds))) and (LFocusRect.Bottom > FKBBounds.Top) then begin
      FNeedOffset := True;
      FLayout.Align := TAlignLayout.Horizontal;
      FVertScroll.RealignContent;
      Application.ProcessMessages;
      FVertScroll.ViewportPosition :=
        PointF(FVertScroll.ViewportPosition.X,
               LFocusRect.Bottom - FKBBounds.Top);
    end;
  end;

  if not FNeedOffset then
    RestorePosition;
end;

end.
