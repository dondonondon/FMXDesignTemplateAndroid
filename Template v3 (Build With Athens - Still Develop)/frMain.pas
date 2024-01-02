unit frMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Controls.Presentation, FMX.InertialMovement, BFA.Keyboard, FMX.Platform,
  FMX.Edit, FMX.VirtualKeyboard, FMX.StdCtrls, BFA.Frame, BFA.PushNotification,
  FMX.Memo.Types, FMX.ScrollBox, FMX.Memo
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
    procedure InitFrame;
    function AppEventProc(AAppEvent: TApplicationEvent;
      AContext: TObject): Boolean;
  public
    Frame : TGoFrame;

  end;

var
  FMain: TFMain;

implementation

{$R *.fmx}

uses frLoading, frLogin, BFA.Permission, frHome;

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
end;

procedure TFMain.FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
  Shift: TShiftState);
begin
  FKeyboard.KeyUp(Key, KeyChar, Shift);
end;

procedure TFMain.FormShow(Sender: TObject);
begin
  FNotification.ServiceConnectionStatus(True);
//  FNotification.DeviceID <-- for device id
//  FNotification.DeviceToken <-- for token

  Frame.GoFrame('LOADING');
end;

procedure TFMain.InitFrame;
begin
  Frame := TGoFrame.Create;
  Frame.ControlParent := loFrame;
  Frame.SetIdle := True;  //setidle not free from memory

  Frame.RegisterClassesFrame(
    [
      TFLoading, TFHome
    ],
    [
      'LOADING', 'HOME'
    ]
  );
  //or you can register class one by one like below...
  Frame.RegisterClassFrame(TFLogin, 'LOGIN');
end;

procedure TFMain.InitFunction;
begin
  InitKeyboard;
  InitPushNotification;
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

end.


