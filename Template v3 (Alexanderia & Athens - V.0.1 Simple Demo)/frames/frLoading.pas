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
    procedure Label1Click(Sender: TObject);
  private
  public
  published
    procedure Show;

    constructor Create(AOwner : TComponent); override;
  end;

var
  FLoading: TFLoading;

implementation

{$R *.fmx}

uses frMain, BFA.Global.Variable,
  BFA.Control.Form.Message, BFA.Control.Frame, BFA.Control.Keyboard,
  BFA.Control.Permission, BFA.Control.PushNotification, BFA.Global.Func,
  BFA.Helper.Main, BFA.Helper.MemoryTable;

constructor TFLoading.Create(AOwner: TComponent);
begin
  inherited;
  Label1.Text := 'Hello World';
end;

procedure TFLoading.faOpaFinish(Sender: TObject);
begin
  TFloatAnimation(Sender).Enabled := False;

{$REGION 'ADD FRAME SIDEBAR'}
  if Assigned(FSidebar) then begin
    FSidebar.LoadListMenu;
    FSidebar.MultiView.Enabled := False;
  end;
{$ENDREGION}

  tiMove.Enabled := True;
end;

procedure TFLoading.Label1Click(Sender: TObject);
begin
  ShowMessage(TFLoading.ClassName);
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
//  Frame.GoFrame(View.DETAIL);
  Frame.GoFrame(View.LOGIN);
end;

end.
