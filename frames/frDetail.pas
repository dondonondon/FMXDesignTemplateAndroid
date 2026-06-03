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
  private
    procedure SetupFrame;
  public
  published
    procedure ShowFrame;
    procedure BackFrame;

    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
  end;

var
  FDetail: TFDetail;

implementation

{$R *.fmx}

uses
  BFA.Helper.Main;

{ TFDetail }

procedure TFDetail.BackFrame;
begin
  TAppHelper.Back;
end;

constructor TFDetail.Create(AOwner: TComponent);
begin
  inherited;

end;

destructor TFDetail.Destroy;
begin

  inherited;
end;

procedure TFDetail.SetupFrame;
begin

end;

procedure TFDetail.ShowFrame;
begin
  SetupFrame;
end;

end.
