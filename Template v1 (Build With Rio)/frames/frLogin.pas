unit frLogin;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Layouts, System.Threading, FMX.Objects,
  FMX.Edit, FMX.Effects;

type
  TFLogin = class(TFrame)
    loMain: TLayout;
    background: TRectangle;
    btnBack: TCornerButton;
    Rectangle1: TRectangle;
    Label1: TLabel;
    Label2: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    btnMasuk: TCornerButton;
    seMain: TShadowEffect;
    procedure FirstShow;
    procedure btnMasukClick(Sender: TObject);
  private
    statF : Boolean;
    procedure setFrame;
  public
    { Public declarations }
    procedure ReleaseFrame;
    procedure fnGoBack;
  end;

var
  FLogin : TFLogin;

implementation

{$R *.fmx}

uses BFA.Func, BFA.GoFrame, BFA.Helper.Control, BFA.Helper.Main, BFA.Main,
  BFA.OpenUrl, BFA.Rest, uDM;

{ TFTemp }

const
  spc = 10;
  pad = 8;

procedure TFLogin.btnMasukClick(Sender: TObject);
begin
  fnGoFrame(C_LOGIN, C_HOME);
end;

procedure TFLogin.FirstShow;
begin
  setFrame;
end;

procedure TFLogin.fnGoBack;
begin
  fnGoFrame(GoFrame, FromFrame);
end;

procedure TFLogin.ReleaseFrame;
begin
  DisposeOf;
end;

procedure TFLogin.setFrame;
begin
  Self.setAnchorContent;

  if statF then
    Exit;

  statF := True;

end;

end.
