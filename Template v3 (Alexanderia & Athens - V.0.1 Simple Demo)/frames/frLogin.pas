unit frLogin;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects, FMX.Layouts, System.Threading,
  FMX.Effects, FMX.Edit, FMX.MediaLibrary.Actions, FMX.StdActns, System.Actions,
  FMX.ActnList, FMX.TabControl, FMX.MediaLibrary
  {$IF DEFINED (ANDROID)}
  , Androidapi.Helpers, Androidapi.JNI.Os, Androidapi.JNI.JavaTypes
  {$ENDIF}
  ;

type
  TFLogin = class(TFrame)
    background: TRectangle;
    loMain: TLayout;
    Rectangle1: TRectangle;
    btnBack: TCornerButton;
    Label1: TLabel;
    Label2: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    btnMasuk: TCornerButton;
    seMain: TShadowEffect;
    AL: TActionList;
    cta0: TChangeTabAction;
    cta1: TChangeTabAction;
    cta2: TChangeTabAction;
    tpLibrary: TTakePhotoFromLibraryAction;
    tpCamera: TTakePhotoFromCameraAction;
    OD: TOpenDialog;
    Image1: TImage;
    procedure btnMasukClick(Sender: TObject);
  private
  public
  published
    procedure Show;
    procedure Back;

    constructor Create(AOwner : TComponent); override;
  end;

var
  FLogin: TFLogin;

implementation

{$R *.fmx}

uses frMain, BFA.Global.Variable,
  BFA.Control.Form.Message, BFA.Control.Frame, BFA.Control.Keyboard,
  BFA.Control.Permission, BFA.Control.PushNotification, BFA.Global.Func,
  BFA.Helper.Main, BFA.Helper.TFDMemTable;


{ TFLogin }

procedure TFLogin.Back;
begin
  Frame.Back;
//  if FMain.Frame.Back then Application.Terminate;
end;

procedure TFLogin.btnMasukClick(Sender: TObject);
begin


//  TTask.Run(procedure begin
//    Helper.StartLoading;
//    try
//      Sleep(3000);
//    finally
//      Helper.StopLoading;
//    end;
//  end).Start;


  Frame.GoFrame(C_HOME);
end;

constructor TFLogin.Create(AOwner: TComponent);
begin
  inherited;

end;

procedure TFLogin.Show;
begin

end;

end.

