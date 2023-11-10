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
    procedure btnMasukClick(Sender: TObject);
  private
  public
  published
    procedure Show;

    constructor Create(AOwner : TComponent); override;
  end;

var
  FLogin: TFLogin;

implementation

{$R *.fmx}

uses frMain;


{ TFLogin }

procedure TFLogin.btnMasukClick(Sender: TObject);
begin
  FMain.Frame.GoFrame('HOME');
end;

constructor TFLogin.Create(AOwner: TComponent);
begin
  inherited;

end;

procedure TFLogin.Show;
begin

end;

end.

