unit frMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  BFA.Control.Frame, FMX.Controls.Presentation, FMX.StdCtrls, System.StrUtils;

type
  TFMain = class(TForm)
    loMain: TLayout;
    vsMain: TVertScrollBox;
    loFrame: TLayout;
    SB: TStyleBook;
    lblBreadCrumb: TLabel;
    tiUpdate: TTimer;
    lblCurrent: TLabel;
    lblClass: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure CornerButton1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure tiUpdateTimer(Sender: TObject);
  private

  public
    Fr : TFrameCollection;
  end;

const
  LOADING = 'LOADING';
  LOGIN = 'LOGIN';
  DETAIL = 'DETAIL';

var
  FMain: TFMain;

implementation

{$R *.fmx}

uses frLoading, frLogin, frTemp, frDetail;

procedure TFMain.CornerButton1Click(Sender: TObject);
begin
//  ShowMessage(TFMain.ClassName);
end;

procedure TFMain.FormCreate(Sender: TObject);
begin
  Fr := TFrameCollection.Create;
end;

procedure TFMain.FormDestroy(Sender: TObject);
begin
  Fr.Free;
end;

procedure TFMain.FormShow(Sender: TObject);
begin
  Fr.Container := loFrame;

//  Fr.RegisterFrame(TFLogin, LOGIN);
//  Fr.RegisterFrame(TFDetail, DETAIL, True);
//  Fr.RegisterFrame(TFLoading, LOADING);

//  Fr.RegisterFrame([TFLogin, TFLoading], [LOGIN, LOADING]);
  Fr.RegisterFrame([TFDetail], [DETAIL], True);

  Fr.RegisterFrame([
    Fr.Add(TFLogin, LOGIN),
    Fr.Add(TFLoading, LOADING)
  ]);

  Fr.LockBack([LOGIN, LOADING], True);

  Fr.NavigateTo(LOADING);

end;

procedure TFMain.tiUpdateTimer(Sender: TObject);
var
  LCurrent : String;
  LPrevious : String;
begin
  if not Assigned(Fr) then Exit;

  lblBreadCrumb.Text := Fr.RouteNavigation;
  lblCurrent.Text := Fr.CurrentAlias + ' | ' + Fr.PreviousAlias;

  LCurrent := IfThen(Assigned(Fr.CurrentFrame), Fr.CurrentFrame.ClassName, 'NOTFOUND');
  if Assigned(Fr.PreviousFrame) then
    LPrevious := Fr.PreviousFrame.ClassName;

  lblClass.Text := LCurrent + ' | ' + LPrevious;
end;

end.
