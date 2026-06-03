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
    procedure Label1Click(Sender: TObject);
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
  BFA.Helper.Main;

constructor TFLoading.Create(AOwner: TComponent);
begin
  inherited;
end;

destructor TFLoading.Destroy;
begin

  inherited;
end;

procedure TFLoading.Label1Click(Sender: TObject);
var
  LErrorMessage: string;
begin
  TAppHelper.ToastMessage('Ok Bosku1');
  TAppHelper.ToastMessage('Ok Bosku2');
  TAppHelper.StartLoading('Hello World');

  TTask.Run(procedure begin
    try
      Sleep(1500);
      TAppHelper.StopLoading;
    except
      on E: Exception do begin
        LErrorMessage := E.Message;
        TThread.Queue(nil, procedure begin
          TAppHelper.ToastMessage(LErrorMessage, TTypeMessage.Error);
        end);
      end;
    end;
  end);
end;

procedure TFLoading.logoClick(Sender: TObject);
begin
  TAppHelper.NavigateTo(TView.LOGIN);
end;

procedure TFLoading.SetupFrame;
begin

end;

procedure TFLoading.ShowFrame;
begin
  SetupFrame;
end;

end.
