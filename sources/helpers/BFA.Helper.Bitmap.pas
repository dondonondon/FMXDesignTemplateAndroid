unit BFA.Helper.Bitmap;

interface

uses
  System.Math, System.SysUtils, System.Types,
  FMX.Graphics;

type
  THelperBitmap = class helper for TBitmap
  private
    procedure EnsureUsableBitmap;
    procedure ResizeProportional(AWidth, AHeight: Integer);
  public
    function IsLandscape: Boolean;
    function IsPortrait: Boolean;

    procedure LoadCenteredSquareFromFile(const AFileName: string;
      ASize: Integer = 150);
    procedure ResizeAuto(ASize: Integer);
    procedure ResizeOnHeight(ASize: Integer);
    procedure ResizeOnWidth(ASize: Integer);

    function isPotrait: Boolean; deprecated 'Use IsPortrait.';
    procedure LoadImageCenter(AFileName: string); deprecated 'Use LoadCenteredSquareFromFile.';
  end;

implementation

{ THelperBitmap }

procedure THelperBitmap.EnsureUsableBitmap;
begin
  if (Self.Width <= 0) or (Self.Height <= 0) then
    raise Exception.Create('Bitmap is empty.');
end;

function THelperBitmap.IsLandscape: Boolean;
begin
  EnsureUsableBitmap;
  Result := Self.Width > Self.Height;
end;

function THelperBitmap.IsPortrait: Boolean;
begin
  EnsureUsableBitmap;
  Result := Self.Height >= Self.Width;
end;

function THelperBitmap.isPotrait: Boolean;
begin
  Result := IsPortrait;
end;

procedure THelperBitmap.LoadCenteredSquareFromFile(const AFileName: string;
  ASize: Integer);
var
  LCrop: TBitmap;
  LSource: TBitmap;
  LSourceRect: TRect;
  LSourceSize: Integer;
begin
  if ASize <= 0 then
    raise EArgumentOutOfRangeException.Create('Image size must be greater than zero.');

  if not FileExists(AFileName) then
    raise EFileNotFoundException.CreateFmt('Image file not found: %s',
      [AFileName]);

  LSource := TBitmap.Create;
  LCrop := TBitmap.Create;
  try
    LSource.LoadFromFile(AFileName);
    if (LSource.Width <= 0) or (LSource.Height <= 0) then
      raise Exception.Create('Loaded image is empty.');

    LSourceSize := Min(LSource.Width, LSource.Height);
    LSourceRect := TRect.Create(
      (LSource.Width - LSourceSize) div 2,
      (LSource.Height - LSourceSize) div 2,
      ((LSource.Width - LSourceSize) div 2) + LSourceSize,
      ((LSource.Height - LSourceSize) div 2) + LSourceSize);

    LCrop.SetSize(LSourceSize, LSourceSize);
    LCrop.CopyFromBitmap(LSource, LSourceRect, 0, 0);
    LCrop.Resize(ASize, ASize);
    Self.Assign(LCrop);
  finally
    FreeAndNil(LCrop);
    FreeAndNil(LSource);
  end;
end;

procedure THelperBitmap.LoadImageCenter(AFileName: string);
begin
  LoadCenteredSquareFromFile(AFileName);
end;

procedure THelperBitmap.ResizeAuto(ASize: Integer);
begin
  EnsureUsableBitmap;

  if IsLandscape then
    ResizeOnWidth(ASize)
  else
    ResizeOnHeight(ASize);
end;

procedure THelperBitmap.ResizeOnHeight(ASize: Integer);
begin
  EnsureUsableBitmap;
  if ASize <= 0 then
    raise EArgumentOutOfRangeException.Create('Height must be greater than zero.');

  ResizeProportional(Round(Self.Width * (ASize / Self.Height)), ASize);
end;

procedure THelperBitmap.ResizeOnWidth(ASize: Integer);
begin
  EnsureUsableBitmap;
  if ASize <= 0 then
    raise EArgumentOutOfRangeException.Create('Width must be greater than zero.');

  ResizeProportional(ASize, Round(Self.Height * (ASize / Self.Width)));
end;

procedure THelperBitmap.ResizeProportional(AWidth, AHeight: Integer);
begin
  if (AWidth <= 0) or (AHeight <= 0) then
    raise EArgumentOutOfRangeException.Create('Bitmap size must be greater than zero.');

  Self.Resize(AWidth, AHeight);
end;

end.
