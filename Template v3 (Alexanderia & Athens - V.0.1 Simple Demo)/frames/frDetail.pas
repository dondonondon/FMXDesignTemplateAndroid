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
    btnFileToIntent: TCornerButton;
    CornerButton1: TCornerButton;
    Image1: TImage;
    procedure btnBackClick(Sender: TObject);
    procedure btnShareClick(Sender: TObject);
    procedure btnGetFileClick(Sender: TObject);
    procedure btnShareFileClick(Sender: TObject);
    procedure btnOpenFileClick(Sender: TObject);
    procedure btnFileToIntentClick(Sender: TObject);
    procedure CornerButton1Click(Sender: TObject);
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

procedure TFDetail.btnFileToIntentClick(Sender: TObject);
begin
  TBFAOpenDialog.SaveFileInternalToExternal(GlobalFunction.LoadFile('a.pdf'));
end;

procedure TFDetail.btnGetFileClick(Sender: TObject);
begin
  TBFAOpenDialog.OD_TRANSFILENAME := GlobalFunction.LoadFile('test.txt');
  TBFAOpenDialog.OpenIntent(TBFARequestCodeOpenDialog.SAVEFILE_TO_INTERNAL, procedure begin
    memResult.Lines.LoadFromFile(GlobalFunction.LoadFile('test.txt'))
  end);
end;

procedure TFDetail.btnOpenFileClick(Sender: TObject);
begin
  TBFAOpenDialog.OpenFile(GlobalFunction.LoadFile('a.pdf'));
end;

procedure TFDetail.btnShareClick(Sender: TObject);
begin
  TBFAOpenDialog.ShareFile(GlobalFunction.LoadFile('calender_main.png'));
end;

procedure TFDetail.btnShareFileClick(Sender: TObject);
begin
  TBFAOpenDialog.ShareFile;
end;

procedure TFDetail.CornerButton1Click(Sender: TObject);
begin
  TBFAOpenDialog.OD_TRANSFILENAME := GlobalFunction.LoadFile('test.jpg');
  TBFAOpenDialog.OpenIntent(TBFARequestCodeOpenDialog.SAVEFILE_TO_INTERNAL, procedure begin
    Image1.Bitmap.LoadFromFile(GlobalFunction.LoadFile('test.jpg'));
  end);
end;

constructor TFDetail.Create(AOwner: TComponent);
begin
  inherited;

end;

procedure TFDetail.Show;
begin

end;

end.
