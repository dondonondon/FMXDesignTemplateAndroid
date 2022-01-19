unit frDetail;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects, FMX.Layouts, System.Threading;

type
  TFDetail = class(TFrame)
    loMain: TLayout;
    background: TRectangle;
    Label1: TLabel;
    btnBack: TCornerButton;
    procedure FirstShow;
    procedure btnBackClick(Sender: TObject);
  private
    FShow : Boolean;
    procedure setFrame;
  public
    procedure fnGoBack;
  end;

var
  FDetail: TFDetail;

implementation

{$R *.fmx}

uses BFA.GoFrame, BFA.Env, BFA.Main, BFA.Func, BFA.Helper.Main,
  BFA.Helper.MemTable, BFA.OpenUrl, BFA.Rest, uDM, BFA.Helper.Control;

{ TFDetail }

procedure TFDetail.btnBackClick(Sender: TObject);
begin
  fnBack;
end;

procedure TFDetail.FirstShow;
begin       //procedure like event onShow
  setFrame;
end;

procedure TFDetail.fnGoBack;
begin
  fnBack;
end;

procedure TFDetail.setFrame;
begin
  Self.setAnchorContent;

  if FShow then
    Exit;

  FShow := True;

  //write code here => like event onCreate
end;

end.
