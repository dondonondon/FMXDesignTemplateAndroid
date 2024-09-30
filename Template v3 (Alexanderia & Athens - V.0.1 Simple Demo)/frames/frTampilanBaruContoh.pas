unit frTampilanBaruContoh;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation;

type
  TFTampilanBaru = class(TFrame)
    CornerButton1: TCornerButton;
    CornerButton2: TCornerButton;
    procedure CornerButton1Click(Sender: TObject);
    procedure CornerButton2Click(Sender: TObject);
  private

  public
    TransID : String;
    TransID2 : String;
  end;

implementation

{$R *.fmx}

uses BFA.Helper.Main;

procedure TFTampilanBaru.CornerButton1Click(Sender: TObject);
begin
  ShowMessage(TransID);
end;

procedure TFTampilanBaru.CornerButton2Click(Sender: TObject);
begin
  HelperFunction.ShowSidebar;
end;

end.
