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
    procedure LoadFromURL(FURL, ASaveFile : String; FReplaceDownload : Boolean = False);
    procedure LoadFromLoc(AFileName : String);
    procedure setAnchorContent;
    procedure setAnchorCenter;
    procedure setPosYAfter(AControl : TControl; ASpace : Single = 0);
    procedure setPosYBefore(AControl : TControl; ASpace : Single = 0);
    procedure setPosXAfter(AControl : TControl; ASpace : Single = 0);
    procedure setPosXBefore(AControl : TControl; ASpace : Single = 0);
  end;

  TRectangleHelper = class helper for TRectangle
    procedure LoadImageCenter(ALokasi : String);
  end;

  TImageHelper = class helper for TImage
    procedure LoadImageCenter(ALokasi : String);
  end;

implementation

procedure TControlHelper.LoadFromLoc(AFileName: String);
begin
  fnSetImage(Self, AFileName);
end;

procedure TControlHelper.LoadFromURL(FURL, ASaveFile: String; FReplaceDownload : Boolean = False);
begin
  if FReplaceDownload then begin
    fnDownloadFile(FURL, ASaveFile);
  end else begin
    if not FileExists(fnLoadFile(ASaveFile)) then
      fnDownloadFile(FURL, ASaveFile);
  end;

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

{ TRectangleHelper }

procedure TRectangleHelper.LoadImageCenter(ALokasi: String);
var
  ABitmap, ACrop : TBitmap;
  xScale, yScale: extended;
  iRect, ARect: TRect;
  sc : Integer;
begin
  sc := 150;
  ABitmap := TBitmap.Create;
  try
    ABitmap.LoadFromFile(ALokasi);
    ACrop := TBitmap.Create;
    try
      ARect.Width := sc;
      ARect.Height := sc;
      xScale := ABitmap.Width / sc;
      yScale := ABitmap.Height / sc;

      if ABitmap.Width > ABitmap.Height then begin
        ACrop.Width := round(ARect.Width * yScale);
        ACrop.Height := round(ARect.Height * yScale);
        iRect.Left := Round((ABitmap.Width - ABitmap.Height) / 2);
        iRect.Top := 0;
      end else begin
        ACrop.Width := round(ARect.Width * xScale);
        ACrop.Height := round(ARect.Height * xScale);
        iRect.Left := 0;
        iRect.Top := Round((ABitmap.Height - ABitmap.Width) / 2);
      end;

      iRect.Width := round(ARect.Width * xScale);
      iRect.Height := round(ARect.Height * yScale);
      ACrop.CopyFromBitmap(ABitmap, iRect, 0, 0);

      Self.Fill.Kind := TBrushKind.Bitmap;
      Self.Fill.Bitmap.WrapMode := TWrapMode.TileStretch;
      Self.Fill.Bitmap.Bitmap := ACrop;

    finally
      ACrop.DisposeOf;
    end;
  finally
    ABitmap.DisposeOf;
  end;
end;

{ TImageHelper }

procedure TImageHelper.LoadImageCenter(ALokasi: String);
var
  ABitmap, ACrop : TBitmap;
  xScale, yScale: extended;
  iRect, ARect: TRect;
  sc : Integer;
begin
  sc := 150;
  ABitmap := TBitmap.Create;
  try
    ABitmap.LoadFromFile(ALokasi);
    ACrop := TBitmap.Create;
    try
      ARect.Width := sc;
      ARect.Height := sc;
      xScale := ABitmap.Width / sc;
      yScale := ABitmap.Height / sc;

      if ABitmap.Width > ABitmap.Height then begin
        ACrop.Width := round(ARect.Width * yScale);
        ACrop.Height := round(ARect.Height * yScale);
        iRect.Left := Round((ABitmap.Width - ABitmap.Height) / 2);
        iRect.Top := 0;
      end else begin
        ACrop.Width := round(ARect.Width * xScale);
        ACrop.Height := round(ARect.Height * xScale);
        iRect.Left := 0;
        iRect.Top := Round((ABitmap.Height - ABitmap.Width) / 2);
      end;

      iRect.Width := round(ARect.Width * xScale);
      iRect.Height := round(ARect.Height * yScale);
      ACrop.CopyFromBitmap(ABitmap, iRect, 0, 0);

      Self.WrapMode := TImageWrapMode.Stretch;
      Self.Bitmap := ACrop;

    finally
      ACrop.DisposeOf;
    end;
  finally
    ABitmap.DisposeOf;
  end;
end;

end.
