unit BFA.Control.Form.Message;

interface

uses
  System.Classes, System.Math, System.SysUtils, System.Types, System.UITypes,
  FMX.Ani, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Layouts, FMX.Objects,
  FMX.StdCtrls, FMX.Types;

type
  TTypeMessage = (Error, Success, Information);

  TMessageVisualStyle = record
    StatusText: string;
    AccentColor: TAlphaColor;

    class function Create(const AStatusText: string;
      AAccentColor: TAlphaColor): TMessageVisualStyle; static;
  end;

  TMainHelper = class
  private
    FForm: TForm;
    FLoadingOverlay: TLayout;
    FPopupCallback: TProc;
    FPopupOverlay: TLayout;
    FStateLoading: Boolean;
    FStatePopup: Boolean;
    FToastHost: TLayout;

    function CreateCloseLabel(AParent: TFmxObject): TLabel;
    function CreateMessageText(AParent: TFmxObject; const AMessage: string;
      ATop, AWidth: Single): TText;
    function CreateSideIndicator(AParent: TFmxObject;
      AAccentColor: TAlphaColor): TRectangle;
    function CreateStatusLabel(AParent: TFmxObject; const AStatusText: string;
      AAccentColor: TAlphaColor; ATop, AWidth: Single): TLabel;
    function EnsureLoadingOverlay: TLayout;
    function EnsureToastHost: TLayout;
    function GetMessageVisualStyle(AType: TTypeMessage): TMessageVisualStyle;
    function GetToastItem(Sender: TObject): TLayout;
    procedure ConfigureLoadingOverlay(const AText: string);
    procedure DetachAndFreeLayout(var ALayout: TLayout);
    procedure EnsureFormAssigned;
    procedure ExecuteOnMainThread(const AProc: TProc);
    procedure ReleasePopup(AExecuteCallback: Boolean);
    procedure ReleaseVisualControls;
    procedure ReleaseToast(AToast: TLayout);
    procedure SetHostForm(const AForm: TForm);

    procedure defClickToast(Sender : TObject);
    procedure defClickPopUp(Sender : TObject);
    procedure flFinish(Sender : TObject);
  public
    procedure Configure(AForm: TForm);
    procedure ShowToastMessage(AMessage : String; AJenis : TTypeMessage = Information);
    procedure ShowPopUpMessage(AMessage : String; AJenis : TTypeMessage; AProc : TProc = nil);
    procedure Loading(IsState : Boolean; AText : String = '');

    procedure StartLoading(AText : String = '');
    procedure StopLoading;

    procedure ClosePopup;

    property SetForm : TForm read FForm write SetHostForm;
    property StateLoading : Boolean read FStateLoading write FStateLoading;
    property StatePopup : Boolean read FStatePopup write FStatePopup;

    constructor Create(AForm: TForm = nil);
    destructor Destroy; override;
  end;


implementation

uses
  BFA.Exception.Base,
  BFA.Resource.Message;

const
  STYLE_LOADING_CONTENT = 'BFA_LOADING_CONTENT';
  STYLE_LOADING_INDICATOR = 'BFA_LOADING_INDICATOR';
  STYLE_LOADING_LABEL = 'BFA_LOADING_LABEL';
  STYLE_LOADING_OVERLAY = 'BFA_LOADING_OVERLAY';
  STYLE_POPUP_CARD = 'BFA_POPUP_CARD';
  STYLE_POPUP_OVERLAY = 'BFA_POPUP_OVERLAY';
  STYLE_TOAST_HOST = 'BFA_TOAST_HOST';

{ TMessageVisualStyle }

class function TMessageVisualStyle.Create(const AStatusText: string;
  AAccentColor: TAlphaColor): TMessageVisualStyle;
begin
  Result.StatusText := AStatusText;
  Result.AccentColor := AAccentColor;
end;

{ TMainHelper }

procedure TMainHelper.ClosePopup;
begin
  ReleasePopup(True);
end;

procedure TMainHelper.Configure(AForm: TForm);
begin
  SetHostForm(AForm);
end;

procedure TMainHelper.ConfigureLoadingOverlay(const AText: string);
var
  LContent: TLayout;
  LIndicator: TAniIndicator;
  LLabel: TLabel;
begin
  LContent := TLayout(FLoadingOverlay.FindStyleResource(STYLE_LOADING_CONTENT));
  LIndicator := TAniIndicator(FLoadingOverlay.FindStyleResource(
    STYLE_LOADING_INDICATOR));
  LLabel := TLabel(FLoadingOverlay.FindStyleResource(STYLE_LOADING_LABEL));

  if not Assigned(LContent) then begin
    LContent := TLayout.Create(FLoadingOverlay);
    LContent.StyleName := STYLE_LOADING_CONTENT;
    LContent.Align := TAlignLayout.Center;
    LContent.Width := Min(FForm.Width - 32, 320);
    LContent.Height := 96;
    LContent.Stored := False;
    FLoadingOverlay.AddObject(LContent);
  end else begin
    LContent.Width := Min(FForm.Width - 32, 320);
  end;

  if not Assigned(LIndicator) then begin
    LIndicator := TAniIndicator.Create(LContent);
    LIndicator.StyleName := STYLE_LOADING_INDICATOR;
    LIndicator.Align := TAlignLayout.Top;
    LIndicator.Margins.Bottom := 16;
    LIndicator.Height := 48;
    LIndicator.Stored := False;
    LContent.AddObject(LIndicator);
  end;

  if not Assigned(LLabel) then begin
    LLabel := TLabel.Create(LContent);
    LLabel.StyleName := STYLE_LOADING_LABEL;
    LLabel.Align := TAlignLayout.Top;
    LLabel.AutoSize := False;
    LLabel.Height := 24;
    LLabel.StyledSettings := [];
    LLabel.Font.Size := 12.5;
    LLabel.FontColor := $FF606060;
    LLabel.TextSettings.HorzAlign := TTextAlign.Center;
    LLabel.Stored := False;
    LContent.AddObject(LLabel);
  end;

  LIndicator.Enabled := True;
  LLabel.Text := AText;
end;

constructor TMainHelper.Create(AForm: TForm);
begin
  inherited Create;
  FForm := AForm;
end;

function TMainHelper.CreateCloseLabel(AParent: TFmxObject): TLabel;
begin
  Result := TLabel.Create(AParent);
  Result.Text := RS_FORM_MESSAGE_ACTION_CLOSE;
  Result.Font.Size := 12.5;
  Result.Width := 60;
  Result.FontColor := $FFBCBFC2;
  Result.TextSettings.HorzAlign := TTextAlign.Center;
  Result.HitTest := True;
  Result.StyledSettings := [];
  Result.Align := TAlignLayout.Right;
  Result.Stored := False;
  AParent.AddObject(Result);
end;

function TMainHelper.CreateMessageText(AParent: TFmxObject;
  const AMessage: string; ATop, AWidth: Single): TText;
begin
  Result := TText.Create(AParent);
  Result.Font.Size := 12.5;
  Result.Text := AMessage;
  Result.AutoSize := True;
  Result.WordWrap := True;
  Result.Width := AWidth;
  Result.TextSettings.FontColor := $FF36414A;
  Result.Position.X := 18;
  Result.Position.Y := ATop;
  Result.TextSettings.HorzAlign := TTextAlign.Leading;
  Result.Stored := False;
  AParent.AddObject(Result);
end;

function TMainHelper.CreateSideIndicator(AParent: TFmxObject;
  AAccentColor: TAlphaColor): TRectangle;
begin
  Result := TRectangle.Create(AParent);
  Result.Fill.Color := AAccentColor;
  Result.Stroke.Kind := TBrushKind.None;
  Result.Width := 10;
  Result.XRadius := 8;
  Result.YRadius := Result.XRadius;
  Result.Corners := [TCorner.TopLeft, TCorner.BottomLeft];
  Result.Align := TAlignLayout.Left;
  Result.HitTest := False;
  Result.Stored := False;
  AParent.AddObject(Result);
end;

function TMainHelper.CreateStatusLabel(AParent: TFmxObject;
  const AStatusText: string; AAccentColor: TAlphaColor; ATop,
  AWidth: Single): TLabel;
begin
  Result := TLabel.Create(AParent);
  Result.Font.Size := 15;
  Result.Text := AStatusText;
  Result.Height := 20;
  Result.Width := AWidth;
  Result.FontColor := AAccentColor;
  Result.Position.X := 18;
  Result.Position.Y := ATop;
  Result.StyledSettings := [];
  Result.Stored := False;
  AParent.AddObject(Result);
end;

procedure TMainHelper.defClickPopUp(Sender: TObject);
begin
  ClosePopup;
end;

procedure TMainHelper.defClickToast(Sender: TObject);
begin
  ReleaseToast(GetToastItem(Sender));
end;

destructor TMainHelper.Destroy;
begin
  ReleaseVisualControls;
  inherited;
end;

procedure TMainHelper.DetachAndFreeLayout(var ALayout: TLayout);
begin
  if not Assigned(ALayout) then
    Exit;

  ALayout.Parent := nil;
  FreeAndNil(ALayout);
end;

procedure TMainHelper.EnsureFormAssigned;
begin
  if not Assigned(FForm) then
    raise EFormMessageFormNotAssignedException.Create(
      RS_FORM_MESSAGE_FORM_NOT_ASSIGNED);
end;

function TMainHelper.EnsureLoadingOverlay: TLayout;
begin
  EnsureFormAssigned;

  Result := FLoadingOverlay;
  if Assigned(Result) then
    Exit;

  Result := TLayout.Create(FForm);
  Result.StyleName := STYLE_LOADING_OVERLAY;
  Result.Align := TAlignLayout.Contents;
  Result.HitTest := True;
  Result.Stored := False;
  FForm.AddObject(Result);
  FLoadingOverlay := Result;
end;

function TMainHelper.EnsureToastHost: TLayout;
begin
  EnsureFormAssigned;

  Result := FToastHost;
  if Assigned(Result) then
    Exit;

  Result := TLayout.Create(FForm);
  Result.StyleName := STYLE_TOAST_HOST;
  Result.Align := TAlignLayout.Contents;
  Result.Stored := False;
  FForm.AddObject(Result);
  FToastHost := Result;
end;

procedure TMainHelper.ExecuteOnMainThread(const AProc: TProc);
begin
  if TThread.CurrentThread.ThreadID = MainThreadID then
    AProc()
  else
    TThread.Queue(nil, procedure begin
      AProc();
    end);
end;

procedure TMainHelper.flFinish(Sender: TObject);
begin
  TFloatAnimation(Sender).Enabled := False;
  ReleaseToast(GetToastItem(Sender));
end;

function TMainHelper.GetMessageVisualStyle(
  AType: TTypeMessage): TMessageVisualStyle;
begin
  case AType of
    TTypeMessage.Success:
      Result := TMessageVisualStyle.Create(RS_FORM_MESSAGE_STATUS_SUCCESS,
        $FF4BC961);
    TTypeMessage.Error:
      Result := TMessageVisualStyle.Create(RS_FORM_MESSAGE_STATUS_ERROR,
        $FFFF6969);
  else
    Result := TMessageVisualStyle.Create(RS_FORM_MESSAGE_STATUS_INFORMATION,
      $FF36414A);
  end;
end;

function TMainHelper.GetToastItem(Sender: TObject): TLayout;
begin
  Result := nil;
  if Sender is TFloatAnimation then
    Result := TLayout(TFloatAnimation(Sender).Parent)
  else if (Sender is TControl) and (TControl(Sender).Parent is TLayout) then
    Result := TLayout(TControl(Sender).Parent);
end;

procedure TMainHelper.Loading(IsState: Boolean; AText : String);
var
  LIndicator: TAniIndicator;
begin
  EnsureFormAssigned;
  StateLoading := IsState;

  if not IsState then begin
    if Assigned(FLoadingOverlay) then begin
      LIndicator := TAniIndicator(FLoadingOverlay.FindStyleResource(
        STYLE_LOADING_INDICATOR));
      if Assigned(LIndicator) then
        LIndicator.Enabled := False;

      FLoadingOverlay.Visible := False;
    end;

    Exit;
  end;

  EnsureLoadingOverlay;
  ConfigureLoadingOverlay(AText);
  FLoadingOverlay.Visible := True;
  FLoadingOverlay.BringToFront;
end;

procedure TMainHelper.ShowPopUpMessage(AMessage: String; AJenis: TTypeMessage;
  AProc: TProc);
var
  LBackground: TRectangle;
  LCard: TLayout;
  LClick: TLabel;
  LMessage: TText;
  LOverlay: TLayout;
  LSide: TRectangle;
  LStatus: TLabel;
  LStyle: TMessageVisualStyle;
  LTextWidth: Single;
begin
  EnsureFormAssigned;
  ReleasePopup(False);

  LStyle := GetMessageVisualStyle(AJenis);
  FPopupCallback := AProc;

  LOverlay := TLayout.Create(FForm);
  LOverlay.StyleName := STYLE_POPUP_OVERLAY;
  LOverlay.Align := TAlignLayout.Contents;
  LOverlay.HitTest := True;
  LOverlay.Stored := False;
  FForm.AddObject(LOverlay);
  FPopupOverlay := LOverlay;

  LBackground := TRectangle.Create(LOverlay);
  LBackground.Align := TAlignLayout.Contents;
  LBackground.Stroke.Kind := TBrushKind.None;
  LBackground.Fill.Color := TAlphaColorRec.Black;
  LBackground.Opacity := 0.20;
  LBackground.Stored := False;
  LOverlay.AddObject(LBackground);

  LCard := TLayout.Create(LOverlay);
  LCard.StyleName := STYLE_POPUP_CARD;
  LCard.Width := FForm.Width - 32;
  LCard.Position.X := 16;
  LCard.Position.Y := 32;
  LCard.Anchors := [TAnchorKind.akLeft, TAnchorKind.akRight, TAnchorKind.akTop];
  LCard.Stored := False;
  LOverlay.AddObject(LCard);

  LBackground := TRectangle.Create(LCard);
  LBackground.Fill.Color := TAlphaColorRec.White;
  LBackground.Stroke.Kind := TBrushKind.None;
  LBackground.XRadius := 8;
  LBackground.YRadius := LBackground.XRadius;
  LBackground.Align := TAlignLayout.Contents;
  LBackground.HitTest := False;
  LBackground.Stored := False;
  LCard.AddObject(LBackground);

  LSide := CreateSideIndicator(LCard, LStyle.AccentColor);

  LClick := CreateCloseLabel(LCard);
  LClick.OnClick := defClickPopUp;

  LTextWidth := LCard.Width - (LClick.Width + LSide.Width + 24);
  LStatus := CreateStatusLabel(LCard, LStyle.StatusText, LStyle.AccentColor,
    8, LTextWidth);
  LMessage := CreateMessageText(LCard, AMessage,
    LStatus.Position.Y + LStatus.Height + 4, LTextWidth);

  LCard.Height := LStatus.Height + LMessage.Height + 20;
  LSide.Height := LCard.Height;
  LClick.Height := LCard.Height;

  StatePopup := True;
  LOverlay.BringToFront;
end;

procedure TMainHelper.ShowToastMessage(AMessage: String; AJenis: TTypeMessage);
var
  LAnimation: TFloatAnimation;
  LBackground: TRectangle;
  LClick: TLabel;
  LMessage: TText;
  LSide: TRectangle;
  LStatus: TLabel;
  LStyle: TMessageVisualStyle;
  LTextWidth: Single;
  LToast: TLayout;
  LToastHost: TLayout;
begin
  EnsureFormAssigned;

  LStyle := GetMessageVisualStyle(AJenis);
  LToastHost := EnsureToastHost;

  LToast := TLayout.Create(LToastHost);
  LToast.Align := TAlignLayout.Top;
  LToast.Margins.Top := 12;
  LToast.Margins.Left := 16;
  if FForm.Width < 392 then
    LToast.Margins.Right := 24
  else
    LToast.Margins.Right := FForm.Width - 392;
  LToast.Stored := False;
  LToastHost.AddObject(LToast);

  LBackground := TRectangle.Create(LToast);
  LBackground.Fill.Color := TAlphaColorRec.White;
  LBackground.Stroke.Color := $FFBCBFC2;
  LBackground.XRadius := 8;
  LBackground.YRadius := LBackground.XRadius;
  LBackground.Align := TAlignLayout.Contents;
  LBackground.HitTest := False;
  LBackground.Stored := False;
  LToast.AddObject(LBackground);

  LSide := CreateSideIndicator(LToast, LStyle.AccentColor);

  LClick := CreateCloseLabel(LToast);
  LClick.OnClick := defClickToast;

  LTextWidth := Max(120, FForm.Width - (LClick.Width + LSide.Width + 64));
  LStatus := CreateStatusLabel(LToast, LStyle.StatusText, LStyle.AccentColor,
    8, LTextWidth);
  LMessage := CreateMessageText(LToast, AMessage,
    LStatus.Position.Y + LStatus.Height + 4, LTextWidth);

  LToast.Height := LStatus.Height + LMessage.Height + 20;
  LClick.Height := LToast.Height;
  LSide.Height := LToast.Height;

  LAnimation := TFloatAnimation.Create(LToast);
  LAnimation.Parent := LToast;
  LAnimation.PropertyName := 'Opacity';
  LAnimation.StartValue := 1;
  LAnimation.StopValue := 0;
  LAnimation.Delay := 1;
  LAnimation.Duration := 3.75;
  LAnimation.OnFinish := flFinish;
  LAnimation.Enabled := True;

  LToastHost.BringToFront;
end;

procedure TMainHelper.StartLoading(AText : String);
begin
  ExecuteOnMainThread(procedure begin
    Self.Loading(True, AText);
  end);
end;

procedure TMainHelper.StopLoading;
begin
  ExecuteOnMainThread(procedure begin
    Self.Loading(False);
  end);
end;

procedure TMainHelper.ReleasePopup(AExecuteCallback: Boolean);
var
  LCallback: TProc;
  LPopup: TLayout;
begin
  LPopup := FPopupOverlay;
  FPopupOverlay := nil;

  if Assigned(LPopup) then
    DetachAndFreeLayout(LPopup);

  StatePopup := False;

  LCallback := FPopupCallback;
  FPopupCallback := nil;
  if AExecuteCallback and Assigned(LCallback) then
    LCallback();
end;

procedure TMainHelper.ReleaseToast(AToast: TLayout);
begin
  if not Assigned(AToast) then
    Exit;

  AToast.Parent := nil;
  AToast.Free;
end;

procedure TMainHelper.ReleaseVisualControls;
begin
  ReleasePopup(False);
  DetachAndFreeLayout(FLoadingOverlay);
  DetachAndFreeLayout(FToastHost);
end;

procedure TMainHelper.SetHostForm(const AForm: TForm);
begin
  if FForm = AForm then
    Exit;

  ReleaseVisualControls;
  FForm := AForm;
end;

end.

