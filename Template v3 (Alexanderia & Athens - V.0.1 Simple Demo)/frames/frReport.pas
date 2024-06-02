unit frReport;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects, FMX.Layouts, System.Threading,
  FMX.Edit, FMX.Effects;

type
  TFReport = class(TFrame)
    loMain: TLayout;
    background: TRectangle;
    Label1: TLabel;
    loHeader: TLayout;
    reHeader: TRectangle;
    seHeader: TShadowEffect;
    lblTitle: TLabel;
    btnMenu: TCornerButton;
    procedure Label1Click(Sender: TObject);
    procedure btnMenuClick(Sender: TObject);
  private
  public
  published
    procedure Show;
    procedure Back;

    constructor Create(AOwner : TComponent); override;
  end;

var
  FReport: TFReport;

implementation

{$R *.fmx}

uses frMain, BFA.Global.Variable,
  BFA.Control.Form.Message, BFA.Control.Frame, BFA.Control.Keyboard,
  BFA.Control.Permission, BFA.Control.PushNotification, BFA.Global.Func,
  BFA.Helper.Main, BFA.Helper.TFDMemTable;

{ TFTemp }

procedure TFReport.Back;
begin
  Frame.Back;
end;

procedure TFReport.btnMenuClick(Sender: TObject);
begin
  FSidebar.MultiView.ShowMaster;
end;

constructor TFReport.Create(AOwner: TComponent);
begin
  inherited;

end;

procedure TFReport.Label1Click(Sender: TObject);
begin
  Frame.GoFrame(C_HOME);
end;

procedure TFReport.Show;
begin
  FSidebar.SetSelectedMenu(C_REPORT);
end;

end.
