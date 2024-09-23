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
  BFA.Helper.MemoryTable, BFA.Global.Func,
  BFA.Helper.Main, BFA.Control.PushNotification
  {$IF DEFINED(IOS) or DEFINED(ANDROID)}
   ,AndroidApi.JNI.GraphicsContentViewText, AndroidApi.JNI.OS, AndroidApi.Helpers, AndroidApi.JNI.Net,
  AndroidApi.JNI.JavaTypes, AndroidApi.JNIBridge, AndroidApi.JNI.Provider, AndroidApi.JNI.Telephony,
  FMX.PhoneDialer, FMX.PhoneDialer.Android, FMX.Platform.Android,
  AndroidApi.JNI.Java.Net,
  AndroidApi.JNI.Android.Security
  {$ENDIF}

  {$REGION 'ADD FRAME SIDEBAR'}
  , frListMenu
  {$ENDREGION}
  ;

type
  View = class
    const
      HOME = 'HOME';
      LOADING = 'LOADING';
      LOGIN = 'LOGIN';
      ACCOUNT = 'ACCOUNT';
      FAVORITE = 'FAVORITE';
      DETAIL = 'DETAIL';


      {$REGION 'ADD FRAME SIDEBAR'}   //just remove this code / add comment if you don't want use sidebar

      SUBMENU = 'SUBMENU';
      DASHBOARD = 'DASHBOARD';
      ORDER = 'ORDER';
      PAYMENT = 'PAYMENT';
      RECORDDATA = 'RECORD';
      HELP = 'HELP';
      REPORT = 'REPORT';
      INVENTORY = 'INVENTORY';
      SAMPLE = 'SAMPLE';

      {$ENDREGION}
  end;

var
  FNotification : TPushNotif;
  FKeyboard : TKeyboardShow;

  Frame : TGoFrame;
  Helper : TMainHelper;

  {$REGION 'ADD FRAME SIDEBAR'}
  FSidebar : TFListMenu;
  {$ENDREGION}

implementation

end.
