unit frHome;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects, FMX.Layouts, System.Threading,
  FMX.Effects, FMX.Edit, FMX.MediaLibrary.Actions, FMX.StdActns, System.Actions,
  FMX.ActnList, FMX.TabControl, FMX.MediaLibrary, FMX.Memo.Types, FMX.ScrollBox,
  FMX.Memo, FMX.ListBox, REST.Types, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client
  {$IF DEFINED (ANDROID)}
  , Androidapi.Helpers, Androidapi.JNI.Os, Androidapi.JNI.JavaTypes
  {$ENDIF}
  ;

type
  TFHome = class(TFrame)
    loHeader: TLayout;
    reHeader: TRectangle;
    seHeader: TShadowEffect;
    lblTitle: TLabel;
    btnBack: TCornerButton;
    lbMenu: TListBox;
    ListBoxItem1: TListBoxItem;
    btnMasuk: TCornerButton;
    ListBoxItem2: TListBoxItem;
    CornerButton1: TCornerButton;
    ListBoxItem3: TListBoxItem;
    CornerButton2: TCornerButton;
    ListBoxItem4: TListBoxItem;
    CornerButton3: TCornerButton;
    ListBoxItem5: TListBoxItem;
    CornerButton4: TCornerButton;
    ListBoxItem6: TListBoxItem;
    CornerButton5: TCornerButton;
    OD: TOpenDialog;
    AL: TActionList;
    cta0: TChangeTabAction;
    cta1: TChangeTabAction;
    cta2: TChangeTabAction;
    tpLibrary: TTakePhotoFromLibraryAction;
    tpCamera: TTakePhotoFromCameraAction;
    tcMain: TTabControl;
    tiMenu: TTabItem;
    tiTokenDeviceID: TTabItem;
    tiPermissionPhoto: TTabItem;
    tiToastMessage: TTabItem;
    tiPopupMessage: TTabItem;
    tiMoveFrame: TTabItem;
    tiPermission: TTabItem;
    CornerButton6: TCornerButton;
    Memo1: TMemo;
    CornerButton7: TCornerButton;
    Memo2: TMemo;
    CornerButton8: TCornerButton;
    Image1: TImage;
    Label1: TLabel;
    Image2: TImage;
    Label2: TLabel;
    Memo3: TMemo;
    CornerButton9: TCornerButton;
    CornerButton10: TCornerButton;
    CornerButton11: TCornerButton;
    CornerButton12: TCornerButton;
    CornerButton13: TCornerButton;
    CornerButton14: TCornerButton;
    CornerButton15: TCornerButton;
    CornerButton16: TCornerButton;
    CornerButton17: TCornerButton;
    CornerButton18: TCornerButton;
    tiRest: TTabItem;
    btnGet: TCornerButton;
    memRest: TMemo;
    btnPost: TCornerButton;
    btnBody: TCornerButton;
    ListBoxItem7: TListBoxItem;
    CornerButton19: TCornerButton;
    QData: TFDMemTable;
    QSubData: TFDMemTable;
    ListBoxItem8: TListBoxItem;
    CornerButton20: TCornerButton;
    tiLoading: TTabItem;
    btnStartLoading: TCornerButton;
    memLoading: TMemo;
    procedure btnBackClick(Sender: TObject);
    procedure lbMenuItemClick(const Sender: TCustomListBox;
      const Item: TListBoxItem);
    procedure CornerButton6Click(Sender: TObject);
    procedure CornerButton7Click(Sender: TObject);
    procedure CornerButton8Click(Sender: TObject);
    procedure tpLibraryDidFinishTaking(Image: TBitmap);
    procedure tpCameraDidFinishTaking(Image: TBitmap);
    procedure CornerButton9Click(Sender: TObject);
    procedure CornerButton11Click(Sender: TObject);
    procedure CornerButton10Click(Sender: TObject);
    procedure CornerButton14Click(Sender: TObject);
    procedure CornerButton13Click(Sender: TObject);
    procedure CornerButton12Click(Sender: TObject);
    procedure CornerButton15Click(Sender: TObject);
    procedure CornerButton16Click(Sender: TObject);
    procedure CornerButton17Click(Sender: TObject);
    procedure CornerButton18Click(Sender: TObject);
    procedure btnGetClick(Sender: TObject);
    procedure btnPostClick(Sender: TObject);
    procedure btnBodyClick(Sender: TObject);
    procedure btnStartLoadingClick(Sender: TObject);
    procedure lblTitleClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  published
    procedure Show;
    procedure Back;

    constructor Create(AOwner : TComponent); override;
  end;

var FHome : TFHome;

const
//  COBASEURL = 'http://localhost:8080/API/APITemplateV3/';
  COBASEURL = 'https://www.blangkon.net/APITemplate/';

implementation

{$R *.fmx}

uses frMain, BFA.Global.Variable,
  BFA.Control.Form.Message, BFA.Control.Frame, BFA.Control.Keyboard,
  BFA.Control.Permission, BFA.Control.PushNotification, BFA.Global.Func,
  BFA.Helper.Main, BFA.Helper.TFDMemTable, BFA.Control.Rest, uDM, frCalender;

procedure TFHome.Back;
begin
  if btnBack.ImageIndex = 2 then begin
    btnBack.ImageIndex := 1;
    if tcMain.TabIndex <> 0 then begin
      tcMain.TabIndex := 0;
      lblTitle.Text := 'Menu Home';
    end else begin
      Frame.Back;
    end;
  end else begin
    FSidebar.MultiView.ShowMaster;
  end;
end;

procedure TFHome.btnBackClick(Sender: TObject);
begin
  Back;
end;

procedure TFHome.btnPostClick(Sender: TObject);
var
  Rest : TRequestAPI;
begin
  Rest := TRequestAPI.Create;
  try
    var FValue := 'Hello world from Blangkon FA';

    Rest.URL := COBASEURL + 'sample_post.php';
    Rest.Method := TRESTRequestMethod.rmPOST;
    Rest.Data := QData;

    Rest.AddParameter('value', FValue);

    Rest.Execute(True);

    memRest.Lines.Clear;
    memRest.Lines.Add('Status Code : ' + Rest.StatusCode.ToString);
    memRest.Lines.Add(Rest.Content);
    memRest.Lines.Add('=================');
    memRest.Lines.Add('status : ' + QData.FieldByName('status').AsString);
    memRest.Lines.Add('messages : ' + QData.FieldByName('messages').AsString);
  finally
    Rest.DisposeOf;
  end;
end;

procedure TFHome.btnBodyClick(Sender: TObject);
var
  Rest : TRequestAPI;
begin
  Rest := TRequestAPI.Create;
  try
    var FValue :=
      '{'#13 +
      '"data1": "Hello world",'#13 +
      '"data2": "testing data values"'#13 +
      '}';

    Rest.URL := COBASEURL + 'sample_body.php';
    Rest.Method := TRESTRequestMethod.rmPOST;
    Rest.Data := QData;

    Rest.AddBody(FValue, TRESTContentType.ctAPPLICATION_JSON);

    Rest.Execute(True);

    memRest.Lines.Clear;
    memRest.Lines.Add('Status Code : ' + Rest.StatusCode.ToString);
    memRest.Lines.Add(Rest.Content);
    memRest.Lines.Add('=================');
    memRest.Lines.Add('status : ' + QData.FieldByName('status').AsString);
    memRest.Lines.Add('messages : ' + QData.FieldByName('messages').AsString);

    QSubData.FillDataFromString(QData.FieldByName('messages').AsString, False);
    if QSubData.IsEmpty then Exit;

    memRest.Lines.Add('=================');
    memRest.Lines.Add('data1 : ' + QSubData.FieldByName('data1').AsString);
    memRest.Lines.Add('data2 : ' + QSubData.FieldByName('data2').AsString);

  finally
    Rest.DisposeOf;
  end;
end;

procedure TFHome.btnGetClick(Sender: TObject);
var
  Rest : TRequestAPI;
begin
  Rest := TRequestAPI.Create;
  try
    var FValue := 'Hello world from Blangkon FA';
    var FParams := 'value=' + FValue;
    Rest.URL := COBASEURL + 'sample_get.php?' + FParams;
    Rest.Method := TRESTRequestMethod.rmGET;
    Rest.Data := QData;

    Rest.Execute(True);

    memRest.Lines.Clear;
    memRest.Lines.Add('Status Code : ' + Rest.StatusCode.ToString);
    memRest.Lines.Add(Rest.Content);
    memRest.Lines.Add('=================');
    memRest.Lines.Add('status : ' + QData.FieldByName('status').AsString);
    memRest.Lines.Add('messages : ' + QData.FieldByName('messages').AsString);
  finally
    Rest.DisposeOf;
  end;
end;

procedure TFHome.btnStartLoadingClick(Sender: TObject);
begin
  memLoading.Lines.Add('Loading Start');

  TTask.Run(procedure begin
    Helper.StartLoading;
    try
      Sleep(3000);

      TThread.Synchronize(nil, procedure begin
        memLoading.Lines.Add('Loading Finish');
      end);

    finally
      Helper.StopLoading;
    end;
  end).Start;
end;

procedure TFHome.CornerButton10Click(Sender: TObject);
begin
  Helper.ShowToastMessage('This is message Information', TTypeMessage.Information);
end;

procedure TFHome.CornerButton11Click(Sender: TObject);
begin
  Helper.ShowToastMessage('This is message Error', TTypeMessage.Error);
end;

procedure TFHome.CornerButton12Click(Sender: TObject);
begin
  Helper.ShowPopUpMessage('This is message Information', TTypeMessage.Information);
end;

procedure TFHome.CornerButton13Click(Sender: TObject);
begin
  Helper.ShowPopUpMessage('This is message Error', TTypeMessage.Error);
end;

procedure TFHome.CornerButton14Click(Sender: TObject);
begin
  Helper.ShowPopUpMessage('This is message Success', TTypeMessage.Success);
end;

procedure TFHome.CornerButton15Click(Sender: TObject);
begin
  Frame.GoFrame(C_ACCOUNT);
end;

procedure TFHome.CornerButton16Click(Sender: TObject);
begin
  Frame.GoFrame(C_FAVORITE);
end;

procedure TFHome.CornerButton17Click(Sender: TObject);
begin
  Frame.GoFrame(C_DETAIL);
end;

procedure TFHome.CornerButton18Click(Sender: TObject);
begin
  {$IF DEFINED(IOS) or DEFINED(ANDROID)}
  var OSVersion := StrToIntDef(JStringToString(TJBuild_VERSION.JavaClass.RELEASE), 10);
  {$ELSE}
  var OSVersion := 10;
  {$ENDIF}

  if OSVersion >= 13 then begin
    HelperPermission.setPermission([
      getPermission.READ_MEDIA_IMAGES
    ],
    procedure begin
      {$IF DEFINED(IOS) or DEFINED(ANDROID)}
        tpLibrary.Execute;
      {$ELSE}
        OD.Filter := 'Image Files (*.jpg)|*.jpg;*.jpeg;*.bmp;*.png';
        OD.FileName := '';
        OD.Execute;
        if OD.FileName = '' then
          Exit;

        Image2.Bitmap.LoadFromFile(OD.FileName);
      {$ENDIF}
    end);
  end else begin
    HelperPermission.setPermission([
      getPermission.READ_EXTERNAL_STORAGE,
      getPermission.WRITE_EXTERNAL_STORAGE
    ],
    procedure begin
      {$IF DEFINED(IOS) or DEFINED(ANDROID)}
        tpLibrary.Execute;
      {$ELSE}
        OD.Filter := 'Image Files (*.jpg)|*.jpg;*.jpeg;*.bmp;*.png';
        OD.FileName := '';
        OD.Execute;
        if OD.FileName = '' then
          Exit;

        Image2.Bitmap.LoadFromFile(OD.FileName);
      {$ENDIF}
    end);
  end;
end;

procedure TFHome.CornerButton6Click(Sender: TObject);
begin
  if not Assigned(FNotification) then begin
    Helper.ShowToastMessage('Please remove comment on BFA.Init -> InitFunction -> InitPushNotification && Event OnShow frMain');
    Exit;
  end;

  Memo1.Lines.Add('Device ID : ' + sLineBreak + FNotification.DeviceID);
  Memo1.Lines.Add('');
  Memo1.Lines.Add('');
  Memo1.Lines.Add('');
  Memo1.Lines.Add('Device Token : ' + sLineBreak + FNotification.DeviceToken);
end;

procedure TFHome.CornerButton7Click(Sender: TObject);
begin
  HelperPermission.setPermission([
    getPermission.BODY_SENSORS
  ],
  procedure begin
    Memo2.Lines.Add('"BODY_SENSORS" Access granted');
  end);
end;

procedure TFHome.CornerButton8Click(Sender: TObject);
begin
  {$IF DEFINED(IOS) or DEFINED(ANDROID)}
  var OSVersion := StrToIntDef(JStringToString(TJBuild_VERSION.JavaClass.RELEASE), 10);
  {$ELSE}
  var OSVersion := 10;
  {$ENDIF}

  if OSVersion >= 13 then begin
    HelperPermission.setPermission([
      getPermission.CAMERA
    ],
    procedure begin
      {$IF DEFINED(IOS) or DEFINED(ANDROID)}
        tpCamera.Execute;
      {$ELSE}
        OD.Filter := 'Image Files (*.jpg)|*.jpg;*.jpeg;*.bmp;*.png';
        OD.FileName := '';
        OD.Execute;
        if OD.FileName = '' then
          Exit;

        Image1.Bitmap.LoadFromFile(OD.FileName);
      {$ENDIF}
    end);
  end else begin
    HelperPermission.setPermission([
      getPermission.READ_EXTERNAL_STORAGE,
      getPermission.WRITE_EXTERNAL_STORAGE,
      getPermission.CAMERA
    ],
    procedure begin
      {$IF DEFINED(IOS) or DEFINED(ANDROID)}
        tpCamera.Execute;
      {$ELSE}
        OD.Filter := 'Image Files (*.jpg)|*.jpg;*.jpeg;*.bmp;*.png';
        OD.FileName := '';
        OD.Execute;
        if OD.FileName = '' then
          Exit;

        Image1.Bitmap.LoadFromFile(OD.FileName);
      {$ENDIF}
    end);
  end;
end;

procedure TFHome.CornerButton9Click(Sender: TObject);
begin
  Helper.ShowToastMessage('This is message Success', TTypeMessage.Success);
end;

constructor TFHome.Create(AOwner: TComponent);
begin
  inherited;

end;

procedure TFHome.lblTitleClick(Sender: TObject);
begin
  var ACalender := TFCalender.Create(Self);
  ACalender.Parent := Self;
  ACalender.Align := TAlignLayout.Contents;
end;

procedure TFHome.lbMenuItemClick(const Sender: TCustomListBox;
  const Item: TListBoxItem);
begin
  tcMain.TabIndex := Item.Tag;
  lblTitle.Text := Item.ItemData.Detail;
  btnBack.ImageIndex := 2;
end;

procedure TFHome.Show;
begin
  if Frame.FrameAliasBefore = C_FAVORITE then Exit;

  FSidebar.SetSelectedMenu(C_HOME);
  tcMain.TabIndex := 0;
  btnBack.ImageIndex := 1;

  lblTitle.Text := 'Menu Home';

  FSidebar.MultiView.Enabled := True;
end;

procedure TFHome.tpCameraDidFinishTaking(Image: TBitmap);
begin
  Image1.Bitmap.Assign(Image);
end;

procedure TFHome.tpLibraryDidFinishTaking(Image: TBitmap);
begin
  Image2.Bitmap.Assign(Image);
end;

end.
