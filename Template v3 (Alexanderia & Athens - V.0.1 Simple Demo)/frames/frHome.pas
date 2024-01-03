unit frHome;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects, FMX.Layouts, System.Threading,
  FMX.Effects, FMX.Edit, FMX.MediaLibrary.Actions, FMX.StdActns, System.Actions,
  FMX.ActnList, FMX.TabControl, FMX.MediaLibrary, FMX.Memo.Types, FMX.ScrollBox,
  FMX.Memo, FMX.ListBox
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

implementation

{$R *.fmx}

uses frMain, BFA.Global.Variable,
  BFA.Control.Form.Message, BFA.Control.Frame, BFA.Control.Keyboard,
  BFA.Control.Permission, BFA.Control.PushNotification, BFA.Global.Func,
  BFA.Helper.Main, BFA.Helper.TFDMemTable;

procedure TFHome.Back;
begin
  if tcMain.TabIndex <> 0 then begin
    tcMain.TabIndex := 0;
    lblTitle.Text := 'Menu Home';
  end else begin
    Frame.Back;
  end;
end;

procedure TFHome.btnBackClick(Sender: TObject);
begin
  Back;
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

procedure TFHome.lbMenuItemClick(const Sender: TCustomListBox;
  const Item: TListBoxItem);
begin
  tcMain.TabIndex := Item.Tag;
  lblTitle.Text := Item.ItemData.Detail;
end;

procedure TFHome.Show;
begin
  tcMain.TabIndex := 0;
  lblTitle.Text := 'Menu Home';
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
