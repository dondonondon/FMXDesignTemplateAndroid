unit frTemp;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects, FMX.Layouts, System.Threading,
  FMX.Edit;

type
  TFTemp = class(TFrame)
    loMain: TLayout;
    background: TRectangle;
  private
  public
  published
    procedure Show;
    procedure Back;

    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
  end;

var
  FTemp: TFTemp;

implementation

{$R *.fmx}

{ TFTemp }

procedure TFTemp.Back;
begin
end;

constructor TFTemp.Create(AOwner: TComponent);
begin
  inherited;

end;

destructor TFTemp.Destroy;
begin

  inherited;
end;

procedure TFTemp.Show;
begin

end;

end.
