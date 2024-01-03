unit frMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Controls.Presentation, FMX.InertialMovement, BFA.Control.Keyboard, FMX.Platform,
  FMX.Edit, FMX.VirtualKeyboard, FMX.StdCtrls, BFA.Control.Frame,
  FMX.Memo.Types, FMX.ScrollBox, FMX.Memo, BFA.Control.Form.Message, System.Rtti,
  FMX.Grid.Style, FMX.Grid, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  Data.Bind.EngExt, Fmx.Bind.DBEngExt, Fmx.Bind.Grid, System.Bindings.Outputs,
  Fmx.Bind.Editors, Data.Bind.Components, Data.Bind.Grid, Data.Bind.DBScope,
  BFA.Helper.TFDMemTable, BFA.Global.Func,
  BFA.Global.Variable, BFA.Helper.Main, BFA.Control.PushNotification
  {$IF DEFINED (ANDROID)}
  , Androidapi.Helpers, Androidapi.JNI.Os, Androidapi.JNI.JavaTypes
  {$ENDIF}
  ;

type
  TFMain = class(TForm)
    loMain: TLayout;
    vsMain: TVertScrollBox;
    loFrame: TLayout;
    SB: TStyleBook;
    loTest: TLayout;
    procedure FormShow(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FNotification : TPushNotif;
    FKeyboard : TKeyboardShow;

    procedure InitFunction;
    procedure InitKeyboard;
    procedure InitPushNotification;
    procedure InitToastMessage;
    procedure InitFrame;

    function AppEventProc(AAppEvent: TApplicationEvent;
      AContext: TObject): Boolean;
  public
    Frame : TGoFrame;
    ToastMessage : TToasMessage;

  end;

var
  FMain: TFMain;

implementation

{$R *.fmx}

uses
  frHome, frLoading, frLogin, BFA.Control.Permission;

function TFMain.AppEventProc(AAppEvent: TApplicationEvent;
  AContext: TObject): Boolean;
begin
  FNotification.AppEventProc(AAppEvent, AContext);

  if (AAppEvent = TApplicationEvent.BecameActive) then begin
    //your code here
  end;
end;

procedure TFMain.FormCreate(Sender: TObject);
begin
  InitFunction;
end;

procedure TFMain.FormDestroy(Sender: TObject);
begin
  if Assigned(FKeyboard) then
    FKeyboard.DisposeOf;

  if Assigned(Frame) then
    Frame.DisposeOf;

  if Assigned(FNotification) then
    FNotification.DisposeOf;

  if Assigned(ToastMessage) then
    ToastMessage.DisposeOf;
end;

procedure TFMain.FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
  Shift: TShiftState);
var
  Routine : TMethod;
  Exec : TExec;
  LFrame : TControl;
  FService: IFMXVirtualKeyboardService;
begin
  if (Key = vkHardwareBack) or (Key = vkEscape) then begin {if you type esc on keyboard, frame execute "Back" Procedure on Published inside TFrame}
    TPlatformServices.Current.SupportsPlatformService(IFMXVirtualKeyboardService, IInterface(FService));
    if (FService <> nil) and (TVirtualKeyboardState.Visible in FService.VirtualKeyBoardState) then begin
      FService.HideVirtualKeyboard;
      FKeyboard.HideKeyboard;
    end else begin
      FKeyboard.HideKeyboard;
      Key := 0;

      if Assigned(Frame.LastControl) then begin
        LFrame := Frame.LastControl;
        Routine.Data := Pointer(LFrame);
        Routine.Code := LFrame.MethodAddress('Back');

        if not Assigned(Routine.Code) then
          Exit;

        Exec := TExec(Routine);
        Exec;
      end;
    end;
  end else begin
    FKeyboard.KeyUp(Key, KeyChar, Shift);
  end;
end;

procedure TFMain.FormShow(Sender: TObject);
begin
  FNotification.ServiceConnectionStatus(True);
//  FNotification.DeviceID      {<-- for device id}
//  FNotification.DeviceToken   {<-- for token}

  Frame.GoFrame('LOADING');
end;

procedure TFMain.InitFrame;
begin
  Frame := TGoFrame.Create;
  Frame.ControlParent := loFrame;
  Frame.CloseAppWhenDoubleTap := True;
  Frame.ToastMessage := ToastMessage;

  Frame.RegisterClassesFrame(  {register class using array}
    [TFLoading, TFHome],
    ['LOADING', 'HOME']
  );

  {or you can register class one by one like below...}
  Frame.RegisterClassFrame(TFLogin, 'LOGIN');

  Frame.AddDoubleTapBackExit(['LOGIN', 'LOADING']); {when frame on list, if you tap back / esc then application terminate}
end;

procedure TFMain.InitFunction;
begin
  InitKeyboard;
  InitPushNotification;
  InitToastMessage; //init before Initframe
  InitFrame;
end;

procedure TFMain.InitKeyboard;
begin
  FKeyboard := TKeyboardShow.Create(
    Self, vsMain, loFrame, True
  );
end;

procedure TFMain.InitPushNotification;
begin
//  FNotification := TPushNotif.Create;
  FNotification := TPushNotif.Create(AppEventProc);
  //you can replace AppEventProc. It's for Push Notif from firebase. You can set nil => FNotification := TPushNotif.Create;
end;

procedure TFMain.InitToastMessage;
begin
  ToastMessage := TToasMessage.Create;
  ToastMessage.SetForm := Self;
end;

end.


