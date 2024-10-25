unit frLogin;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects, FMX.Layouts, System.Threading,
  FMX.Edit, FMX.Effects, IdGlobal;

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
  private
  public
  published
    procedure Show;
    procedure Back;

    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
  end;

var
  FLogin: TFLogin;

implementation

{$R *.fmx}

uses BFA.Control.Frame, frMain;

{ TFTemp }

procedure TFLogin.Back;
begin
end;

procedure TFLogin.btnMasukClick(Sender: TObject);
begin

  FMain.Fr.MoveTo(DETAIL);
end;

constructor TFLogin.Create(AOwner: TComponent);
begin
  inherited;
end;

destructor TFLogin.Destroy;
begin

  inherited;
end;

procedure TFLogin.Show;
begin

end;

end.
