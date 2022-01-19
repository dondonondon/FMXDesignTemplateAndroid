unit frDetail;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Layouts, System.Threading, FMX.Objects,
  System.Actions, FMX.ActnList, FMX.TabControl, FMXTee.Series, FMXTee.Engine,
  FMXTee.Procs, FMXTee.Chart, FMX.Ani, FMX.ImgList, FMX.Memo.Types,
  FMX.ScrollBox, FMX.Memo;

type
  TFDetail = class(TFrame)
    loMain: TLayout;
    Rectangle1: TRectangle;
    Label1: TLabel;
    background: TRectangle;
    loHeader: TLayout;
    reHeader: TRectangle;
    btnBack: TCornerButton;
    loTBanner: TLayout;
    img: TImage;
    AL: TActionList;
    cta0: TChangeTabAction;
    cta1: TChangeTabAction;
    cta2: TChangeTabAction;
    CornerButton1: TCornerButton;
    procedure FirstShow;
    procedure CornerButton1Click(Sender: TObject);
  private
    statF : Boolean;
    procedure setFrame;
  public
    { Public declarations }
    procedure ReleaseFrame;
    procedure fnGoBack;
  end;

var
  FDetail : TFDetail;

implementation

{$R *.fmx}

uses BFA.Func, BFA.GoFrame, BFA.Helper.Control, BFA.Helper.Main, BFA.Main,
  BFA.OpenUrl, BFA.Rest;

{ TFTemp }

const
  spc = 10;
  pad = 8;

procedure TFDetail.CornerButton1Click(Sender: TObject);
begin
  fnBack();
end;

procedure TFDetail.FirstShow;
begin
  setFrame;
end;

procedure TFDetail.fnGoBack;
begin
  fnGoFrame(GoFrame, FromFrame);
end;

procedure TFDetail.ReleaseFrame;
begin
  DisposeOf;
end;

procedure TFDetail.setFrame;
begin
  Self.setAnchorContent;

  if statF then
    Exit;

  statF := True;

end;

end.
