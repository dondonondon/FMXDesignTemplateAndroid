unit frOrder;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects, FMX.Layouts, System.Threading,
  FMX.Edit, System.Rtti, FMX.Grid.Style, FMX.ScrollBox, FMX.Grid,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, FMX.TextLayout,
  FMX.Effects;

type
  TFOrder = class(TFrame)
    loMain: TLayout;
    background: TRectangle;
    Label2: TLabel;
    stgMain: TStringGrid;
    StringColumn1: TStringColumn;
    StringColumn2: TStringColumn;
    StringColumn3: TStringColumn;
    StringColumn4: TStringColumn;
    StringColumn5: TStringColumn;
    StringColumn6: TStringColumn;
    QData: TFDMemTable;
    loHeader: TLayout;
    reHeader: TRectangle;
    seHeader: TShadowEffect;
    lblTitle: TLabel;
    btnMenu: TCornerButton;
    procedure Label1Click(Sender: TObject);
    procedure stgMainDrawColumnHeader(Sender: TObject;
      const Canvas: TCanvas; const Column: TColumn; const Bounds: TRectF);
    procedure stgMainDrawColumnCell(Sender: TObject; const Canvas: TCanvas;
      const Column: TColumn; const Bounds: TRectF; const Row: Integer;
      const Value: TValue; const State: TGridDrawStates);
    procedure stgMainCellClick(const Column: TColumn; const Row: Integer);
    procedure btnMenuClick(Sender: TObject);
  private
  public
  published
    procedure Show;
    procedure Back;

    constructor Create(AOwner : TComponent); override;
  end;

var
  FOrder: TFOrder;

implementation

{$R *.fmx}

uses frMain, BFA.Global.Variable,
  BFA.Control.Form.Message, BFA.Control.Frame, BFA.Control.Keyboard,
  BFA.Control.Permission, BFA.Control.PushNotification, BFA.Global.Func,
  BFA.Helper.Main, BFA.Helper.MemoryTable, uDM;

{ TFTemp }

procedure TFOrder.Back;
begin
  Frame.Back;
end;

procedure TFOrder.btnMenuClick(Sender: TObject);
begin
  FSidebar.MultiView.ShowMaster;
end;

constructor TFOrder.Create(AOwner: TComponent);
begin
  inherited;

  try
    var FFileName := GlobalFunction.LoadFile('data.json');
    if FileExists(FFileName) then begin
      var SL := TStringList.Create;
      try
        SL.LoadFromFile(FFileName);
        QData.FillDataFromString(SL.Text);
        QData.FillDataFromString(QData.FieldByName('tickets').AsString);
      finally
        SL.DisposeOf;
      end;
    end;
  except on E: Exception do
    Helper.ShowToastMessage(E.Message, TTypeMessage.Error);
  end;
end;

procedure TFOrder.Label1Click(Sender: TObject);
begin
  Frame.GoFrame(C_HOME);
end;

procedure TFOrder.Show;
begin
  FSidebar.SetSelectedMenu(C_ORDER);
//  if not QData.Active then Exit;
//  if not QData.IsEmpty then Exit;

  try
    GlobalFunction.ClearStringGrid(stgMain, QData.RecordCount);
    QData.First;
    for var i := 0 to QData.RecordCount - 1 do begin
      stgMain.Cells[0, i] := QData.FieldByName('name').AsString;
      stgMain.Cells[1, i] := QData.FieldByName('location').AsString;
      stgMain.Cells[2, i] := QData.FieldByName('phone_Number').AsString;
      stgMain.Cells[3, i] := QData.FieldByName('status').AsString;
      stgMain.Cells[4, i] := QData.FieldByName('priority').AsString;
      stgMain.Cells[5, i] := QData.FieldByName('ticket_number').AsString;

      QData.Next;
    end;
  except on E: Exception do
    Helper.ShowToastMessage(E.Message, TTypeMessage.Error);
  end;
end;

procedure TFOrder.stgMainCellClick(const Column: TColumn; const Row: Integer);
  //#7F9CBEDC #FF9CBEDC
begin
  if Assigned(stgMain.FindStyleResource('focus')) then begin
    var R := TRectangle(stgMain.FindStyleResource('focus'));
    if (Row mod 2) = 1 then R.Fill.Color := $FFF2F2F2 else R.Fill.Color := $FFF9F9F9;
  end;

  if Assigned(stgMain.FindStyleResource('selection')) then begin
    var R := TRectangle(stgMain.FindStyleResource('selection'));
    if (Row mod 2) = 1 then R.Fill.Color := $FFF2F2F2 else R.Fill.Color := $FFF9F9F9;
  end;
end;

procedure TFOrder.stgMainDrawColumnCell(Sender: TObject; const Canvas: TCanvas;
  const Column: TColumn; const Bounds: TRectF; const Row: Integer;
  const Value: TValue; const State: TGridDrawStates);
const
   HorzTextMargin = 1;
   VertTextMargin = 2;
var
   TextLayout : TTextLayout;
   TextRect: TRectF;
begin
  TextRect := Bounds;
  TextRect.Inflate(-HorzTextMargin, -VertTextMargin);

  if Column.Index = 3 then begin
    if Value.ToString = 'Open' then
      Canvas.Fill.Color := $FFB0CE6A
    else if Value.ToString = 'In Progress' then
      Canvas.Fill.Color := $FF50C6F6
    else if Value.ToString = 'Closed' then
      Canvas.Fill.Color := $FFFA7576;
  end else if Column.Index = 4 then begin
    if Value.ToString = 'High' then
      Canvas.Fill.Color := $FFE33D01
    else if Value.ToString = 'Medium' then
      Canvas.Fill.Color := $FFFA7576
    else if Value.ToString = 'Low' then
      Canvas.Fill.Color := $FFF5AE20;
  end else begin
//    if (Row mod 2) = 0 then Canvas.Fill.Color := $FFF9F9F9 else Canvas.Fill.Color := $FFFFFFFF;
    if (Row mod 2) = 1 then Canvas.Fill.Color := $FFF2F2F2 else Canvas.Fill.Color := $FFF9F9F9;
  end;

  Canvas.FillRect(Bounds, 4, 4, AllCorners, 1);


  TextLayout := TTextLayoutManager.DefaultTextLayout.Create;
  try
     TextLayout.BeginUpdate;
     try
        TextLayout.WordWrap := True; // True for Multiline text
        TextLayout.Opacity := Column.AbsoluteOpacity;
        TextLayout.HorizontalAlign := stgMain.TextSettings.HorzAlign;
        TextLayout.VerticalAlign := stgMain.TextSettings.VertAlign;
        TextLayout.Trimming := TTextTrimming.Character;
        TextLayout.TopLeft := TextRect.TopLeft;
        TextLayout.Text := Value.ToString;
        TextLayout.MaxSize := PointF(TextRect.Width, TextRect.Height);
        TextLayout.Font.Size := 13;
        TextLayout.Color := $FF1C1C1C;

        if (Column.Index = 3) OR (Column.Index = 4) OR (Column.Index = 5) then begin
          TextLayout.HorizontalAlign := TTextAlign.Center;
          TextLayout.Color := $FFFFFFFF;
        end;

        if Column.Index = 5 then begin
          TextLayout.Color := $FF1C1C1C;
        end;

        // Custom settings rendering
        //TextLayout.Font.Family := FontF;
        //TextLayout.Font.Style := [ TFontStyle.fsBold ];

     finally
        TextLayout.EndUpdate;
     end;
     TextLayout.RenderLayout(Canvas);
  finally
     TextLayout.Free;
  end;
end;

procedure TFOrder.stgMainDrawColumnHeader(Sender: TObject;
  const Canvas: TCanvas; const Column: TColumn; const Bounds: TRectF);
begin
  Canvas.Fill.Color := $FFE5E5E5;

  Bounds.Height := 20;
  Canvas.FillRect(Bounds, 0, 0, AllCorners, 1);
  Canvas.Font.Size := 13;
  Canvas.Fill.Color := TAlphaColorRec.Black;
  Canvas.Font.Style := [ TFontStyle.fsBold ];
  Canvas.FillText(Bounds, Column.Header , False, 1, [] , TTextAlign.Center);

  stgMain.Columns[0].Width := 210;
  stgMain.Columns[1].Width := 170;
  stgMain.Columns[2].Width := 130;
  stgMain.Columns[3].Width := 100;
  stgMain.Columns[4].Width := 100;

  stgMain.Columns[5].Width := stgMain.Width - (210 + 170 + 130 + 200 + 20);

end;

end.
