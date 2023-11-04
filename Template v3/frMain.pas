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
    CornerButton1: TCornerButton;
    CornerButton2: TCornerButton;
    Memo1: TMemo;
    procedure FormShow(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure FormDestroy(Sender: TObject);
    procedure CornerButton1Click(Sender: TObject);
    procedure CornerButton2Click(Sender: TObject);
  private
    FNotification : TPushNotif;
    FKeyboard : TKeyboardShow;

    function AppEventProc(AAppEvent: TApplicationEvent;
      AContext: TObject): Boolean;
  public
    Frame : TGoFrame;

  end;

var
  FMain: TFMain;

implementation

{$R *.fmx}

uses frLoading, frLogin, BFA.Permission;

function TFMain.AppEventProc(AAppEvent: TApplicationEvent;
  AContext: TObject): Boolean;
begin
  FNotification.AppEventProc(AAppEvent, AContext);

  if (AAppEvent = TApplicationEvent.BecameActive) then begin
    //your code here
  end;
end;

procedure TFMain.CornerButton1Click(Sender: TObject);
begin
  Memo1.Lines.Add(FNotification.DeviceID);
  Memo1.Lines.Add(FNotification.DeviceToken);
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

procedure TFMain.CornerButton2Click(Sender: TObject);
begin
  Frame.GoFrame('LOADING');
//  Frame.GoFrame(TFLogin);
end;

procedure TFMain.FormShow(Sender: TObject);
begin
  FKeyboard := TKeyboardShow.Create(
    Self, vsMain, loFrame, True
  );

//  FNotification := TPushNotif.Create;
  FNotification := TPushNotif.Create(AppEventProc);  //you can replace AppEventProc
  FNotification.ServiceConnectionStatus(True);

  Frame := TGoFrame.Create;
  Frame.ControlParent := loFrame;
  Frame.SetIdle := True;

  Frame.RegisterClassesFrame(
    [
      TFLoading
    ],
    [
      'LOADING'
    ]
  );

  Frame.RegisterClassFrame(TFLogin, 'LOGIN');

//  Frame.GoFrame('LOADING');
end;

end.


