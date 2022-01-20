unit frHome;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects, FMX.Layouts, System.Threading;

type
  TFHome = class(TFrame)
    loMain: TLayout;
    background: TRectangle;
    btnMasuk: TCornerButton;
    procedure FirstShow;
    procedure btnMasukClick(Sender: TObject);
  private
    FShow : Boolean;
    procedure setFrame;
  public
    procedure fnGoBack;
  end;

var
  FHome: TFHome;

implementation

{$R *.fmx}

uses BFA.Func, BFA.GoFrame, BFA.Helper.Control, BFA.Helper.Main,
  BFA.Helper.MemTable, BFA.Main, BFA.OpenUrl, BFA.Rest;

{ TFHome }

procedure TFHome.btnMasukClick(Sender: TObject);
begin
  fnGoFrame(C_HOME, C_DETAIL);
end;

procedure TFHome.FirstShow;
begin       //procedure like event onShow
  setFrame;
end;

procedure TFHome.fnGoBack;
begin
  fnBack;
end;

procedure TFHome.setFrame;
begin
  Self.setAnchorContent;

  if FShow then
    Exit;

  FShow := True;

  //write code here => like event onCreate
end;

end.
