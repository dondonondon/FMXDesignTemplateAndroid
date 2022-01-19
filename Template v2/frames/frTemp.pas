unit frTemp;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects, FMX.Layouts, System.Threading;

type
  TFTemp = class(TFrame)
    loMain: TLayout;
    background: TRectangle;
    procedure FirstShow;
  private
    FShow : Boolean;
    procedure setFrame;
  public
    procedure fnGoBack;
  end;

var
  FTemp: TFTemp;

implementation

{$R *.fmx}

uses BFA.GoFrame, BFA.Env, BFA.Main, BFA.Func, BFA.Helper.Main,
  BFA.Helper.MemTable, BFA.OpenUrl, BFA.Rest, uDM, BFA.Helper.Control;

{ TFTemp }

procedure TFTemp.FirstShow;
begin       //procedure like event onShow
  setFrame;
end;

procedure TFTemp.fnGoBack;
begin
  fnBack;
end;

procedure TFTemp.setFrame;
begin
  Self.setAnchorContent;

  if FShow then
    Exit;

  FShow := True;

  //write code here => like event onCreate
end;

end.
