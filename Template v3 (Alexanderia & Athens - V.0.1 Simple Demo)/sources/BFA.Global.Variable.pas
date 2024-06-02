unit BFA.Global.Variable;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Controls.Presentation, FMX.InertialMovement, BFA.Control.Keyboard, FMX.Platform,
  FMX.Edit, FMX.VirtualKeyboard, FMX.StdCtrls, BFA.Control.Frame,
  FMX.Memo.Types, FMX.ScrollBox, FMX.Memo, BFA.Control.Form.Message, System.Rtti,
  FMX.Grid.Style, FMX.Grid, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  Data.Bind.EngExt, Fmx.Bind.DBEngExt, Fmx.Bind.Grid, System.Bindings.Outputs,
  Fmx.Bind.Editors, Data.Bind.Components, Data.Bind.Grid, Data.Bind.DBScope,
  BFA.Helper.TFDMemTable, BFA.Global.Func,
  BFA.Helper.Main, BFA.Control.PushNotification, frListMenu
  {$IF DEFINED(IOS) or DEFINED(ANDROID)}
   ,AndroidApi.JNI.GraphicsContentViewText, AndroidApi.JNI.OS, AndroidApi.Helpers, AndroidApi.JNI.Net,
  AndroidApi.JNI.JavaTypes, AndroidApi.JNIBridge, AndroidApi.JNI.Provider, AndroidApi.JNI.Telephony,
  FMX.PhoneDialer, FMX.PhoneDialer.Android, FMX.Platform.Android,
  AndroidApi.JNI.Java.Net,
  AndroidApi.JNI.Android.Security
  {$ENDIF}
  ;

const
  C_HOME = 'HOME';
  C_LOADING = 'LOADING';
  C_LOGIN = 'LOGIN';
  C_ACCOUNT = 'ACCOUNT';
  C_FAVORITE = 'FAVORITE';
  C_DETAIL = 'DETAIL';

  C_SUBMENU = 'SUBMENU';

  C_DASHBOARD = 'DASHBOARD';
  C_ORDER = 'ORDER';
  C_PAYMENT = 'PAYMENT';
  C_RECORD = 'RECORD';
  C_HELP = 'HELP';
  C_REPORT = 'REPORT';
  C_INVENTORY = 'INVENTORY';

var
  FNotification : TPushNotif;
  FKeyboard : TKeyboardShow;

  Frame : TGoFrame;
  Helper : TMainHelper;
  FSidebar : TFListMenu;

implementation

end.
