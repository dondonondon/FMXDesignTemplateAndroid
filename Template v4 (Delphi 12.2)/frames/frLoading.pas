unit frLoading;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects, FMX.Layouts, FMX.Effects, FMX.Ani, System.Threading;

type
  TFLoading = class(TFrame)
    loMain: TLayout;
    background: TRectangle;
    logo: TImage;
    ShadowEffect1: TShadowEffect;
    Image1: TImage;
    ShadowEffect2: TShadowEffect;
    Image2: TImage;
    ShadowEffect3: TShadowEffect;
    Image3: TImage;
    ShadowEffect4: TShadowEffect;
    Label1: TLabel;
    tiMove: TTimer;
    faOpa: TFloatAnimation;
    procedure logoClick(Sender: TObject);
  private
  public
  published
    procedure Show;

    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
  end;

var
  FLoading: TFLoading;

implementation

{$R *.fmx}

uses BFA.Control.Frame, frMain;

constructor TFLoading.Create(AOwner: TComponent);
begin
  inherited;
end;

destructor TFLoading.Destroy;
begin

  inherited;
end;

procedure TFLoading.logoClick(Sender: TObject);
begin
  FMain.Fr.MoveTo(LOGIN);
end;

procedure TFLoading.Show;
begin

end;

end.
