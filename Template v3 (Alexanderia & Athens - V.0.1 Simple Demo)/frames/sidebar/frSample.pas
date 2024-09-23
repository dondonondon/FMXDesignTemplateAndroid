unit frSample;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects, FMX.Layouts, System.Threading,
  FMX.Edit;

type
  TFSample = class(TFrame)
    loMain: TLayout;
    background: TRectangle;
    Label1: TLabel;
    procedure Label1Click(Sender: TObject);
  private
  public
  published
    procedure Show;
    procedure Back;

    constructor Create(AOwner : TComponent); override;
  end;

var
  FSample: TFSample;

implementation

{$R *.fmx}

uses frMain, BFA.Global.Variable,
  BFA.Control.Form.Message, BFA.Control.Frame, BFA.Control.Keyboard,
  BFA.Control.Permission, BFA.Control.PushNotification, BFA.Global.Func,
  BFA.Helper.Main, BFA.Helper.MemoryTable;

{ TFTemp }

procedure TFSample.Back;
begin
  Frame.Back;
end;

constructor TFSample.Create(AOwner: TComponent);
begin
  inherited;

end;

procedure TFSample.Label1Click(Sender: TObject);
begin
  Frame.GoFrame(View.HOME);
end;

procedure TFSample.Show;
begin

end;

end.
