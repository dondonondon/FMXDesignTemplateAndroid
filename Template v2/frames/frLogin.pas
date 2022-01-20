unit frLogin;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects, FMX.Layouts, System.Threading,
  FMX.Effects, FMX.Edit;

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
    procedure FirstShow;
    procedure btnMasukClick(Sender: TObject);
  private
    FShow : Boolean;
    procedure setFrame;
  public
    procedure fnGoBack;
  end;

var
  FLogin: TFLogin;

implementation

{$R *.fmx}

uses BFA.GoFrame, BFA.Env, BFA.Main, BFA.Func, BFA.Helper.Main,
  BFA.Helper.MemTable, BFA.OpenUrl, BFA.Rest, uDM, BFA.Helper.Control;

{ TFLogin }

procedure TFLogin.btnMasukClick(Sender: TObject);
begin
  {TForm(Screen.ActiveForm).
    ShowPopUpMessage(
      'Lorem Ipsum is simply dummy text of the printing and typesetting industry. ' +
      'Lorem Ipsum has been the industry`s standard dummy text ever since the 1500s',
      C_SUKSES); }
  {TForm(Screen.ActiveForm).
    ShowToastMessage( TCornerButton(Sender).Tag.ToString + '. ' +
      'Lorem Ipsum is simply dummy text of the printing and typesetting industry. ' +
      'Lorem Ipsum has been the industry`s standard dummy text ever since the 1500s',
      C_SUKSES);

  TCornerButton(Sender).Tag := TCornerButton(Sender).Tag + 1;  }
  fnGoFrame(goFrame, C_HOME);
end;

procedure TFLogin.FirstShow;
begin       //procedure like event onShow
  setFrame;
end;

procedure TFLogin.fnGoBack;
begin
 fnBack;
end;

procedure TFLogin.setFrame;
begin
  Self.setAnchorContent;

  if FShow then
    Exit;

  FShow := True;

  //write code here => like event onCreate
end;

end.
