unit frHome;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Layouts, System.Threading, FMX.Objects,
  FMX.Edit;

type
  TFHome = class(TFrame)
    loMain: TLayout;
    Label1: TLabel;
    Rectangle1: TRectangle;
    CornerButton1: TCornerButton;
    CornerButton2: TCornerButton;
    procedure FirstShow;
    procedure btnBackClick(Sender: TObject);
    procedure Rectangle1Click(Sender: TObject);
    procedure CornerButton1Click(Sender: TObject);
    procedure CornerButton2Click(Sender: TObject);
  private
    statF : Boolean;
    procedure setFrame;
  public
    { Public declarations }
    procedure ReleaseFrame;
    procedure fnGoBack;
  end;

var
  FHome : TFHome;

implementation

{$R *.fmx}

uses BFA.Func, BFA.GoFrame, BFA.Helper.Control, BFA.Helper.Main, BFA.Main,
  BFA.OpenUrl, BFA.Rest, frMain;


{ TFTemp }

const
  spc = 10;
  pad = 8;

procedure TFHome.btnBackClick(Sender: TObject);
begin
  fnGoBack;
end;

procedure TFHome.CornerButton1Click(Sender: TObject);
begin
  fnGoFrame(C_HOME, C_DETAIL);
end;

procedure TFHome.CornerButton2Click(Sender: TObject);
begin
  fnGoBack;
end;

procedure TFHome.FirstShow;
begin
  setFrame;
end;

procedure TFHome.fnGoBack;
begin
  fnGoFrame(GoFrame, FromFrame);
end;

procedure TFHome.Rectangle1Click(Sender: TObject);
begin
  fnGoFrame(C_HOME, C_DETAIL);
end;

procedure TFHome.ReleaseFrame;
begin
  DisposeOf;
end;

procedure TFHome.setFrame;
begin
  Self.setAnchorContent;

  if statF then
    Exit;

  statF := True;

end;

end.
