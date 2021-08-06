unit BFA.Helper.Main;

interface

uses
  BFA.Func, System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, System.Generics.Collections, System.Net.URLClient, System.Net.HttpClient,
  System.Net.HttpClientComponent,
  FMX.Objects;


type
  TFormLoading = class helper for TForm
    procedure heLoading(isStat : Boolean);
  end;


implementation

{ TLoadingForm }

procedure TFormLoading.heLoading(isStat: Boolean);
var
  FLayout : TLayout;
  FAni : TAniIndicator;
begin
  if not isStat then begin
    FLayout := TLayout(Self.FindStyleResource('FLayout'));
    if Assigned(FLayout) then
      FLayout.DisposeOf;

    Exit;
  end;

  FLayout := TLayout(Self.FindStyleResource('FLayout'));
  if not Assigned(FLayout) then begin
    FLayout := TLayout.Create(Self);
    FLayout.Align := TAlignLayout.Contents;
    FLayout.HitTest := True;
    FLayout.StyleName := 'FLayout';

    FAni := TAniIndicator.Create(FLayout);
    FAni.Align := TAlignLayout.Center;
    FAni.Enabled := isStat;
    FAni.StyleName := 'FAni';

    FLayout.AddObject(FAni);
    Self.AddObject(FLayout);
    FLayout.BringToFront;
  end else begin
    FLayout.Visible := isStat;
    FAni := TAniIndicator(FLayout.FindStyleResource('FAni'));
    if Assigned(FAni) then
      FAni.Enabled := isStat;
    FLayout.BringToFront;
  end;
end;

end.
