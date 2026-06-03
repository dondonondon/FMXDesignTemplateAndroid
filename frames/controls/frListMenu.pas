unit frListMenu;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Layouts, FMX.ListBox, FMX.Controls.Presentation,
  System.ImageList, FMX.ImgList, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  System.Generics.Collections, System.StrUtils, FMX.Effects, FMX.MultiView,
  FMX.Edit, FMX.SearchBox, FMX.Memo.Types, FMX.ScrollBox, FMX.Memo
  {$IFDEF IOS}
    , Posix.Unistd
  {$ENDIF}
  ;

type
  TListMenuSideBar = class(TObject)
    ListBoxItem : TListBoxItem;
    Layout : TLayout;
    LabelText : TLabel;
    Glyph : TGlyph;
    ImageDefault : TImage;
    ImageSelected : TImage;
    Background : TRectangle;
    Shadow : TShadowEffect;
    //SelectedRect : TRectangle;

    MasterListBoxItem : TListBoxItem;

    Index : Integer;
    ItemIndex : Integer;
    IsHaveSubMenu : Boolean;
    IsSubMenu : Boolean;
    IsSubMenuSelected : Boolean;
    IsExpand : Boolean;
  published
    destructor Destroy; override;
  end;

  TFListMenu = class(TFrame)
    loMain: TLayout;
    loHeader: TLayout;
    reLine: TRectangle;
    imgLogo: TImage;
    Label1: TLabel;
    Label2: TLabel;
    lbMenu: TListBox;
    seTemp: TShadowEffect;
    img: TImageList;
    QListMenu: TFDMemTable;
    sbSearch: TSearchBox;
    Rectangle1: TRectangle;
    ShadowEffect1: TShadowEffect;
    loLogout: TLayout;
    Rectangle2: TRectangle;
    lblLogout: TLabel;
    Image2: TImage;
    Line1: TLine;
    seLine: TShadowEffect;
    lblVersion: TLabel;
    Rectangle3: TRectangle;
    background: TRectangle;
    loTemp: TLayout;
    reTempShadow: TRectangle;
    lblTempText: TLabel;
    glTempDrop: TGlyph;
    imgTempDefault: TImage;
    imgTempSelected: TImage;
    procedure lbMenuItemClick(const Sender: TCustomListBox;
      const Item: TListBoxItem);
    procedure sbSearchTyping(Sender: TObject);
    procedure loLogoutClick(Sender: TObject);
  private
    ListMenu : TList<TListMenuSideBar>;

    ListPanel, ListPanelEC : TList<TLayout>;
    ListCheckMenu : array of Boolean;
    ListImageDefault, ListImageSelected : TList<TImage>;
    ListLabelMenu : TList<TLabel>;

    FJSONListMenu: String;
    FBaseColor: Cardinal;
    FAddShadow: Boolean;
    FFontSizeDefault: Single;
    FFontSizeSelected: Single;
    FMultiView: TMultiView;
    FOwner : TComponent;

    procedure ClearMenu;
    procedure ExpandMenu(AListBoxItem : TListBoxItem);
    procedure CollapseMenu(AListBoxItem : TListBoxItem);
    procedure ClearSelectedMenu;
    procedure SetSelectedMenu(AListBoxItem : TListBoxItem; AClearSelectedMenu : Boolean = True); overload;
    procedure SetDefaultMenu(AListBoxItem : TListBoxItem);
    function AddMenu(AOwner : TListBox; AIndex : Integer; AIsSubMenu : Boolean = False) : TListMenuSideBar;

    procedure setBaseColor(const Value: Cardinal);
  public
    property JSONListMenu : String read FJSONListMenu write FJSONListMenu;
    property BaseColor : Cardinal read FBaseColor write setBaseColor;
    property AddShadow : Boolean read FAddShadow write FAddShadow;
    property FontSizeDefault : Single read FFontSizeDefault write FFontSizeDefault;
    property FontSizeSelected : Single read FFontSizeSelected write FFontSizeSelected;
    property MultiView : TMultiView read FMultiView write FMultiView;

    procedure SetSelectedMenu(AName : String); overload;
    procedure LoadListMenu;
  published
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
  end;

implementation

{$R *.fmx}

uses BFA.Control.Frame, BFA.App.Func, BFA.Control.Form.Message, frMain,
  BFA.Helper.Main, BFA.Helper.Dataset, BFA.App.Types;

{ TFListMenu }

function TFListMenu.AddMenu(AOwner: TListBox; AIndex: Integer; AIsSubMenu : Boolean): TListMenuSideBar;
begin
  Result := TListMenuSideBar.Create;

  Result.Index := AIndex;

  Result.ListBoxItem := TListBoxItem.Create(Self);
  Result.ListBoxItem.Selectable := False;
  Result.ListBoxItem.Height := loTemp.Height + 4;
  Result.ListBoxItem.Width := AOwner.Width;

  Result.ListBoxItem.StyledSettings := [];
  Result.ListBoxItem.FontColor := $00FFFFFF;   //FFDADADA

  Result.Layout := TLayout(loTemp.Clone(Self));
  Result.Layout.Width := AOwner.Width;
  Result.Layout.Position.X := 0;
  Result.Layout.Position.Y := 2;
  Result.Layout.Visible := True;

  Result.LabelText := TLabel(Result.Layout.FindStyleResource(lblTempText.StyleName));
  Result.Glyph := TGlyph(Result.Layout.FindStyleResource(glTempDrop.StyleName));
  Result.ImageDefault := TImage(Result.Layout.FindStyleResource(imgTempDefault.StyleName));
  Result.ImageSelected := TImage(Result.Layout.FindStyleResource(imgTempSelected.StyleName));
  Result.Background := TRectangle(Result.Layout.FindStyleResource(reTempShadow.StyleName));

  Result.LabelText.Font.Size := FontSizeDefault;
  Result.LabelText.FontColor := $FF475569;
  Result.LabelText.StyledSettings := [];

  Result.Background.Fill.Color := $FFFDFDFD;

  if AddShadow then begin
    Result.Shadow := TShadowEffect.Create(Result.Background);
    Result.Background.AddObject(Result.Shadow);

    Result.Shadow.Enabled := False;
    Result.Shadow.Opacity := 0.1;
    Result.Shadow.Softness := 0.1;
  end;

  if AIsSubMenu then begin
    Result.Layout.Width := AOwner.Width - 24;
    Result.Layout.Position.X := 24;
  end;

  Result.ListBoxItem.AddObject(Result.Layout);
  AOwner.AddObject(Result.ListBoxItem);
end;

procedure TFListMenu.ClearMenu;
begin
  for var I in ListMenu do
    I.Free;

  for var I in ListImageDefault do
    I.Free;

  for var I in ListImageSelected do
    I.Free;

  for var I in ListPanel do
    I.Free;

  ListImageDefault.Clear;
  ListImageSelected.Clear;
  ListPanel.Clear;
  ListPanelEC.Clear;
end;

procedure TFListMenu.ClearSelectedMenu;
begin
  for var L in ListMenu do begin
    L.ImageDefault.Visible := True;
    L.ImageSelected.Visible := False;
    //L.SelectedRect.Visible := False;

    L.LabelText.FontColor := $FF475569;
    L.LabelText.Font.Style := [];
    L.LabelText.Font.Size := FontSizeDefault;
    L.Background.Fill.Color := $FFFDFDFD;

    L.IsSubMenuSelected := False;
  end;
end;

procedure TFListMenu.CollapseMenu(AListBoxItem: TListBoxItem);
var
  lb : TListBoxItem;
begin
  for var i := AListBoxItem.Index + 1 to lbMenu.Items.Count - 1 do begin
    lb := lbMenu.ItemByIndex(i);
    if lb.Hint = AListBoxItem.Hint + '_sub' then begin
      lb.Visible := False;
      Application.ProcessMessages;
    end else begin Break; end;
  end;

  ListMenu[AListBoxItem.Tag].IsExpand := False;
  ListMenu[AListBoxItem.Tag].Glyph.ImageIndex := 0;

  if ListMenu[AListBoxItem.Tag].IsSubMenuSelected then
    SetSelectedMenu(AListBoxItem, False);
end;

constructor TFListMenu.Create(AOwner: TComponent);
begin
  inherited;
  loTemp.Visible := False;
  imgTempSelected.Visible := False;

  FOwner := AOwner;

  var FFileName : String;

  FFileName := TAppPath.LoadFile('list_menu_migrate_01.json');
  if FileExists(FFileName) then begin
    var SL := TStringList.Create;
    try
      SL.LoadFromFile(FFileName);
      SL.SaveToFile(TAppPath.LoadFile('list_menuv2.json'));
    finally
      FreeAndNil(SL);
    end;
  end;

  FFileName := TAppPath.LoadFile('list_menuv2.json');
  if FileExists(FFileName) then begin
    var SL := TStringList.Create;
    try
      SL.LoadFromFile(FFileName);
      JSONListMenu := SL.Text;
    finally
      FreeAndNil(SL);
    end;
  end;

  FontSizeDefault := 12.5;
  FontSizeSelected := 13;

  ListImageDefault := TList<TImage>.Create;
  ListImageSelected := TList<TImage>.Create;
  ListLabelMenu := TList<TLabel>.Create;
  ListPanel := TList<TLayout>.Create;
  ListPanelEC := TList<TLayout>.Create;

  ListMenu := TList<TListMenuSideBar>.Create;

  lblLogout.FontColor := $FFDADADA;
  lblLogout.Font.Style := [];
  lblLogout.Font.Size := FontSizeDefault;

end;

destructor TFListMenu.Destroy;
begin
  ClearMenu;

  FreeAndNil(ListImageDefault);
  FreeAndNil(ListImageSelected);
  FreeAndNil(ListLabelMenu);
  FreeAndNil(ListPanel);
  FreeAndNil(ListPanelEC);

  FreeAndNil(ListMenu);

  inherited;
end;

procedure TFListMenu.ExpandMenu(AListBoxItem: TListBoxItem);
var
  lb : TListBoxItem;
begin
  lb := nil;

  for var i := AListBoxItem.Index + 1 to lbMenu.Items.Count - 1 do begin
    lb := lbMenu.ItemByIndex(i);
    if lb.Hint = AListBoxItem.Hint + '_sub' then begin
      lb.Visible := True;
//      Application.ProcessMessages;
    end else begin Break; end;
  end;

  lbMenu.RealignContent;

  if Assigned(lb) then lbMenu.ScrollToItem(lb);

  ListMenu[AListBoxItem.Tag].IsExpand := True;
  ListMenu[AListBoxItem.Tag].Glyph.ImageIndex := 1;
  SetDefaultMenu(AListBoxItem);
end;

procedure TFListMenu.lbMenuItemClick(const Sender: TCustomListBox;
  const Item: TListBoxItem);
begin
  if ListMenu[Item.Tag].IsHaveSubMenu then begin
    if ListMenu[Item.Tag].IsExpand then begin
      CollapseMenu(Item);
    end else begin
      ExpandMenu(Item);
    end;
  end else begin
    SetSelectedMenu(Item);
    TAppHelper.NavigateTo(Item.TagString);

    if Assigned(MultiView) then
      MultiView.HideMaster;
  end;
end;

procedure TFListMenu.LoadListMenu;
var
  FIndex : Integer;
begin

  if JSONListMenu = '' then raise Exception.Create('JSONListMenu Empty');
  if not QListMenu.LoadFromJSON(JSONListMenu) then raise Exception.Create('JSONListMenu Parsing Failed');
  if not QListMenu.LoadFromJSON(QListMenu.FieldByName('config_splitview').AsString) then raise Exception.Create('config_splitview Not Found');

  reTempShadow.Fill.Color := BaseColor;

  ClearMenu;

  QListMenu.IndexFieldNames := 'index:A';
  QListMenu.First;

  SetLength(ListCheckMenu, QListMenu.RecordCount);
  FIndex := 0;
  var QSubListMenu := TFDMemTable.Create(nil);
  try
    for var i := 0 to QListMenu.RecordCount - 1 do begin
      var LM := AddMenu(lbMenu, QListMenu.RecNo);
      ListMenu.Add(LM);

      LM.ListBoxItem.Tag := FIndex;
      LM.ItemIndex := FIndex;

      Inc(FIndex);

      LM.ListBoxItem.Text := QListMenu.FieldByName('name').AsString;
      LM.ListBoxItem.Hint := QListMenu.FieldByName('name').AsString;
      LM.ListBoxItem.TagString := QListMenu.FieldByName('alias').AsString;
      LM.LabelText.Text := QListMenu.FieldByName('name').AsString;

      if FileExists(TAppPath.LoadFile(QListMenu.FieldByName('imagefilenamedefault').AsString)) then
        LM.ImageDefault.Bitmap.LoadFromFile(TAppPath.LoadFile(QListMenu.FieldByName('imagefilenamedefault').AsString));

      if FileExists(TAppPath.LoadFile(QListMenu.FieldByName('imagefilenameselected').AsString)) then
        LM.ImageSelected.Bitmap.LoadFromFile(TAppPath.LoadFile(QListMenu.FieldByName('imagefilenameselected').AsString));

      LM.IsHaveSubMenu := False;

      if QSubListMenu.LoadFromJSON(QListMenu.FieldByName('submenu').AsString) then begin
        QSubListMenu.First;

        LM.IsHaveSubMenu := True;
        LM.Glyph.Images := img;
        LM.Glyph.ImageIndex := 0;

        for var ii := 0 to QSubListMenu.RecordCount - 1 do begin
          var LMSub := AddMenu(lbMenu, QSubListMenu.RecNo, True);
          ListMenu.Add(LMSub);

          LMSub.MasterListBoxItem := LM.ListBoxItem;
          LMSub.ListBoxItem.Tag := FIndex;
          LMSub.ItemIndex := FIndex;

          LMSub.IsSubMenu := True;

          Inc(FIndex);

          LM.ListBoxItem.Text := LM.ListBoxItem.Text + ' ' + QSubListMenu.FieldByName('name').AsString;
          LMSub.ListBoxItem.Text := QSubListMenu.FieldByName('name').AsString;
          LMSub.ListBoxItem.Hint := QListMenu.FieldByName('name').AsString + '_sub'; //identify sub from LM
          LMSub.ListBoxItem.TagString := QSubListMenu.FieldByName('alias').AsString;
          LMSub.LabelText.Text := QSubListMenu.FieldByName('name').AsString;

          if FileExists(TAppPath.LoadFile(QSubListMenu.FieldByName('imagefilenamedefault').AsString)) then
            LMSub.ImageDefault.Bitmap.LoadFromFile(TAppPath.LoadFile(QSubListMenu.FieldByName('imagefilenamedefault').AsString));

          if FileExists(TAppPath.LoadFile(QSubListMenu.FieldByName('imagefilenameselected').AsString)) then
            LMSub.ImageSelected.Bitmap.LoadFromFile(TAppPath.LoadFile(QSubListMenu.FieldByName('imagefilenameselected').AsString));

          LMSub.ListBoxItem.Visible := False;

          QSubListMenu.Next;
        end;
      end;

      QListMenu.Next;
    end;
  finally
    FreeAndNil(QSubListMenu);
    if Assigned(MultiView) then
      MultiView.Enabled := True;
  end;
end;

procedure TFListMenu.loLogoutClick(Sender: TObject);
begin
  if Assigned(MultiView) then begin
    MultiView.HideMaster;
    MultiView.Enabled := False;
  end;

  TAppHelper.NavigateTo(TView.LOGIN);
end;

procedure TFListMenu.sbSearchTyping(Sender: TObject);
begin
  for var i := 0 to lbMenu.items.Count - 1 do begin
    var Item := lbMenu.ItemByIndex(i);
    if ListMenu[Item.Tag].IsHaveSubMenu then begin
      if not ListMenu[Item.Tag].IsExpand then begin
        ExpandMenu(Item);
      end;
    end
  end;
end;

procedure TFListMenu.setBaseColor(const Value: Cardinal);
begin
  FBaseColor := Value;

  background.Fill.Color := Value;
end;

procedure TFListMenu.SetDefaultMenu(AListBoxItem: TListBoxItem);
begin
  ListMenu[AListBoxItem.Tag].ImageDefault.Visible := True;
  ListMenu[AListBoxItem.Tag].ImageSelected.Visible := False;

  ListMenu[AListBoxItem.Tag].LabelText.FontColor := $FF475569;
  ListMenu[AListBoxItem.Tag].LabelText.Font.Style := [];
  ListMenu[AListBoxItem.Tag].LabelText.Font.Size := FontSizeDefault;
  ListMenu[AListBoxItem.Tag].LabelText.StyledSettings:= [];
  ListMenu[AListBoxItem.Tag].Background.Fill.Color := $FFFDFDFD;
end;

procedure TFListMenu.SetSelectedMenu(AName: String);
begin
  for var L in ListMenu do begin
    if LowerCase(L.ListBoxItem.TagString) = LowerCase(AName) then begin
      SetSelectedMenu(L.ListBoxItem);
      Break;
    end;
  end;
end;

procedure TFListMenu.SetSelectedMenu(AListBoxItem: TListBoxItem; AClearSelectedMenu : Boolean);
begin
  if AClearSelectedMenu then ClearSelectedMenu;

  ListMenu[AListBoxItem.Tag].LabelText.FontColor := $FFFDFDFD;
  ListMenu[AListBoxItem.Tag].LabelText.Font.Style := [TFontStyle.fsBold];
  ListMenu[AListBoxItem.Tag].LabelText.Font.Size := FontSizeSelected;
  ListMenu[AListBoxItem.Tag].ImageDefault.Visible := False;
  ListMenu[AListBoxItem.Tag].ImageSelected.Visible := True;
  ListMenu[AListBoxItem.Tag].Background.Fill.Color := $FF6E4324;

  if ListMenu[AListBoxItem.Tag].IsSubMenu then
    ListMenu[ListMenu[AListBoxItem.Tag].MasterListBoxItem.Tag].IsSubMenuSelected := True;
end;

{ TListMenuSideBar }

destructor TListMenuSideBar.Destroy;
begin
  if Assigned(Layout) then
    FreeAndNil(Layout);

  if Assigned(ListBoxItem) then
    FreeAndNil(ListBoxItem);

  inherited;
end;

end.
