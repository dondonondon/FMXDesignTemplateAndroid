unit frLoading;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Layouts, FMX.Ani, System.Threading, FMX.Controls.Presentation,
  FMX.Effects;

type
  TFLoading = class(TFrame)
    background: TRectangle;
    tiMove: TTimer;
    loMain: TLayout;
    faOpa: TFloatAnimation;
    Label1: TLabel;
    imgLogo: TImage;
    seLogo: TShadowEffect;
    procedure FirstShow;
    procedure faOpaFinish(Sender: TObject);
    procedure tiMoveTimer(Sender: TObject);
  private
    { Private declarations }
    procedure setFrame;
  public
    { Public declarations }
    procedure ReleaseFrame;
  end;

var
  FLoading : TFLoading;

implementation

{$R *.fmx}

uses BFA.Func, BFA.GoFrame, BFA.Helper.Control, BFA.Helper.Main, BFA.Main,
  BFA.OpenUrl, BFA.Rest;

{ TFTemp }

procedure TFLoading.faOpaFinish(Sender: TObject);
begin
  TFloatAnimation(Sender).Enabled := False;
  tiMove.Enabled := True;
end;

procedure TFLoading.FirstShow;
begin
  setFrame;
  loMain.Visible := False;
  TTask.Run(procedure begin
    Sleep(Round(CIdle * 1.5));
    TThread.Synchronize(TThread.CurrentThread, procedure begin
      Self.setAnchorContent;
      loMain.Opacity := 0;
      loMain.Visible := True;
      faOpa.Enabled := True;
    end);
  end).Start;
end;

procedure TFLoading.ReleaseFrame;
begin
  DisposeOf;
end;

procedure TFLoading.setFrame;
begin
  Self.setAnchorContent;
end;

procedure TFLoading.tiMoveTimer(Sender: TObject);
begin
  tiMove.Enabled := False;
  fnGoFrame(C_LOADING, C_HOME);
end;

end.
