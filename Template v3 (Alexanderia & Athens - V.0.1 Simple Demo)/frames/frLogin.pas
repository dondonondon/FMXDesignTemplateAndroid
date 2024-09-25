unit frLogin;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects, FMX.Layouts, System.Threading,
  FMX.Edit, FMX.Effects, frCalender, IdGlobal;

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
    ACalender : TFCalender;
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
  BFA.Helper.Main, BFA.Helper.MemoryTable, uDM, frConfirmation;

{ TFTemp }

procedure TFLogin.Back;
begin
  Frame.Back;
end;

procedure TFLogin.btnBiometricClick(Sender: TObject);
begin
//  ShowMessage(Frame.FrameAliasNow + ' | ' + Frame.FrameAliasBefore);
  Frame.GoFrame(View.HOME);
end;

procedure TFLogin.btnMasukClick(Sender: TObject);
begin
//  if Assigned(FConfirmation) then begin
//    FreeAndNil(FConfirmation);
//  end;
//
//  FConfirmation := TFConfirmation.Create(FMain);
//  FConfirmation.Parent := FMain;
//
//  FConfirmation.Title := 'Helo Dunia';
//  FConfirmation.Caption := 'Oke Siap';
//  FConfirmation.Description := 'Ini adalah sebuah deskripsi';
//
//  FConfirmation.ChangeRadius := 25;
//
//  FConfirmation.CancelProcedure := procedure begin
//    ShowMessage('Anda membatalkan pindah view');
//  end;
//
//  FConfirmation.Show(procedure begin
//    HelperFunction.MoveToFrame(View.HOME);
//  end);

  HelperFunction.MoveToFrame(View.HOME);
end;

constructor TFLogin.Create(AOwner: TComponent);
begin
  inherited;

//  ACalender := TFCalender.Create(Self);
//  ACalender.Parent := Self;
//  ACalender.Align := TAlignLayout.Contents;

end;

procedure TFLogin.Show;
begin

end;

end.
