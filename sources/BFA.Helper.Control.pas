unit BFA.Helper.Control;

interface

uses
  BFA.Func, System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, System.Generics.Collections, System.Net.URLClient, System.Net.HttpClient,
  System.Net.HttpClientComponent,
  FMX.Objects;


type
  TControlHelper = class helper for TControl
    procedure LoadFromURL(FURL, ASaveFile : String);
    procedure LoadFromLoc(AFileName : String);
    procedure setAnchorContent;
    procedure setAnchorCenter;
    procedure setPosYAfter(AControl : TControl; ASpace : Single = 0);
    procedure setPosYBefore(AControl : TControl; ASpace : Single = 0);
    procedure setPosXAfter(AControl : TControl; ASpace : Single = 0);
    procedure setPosXBefore(AControl : TControl; ASpace : Single = 0);
  end;

implementation

procedure TControlHelper.LoadFromLoc(AFileName: String);
begin
  fnSetImage(Self, AFileName);
end;

procedure TControlHelper.LoadFromURL(FURL, ASaveFile: String);
begin
  if not FileExists(fnLoadFile(ASaveFile)) then
    fnDownloadFile(FURL, ASaveFile);

  TThread.Synchronize(nil, procedure begin
    fnSetImage(Self, ASaveFile);
  end);
end;

procedure TControlHelper.setAnchorCenter;
var
  isVisible : Boolean;
begin
  isVisible := Self.Visible;
  if not isVisible then
    Self.Visible := True;

  Self.Align := TAlignLayout.Center;
  Self.Align := TAlignLayout.None;
  Self.Anchors := [];

  Self.Visible := isVisible;
end;

procedure TControlHelper.setAnchorContent;
var
  isVisible : Boolean;
begin
  try
    {isVisible := Self.Visible;
    if not isVisible then
      Self.Visible := True; }

    //Self.Align := TAlignLayout.Contents;
    Self.Align := TAlignLayout.None;
    Self.Width := TControl(Self.Parent).Width;
    Self.Height := TControl(Self.Parent).Height;
    Self.Anchors := [TAnchorKind.akLeft, TAnchorKind.akTop, TAnchorKind.akRight, TAnchorKind.akBottom];

    Self.Position.X := 0;
    Self.Position.Y := 0;
  except
    ShowMessage('');
  end;
end;

procedure TControlHelper.setPosXAfter(AControl: TControl; ASpace: Single);
begin
  Self.Position.X := AControl.Position.X + AControl.Width + ASpace;
end;

procedure TControlHelper.setPosXBefore(AControl: TControl; ASpace: Single);
begin
  Self.Position.X := AControl.Position.X - AControl.Width - ASpace;
end;

procedure TControlHelper.setPosYAfter(AControl: TControl; ASpace: Single = 0);
begin
  Self.Position.Y := AControl.Position.Y + AControl.Height + ASpace;
end;

procedure TControlHelper.setPosYBefore(AControl: TControl; ASpace: Single = 0);
begin
  Self.Position.Y := AControl.Position.Y - Self.Height - ASpace;
end;

end.
