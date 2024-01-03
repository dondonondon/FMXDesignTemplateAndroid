unit frFavorite;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects, FMX.Layouts, System.Threading;

type
  TFFavorite = class(TFrame)
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
  FFavorite: TFFavorite;

implementation

{$R *.fmx}

uses frMain, BFA.Global.Variable,
  BFA.Control.Form.Message, BFA.Control.Frame, BFA.Control.Keyboard,
  BFA.Control.Permission, BFA.Control.PushNotification, BFA.Global.Func,
  BFA.Helper.Main, BFA.Helper.TFDMemTable;

{ TFFavorite }

procedure TFFavorite.Back;
begin
  Frame.Back;
end;

procedure TFFavorite.CornerButton1Click(Sender: TObject);
begin
  Back;
end;

constructor TFFavorite.Create(AOwner: TComponent);
begin
  inherited;

end;

procedure TFFavorite.Show;
begin

end;

end.
