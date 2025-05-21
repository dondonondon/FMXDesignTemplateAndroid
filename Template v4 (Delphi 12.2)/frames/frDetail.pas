unit frDetail;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects, FMX.Layouts, System.Threading,
  FMX.Memo.Types, FMX.ScrollBox, FMX.Memo;

type
  TFDetail = class(TFrame)
    loMain: TLayout;
    background: TRectangle;
    btnBack: TCornerButton;
    btnShare: TCornerButton;
    btnGetFile: TCornerButton;
    btnShareFile: TCornerButton;
    memResult: TMemo;
    btnOpenFile: TCornerButton;
    procedure btnBackClick(Sender: TObject);
  private
  public
  published
    procedure Show;
    procedure Back;

    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
  end;

var
  FDetail: TFDetail;

implementation

{$R *.fmx}

uses BFA.Control.Frame, frMain, frLogin;

{ TFDetail }

procedure TFDetail.Back;
begin
end;

procedure TFDetail.btnBackClick(Sender: TObject);
begin
  var LLogin := TFLogin(FMain.Fr.GetFrame(LOGIN));
  LLogin.btnMasuk.Text := 'Ganti Text';

  FMain.Fr.Back; Exit;
  FMain.Fr.NavigateTo(LOGIN);
//  FMain.Fr.Back;
end;

constructor TFDetail.Create(AOwner: TComponent);
begin
  inherited;

end;

destructor TFDetail.Destroy;
begin

  inherited;
end;

procedure TFDetail.Show;
begin

end;

end.
