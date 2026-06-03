unit frDemoPermission;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects, FMX.Layouts, System.Threading,
  FMX.Edit, FMX.Effects, FMX.Memo.Types, FMX.ScrollBox, FMX.Memo;

type
  TFDemoPermission = class(TFrame)
    background: TRectangle;
    loMain: TLayout;
    loHeader: TLayout;
    reHeader: TRectangle;
    seHeader: TShadowEffect;
    btnMenu: TCornerButton;
    LabelTitle: TLabel;
    btnPermissionManual: TCornerButton;
    memLog: TMemo;
    btnPermission: TCornerButton;
    procedure btnMenuClick(Sender: TObject);
    procedure btnPermissionManualClick(Sender: TObject);
    procedure btnPermissionClick(Sender: TObject);
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
  FDemoPermission: TFDemoPermission;

implementation

{$R *.fmx}

uses BFA.Helper.Main, BFA.Control.Permission;

{ TFTemp }

procedure TFDemoPermission.BackFrame;
begin
  TAppHelper.Back;
end;

procedure TFDemoPermission.btnMenuClick(Sender: TObject);
begin
  BackFrame;
end;

procedure TFDemoPermission.btnPermissionClick(Sender: TObject);
begin
  memLog.Lines.Clear;

  THelperPermission.RequireCamera(
    procedure begin
      memLog.Lines.Add('Permission Granted');
    end,
    procedure(const APermissions: TArray<string>) begin
      for var LPermission in APermissions do begin
        memLog.Lines.Add('Denied: ' + LPermission);
      end;
    end);
end;

procedure TFDemoPermission.btnPermissionManualClick(Sender: TObject);
begin
  memLog.Lines.Clear;
  THelperPermission.RequestPermissions(
    [TPermissionName.CAMERA],
    procedure begin
      memLog.Lines.Add('Permssion Granted');
    end,
    procedure (const APermissions: TArray<string>) begin
      for var i := 0 to Length(APermissions) - 1 do
        memLog.Lines.Add('Denied ' + APermissions[i]);
    end);
end;

constructor TFDemoPermission.Create(AOwner: TComponent);
begin
  inherited;

end;

destructor TFDemoPermission.Destroy;
begin

  inherited;
end;

procedure TFDemoPermission.SetupFrame;
begin

end;

procedure TFDemoPermission.ShowFrame;
begin
  SetupFrame;
end;

end.
