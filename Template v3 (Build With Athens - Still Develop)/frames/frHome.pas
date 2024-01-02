unit frHome;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation;

type
  TFHome = class(TFrame)
    Label1: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  published
    constructor Create(AOwner : TComponent); override;
  end;

var FHome : TFHome;

implementation

{$R *.fmx}

{ TFrame1 }

{ TFrame1 }

constructor TFHome.Create(AOwner: TComponent);
begin
  inherited;

end;

end.
