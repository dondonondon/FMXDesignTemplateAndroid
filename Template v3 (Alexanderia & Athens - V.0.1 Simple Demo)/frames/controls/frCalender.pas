unit frCalender;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, System.DateUtils,
  FMX.Objects, FMX.Layouts, FMX.Controls.Presentation, FMX.ListBox, FMX.Effects;

type
  TFCalender = class(TFrame)
    loDate: TLayout;
    background: TRectangle;
    reDate: TRectangle;
    lblYear: TLabel;
    lblMonth: TLabel;
    Previous: TImage;
    Next: TImage;
    Rectangle1: TRectangle;
    lbDate: TListBox;
    ListBoxItem1: TListBoxItem;
    tiResize: TTimer;
    ciSelected: TCircle;
    seSelected: TShadowEffect;
    lblText: TLabel;
    ciTempDateNow: TCircle;
    lblTextNow: TLabel;
    reHeader: TRectangle;
    seHeader: TShadowEffect;
    procedure tiResizeTimer(Sender: TObject);
    procedure lblMonthClick(Sender: TObject);
    procedure lbDateItemClick(const Sender: TCustomListBox;
      const Item: TListBoxItem);
    procedure lblYearClick(Sender: TObject);
    procedure PreviousClick(Sender: TObject);
    procedure NextClick(Sender: TObject);
    procedure backgroundClick(Sender: TObject);
  private
    IsDate, IsMonth, IsYear : Boolean;
    FDateTimeSelected : TDateTime;
    FDateSelected, FMonthSelected, FYearSelected : Word;
    procedure LoadDate(ADateTime : TDateTime);
    procedure LoadMonth;
    procedure LoadYear(AStartYear : Integer);
    procedure ClearType;
    procedure SetTag;
  public
  published
    constructor Create(AOwner : TComponent); override;
  end;

implementation

{$R *.fmx}

{ TFCalender }

procedure TFCalender.backgroundClick(Sender: TObject);
begin
  Self.DisposeOf;
end;

procedure TFCalender.ClearType;
begin
  IsDate := False;
  IsMonth := False;
  IsYear := False;
end;

constructor TFCalender.Create(AOwner: TComponent);
begin
  inherited;
  FDateTimeSelected := Now;

  DecodeDate(FDateTimeSelected, FYearSelected, FMonthSelected, FDateSelected);
  SetTag;

  LoadDate(FDateTimeSelected);

  ciSelected.Visible := False;
  ciSelected.Align := TAlignLayout.Contents;
end;

procedure TFCalender.lbDateItemClick(const Sender: TCustomListBox;
  const Item: TListBoxItem);
begin
  if IsDate then begin
    if Item.Text = '' then Exit;
    if Item.Index <= 6 then Exit;    

    var FDate : TDateTime;

    FMonthSelected := lblMonth.Tag;
    FYearSelected := lblYear.Tag;
    FDateSelected := StrToIntDef(Item.Text, 1);

    FDate := EncodeDate(FYearSelected, FMonthSelected, FDateSelected);

    SetTag;

    ciSelected.Parent := Item;
    ciSelected.Visible := True;

    lblText.Text := Item.Text;

    FDateTimeSelected := FDate;
  end else if IsMonth then begin
    lblMonth.Tag := Item.Tag;
    var FDate := EncodeDate(lblYear.Tag, lblMonth.Tag, 1);
    LoadDate(FDate);
    lblMonth.Visible := True;
    lblMonth.Text := FormatDateTime('mmmm', FDate);
    lblYear.Text :=  FormatDateTime('yyyy', FDate);
  end else if IsYear then begin
    lblYear.Tag := Item.Tag;
    var FDate := EncodeDate(lblYear.Tag, lblMonth.Tag, 1);
    LoadDate(FDate);
    lblMonth.Visible := True;
    lblYear.Text := FormatDateTime('yyyy', FDate);
  end;
end;

procedure TFCalender.lblMonthClick(Sender: TObject);
begin
  ciSelected.Visible := False;
  ciSelected.Parent := Self;

  lblMonth.Visible := False;
  LoadMonth;
end;

procedure TFCalender.lblYearClick(Sender: TObject);
begin
  ciSelected.Visible := False;
  ciSelected.Parent := Self;

  lblMonth.Visible := False;
  LoadYear(lblYear.Tag);
end;

procedure TFCalender.LoadDate(ADateTime : TDateTime);
begin
  lbDate.Items.Clear;
  lbDate.Columns := 7;

  reHeader.Height := 121;

  var DayIndex : Integer;
  var FTotalDay : Integer;
  var FHeight : Single;
  var FStartWeek, FStartMonth, FMonthBefore : TDateTime;

  FHeight := lbDate.Width / lbDate.Columns;
  FStartWeek := StartOfTheWeek(ADateTime) - 1;
  FTotalDay := StrToIntDef(FormatDateTime('dd', EndOfTheMonth(ADateTime)), 0);

  for var i := 0 to 6 do begin
    var lb := TListBoxItem.Create(Self);
    lb.Width := FHeight;
    lb.Height := FHeight;
    lb.Text := FormatDateTime('ddd', FStartWeek);
    lb.Selectable := False;

    lb.Font.Size := 14;
//    lb.FontColor := $FF313131;
    lb.FontColor := $FFFFFFFF;
    lb.TextSettings.HorzAlign := TTextAlign.Center;
    lb.Font.Style := [TFontStyle.fsBold];
    lb.StyledSettings := [];

    lbDate.AddObject(lb);

    FStartWeek := IncDay(FStartWeek, 1);
  end;

  FStartMonth := StartOfTheMonth(ADateTime);
  DayIndex := DayOfWeek(FStartMonth);
  FMonthBefore := FStartMonth - DayIndex + 1;

  if DayIndex <> 1 then begin
    for var i := 1 to DayIndex - 1 do begin
      var lb := TListBoxItem.Create(Self);
      lb.Width := FHeight;
      lb.Height := FHeight;
      lb.Selectable := False;
//      lb.Text := FormatDateTime('dd', FMonthBefore);

      lb.Font.Size := 14;
      lb.FontColor := $FFB5B5B5;
      lb.TextSettings.HorzAlign := TTextAlign.Center;
      lb.StyledSettings := [];

      lbDate.AddObject(lb);

      FMonthBefore := IncDay(FMonthBefore, 1);
    end;
  end;

  var FM := StrToIntDef(FormatDateTime('mm', ADateTime), 1);
  var FY := StrToIntDef(FormatDateTime('yyyy', ADateTime), 2000);

  for var i := 0 to FTotalDay - 1 do begin
    var lb := TListBoxItem.Create(Self);
    lb.Width := FHeight;
    lb.Height := FHeight;
    lb.Text := (i + 1).ToString;
    lb.Selectable := False;

    lb.Font.Size := 14;

    if EncodeDate(FY, FM, (i + 1)) < Now then
      lb.FontColor := $FFC3C3C3
    else
      lb.FontColor := $FF313131;

    lb.TextSettings.HorzAlign := TTextAlign.Center;
    lb.StyledSettings := [];

    lbDate.AddObject(lb);

    if FormatDateTime('yyyymmdd', FDateTimeSelected) = FormatDateTime('yyyymmdd', EncodeDate(FY, FM, (i + 1))) then begin
      ciSelected.Visible := True;
      ciSelected.Parent := lb;
      lblText.Text := FDateSelected.ToString;
    end;

    if FormatDateTime('yyyymmdd', EncodeDate(FY, FM, (i + 1))) = FormatDateTime('yyyymmdd', Now) then begin
      var ciDateNow := TCircle(ciTempDateNow.Clone(Self));
      ciDateNow.Visible := True;
      ciDateNow.Parent := lb;
      ciDateNow.Align := TAlignLayout.Contents;
      ciDateNow.HitTest := False;
      TLabel(ciDateNow.FindStyleResource(lblTextNow.StyleName)).Text := (i + 1).ToString;

      ciSelected.BringToFront;
    end;

  end;

  lblYear.Text := FormatDateTime('yyyy', ADateTime);
  lblMonth.Text := FormatDateTime('mmmm', ADateTime);

  ClearType;
  IsDate := True;

  tiResize.Enabled := True;
end;

procedure TFCalender.LoadMonth;
begin
  lbDate.Items.Clear;
  lbDate.Columns := 4;

  reHeader.Height := lbDate.Position.Y;

  var FStartYear : TDateTime;
  var FHeight : Single;

  FHeight := lbDate.Width / lbDate.Columns;
  FStartYear := StartOfTheYear(FStartYear);

  for var i := 0 to 12 - 1 do begin
    var lb := TListBoxItem.Create(Self);
    lb.Width := FHeight;
    lb.Height := FHeight;
    lb.Text := FormatDateTime('mmm', FStartYear);
    lb.Selectable := False;

    lb.Tag := i + 1;

    lb.Font.Size := 14;
    lb.FontColor := $FF313131;
    lb.TextSettings.HorzAlign := TTextAlign.Center;
    lb.Font.Style := [TFontStyle.fsBold];
    lb.StyledSettings := [];

    lbDate.AddObject(lb);

    FStartYear := IncMonth(FStartYear, 1);
  end;

  ClearType;
  IsMonth := True;

  tiResize.Enabled := True;
end;

procedure TFCalender.LoadYear(AStartYear : Integer);
begin
  lbDate.Items.Clear;
  lbDate.Columns := 4;

  reHeader.Height := lbDate.Position.Y;

  lblYear.Text := AStartYear.ToString + ' - ';

  var FHeight : Single;
  FHeight := lbDate.Width / lbDate.Columns;

  for var i := 0 to 12 - 1 do begin
    var lb := TListBoxItem.Create(Self);
    lb.Width := FHeight;
    lb.Height := FHeight;
    lb.Text := AStartYear.ToString;
    lb.Selectable := False;

    lb.Tag := AStartYear;

    lb.Font.Size := 14;
    lb.FontColor := $FF313131;
    lb.TextSettings.HorzAlign := TTextAlign.Center;
    lb.Font.Style := [TFontStyle.fsBold];
    lb.StyledSettings := [];

    lbDate.AddObject(lb);

    AStartYear := AStartYear + 1;
  end;

  ClearType;
  IsYear := True;

  lblYear.Text := lblYear.Text + (AStartYear - 1).ToString;

  tiResize.Enabled := True;
end;

procedure TFCalender.NextClick(Sender: TObject);
begin
  if IsDate then begin
    ciSelected.Visible := False;
    ciSelected.Parent := Self;

    var FDate : TDateTime;
    FDate := EncodeDate(lblYear.Tag, lblMonth.Tag, lbDate.Tag);
    FDate := EndOfTheMonth(FDate) + 1;
    LoadDate(FDate);

    lblYear.Text := FormatDateTime('yyyy', FDate);
    lblMonth.Text := FormatDateTime('mmmm', FDate);

    lblYear.Tag := StrToIntDef(FormatDateTime('yyyy', FDate), 2000);
    lblMonth.Tag := StrToIntDef(FormatDateTime('mm', FDate), 1);

  end else if IsMonth then begin
    var FDate : TDateTime;
    FDate := EncodeDate(lblYear.Tag + 1, lblMonth.Tag, lbDate.Tag);

    lblYear.Text := FormatDateTime('yyyy', FDate);
    lblYear.Tag := StrToIntDef(FormatDateTime('yyyy', FDate), 2000);
  end else if IsYear then begin
    lblYear.Tag := lblYear.Tag + 12;
    LoadYear(lblYear.Tag);
  end;
end;

procedure TFCalender.PreviousClick(Sender: TObject);
begin
  if IsDate then begin
    ciSelected.Visible := False;
    ciSelected.Parent := Self;

    var FDate : TDateTime;
    FDate := EncodeDate(lblYear.Tag, lblMonth.Tag, lbDate.Tag);
    FDate := StartOfTheMonth(FDate) - 1;
    LoadDate(FDate);

    lblYear.Text := FormatDateTime('yyyy', FDate);
    lblMonth.Text := FormatDateTime('mmmm', FDate);

    lblYear.Tag := StrToIntDef(FormatDateTime('yyyy', FDate), 2000);
    lblMonth.Tag := StrToIntDef(FormatDateTime('mm', FDate), 1);
  end else if IsMonth then begin
    var FDate : TDateTime;
    FDate := EncodeDate(lblYear.Tag - 1, lblMonth.Tag, lbDate.Tag);

    lblYear.Text := FormatDateTime('yyyy', FDate);
    lblYear.Tag := StrToIntDef(FormatDateTime('yyyy', FDate), 2000);
  end else if IsYear then begin
    lblYear.Tag := lblYear.Tag - 12;
    LoadYear(lblYear.Tag);
  end;
end;

procedure TFCalender.SetTag;
begin
  lblYear.Tag := FYearSelected;
  lblMonth.Tag := FMonthSelected;
  lbDate.Tag := FDateSelected;
end;

procedure TFCalender.tiResizeTimer(Sender: TObject);
begin
  tiResize.Enabled := False;
  loDate.Height := lbDate.ContentBounds.Size.cy + lbDate.Position.Y + 16;
end;

end.
