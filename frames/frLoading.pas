unit frLoading;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects, FMX.Layouts, FMX.Effects, FMX.Ani, System.Threading;

type
  TFLoading = class(TFrame)
    loMain: TLayout;
    logo: TImage;
    ShadowEffect1: TShadowEffect;
    Image1: TImage;
    ShadowEffect2: TShadowEffect;
    Image2: TImage;
    ShadowEffect3: TShadowEffect;
    Image3: TImage;
    ShadowEffect4: TShadowEffect;
    LabelLoading: TLabel;
    tiMove: TTimer;
    faOpa: TFloatAnimation;
    LabelVersion: TLabel;
    FlowLayout1: TFlowLayout;
    background: TRectangle;
    procedure faOpaFinish(Sender: TObject);
    procedure tiMoveTimer(Sender: TObject);
  private
    procedure SetupFrame;
  public
  published
    procedure ShowFrame;

    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
  end;

var
  FLoading: TFLoading;

implementation

{$R *.fmx}

uses
  BFA.App.Types,
  BFA.Control.Form.Message,
  BFA.Helper.Main, BFA.App.Func, BFA.App.Services;

constructor TFLoading.Create(AOwner: TComponent);
begin
  inherited;
end;

destructor TFLoading.Destroy;
begin

  inherited;
end;

procedure TFLoading.faOpaFinish(Sender: TObject);
begin
  TFloatAnimation(Sender).Enabled := False;
  tiMove.Enabled := True;
end;

procedure TFLoading.SetupFrame;
begin
  loMain.Visible := False;
  TAppHelper.ChangeColorStatusBar($FFC7B6AA, False);
end;

procedure TFLoading.ShowFrame;
begin
  SetupFrame;

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
  TAppHelper.NavigateTo(TView.LOGIN);
//  TAppHelper.EnabledSidebar(True);
end;

end.
