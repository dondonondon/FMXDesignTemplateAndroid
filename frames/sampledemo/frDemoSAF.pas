unit frDemoSAF;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects, FMX.Layouts, System.Threading,
  FMX.Edit, FMX.Effects, FMX.Memo.Types, FMX.ScrollBox, FMX.Memo;

type
  TFDemoSAF = class(TFrame)
    background: TRectangle;
    loMain: TLayout;
    loHeader: TLayout;
    reHeader: TRectangle;
    seHeader: TShadowEffect;
    btnMenu: TCornerButton;
    LabelTitle: TLabel;
    btnGet: TCornerButton;
    memData: TMemo;
    procedure btnMenuClick(Sender: TObject);
    procedure btnGetClick(Sender: TObject);
  private
    procedure SetupFrame;
    procedure SAFFilePicked(Sender: TObject; const AUri: string);
  public
  published
    procedure ShowFrame;
    procedure BackFrame;

    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
  end;

var
  FDemoSAF: TFDemoSAF;

implementation

{$R *.fmx}

uses BFA.Helper.Main, BFA.App.Context, BFA.App.Services, BFA.App.Func,
  BFA.Control.Form.Message;

{ TFTemp }

procedure TFDemoSAF.BackFrame;
begin
  TAppHelper.Back;
end;

procedure TFDemoSAF.btnGetClick(Sender: TObject);
begin
  AppContext.Services.SAF.OnFilePicked := SAFFilePicked;
  AppContext.Services.SAF.PickFile(TArray<string>.Create(
    'image/png',
    'image/jpeg',
    'application/pdf'
  ));
end;

procedure TFDemoSAF.btnMenuClick(Sender: TObject);
begin
  BackFrame;
end;

constructor TFDemoSAF.Create(AOwner: TComponent);
begin
  inherited;

end;

destructor TFDemoSAF.Destroy;
begin

  inherited;
end;

procedure TFDemoSAF.SAFFilePicked(Sender: TObject; const AUri: string);
var
  LTargetPath : String;
  LFileName : String;
begin
  memData.Lines.Clear;
  LFileName := '';

  if Assigned(AppContext.Services.SAF) then begin
    LFileName := AppContext.Services.SAF.GetDisplayName(AUri).Trim;
  end;

  if LFileName.IsEmpty then begin
    LFileName := 'file_' + TGUID.NewGuid.ToString.Replace('{', '').Replace('}', '');
  end;
  LTargetPath := TGlobalFunction.LoadFile(LFileName);

  if AppContext.Services.SAF.CopyToLocalFile(AUri, LTargetPath) then begin
    TAppHelper.ToastMessage('File tersimpan ke: ' + LTargetPath);
    memData.Lines.Add('File tersimpan ke: ' + LTargetPath);
  end else begin
    TAppHelper.ToastMessage('Gagal copy file.', TTypeMessage.Error);
    memData.Lines.Add('Gagal copy file.');
  end;
end;

procedure TFDemoSAF.SetupFrame;
begin

end;

procedure TFDemoSAF.ShowFrame;
begin
  SetupFrame;
end;

end.
