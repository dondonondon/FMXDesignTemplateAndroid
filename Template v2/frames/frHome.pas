unit frHome;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects, FMX.Layouts, System.Threading, REST.Types, System.Net.Mime;

type
  TFHome = class(TFrame)
    loMain: TLayout;
    background: TRectangle;
    btnMasuk: TCornerButton;
    procedure btnMasukClick(Sender: TObject);
  private
    FShow : Boolean;
    procedure setFrame;
  public
  published
    procedure FirstShow;
    procedure fnGoBack;
  end;

var
  FHome: TFHome;

implementation

{$R *.fmx}

uses BFA.GoFrame, BFA.Env, BFA.Main, BFA.Func, BFA.Helper.Main,
  BFA.Helper.MemTable, BFA.OpenUrl, BFA.Rest, uDM, BFA.Helper.Control, BFA.Permission;

{ TFHome }

procedure TFHome.btnMasukClick(Sender: TObject);
begin
  HelperPermission.setPermission(
    [
      getPermission.READ_EXTERNAL_STORAGE,
      getPermission.WRITE_EXTERNAL_STORAGE
    ],
    procedure begin
      fnGoFrame(C_HOME, C_DETAIL);
    end);
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
