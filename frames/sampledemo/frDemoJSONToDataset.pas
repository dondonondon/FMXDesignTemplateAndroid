unit frDemoJSONToDataset;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects, FMX.Layouts, System.Threading,
  FMX.Edit, FMX.Effects, FMX.Memo.Types, FMX.ScrollBox, FMX.Memo,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TFDemoJSONToDataset = class(TFrame)
    background: TRectangle;
    loMain: TLayout;
    loHeader: TLayout;
    reHeader: TRectangle;
    seHeader: TShadowEffect;
    btnMenu: TCornerButton;
    LabelTitle: TLabel;
    memJSON: TMemo;
    btnLoad: TCornerButton;
    btnNext: TCornerButton;
    btnBack: TCornerButton;
    memData: TMemo;
    QData: TFDMemTable;
    btnLoadSubMenu: TCornerButton;
    procedure btnMenuClick(Sender: TObject);
    procedure btnLoadClick(Sender: TObject);
    procedure btnNextClick(Sender: TObject);
    procedure btnBackClick(Sender: TObject);
    procedure btnLoadSubMenuClick(Sender: TObject);
  private
    procedure SetupFrame;
    procedure FillData;
  public
  published
    procedure ShowFrame;
    procedure BackFrame;

    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
  end;

var
  FDemoJSONToDataset: TFDemoJSONToDataset;

implementation

{$R *.fmx}

uses BFA.Helper.Main, BFA.Helper.Dataset;

{ TFTemp }

procedure TFDemoJSONToDataset.BackFrame;
begin
  TAppHelper.Back;
end;

procedure TFDemoJSONToDataset.btnBackClick(Sender: TObject);
begin
  QData.Prior;
  FillData;
end;

procedure TFDemoJSONToDataset.btnLoadClick(Sender: TObject);
begin
  btnNext.Enabled := True;
  btnBack.Enabled := True;
  btnLoadSubMenu.Enabled := True;

  if not QData.LoadFromJSON(memJSON.Text) then begin
    btnNext.Enabled := False;
    btnBack.Enabled := False;
    btnLoadSubMenu.Enabled := False;
    FillData;
    Exit;
  end;

  FillData;
end;

procedure TFDemoJSONToDataset.btnLoadSubMenuClick(Sender: TObject);
begin
  var LText :=
    'EN : If the submenu field is not empty, the JSON in the submenu will be loaded.' + sLineBreak +
    'ID : Jika field submenu tidak kosong, maka akan di load json yang ada di submenu';

  ShowMessage(LText);

  if Assigned(QData.FindField('submenu')) then begin
    if Trim(QData.FieldByName('submenu').AsString) <> '' then begin
      if not QData.LoadFromJSON(QData.FieldByName('submenu').AsString) then begin
        btnNext.Enabled := False;
        btnBack.Enabled := False;
        FillData;
        Exit;
      end;

      FillData;
    end else begin
      ShowMessage('submenu null');
    end;
  end;

end;

procedure TFDemoJSONToDataset.btnMenuClick(Sender: TObject);
begin
  BackFrame;
end;

procedure TFDemoJSONToDataset.btnNextClick(Sender: TObject);
begin
  QData.Next;
  FillData;
end;

constructor TFDemoJSONToDataset.Create(AOwner: TComponent);
begin
  inherited;

end;

destructor TFDemoJSONToDataset.Destroy;
begin

  inherited;
end;

procedure TFDemoJSONToDataset.FillData;
var
  LField: TField;
begin
  memData.Lines.Clear;

  if not Assigned(QData) then
    Exit;

  if not QData.Active then begin
    memData.Lines.Add('Dataset not active');
    Exit;
  end;

  if QData.IsEmpty then begin
    memData.Lines.Add('No data found');
    Exit;
  end;

  for LField in QData.Fields do begin
    if LField.IsNull then
      memData.Lines.Add(LField.FieldName + ' : null')
    else
      memData.Lines.Add(LField.FieldName + ' : ' + LField.AsString);
  end;
end;

procedure TFDemoJSONToDataset.SetupFrame;
begin

end;

procedure TFDemoJSONToDataset.ShowFrame;
begin
  SetupFrame;
end;

end.
