unit frMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Controls.Presentation, FMX.StdCtrls,
  BFA.App.Services;

type
  TFMain = class(TForm)
    loMain: TLayout;
    vsMain: TVertScrollBox;
    loFrame: TLayout;
    SB: TStyleBook;
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: WideChar;
      Shift: TShiftState);
    procedure FormFocusChanged(Sender: TObject);
  private
    procedure ExecuteCurrentFrameBack(const AServices: TAppServices);
    procedure HandleBackKey(var Key: Word; var KeyChar: WideChar;
      Shift: TShiftState);
    procedure HideKeyboard;
    procedure InitializeServices;
    function IsVirtualKeyboardVisible: Boolean;
    procedure ReleaseServices;
    function TryGetServices(out AServices: TAppServices): Boolean;
  public
  end;

var
  FMain: TFMain;

implementation

{$R *.fmx}

uses
  BFA.App.Context,
  FMX.Platform, FMX.VirtualKeyboard;

type
  TFrameBackExec = procedure of object;

procedure TFMain.FormCreate(Sender: TObject);
begin
  if not Assigned(AppContext) then
    AppContext := TAppContext.Create;
end;

procedure TFMain.FormDestroy(Sender: TObject);
begin
  ReleaseServices;
end;

procedure TFMain.FormFocusChanged(Sender: TObject);
begin
  HideKeyboard;
end;

procedure TFMain.FormKeyUp(Sender: TObject; var Key: Word;
  var KeyChar: WideChar; Shift: TShiftState);
begin
  if (Key = vkHardwareBack) or (Key = vkEscape) then begin {if you type esc on keyboard, frame execute "Back" Procedure on Published inside TFrame}
    HandleBackKey(Key, KeyChar, Shift);
  end else begin
    var LServices: TAppServices;

    if TryGetServices(LServices) and Assigned(LServices.Keyboard) then begin
      LServices.Keyboard.KeyUp(Key, KeyChar, Shift);
    end;
  end;
end;

procedure TFMain.ExecuteCurrentFrameBack(const AServices: TAppServices);
var
  LExec: TFrameBackExec;
  LFrame: TFrame;
  LRoutine: TMethod;
begin
  if not Assigned(AServices) then exit;
  if not Assigned(AServices.Router) then exit;

  LFrame := AServices.Router.CurrentFrame;
  if not Assigned(LFrame) then exit;

  LRoutine.Data := Pointer(LFrame);
  LRoutine.Code := LFrame.MethodAddress('BackFrame');
  if not Assigned(LRoutine.Code) then exit;

  LExec := TFrameBackExec(LRoutine);
  LExec;
end;

procedure TFMain.FormShow(Sender: TObject);
begin
  if Assigned(AppContext) and Assigned(AppContext.Services) then
    Exit;

  InitializeServices;
end;

procedure TFMain.InitializeServices;
begin
  if not Assigned(AppContext) then
    AppContext := TAppContext.Create;

  if Assigned(AppContext.Services) then
    Exit;

  AppContext.Services := TAppServices.Create;
  AppContext.Services.Initialize(Self, vsMain, loFrame, True);
end;

procedure TFMain.HandleBackKey(var Key: Word; var KeyChar: WideChar;
  Shift: TShiftState);
var
  LServices: TAppServices;
begin
  if IsVirtualKeyboardVisible then begin
    HideKeyboard;
    Exit;
  end;

  HideKeyboard;
  Key := 0;

  if not TryGetServices(LServices) then exit;

  if Assigned(LServices.MainHelper) then begin
    if LServices.MainHelper.StateLoading then begin
      LServices.MainHelper.ShowToastMessage('Still loading');
      Exit;
    end else if LServices.MainHelper.StatePopup then begin
      LServices.MainHelper.ClosePopup;
      Exit;
    end;
  end;

  ExecuteCurrentFrameBack(LServices);
end;

procedure TFMain.HideKeyboard;
var
  LKeyboardService: IFMXVirtualKeyboardService;
  LServices: TAppServices;
begin
  if TPlatformServices.Current.SupportsPlatformService(IFMXVirtualKeyboardService,
    IInterface(LKeyboardService)) and Assigned(LKeyboardService) then begin
    LKeyboardService.HideVirtualKeyboard;
  end;

  if TryGetServices(LServices) and Assigned(LServices.Keyboard) then begin
    LServices.Keyboard.HideKeyboard;
  end;
end;

function TFMain.IsVirtualKeyboardVisible: Boolean;
var
  LKeyboardService: IFMXVirtualKeyboardService;
begin
  Result := TPlatformServices.Current.SupportsPlatformService(IFMXVirtualKeyboardService,
    IInterface(LKeyboardService)) and Assigned(LKeyboardService) and
    (TVirtualKeyboardState.Visible in LKeyboardService.VirtualKeyBoardState);
end;

procedure TFMain.ReleaseServices;
begin
  FreeAndNil(AppContext);
end;

function TFMain.TryGetServices(out AServices: TAppServices): Boolean;
begin
  AServices := nil;

  if not Assigned(AppContext) then exit(False);
  if not Assigned(AppContext.Services) then exit(False);

  AServices := AppContext.Services;
  Result := True;
end;

end.
