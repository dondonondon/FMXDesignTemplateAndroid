unit frTemp;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects, FMX.Layouts, System.Threading;

type
  TFTemp = class(TFrame)
    loMain: TLayout;
    background: TRectangle;
    Label1: TLabel;
    CornerButton1: TCornerButton;
    procedure CornerButton1Click(Sender: TObject);
  private
  public
  published
    procedure Show;
    procedure Back;

    constructor Create(AOwner : TComponent); override;
  end;

var
  FTemp: TFTemp;

implementation

{$R *.fmx}

uses frMain, BFA.Global.Variable,
  BFA.Control.Form.Message, BFA.Control.Frame, BFA.Control.Keyboard,
  BFA.Control.Permission, BFA.Control.PushNotification, BFA.Global.Func,
  BFA.Helper.Main, BFA.Helper.TFDMemTable;

{ TFTemp }

procedure TFTemp.Back;
begin
  Frame.Back;
end;

procedure TFTemp.CornerButton1Click(Sender: TObject);
begin
  Back;
end;

constructor TFTemp.Create(AOwner: TComponent);
begin
  inherited;

end;

procedure TFTemp.Show;
begin

end;

end.
