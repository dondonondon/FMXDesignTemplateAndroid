{*******************************************************}
{                                                       }
{             Delphi FireMonkey Platform                }
{ Copyright(c) 2012-2021 Embarcadero Technologies, Inc. }
{              All rights reserved                      }
{                                                       }
{*******************************************************}

unit FMX.FontGlyphs.Win;

interface

{$SCOPEDENUMS ON}

uses
  System.Types, System.Classes, System.SysUtils, System.UITypes, System.UIConsts, System.Generics.Collections,
  System.Generics.Defaults, Winapi.Windows, FMX.Types, FMX.Surfaces, FMX.FontGlyphs, FMX.Utils;

type
  TWinFontGlyphManager = class(TFontGlyphManager)
  private type
    TWinBitmap = record
      BitmapInfo: TBitmapInfo;
      DC: HDC;
      Bitmap: HBITMAP;
      Bits: PAlphaColorRecArray;
      Width, Height: Integer;
    end;
  private
    FFont: HFONT;
    FMeasureBitmap: TWinBitmap;
    FBaseline: Integer;
    function CreateBitmap(const Width, Height: Integer): TWinBitmap;
    procedure DestroyBitmap(var Bitmap: TWinBitmap);
  protected
    procedure LoadResource; override;
    procedure FreeResource; override;
    function DoGetGlyph(const ACharacter: UCS4String; const Settings: TFontGlyphSettings;
      const UseColorfulPalette: Boolean): TFontGlyph; override;
    function DoGetBaseline: Single; override;
  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation

uses
  System.Math, System.Character, FMX.Helpers.Win;

{ TWinFontGlyphManager }

constructor TWinFontGlyphManager.Create;
begin
  inherited Create;
  FMeasureBitmap := CreateBitmap(1, 1);
end;

destructor TWinFontGlyphManager.Destroy;
begin
  DestroyBitmap(FMeasureBitmap);
  inherited;
end;

function TWinFontGlyphManager.CreateBitmap(const Width, Height: Integer): TWinBitmap;
begin
  Result.Width := Width;
  Result.Height := Height;
  Result.DC := CreateCompatibleDC(0);
  ZeroMemory(@(Result.BitmapInfo.bmiHeader), SizeOf(TBitmapInfoHeader));
  Result.BitmapInfo.bmiHeader.biSize := SizeOf(TBitmapInfoHeader);
  Result.BitmapInfo.bmiHeader.biWidth := Width;
  Result.BitmapInfo.bmiHeader.biHeight := -Height;
  Result.BitmapInfo.bmiHeader.biPlanes := 1;
  Result.BitmapInfo.bmiHeader.biCompression := BI_RGB;
  Result.BitmapInfo.bmiHeader.biBitCount := 32;
  Result.Bitmap := CreateDIBSection(Result.DC, Result.BitmapInfo, DIB_RGB_COLORS, Pointer(Result.Bits), 0, 0);
  SetMapMode(Result.DC, MM_TEXT);
  SelectObject(Result.DC, Result.Bitmap);
end;

procedure TWinFontGlyphManager.DestroyBitmap(var Bitmap: TWinBitmap);
begin
  Bitmap.Bits := nil;
  DeleteObject(Bitmap.Bitmap);
  DeleteDC(Bitmap.DC);
end;

procedure TWinFontGlyphManager.LoadResource;

  function DefineFontHeight: Integer;
  var
    PixelsPerInchY: Integer;
  begin
    if GlobalUseGPUCanvas then
      Result := -Round(CurrentSettings.Size * CurrentSettings.Scale)
    else
    begin
      PixelsPerInchY := GetDeviceCaps(FMeasureBitmap.DC, LOGPIXELSY);
      //Pixels to logical units
      Result := -MulDiv(Round(CurrentSettings.Size), PixelsPerInchY, 72);
    end;
  end;

  function ExtractBaseline(const AMetrics: TTextMetric) : Integer;
  var
    PixelsPerInchY: Integer;
  begin
    if GlobalUseGPUCanvas then
      Result := AMetrics.tmAscent
    else
    begin
      PixelsPerInchY := GetDeviceCaps(FMeasureBitmap.DC, LOGPIXELSY);
      //Logical units to pixels
      Result := MulDiv(AMetrics.tmAscent, 72, PixelsPerInchY);
    end;
  end;

var
  Height: Integer;
  Metrics: TTextMetric;
begin
  Height := DefineFontHeight;
  FFont := CreateFont(Height, 0, 0, 0, FontWeightToWinapi(CurrentSettings.Style.Weight),
                      Cardinal(not CurrentSettings.Style.Slant.IsRegular), 0, 0,
                      DEFAULT_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS, DEFAULT_QUALITY,
                      DEFAULT_PITCH or FF_DONTCARE, PChar(CurrentSettings.Family));
  if FFont = 0 then
    Exit;

  SelectObject(FMeasureBitmap.DC, FFont);
  GetTextMetrics(FMeasureBitmap.DC, Metrics);

  FBaseline := ExtractBaseline(Metrics);
end;

procedure TWinFontGlyphManager.FreeResource;
begin
  if FFont <> 0 then
    DeleteObject(FFont);
  FFont := 0;
end;

function TWinFontGlyphManager.DoGetBaseline: Single;
begin
  Result := FBaseline;
end;

function TWinFontGlyphManager.DoGetGlyph(const ACharacter: UCS4String; const Settings: TFontGlyphSettings;
  const UseColorfulPalette: Boolean): TFontGlyph;
const
  PT_UNDECLARATED = 3; //Not declarated value for windows path point type
var
  CharsString: string;
  Abc: TABCFLOAT;
  CharSize: TSize;
  GlyphRect: TRect;
  I, J: Integer;
  C: Byte;
  Color: TAlphaColorRec;
  GlyphStyle: TFontGlyphStyles;
  Bitmap: TWinBitmap;
  PathSize: Integer;
  Points: TArray<TPointL>;
  Types: TArray<Byte>;
begin
  CharsString := UCS4StringToUnicodeString(ACharacter);

  GetTextExtentPoint32W(FMeasureBitmap.DC, CharsString, Length(CharsString), CharSize);
  GetCharABCWidthsFloat(FMeasureBitmap.DC, ACharacter[Low(ACharacter)], ACharacter[Low(ACharacter)], Abc);
  if Length(CharsString) > 1 then
  begin
    Abc.abcfA := 0;
    Abc.abcfB := CharSize.cx;
    Abc.abcfC := 0;
  end;

  if [TFontGlyphSetting.Bitmap, TFontGlyphSetting.Path] * Settings <> [] then
  begin
    Bitmap := CreateBitmap(Max(Ceil(Abs(Abc.abcfA) + Abs(Abc.abcfB) + Abs(Abc.abcfC)), CharSize.cx), CharSize.cy);
    FillAlphaColor(PAlphaColorArray(Bitmap.Bits), Bitmap.Width * Bitmap.Height, TAlphaColorRec.White);

    SetTextColor(Bitmap.DC, RGB(0, 0, 0));
    SetBkColor(Bitmap.DC, RGB(255, 255, 255));
    SetTextAlign(Bitmap.DC, TA_TOP);
    SelectObject(Bitmap.DC, FFont);
    TextOut(Bitmap.DC, -Trunc(Abc.abcfA), 0, PChar(CharsString), Length(CharsString));
  end;

  if TFontGlyphSetting.Bitmap in Settings then
  begin
    // search for minimal non transprent rect
    GlyphRect := TRect.Create(Bitmap.Width, CharSize.cy, 0, 0);
    for I := 0 to Bitmap.Width - 1 do
      for J := 0 to CharSize.cy - 1 do
      begin
        C := Bitmap.Bits[J * Bitmap.Width + I].R;
        if C > 0 then
        begin
          if J < GlyphRect.Top then
            GlyphRect.Top := J;
          if I < GlyphRect.Left then
            GlyphRect.Left := I;
        end;
      end;
    for I := Bitmap.Width - 1 downto GlyphRect.Left do
      for J := CharSize.cy - 1 downto GlyphRect.Top do
      begin
        C := Bitmap.Bits[J * Bitmap.Width + I].R;
        if C > 0 then
        begin
          if J > GlyphRect.Bottom then
            GlyphRect.Bottom := J;
          if I > GlyphRect.Right then
            GlyphRect.Right := I;
        end;
      end;
    GlyphRect.Left := Min(CharSize.cx, GlyphRect.Left);
    GlyphRect.Top := Min(CharSize.cy, GlyphRect.Top);
    GlyphRect.Right := Max(CharSize.cx, GlyphRect.Right + 1);
    GlyphRect.Bottom := Max(CharSize.cy, GlyphRect.Bottom + 1);
  end
  else
    GlyphRect := TRect.Empty;

  GlyphStyle := [];
  if (Length(ACharacter) = 0) and not HasGlyph(ACharacter) then
    GlyphStyle := [TFontGlyphStyle.NoGlyph];
  if TFontGlyphSetting.Path in Settings then
    GlyphStyle := GlyphStyle + [TFontGlyphStyle.HasPath];
  if UseColorfulPalette then
    GlyphStyle := GlyphStyle + [TFontGlyphStyle.ColorGlyph];

  Result := TFontGlyph.Create(TPoint.Create(GlyphRect.Left + Trunc(Abc.abcfA), GlyphRect.Top),
    Abc.abcfA + Abc.abcfB + Abc.abcfC, CharSize.Height, GlyphStyle);

  if TFontGlyphSetting.Path in Settings then
  begin
    BeginPath(Bitmap.DC);
    TextOut(Bitmap.DC, -Trunc(Abc.abcfA), 0, PChar(CharsString), 1);
    EndPath(Bitmap.DC);

    PathSize := GetPath(Bitmap.DC, nil, nil, 0);
    if PathSize > 0 then
    begin
      SetLength(Points, PathSize);
      SetLength(Types, PathSize);

      GetPath(Bitmap.DC, @Points[0], @Types[0], PathSize);
      I := 4; //Skipping first four values that indicates text border
      while I < PathSize do
      begin
        case Types[I] of
          PT_MOVETO:
            Result.Path.MoveTo(TPointF.Create(Points[I].x, Points[I].y));
          PT_LINETO:
            Result.Path.LineTo(TPointF.Create(Points[I].x, Points[I].y));
          PT_BEZIERTO:
          begin
            Result.Path.CurveTo(TPointF.Create(Points[I].x, Points[I].y), TPointF.Create(Points[I + 1].x, Points[I + 1].y), TPointF.Create(Points[I + 2].x, Points[I + 2].y));
            Inc(I, 2);
          end;
          PT_CLOSEFIGURE, PT_UNDECLARATED:
            Result.Path.ClosePath;
         end;
        Inc(I);
      end;
    end;
  end;

  if (TFontGlyphSetting.Bitmap in Settings) and (Result.Bitmap <> nil) then
  begin
    Result.Bitmap.SetSize(Max(GlyphRect.Width, GlyphRect.Right), GlyphRect.Height, TPixelFormat.BGRA);

    for I := GlyphRect.Left to GlyphRect.Right - 1 do
      for J := GlyphRect.Top to GlyphRect.Bottom - 1 do
      begin
        Color := Bitmap.Bits[J * Bitmap.Width + I];
        if Color.R < 255 then
        begin
          { Faster integer variant of formula:
            Result = R * 0.2126 + G * 0.7152 + B * 0.0722 }
          C := 255 - ((Integer(Color.R * 54) + Integer(Color.G * 183) + Integer(Color.B * 19)) div 256);
          if TFontGlyphSetting.PremultipliedAlpha in Settings then
            Result.Bitmap.Pixels[I - GlyphRect.Left, J - GlyphRect.Top] := MakeColor(C, C, C, C)
          else
            Result.Bitmap.Pixels[I - GlyphRect.Left, J - GlyphRect.Top] := MakeColor($FF, $FF, $FF, C);
        end;
      end;
  end;

  if [TFontGlyphSetting.Bitmap, TFontGlyphSetting.Path] * Settings <> [] then
    DestroyBitmap(Bitmap);
end;

end.
