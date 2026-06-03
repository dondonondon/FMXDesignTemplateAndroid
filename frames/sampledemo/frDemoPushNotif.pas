unit frDemoPushNotif;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects, FMX.Layouts, System.Threading,
  FMX.Edit, FMX.Effects, FMX.Memo.Types, FMX.ScrollBox, FMX.Memo;

type
  TFDemoPushNotif = class(TFrame)
    background: TRectangle;
    loMain: TLayout;
    loHeader: TLayout;
    reHeader: TRectangle;
    seHeader: TShadowEffect;
    btnMenu: TCornerButton;
    LabelTitle: TLabel;
    memData: TMemo;
    btnGet: TCornerButton;
    procedure btnMenuClick(Sender: TObject);
    procedure btnGetClick(Sender: TObject);
  private
    procedure SetupFrame;
  public
  published
    procedure ShowFrame;
    procedure BackFrame;

    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
  end;

var
  FDemoPushNotif: TFDemoPushNotif;

implementation

{$R *.fmx}

uses BFA.Helper.Main, BFA.App.Context;

{ TFTemp }

procedure TFDemoPushNotif.BackFrame;
begin
  TAppHelper.Back;
end;

procedure TFDemoPushNotif.btnGetClick(Sender: TObject);
begin
  if not Assigned(AppContext.Services.PushNotification) then begin
    TAppHelper.ToastMessage('Please remove comment on BFA.App.Services -> TAppServices.Initialize -> InitPushNotification;');
    Exit;
  end;

  memData.Lines.Add('Device ID : ' + sLineBreak + AppContext.Services.PushNotification.DeviceID);
  memData.Lines.Add('');
  memData.Lines.Add('');
  memData.Lines.Add('');
  memData.Lines.Add('Device Token : ' + sLineBreak + AppContext.Services.PushNotification.DeviceToken);
end;

procedure TFDemoPushNotif.btnMenuClick(Sender: TObject);
begin
  BackFrame;
end;

constructor TFDemoPushNotif.Create(AOwner: TComponent);
begin
  inherited;

end;

destructor TFDemoPushNotif.Destroy;
begin

  inherited;
end;

procedure TFDemoPushNotif.SetupFrame;
begin

end;

procedure TFDemoPushNotif.ShowFrame;
begin
  SetupFrame;
end;

end.
