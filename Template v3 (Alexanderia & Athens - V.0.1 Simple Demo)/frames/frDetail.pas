unit frDetail;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects, FMX.Layouts, System.Threading,
  FMX.Memo.Types, FMX.ScrollBox, FMX.Memo;

type
  TFDetail = class(TFrame)
    loMain: TLayout;
    background: TRectangle;
    btnBack: TCornerButton;
    btnShare: TCornerButton;
    btnGetFile: TCornerButton;
    btnShareFile: TCornerButton;
    memResult: TMemo;
    btnOpenFile: TCornerButton;
    procedure btnBackClick(Sender: TObject);
    procedure btnShareClick(Sender: TObject);
    procedure btnGetFileClick(Sender: TObject);
    procedure btnShareFileClick(Sender: TObject);
    procedure btnOpenFileClick(Sender: TObject);
  private
  public
  published
    procedure Show;
    procedure Back;

    constructor Create(AOwner : TComponent); override;
  end;

var
  FDetail: TFDetail;

implementation

{$R *.fmx}

uses frMain, BFA.Global.Variable,
  BFA.Control.Form.Message, BFA.Control.Frame, BFA.Control.Keyboard,
  BFA.Control.Permission, BFA.Control.PushNotification, BFA.Global.Func,
  BFA.Helper.Main, BFA.Helper.MemoryTable, BFA.Helper.OpenDialog;

{ TFDetail }

procedure TFDetail.Back;
begin
  Frame.Back;
end;

procedure TFDetail.btnBackClick(Sender: TObject);
begin
  Back;
end;

procedure TFDetail.btnGetFileClick(Sender: TObject);
begin
  TBFAOpenDialog.OpenIntent(TBFARequestCodeOpenDialog.GET_FILE_OPEN_DIRECTORY);
end;

procedure TFDetail.btnOpenFileClick(Sender: TObject);
begin
  TBFAOpenDialog.OpenFile(GlobalFunction.LoadFile('calender_main.png'));
end;

procedure TFDetail.btnShareClick(Sender: TObject);
begin
  TBFAOpenDialog.ShareFile(GlobalFunction.LoadFile('calender_main.png'));
end;

procedure TFDetail.btnShareFileClick(Sender: TObject);
begin
  TBFAOpenDialog.ShareFile;
end;

constructor TFDetail.Create(AOwner: TComponent);
begin
  inherited;

end;

procedure TFDetail.Show;
begin

end;

end.
