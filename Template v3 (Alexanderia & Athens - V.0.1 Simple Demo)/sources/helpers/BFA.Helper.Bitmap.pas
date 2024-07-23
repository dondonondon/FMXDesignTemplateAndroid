unit BFA.Helper.Bitmap;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, System.Generics.Collections, System.Net.URLClient, System.Net.HttpClient,
  System.Net.HttpClientComponent,
  FMX.Objects;

type
  TBitmapHelper = class helper for TBitmap
    procedure LoadImageCenter(AFileName : String);

    procedure ResizeOnWidth(ASize : Integer);
    procedure ResizeOnHeight(ASize : Integer);

    function isLandscape : Boolean;
    function isPotrait : Boolean;
  end;

implementation

{ TBitmapHelper }

function TBitmapHelper.isLandscape: Boolean;
begin
  if Self.Width > Self.Height then Result := True else Result := False;
end;

function TBitmapHelper.isPotrait: Boolean;
begin
  if Self.Width > Self.Height then Result := False else Result := True;
end;

procedure TBitmapHelper.LoadImageCenter(AFileName: String);
var
  ABitmap, ACrop : TBitmap;
  xScale, yScale: extended;
  iRect, ARect: TRect;
  FSizeImage : Integer;
begin
  FSizeImage := 150;
  ABitmap := TBitmap.Create;
  try
    ABitmap.LoadFromFile(AFileName);
    ACrop := TBitmap.Create;
    try
      ARect.Width := FSizeImage;
      ARect.Height := FSizeImage;
      xScale := ABitmap.Width / FSizeImage;
      yScale := ABitmap.Height / FSizeImage;

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

      Self.Assign(ACrop);

//      Self.Fill.Kind := TBrushKind.Bitmap;
//      Self.Fill.Bitmap.WrapMode := TWrapMode.TileStretch;
//      Self.Fill.Bitmap.Bitmap := ACrop;

    finally
      ACrop.DisposeOf;
    end;
  finally
    ABitmap.DisposeOf;
  end;
end;

procedure TBitmapHelper.ResizeOnHeight(ASize: Integer);
begin
  var FScale := Self.Height / ASize;
  Self.Resize(Round(Self.Width / FScale), Round(Self.Height / FScale));
end;

procedure TBitmapHelper.ResizeOnWidth(ASize: Integer);
begin
  var FScale := Self.Width / ASize;
  Self.Resize(Round(Self.Width / FScale), Round(Self.Height / FScale));
end;

end.
