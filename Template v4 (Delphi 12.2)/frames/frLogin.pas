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
    btnBack: TCornerButton;
    procedure btnMasukClick(Sender: TObject);
    procedure btnBackClick(Sender: TObject);
    procedure Label3Click(Sender: TObject);
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

uses BFA.Control.Frame, frMain, frDetail;

{ TFTemp }

procedure TFLogin.Back;
begin
end;

procedure TFLogin.btnBackClick(Sender: TObject);
begin
  FMain.Fr.Back;
end;

procedure TFLogin.btnMasukClick(Sender: TObject);
begin
  FMain.Fr.NavigateTo(DETAIL);
end;

constructor TFLogin.Create(AOwner: TComponent);
begin
  inherited;
end;

destructor TFLogin.Destroy;
begin

  inherited;
end;

procedure TFLogin.Label3Click(Sender: TObject);
begin
  var LDetail := TFDetail(FMain.Fr.GetFrame(DETAIL));
  LDetail.btnBack.Text := 'Ganti Text';

  FMain.Fr.NavigateTo(LOGIN);
end;

procedure TFLogin.Show;
begin

end;

end.
