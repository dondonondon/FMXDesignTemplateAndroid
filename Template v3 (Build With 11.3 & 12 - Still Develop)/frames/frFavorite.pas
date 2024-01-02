unit frFavorite;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects, FMX.Layouts, System.Threading;

type
  TFFavorite = class(TFrame)
    loMain: TLayout;
    background: TRectangle;
    Label1: TLabel;
  private
    FShow : Boolean;
    procedure setFrame;
  public
  published
    procedure FirstShow;
    procedure fnGoBack;
  end;

var
  FFavorite: TFFavorite;

implementation

{$R *.fmx}

uses BFA.GoFrame, BFA.Env, BFA.Main, BFA.Func, BFA.Helper.Main,
  BFA.Helper.MemTable, BFA.OpenUrl, BFA.Rest, uDM, BFA.Helper.Control;

{ TFTemp }

procedure TFFavorite.FirstShow;
begin       //procedure like event onShow
  setFrame;
end;

procedure TFFavorite.fnGoBack;
begin
  fnBack;
end;

procedure TFFavorite.setFrame;
begin
  Self.setAnchorContent;

  if FShow then
    Exit;

  FShow := True;

  //write code here => like event onCreate
end;

end.
