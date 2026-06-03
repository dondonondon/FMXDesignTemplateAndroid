unit BFA.Control.Keyboard;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.VirtualKeyboard, System.Math, FMX.Platform;

type
  TKeyboardCalcContentBoundsEvent = procedure(Sender: TObject;
    var ContentBounds: TRectF) of object;
  TKeyboardVirtualKeyboardEvent = procedure(Sender: TObject;
    KeyboardVisible: Boolean; const Bounds: TRect) of object;

  TKeyboardShow = class
  private
    FEventsAttached: Boolean;
    FServiceVirtualKeyboard: IFMXVirtualKeyboardToolbarService;
    FKBBounds: TRectF;
    FNeedOffset: Boolean;
    FForm: TForm;
    FPrevOnCalcContentBounds: TMethod;
    FPrevOnFocusChanged: TMethod;
    FPrevOnVirtualKeyboardHidden: TMethod;
    FPrevOnVirtualKeyboardShown: TMethod;
    FVertScroll: TVertScrollBox;
    FLayout: TLayout;

    procedure AttachEvents;
    procedure DetachEvents;
    procedure EnsureControlsAssigned;
    procedure FormFocusChanged(Sender: TObject);
    procedure FormVirtualKeyboardHidden(Sender: TObject;
      KeyboardVisible: Boolean; const Bounds: TRect);
    procedure FormVirtualKeyboardShown(Sender: TObject;
      KeyboardVisible: Boolean; const Bounds: TRect);
    procedure CalcContentBoundsProc(Sender: TObject; var ContentBounds: TRectF);
    procedure InvokePrevCalcContentBounds(Sender: TObject;
      var ContentBounds: TRectF);
    procedure InvokePrevFocusChanged(Sender: TObject);
    procedure InvokePrevVirtualKeyboardHidden(Sender: TObject;
      KeyboardVisible: Boolean; const Bounds: TRect);
    procedure InvokePrevVirtualKeyboardShown(Sender: TObject;
      KeyboardVisible: Boolean; const Bounds: TRect);
    procedure ResetKeyboardBounds;

    function GetCalcContentBoundsMethod: TMethod;
    function GetFocusChangedMethod: TMethod;
    function GetVirtualKeyboardHiddenMethod: TMethod;
    function GetVirtualKeyboardShownMethod: TMethod;
    function TryGetFocusedControl(out AFocusedControl: TControl): Boolean;
    class function SameMethod(const ALeft, ARight: TMethod): Boolean; static;

  public
    property Form : TForm read FForm write FForm;
    property VertScroll : TVertScrollBox read FVertScroll write FVertScroll;
    property Layout : TLayout read FLayout write FLayout;

    procedure Attach;
    procedure Detach;
    procedure RestorePosition;
    procedure UpdateKBBounds;

    procedure HideKeyboard;
    procedure KeyUp(var Key: Word; var KeyChar: Char; Shift: TShiftState);

    constructor Create(AForm : TForm; AVertScroll : TVertScrollBox; ALayout : TLayout; AutoSetEvent : Boolean = False); overload;
    destructor Destroy; override;
  end;

implementation

uses
  BFA.Exception.Base,
  BFA.Resource.Message;

{ TKeyboardShow }

procedure TKeyboardShow.Attach;
begin
  AttachEvents;
end;

procedure TKeyboardShow.AttachEvents;
begin
  EnsureControlsAssigned;

  if FEventsAttached then
    Exit;

  FPrevOnCalcContentBounds := TMethod(FVertScroll.OnCalcContentBounds);
  FPrevOnFocusChanged := TMethod(FForm.OnFocusChanged);
  FPrevOnVirtualKeyboardShown := TMethod(FForm.OnVirtualKeyboardShown);
  FPrevOnVirtualKeyboardHidden := TMethod(FForm.OnVirtualKeyboardHidden);

  FVertScroll.OnCalcContentBounds := CalcContentBoundsProc;
  FForm.OnFocusChanged := FormFocusChanged;
  FForm.OnVirtualKeyboardShown := FormVirtualKeyboardShown;
  FForm.OnVirtualKeyboardHidden := FormVirtualKeyboardHidden;
  FEventsAttached := True;
end;

procedure TKeyboardShow.CalcContentBoundsProc(Sender: TObject;
  var ContentBounds: TRectF);
begin
  InvokePrevCalcContentBounds(Sender, ContentBounds);
  EnsureControlsAssigned;

  if FNeedOffset and (FKBBounds.Top > 0) then begin
    ContentBounds.Bottom := Max(ContentBounds.Bottom,
                                2 * FForm.ClientHeight - FKBBounds.Top);
  end;
end;

constructor TKeyboardShow.Create(AForm: TForm; AVertScroll: TVertScrollBox;
  ALayout: TLayout; AutoSetEvent : Boolean);
begin
  inherited Create;

  FForm := AForm;
  FLayout := ALayout;
  FVertScroll := AVertScroll;
  ResetKeyboardBounds;

  if TPlatformServices.Current.SupportsPlatformService(
    IFMXVirtualKeyboardToolbarService, IInterface(FServiceVirtualKeyboard)) then begin
    FServiceVirtualKeyboard.SetToolbarEnabled(True);
    FServiceVirtualKeyboard.SetHideKeyboardButtonVisibility(True);
  end;

  if AutoSetEvent then
    AttachEvents;
end;

destructor TKeyboardShow.Destroy;
begin
  DetachEvents;
  inherited;
end;

procedure TKeyboardShow.Detach;
begin
  DetachEvents;
end;

procedure TKeyboardShow.DetachEvents;
var
  LCalcHandler: TKeyboardCalcContentBoundsEvent;
  LVirtualKeyboardHandler: TKeyboardVirtualKeyboardEvent;
  LNotifyHandler: TNotifyEvent;
begin
  if not FEventsAttached then
    Exit;

  if Assigned(FVertScroll) and SameMethod(TMethod(FVertScroll.OnCalcContentBounds),
    GetCalcContentBoundsMethod) then begin
    TMethod(LCalcHandler) := FPrevOnCalcContentBounds;
    FVertScroll.OnCalcContentBounds := LCalcHandler;
  end;

  if Assigned(FForm) and SameMethod(TMethod(FForm.OnFocusChanged),
    GetFocusChangedMethod) then begin
    TMethod(LNotifyHandler) := FPrevOnFocusChanged;
    FForm.OnFocusChanged := LNotifyHandler;
  end;

  if Assigned(FForm) and SameMethod(TMethod(FForm.OnVirtualKeyboardShown),
    GetVirtualKeyboardShownMethod) then begin
    TMethod(LVirtualKeyboardHandler) := FPrevOnVirtualKeyboardShown;
    FForm.OnVirtualKeyboardShown := LVirtualKeyboardHandler;
  end;

  if Assigned(FForm) and SameMethod(TMethod(FForm.OnVirtualKeyboardHidden),
    GetVirtualKeyboardHiddenMethod) then begin
    TMethod(LVirtualKeyboardHandler) := FPrevOnVirtualKeyboardHidden;
    FForm.OnVirtualKeyboardHidden := LVirtualKeyboardHandler;
  end;

  FPrevOnCalcContentBounds := Default(TMethod);
  FPrevOnFocusChanged := Default(TMethod);
  FPrevOnVirtualKeyboardShown := Default(TMethod);
  FPrevOnVirtualKeyboardHidden := Default(TMethod);
  FEventsAttached := False;
end;

procedure TKeyboardShow.EnsureControlsAssigned;
begin
  if not Assigned(FForm) then
    raise EKeyboardFormNotAssignedException.Create(RS_KEYBOARD_FORM_NOT_ASSIGNED);

  if not Assigned(FLayout) then
    raise EKeyboardLayoutNotAssignedException.Create(RS_KEYBOARD_LAYOUT_NOT_ASSIGNED);

  if not Assigned(FVertScroll) then
    raise EKeyboardVertScrollNotAssignedException.Create(
      RS_KEYBOARD_VERTSCROLL_NOT_ASSIGNED);
end;

procedure TKeyboardShow.FormFocusChanged(Sender: TObject);
begin
  InvokePrevFocusChanged(Sender);
  UpdateKBBounds;
end;

procedure TKeyboardShow.FormVirtualKeyboardHidden(Sender: TObject;
  KeyboardVisible: Boolean; const Bounds: TRect);
begin
  InvokePrevVirtualKeyboardHidden(Sender, KeyboardVisible, Bounds);
  EnsureControlsAssigned;

  ResetKeyboardBounds;
  RestorePosition;
end;

procedure TKeyboardShow.FormVirtualKeyboardShown(Sender: TObject;
  KeyboardVisible: Boolean; const Bounds: TRect);
begin
  InvokePrevVirtualKeyboardShown(Sender, KeyboardVisible, Bounds);
  EnsureControlsAssigned;

  FKBBounds := TRectF.Create(Bounds);
  FKBBounds.TopLeft := FForm.ScreenToClient(FKBBounds.TopLeft);
  FKBBounds.BottomRight := FForm.ScreenToClient(FKBBounds.BottomRight);
  UpdateKBBounds;
end;

procedure TKeyboardShow.HideKeyboard;
begin
  EnsureControlsAssigned;

  ResetKeyboardBounds;
  RestorePosition;
end;

function TKeyboardShow.GetCalcContentBoundsMethod: TMethod;
var
  LHandler: TKeyboardCalcContentBoundsEvent;
begin
  LHandler := CalcContentBoundsProc;
  Result := TMethod(LHandler);
end;

function TKeyboardShow.GetFocusChangedMethod: TMethod;
var
  LHandler: TNotifyEvent;
begin
  LHandler := FormFocusChanged;
  Result := TMethod(LHandler);
end;

function TKeyboardShow.GetVirtualKeyboardHiddenMethod: TMethod;
var
  LHandler: TKeyboardVirtualKeyboardEvent;
begin
  LHandler := FormVirtualKeyboardHidden;
  Result := TMethod(LHandler);
end;

function TKeyboardShow.GetVirtualKeyboardShownMethod: TMethod;
var
  LHandler: TKeyboardVirtualKeyboardEvent;
begin
  LHandler := FormVirtualKeyboardShown;
  Result := TMethod(LHandler);
end;

procedure TKeyboardShow.InvokePrevCalcContentBounds(Sender: TObject;
  var ContentBounds: TRectF);
var
  LHandler: TKeyboardCalcContentBoundsEvent;
begin
  TMethod(LHandler) := FPrevOnCalcContentBounds;
  if Assigned(LHandler) then
    LHandler(Sender, ContentBounds);
end;

procedure TKeyboardShow.InvokePrevFocusChanged(Sender: TObject);
var
  LHandler: TNotifyEvent;
begin
  TMethod(LHandler) := FPrevOnFocusChanged;
  if Assigned(LHandler) then
    LHandler(Sender);
end;

procedure TKeyboardShow.InvokePrevVirtualKeyboardHidden(Sender: TObject;
  KeyboardVisible: Boolean; const Bounds: TRect);
var
  LHandler: TKeyboardVirtualKeyboardEvent;
begin
  TMethod(LHandler) := FPrevOnVirtualKeyboardHidden;
  if Assigned(LHandler) then
    LHandler(Sender, KeyboardVisible, Bounds);
end;

procedure TKeyboardShow.InvokePrevVirtualKeyboardShown(Sender: TObject;
  KeyboardVisible: Boolean; const Bounds: TRect);
var
  LHandler: TKeyboardVirtualKeyboardEvent;
begin
  TMethod(LHandler) := FPrevOnVirtualKeyboardShown;
  if Assigned(LHandler) then
    LHandler(Sender, KeyboardVisible, Bounds);
end;

procedure TKeyboardShow.KeyUp(var Key: Word; var KeyChar: Char;
  Shift: TShiftState);
var
  LKeyboardService: IFMXVirtualKeyboardService;
begin
  TPlatformServices.Current.SupportsPlatformService(
    IFMXVirtualKeyboardService, IInterface(LKeyboardService));

  if Key = vkHardwareBack  then begin
    if Assigned(LKeyboardService) and
      (TVirtualKeyboardState.Visible in LKeyboardService.VirtualKeyBoardState) then begin
      LKeyboardService.HideVirtualKeyboard;
      HideKeyboard;
    end else begin
      HideKeyboard;
      Key := 0;
    end;
  end else if Key = vkReturn then begin
    if Assigned(LKeyboardService) and
      (TVirtualKeyboardState.Visible in LKeyboardService.VirtualKeyBoardState) then begin
      LKeyboardService.HideVirtualKeyboard;
      HideKeyboard;
    end;
  end;
end;

procedure TKeyboardShow.RestorePosition;
begin
  EnsureControlsAssigned;

  FVertScroll.ViewportPosition := PointF(FVertScroll.ViewportPosition.X, 0);
  FLayout.Align := TAlignLayout.Contents;
  FVertScroll.Align := TAlignLayout.Contents;
  FVertScroll.RealignContent;
end;

procedure TKeyboardShow.ResetKeyboardBounds;
begin
  FKBBounds := TRectF.Create(0, 0, 0, 0);
  FNeedOffset := False;
end;

class function TKeyboardShow.SameMethod(const ALeft, ARight: TMethod): Boolean;
begin
  Result := (ALeft.Code = ARight.Code) and (ALeft.Data = ARight.Data);
end;

function TKeyboardShow.TryGetFocusedControl(
  out AFocusedControl: TControl): Boolean;
var
  LFocusedObject: TObject;
begin
  AFocusedControl := nil;
  Result := False;

  if not Assigned(FForm.Focused) then
    Exit;

  LFocusedObject := FForm.Focused.GetObject;
  if not Assigned(LFocusedObject) then
    Exit;

  if not (LFocusedObject is TControl) then
    Exit;

  AFocusedControl := TControl(LFocusedObject);
  Result := True;
end;

procedure TKeyboardShow.UpdateKBBounds;
var
  LFocused : TControl;
  LFocusRect: TRectF;
begin
  EnsureControlsAssigned;

  FNeedOffset := False;
  if TryGetFocusedControl(LFocused) then begin
    LFocusRect := LFocused.AbsoluteRect;
    LFocusRect.Offset(FVertScroll.ViewportPosition);

    if (LFocusRect.IntersectsWith(TRectF.Create(FKBBounds))) and (LFocusRect.Bottom > FKBBounds.Top) then begin
      FNeedOffset := True;
      FLayout.Align := TAlignLayout.Horizontal;
      FVertScroll.RealignContent;
      FVertScroll.ViewportPosition :=
        PointF(FVertScroll.ViewportPosition.X,
               LFocusRect.Bottom - FKBBounds.Top);
    end;
  end;

  if not FNeedOffset then
    RestorePosition;
end;

end.
