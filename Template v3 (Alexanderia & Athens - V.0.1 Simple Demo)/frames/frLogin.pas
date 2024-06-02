unit frLogin;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects, FMX.Layouts, System.Threading,
  FMX.Edit, FMX.Effects;

type
  TFLogin = class(TFrame)
    loMain: TLayout;
    background: TRectangle;
    loPopUpLogin: TLayout;
    Rectangle5: TRectangle;
    Layout1: TLayout;
    Rectangle6: TRectangle;
    btnMasuk: TCornerButton;
    edKodeAkses: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    btnBiometric: TCornerButton;
    lblRS: TLabel;
    Image1: TImage;
    ShadowEffect1: TShadowEffect;
    procedure btnMasukClick(Sender: TObject);
    procedure btnBiometricClick(Sender: TObject);
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
  BFA.Helper.Main, BFA.Helper.TFDMemTable, uDM;

{ TFTemp }

procedure TFLogin.Back;
begin
  Frame.Back;
end;

procedure TFLogin.btnBiometricClick(Sender: TObject);
begin
//  ShowMessage(Frame.FrameAliasNow + ' | ' + Frame.FrameAliasBefore);
  Frame.GoFrame(C_HOME);
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
