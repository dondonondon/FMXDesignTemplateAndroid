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
    procedure tiMoveTimer(Sender: TObject);
    procedure faOpaFinish(Sender: TObject);
  private
  public
  published
    procedure Show;

    constructor Create;
  end;

var
  FLoading: TFLoading;

implementation

{$R *.fmx}

uses BFA.Form.Message, BFA.Frame, BFA.Keyboard, BFA.Permission,
  BFA.PushNotification, frMain;

constructor TFLoading.Create;
begin

end;

procedure TFLoading.faOpaFinish(Sender: TObject);
begin
  TFloatAnimation(Sender).Enabled := False;
  tiMove.Enabled := True;
end;

procedure TFLoading.Show;
begin
  loMain.Visible := False;
  TTask.Run(procedure begin
    Sleep(Round(250));
    TThread.Synchronize(TThread.CurrentThread, procedure begin
      loMain.Opacity := 0;
      loMain.Visible := True;
      faOpa.Enabled := True;
    end);
  end).Start;
end;

procedure TFLoading.tiMoveTimer(Sender: TObject);
begin
  tiMove.Enabled := False;
  FMain.Frame.GoFrame('LOGIN');
end;

end.
