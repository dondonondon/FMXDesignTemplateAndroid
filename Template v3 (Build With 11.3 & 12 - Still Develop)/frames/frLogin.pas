unit frLogin;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects, FMX.Layouts, System.Threading,
  FMX.Effects, FMX.Edit, FMX.MediaLibrary.Actions, FMX.StdActns, System.Actions,
  FMX.ActnList, FMX.TabControl, FMX.MediaLibrary, BFA.Control.Form.Message
  {$IF DEFINED (ANDROID)}
  , Androidapi.Helpers, Androidapi.JNI.Os, Androidapi.JNI.JavaTypes
  {$ENDIF}
  ;

type
  TFLogin = class(TFrame)
    background: TRectangle;
    loMain: TLayout;
    Rectangle1: TRectangle;
    btnBack: TCornerButton;
    Label1: TLabel;
    Label2: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    btnMasuk: TCornerButton;
    seMain: TShadowEffect;
    AL: TActionList;
    cta0: TChangeTabAction;
    cta1: TChangeTabAction;
    cta2: TChangeTabAction;
    tpLibrary: TTakePhotoFromLibraryAction;
    tpCamera: TTakePhotoFromCameraAction;
    OD: TOpenDialog;
    Image1: TImage;
    procedure btnMasukClick(Sender: TObject);
    procedure tpLibraryDidFinishTaking(Image: TBitmap);
  private
  public
  published
    procedure Show;
    procedure Back;

    constructor Create(AOwner : TComponent); override;
  end;

var
  FLogin: TFLogin;

implementation

{$R *.fmx}

uses frMain;


{ TFLogin }

procedure TFLogin.Back;
begin
  FMain.Frame.Back;
//  if FMain.Frame.Back then Application.Terminate;
end;

procedure TFLogin.btnMasukClick(Sender: TObject);
begin
//  {$IF DEFINED(IOS) or DEFINED(ANDROID)}
//  var OSVersion := StrToIntDef(JStringToString(TJBuild_VERSION.JavaClass.RELEASE), 10);
//  {$ELSE}
//  var OSVersion := 10;
//  {$ENDIF}
//
//  if OSVersion >= 13 then begin
//    HelperPermission.setPermission([
//      getPermission.READ_MEDIA_IMAGES,
//      getPermission.READ_MEDIA_VIDEO,
//      getPermission.READ_MEDIA_AUDIO,
//      getPermission.CAMERA
//    ],
//    procedure begin
//      {$IF DEFINED(IOS) or DEFINED(ANDROID)}
//        tpCamera.Execute;
//      {$ELSE}
//        OD.Filter := 'Image Files (*.jpg)|*.jpg;*.jpeg;*.bmp;*.png';
//        OD.FileName := '';
//        OD.Execute;
//        if OD.FileName = '' then
//          Exit;
//
//        Image1.Bitmap.LoadFromFile(OD.FileName);
//      {$ENDIF}
//    end);
//  end else begin
//    HelperPermission.setPermission([
//      getPermission.READ_EXTERNAL_STORAGE,
//      getPermission.WRITE_EXTERNAL_STORAGE,
//      getPermission.CAMERA
//    ],
//    procedure begin
//      {$IF DEFINED(IOS) or DEFINED(ANDROID)}
//        tpCamera.Execute;
//      {$ELSE}
//        OD.Filter := 'Image Files (*.jpg)|*.jpg;*.jpeg;*.bmp;*.png';
//        OD.FileName := '';
//        OD.Execute;
//        if OD.FileName = '' then
//          Exit;
//
//        Image1.Bitmap.LoadFromFile(OD.FileName);
//      {$ENDIF}
//    end);
//  end;

  FMain.Frame.GoFrame('HOME');
end;

constructor TFLogin.Create(AOwner: TComponent);
begin
  inherited;

end;

procedure TFLogin.Show;
begin

end;

procedure TFLogin.tpLibraryDidFinishTaking(Image: TBitmap);
begin
  Image1.Bitmap.Assign(Image);
end;

end.

