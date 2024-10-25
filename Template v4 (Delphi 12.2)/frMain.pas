unit frMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  BFA.Control.Frame, FMX.Controls.Presentation, FMX.StdCtrls;

type
  TFMain = class(TForm)
    loMain: TLayout;
    vsMain: TVertScrollBox;
    loFrame: TLayout;
    SB: TStyleBook;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure CornerButton1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
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
  ShowMessage(TFMain.ClassName);
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
  Fr.FrameContainer := loFrame;

  Fr.RegisterFrame(TFLogin, LOGIN);
  Fr.RegisterFrame(TFDetail, DETAIL);
  Fr.RegisterFrame(TFLoading, LOADING);

  Fr.Visible := False;

  Fr.MoveTo(LOADING);

end;

end.
