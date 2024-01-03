unit frHome;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Edit, FMX.Effects, FMX.Objects,
  FMX.Layouts;

type
  TFHome = class(TFrame)
    loHeader: TLayout;
    reHeader: TRectangle;
    seHeader: TShadowEffect;
    lblTitle: TLabel;
    btnBack: TCornerButton;
    procedure btnBackClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  published
    procedure Show;
    procedure Back;

    constructor Create(AOwner : TComponent); override;
  end;

var FHome : TFHome;

implementation

{$R *.fmx}

uses frMain;

procedure TFHome.Back;
begin
  FMain.Frame.Back;
end;

procedure TFHome.btnBackClick(Sender: TObject);
begin
  Back;
end;

constructor TFHome.Create(AOwner: TComponent);
begin
  inherited;

end;

procedure TFHome.Show;
begin

end;

end.
