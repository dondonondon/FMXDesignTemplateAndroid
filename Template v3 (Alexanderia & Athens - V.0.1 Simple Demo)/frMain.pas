unit frMain;

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
  BFA.Global.Variable, BFA.Helper.Main, BFA.Control.PushNotification,
  FMX.MultiView
  {$IF DEFINED (ANDROID)}
  , Androidapi.Helpers, Androidapi.JNI.Os, Androidapi.JNI.JavaTypes
  {$ENDIF}
  ;

type
  TFMain = class(TForm)
    loMain: TLayout;
    vsMain: TVertScrollBox;
    loFrame: TLayout;
    SB: TStyleBook;
    loTest: TLayout;
    loSidebar: TLayout;
    mvMain: TMultiView;
    memAnnounce: TMemo;
    procedure FormShow(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private

  public

    function AppEventProc(AAppEvent: TApplicationEvent;
      AContext: TObject): Boolean;

  end;

var
  FMain: TFMain;

implementation

{$R *.fmx}

uses
  frHome, frLoading, frLogin, BFA.Control.Permission, BFA.Init

  {, frListMenu};

function TFMain.AppEventProc(AAppEvent: TApplicationEvent;
  AContext: TObject): Boolean;
begin
//  FNotification.AppEventProc(AAppEvent, AContext);
  if (AAppEvent = TApplicationEvent.BecameActive) then begin
    //your code here
  end;
end;

procedure TFMain.FormCreate(Sender: TObject);
begin
  TInitControls.InitFunction;

  memAnnounce.DisposeOf;
end;

procedure TFMain.FormDestroy(Sender: TObject);
begin
  TInitControls.ReleaseVariable;
end;

procedure TFMain.FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
  Shift: TShiftState);
var
  Routine : TMethod;
  Exec : TExec;
  LFrame : TControl;
  FService: IFMXVirtualKeyboardService;
begin
  if (Key = vkHardwareBack) or (Key = vkEscape) then begin {if you type esc on keyboard, frame execute "Back" Procedure on Published inside TFrame}
    TPlatformServices.Current.SupportsPlatformService(IFMXVirtualKeyboardService, IInterface(FService));
    if (FService <> nil) and (TVirtualKeyboardState.Visible in FService.VirtualKeyBoardState) then begin
      FService.HideVirtualKeyboard;
      FKeyboard.HideKeyboard;
    end else begin
      FKeyboard.HideKeyboard;
      Key := 0;

      if Assigned(FSidebar) then begin
        if Assigned(FSidebar.MultiView) then begin
          if FSidebar.MultiView.IsShowed then begin
            FSidebar.MultiView.HideMaster;
            Exit;
          end;
        end;
      end;

      if Assigned(Helper) then begin
        if Helper.StateLoading then begin
          Helper.ShowToastMessage('Still loading');
          Exit;
        end else if Helper.StatePopup then begin
          Helper.ClosePopup;
          Exit;
        end;
      end;

      if Assigned(Frame.LastControl) then begin
        LFrame := Frame.LastControl;
        Routine.Data := Pointer(LFrame);
        Routine.Code := LFrame.MethodAddress('Back');

        if not Assigned(Routine.Code) then
          Exit;

        Exec := TExec(Routine);
        Exec;
      end;
    end;
  end else begin
    FKeyboard.KeyUp(Key, KeyChar, Shift);
  end;
end;

procedure TFMain.FormShow(Sender: TObject);
begin
//  FNotification.ServiceConnectionStatus(True); //uncomment this if you want uses Push Notification from firebase
  Frame.GoFrame(View.LOADING);
end;

end.


