unit frInventory;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects, FMX.Layouts, System.Threading,
  FMX.Edit, FMX.Effects;

type
  TFInventory = class(TFrame)
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
  FInventory: TFInventory;

implementation

{$R *.fmx}

uses frMain, BFA.Global.Variable,
  BFA.Control.Form.Message, BFA.Control.Frame, BFA.Control.Keyboard,
  BFA.Control.Permission, BFA.Control.PushNotification, BFA.Global.Func,
  BFA.Helper.Main, BFA.Helper.MemoryTable;

{ TFTemp }

procedure TFInventory.Back;
begin
  Frame.Back;
end;

procedure TFInventory.btnMenuClick(Sender: TObject);
begin
  HelperFunction.ShowSidebar;
end;

constructor TFInventory.Create(AOwner: TComponent);
begin
  inherited;

end;

procedure TFInventory.Label1Click(Sender: TObject);
begin
  Frame.GoFrame(View.HOME);
end;

procedure TFInventory.Show;
begin
  HelperFunction.SetSelectedMenuSidebar(View.INVENTORY);
end;

end.