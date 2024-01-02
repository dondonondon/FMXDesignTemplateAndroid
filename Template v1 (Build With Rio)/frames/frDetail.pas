unit frDetail;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects, FMX.Layouts, System.Threading,
  FMX.TabControl, System.Actions, FMX.ActnList, FMX.Edit, FMX.Memo.Types,
  FMX.ScrollBox, FMX.Memo, System.Rtti, FMX.Grid.Style, FMX.Grid,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, REST.Types, System.Net.Mime;

type
  TFDetail = class(TFrame)
    loMain: TLayout;
    background: TRectangle;
    btnBack: TCornerButton;
    tcMain: TTabControl;
    tiHome: TTabItem;
    tiLoadImage: TTabItem;
    tiLoading: TTabItem;
    tiJSONMemTable: TTabItem;
    tiJSONRest: TTabItem;
    AL: TActionList;
    tiCount: TTimer;
    ctHome: TChangeTabAction;
    ctLoadImage: TChangeTabAction;
    ctLoading: TChangeTabAction;
    ctJSONMemTable: TChangeTabAction;
    ctJSONRest: TChangeTabAction;
    btnMain: TCornerButton;
    Layout1: TLayout;
    Rectangle1: TRectangle;
    CornerButton1: TCornerButton;
    CornerButton2: TCornerButton;
    CornerButton3: TCornerButton;
    CornerButton4: TCornerButton;
    edURL: TEdit;
    imgURL: TImage;
    CornerButton5: TCornerButton;
    imgLoc: TImage;
    CornerButton6: TCornerButton;
    reCenterImage: TRectangle;
    Label1: TLabel;
    btnLoadJSONMem: TCornerButton;
    stgData1: TStringGrid;
    stgData2: TStringGrid;
    Label2: TLabel;
    btnCekRespon: TCornerButton;
    loRespon1: TLayout;
    Rectangle2: TRectangle;
    CornerButton7: TCornerButton;
    Memo1: TMemo;
    QData1: TFDMemTable;
    QTemp1: TFDMemTable;
    btnLoadJSONRest: TCornerButton;
    CornerButton9: TCornerButton;
    stgDataRest1: TStringGrid;
    stgDataRest2: TStringGrid;
    Label3: TLabel;
    QData2: TFDMemTable;
    QTemp2: TFDMemTable;
    loRespon2: TLayout;
    Rectangle3: TRectangle;
    CornerButton8: TCornerButton;
    Memo2: TMemo;
    CornerButton10: TCornerButton;
    CornerButton11: TCornerButton;
    CornerButton12: TCornerButton;
    Label4: TLabel;
    CornerButton13: TCornerButton;
    CornerButton14: TCornerButton;
    CornerButton15: TCornerButton;
    CornerButton16: TCornerButton;
    CornerButton17: TCornerButton;
    Label5: TLabel;
    CornerButton18: TCornerButton;
    procedure FirstShow;
    procedure btnBackClick(Sender: TObject);
    procedure btnMainClick(Sender: TObject);
    procedure CornerButton4Click(Sender: TObject);
    procedure CornerButton5Click(Sender: TObject);
    procedure CornerButton6Click(Sender: TObject);
    procedure CornerButton1Click(Sender: TObject);
    procedure btnLoadJSONMemClick(Sender: TObject);
    procedure CornerButton7Click(Sender: TObject);
    procedure btnCekResponClick(Sender: TObject);
    procedure stgData1CellClick(const Column: TColumn; const Row: Integer);
    procedure CornerButton9Click(Sender: TObject);
    procedure CornerButton8Click(Sender: TObject);
    procedure btnLoadJSONRestClick(Sender: TObject);
    procedure CornerButton10Click(Sender: TObject);
    procedure CornerButton11Click(Sender: TObject);
    procedure stgDataRest1CellClick(const Column: TColumn; const Row: Integer);
    procedure CornerButton12Click(Sender: TObject);
    procedure CornerButton17Click(Sender: TObject);
  private
    FShow : Boolean;
    procedure setFrame;
    procedure fillStringGrid(FMemTable : TFDMemTable; FStringGrid : TStringGrid);
  public
    procedure fnGoBack;
  end;

var
  FDetail: TFDetail;

implementation

{$R *.fmx}

uses BFA.GoFrame, BFA.Main, BFA.Func, BFA.Helper.Main,
  BFA.Helper.MemTable, BFA.OpenUrl, BFA.Rest, uDM, BFA.Helper.Control, frMain;

{ TFDetail }

procedure TFDetail.btnBackClick(Sender: TObject);
begin
  fnGoBack;
end;

procedure TFDetail.btnCekResponClick(Sender: TObject);
begin
  loRespon1.BringToFront;
  loRespon1.Visible := True;
end;

procedure TFDetail.btnLoadJSONMemClick(Sender: TObject);
begin
  if not QData1.FillDataFromURL('https://www.blangkon.net/JSON/API.php?act=findDataGetSample&keyword=AALI') then begin
    fnShowMessage(QData1.FieldByName('messages').AsString);
  end else begin
    fillStringGrid(QData1, stgData1);
  end;
end;

procedure TFDetail.btnLoadJSONRestClick(Sender: TObject);
begin
  fnClearStringGrid(stgDataRest1);
  TTask.Run(procedure begin
    fnLoading(True);
    try
      var req := 'findDataGetSample&keyword=AALI';
      if not fnParsingJSON(req, QData2, TRESTRequestMethod.rmGET) then begin
        fnShowMessage(QData2.FieldByName('messages').AsString);
        Exit;
      end;

      TThread.Synchronize(nil, procedure begin
        fillStringGrid(QData2, stgDataRest1);
        Memo2.Lines.Clear;
        Memo2.Lines.Add(DM.RResp.Content);
      end);
    finally
      fnLoading(False);
    end;
  end).Start;
end;

procedure TFDetail.btnMainClick(Sender: TObject);
begin
  AL.Actions[TCornerButton(Sender).Tag].Execute;
end;

procedure TFDetail.CornerButton10Click(Sender: TObject);
begin
  fnClearStringGrid(stgDataRest1);
  TTask.Run(procedure begin
    fnLoading(True);
    try
      var req := 'findDataPostSample';
      DM.RReq.Params.Clear;
      DM.RReq.AddParameter('keyword', 'ABBA');
      if not fnParsingJSON(req, QData2, TRESTRequestMethod.rmPOST) then begin
        fnShowMessage(QData2.FieldByName('messages').AsString);
        Exit;
      end;

      TThread.Synchronize(nil, procedure begin
        fillStringGrid(QData2, stgDataRest1);
        Memo2.Lines.Clear;
        Memo2.Lines.Add(DM.RResp.Content);
      end);
    finally
      fnLoading;
    end;
  end).Start;
end;

procedure TFDetail.CornerButton11Click(Sender: TObject);
begin
  var LMethod : TMultipartFormData;
  LMethod := TMultipartFormData.Create;
  try
    LMethod.AddField('keyword', 'ABBA');
    if not QData1.FillDataFromURL('https://www.blangkon.net/JSON/API.php?act=findDataPostSample', LMethod) then begin
      fnShowMessage(QData1.FieldByName('messages').AsString);
    end else begin
      fillStringGrid(QData1, stgData1);
    end;
  finally
    LMethod.DisposeOf;
  end;
end;

procedure TFDetail.CornerButton12Click(Sender: TObject);
begin
  {
  C_ERROR = 0;
  C_SUKSES = 1;
  C_INFO  = 2;
  }

  TCornerButton(Sender).TagString := Random(100).ToString;

  TForm(Screen.ActiveForm).
    ShowPopUpMessage( TCornerButton(Sender).TagString + '. ' +
      'Lorem Ipsum is simply dummy text of the printing and typesetting industry. ' +
      'Lorem Ipsum has been the industry`s standard dummy text ever since the 1500s',
     TCornerButton(Sender).Tag);
end;

procedure TFDetail.CornerButton17Click(Sender: TObject);
begin
  {
  C_ERROR = 0;
  C_SUKSES = 1;
  C_INFO  = 2;
  }

  TCornerButton(Sender).TagString := Random(100).ToString;

  TForm(Screen.ActiveForm).
    ShowToastMessage( TCornerButton(Sender).TagString + '. ' +
      'Lorem Ipsum is simply dummy text of the printing and typesetting industry. ' +
      'Lorem Ipsum has been the industry`s standard dummy text ever since the 1500s',
      TCornerButton(Sender).Tag);
end;

procedure TFDetail.CornerButton1Click(Sender: TObject);
begin
  TTask.Run(procedure begin
    fnLoading(True);
    try
      Sleep(2000);
    finally
      fnLoading(False);
    end;
  end).Start;
end;

procedure TFDetail.CornerButton4Click(Sender: TObject);
begin
  imgURL.LoadFromURL(edURL.Text, 'nama_image.jpg', True);
end;

procedure TFDetail.CornerButton5Click(Sender: TObject);
begin
  if FileExists(fnLoadFile('nama_image.jpg')) then
    imgLoc.LoadFromLoc('nama_image.jpg')
  else
    fnShowMessage('Tidak ada image ditemukan');
end;

procedure TFDetail.CornerButton6Click(Sender: TObject);
begin
  reCenterImage.LoadImageCenter(fnLoadFile('nama_image.jpg'));
end;

procedure TFDetail.CornerButton7Click(Sender: TObject);
begin
  loRespon1.Visible := False;
end;

procedure TFDetail.CornerButton8Click(Sender: TObject);
begin
  loRespon2.Visible := False;
end;

procedure TFDetail.CornerButton9Click(Sender: TObject);
begin
  loRespon2.BringToFront;
  loRespon2.Visible := True;
end;

procedure TFDetail.fillStringGrid(FMemTable: TFDMemTable;
  FStringGrid: TStringGrid);
begin
  try
    fnClearStringGrid(FStringGrid);
    if FMemTable.IsEmpty then begin
      fnShowMessage('Data Kosong');
    end else begin
      FStringGrid.ClearColumns;
      for var i := 0 to FMemTable.FieldCount - 1 do begin
        var sc := TStringColumn.Create(nil);
        sc.Header := FMemTable.FieldDefs[i].Name;
        FStringGrid.AddObject(sc);
      end;

      FStringGrid.RowCount := FMemTable.RecordCount;
      FMemTable.First;

      for var i := 0 to FMemTable.RecordCount - 1 do begin
        for var ii := 0 to FMemTable.FieldCount - 1 do
          FStringGrid.Cells[ii, i] := FMemTable.FieldByName(FMemTable.FieldDefs[ii].Name).AsString;

        FMemTable.Next;
      end;
    end;
  except
    on E : Exception do fnShowMessage(E.Message);
  end;
end;

procedure TFDetail.FirstShow;
begin       //procedure like event onShow
  setFrame;
end;

procedure TFDetail.fnGoBack;
begin
  if tcMain.TabIndex <> 0 then
    tcMain.First
  else
    fnBack;
end;

procedure TFDetail.setFrame;
begin
  Self.setAnchorContent;

  tcMain.TabIndex := 0;
  loRespon1.Visible := False;
  loRespon2.Visible := False;

  if FShow then
    Exit;

  FShow := True;

  //write code here => like event onCreate
end;

procedure TFDetail.stgData1CellClick(const Column: TColumn; const Row: Integer);
begin
  if not QTemp1.FillDataFromString(stgData1.Cells[Column.Index, Row]) then begin
    fnShowMessage(QTemp1.FieldByName('messages').AsString);
  end else begin
    fillStringGrid(QTemp1, stgData2);
  end;
end;

procedure TFDetail.stgDataRest1CellClick(const Column: TColumn;
  const Row: Integer);
begin
  DM.RResp.RootElement := 'data['+row.ToString+'].' + Column.Header;
  if QData2.IsEmpty then
    fnShowMessage('Data Kosong')
  else
    fillStringGrid(QData2, stgDataRest2);
end;

end.
