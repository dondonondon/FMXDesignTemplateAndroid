program prjTemplateV3;

{$R *.dres}

uses
  System.StartUpCopy,
  FMX.Forms,
  frMain in 'frMain.pas' {FMain},
  uDM in 'uDM.pas' {DM: TDataModule},
  BFA.Global.Variable in 'sources\BFA.Global.Variable.pas',
  BFA.Global.Func in 'sources\BFA.Global.Func.pas',
  BFA.Control.Form.Message in 'sources\controls\BFA.Control.Form.Message.pas',
  BFA.Control.Frame in 'sources\controls\BFA.Control.Frame.pas',
  BFA.Control.Keyboard in 'sources\controls\BFA.Control.Keyboard.pas',
  BFA.Control.Permission in 'sources\controls\BFA.Control.Permission.pas',
  BFA.Control.PushNotification in 'sources\controls\BFA.Control.PushNotification.pas',
  BFA.Helper.Main in 'sources\helpers\BFA.Helper.Main.pas',
  BFA.Helper.MemoryTable in 'sources\helpers\BFA.Helper.MemoryTable.pas',
  BFA.Init in 'sources\BFA.Init.pas',
  BFA.Control.Rest in 'sources\controls\BFA.Control.Rest.pas',
  frAccount in 'frames\frAccount.pas' {FAccount: TFrame},
  frDetail in 'frames\frDetail.pas' {FDetail: TFrame},
  frFavorite in 'frames\frFavorite.pas' {FFavorite: TFrame},
  frHome in 'frames\frHome.pas' {FHome: TFrame},
  frLoading in 'frames\frLoading.pas' {FLoading: TFrame},
  frLogin in 'frames\frLogin.pas' {FLogin: TFrame},
  frCalender in 'frames\controls\frCalender.pas' {FCalender: TFrame},
  BFA.Helper.Bitmap in 'sources\helpers\BFA.Helper.Bitmap.pas',
  BFA.Log in 'sources\helpers\BFA.Log.pas',
  BFA.OpenUrl in 'sources\helpers\BFA.OpenUrl.pas',
  BFA.Helper.OpenDialog in 'sources\helpers\BFA.Helper.OpenDialog.pas',
  frDashboard in 'frames\sidebar\frDashboard.pas' {FDashboard: TFrame},
  frHelp in 'frames\sidebar\frHelp.pas' {FHelp: TFrame},
  frInventory in 'frames\sidebar\frInventory.pas' {FInventory: TFrame},
  frOrder in 'frames\sidebar\frOrder.pas' {FOrder: TFrame},
  frPayment in 'frames\sidebar\frPayment.pas' {FPayment: TFrame},
  frRecord in 'frames\sidebar\frRecord.pas' {FRecord: TFrame},
  frReport in 'frames\sidebar\frReport.pas' {FReport: TFrame},
  frSample in 'frames\sidebar\frSample.pas' {FSample: TFrame},
  frSubMenuTemp in 'frames\sidebar\frSubMenuTemp.pas' {FSubMenuTemp: TFrame},
  frListMenu in 'frames\controls\frListMenu.pas' {FListMenu: TFrame},
  frConfirmation in 'frames\controls\frConfirmation.pas' {FConfirmation: TFrame};

// {$IF DEFINED (ANDROID)}
// FMX.MediaLibrary.Android in 'sources\libraries\FMX.MediaLibrary.Android.pas',
// {$ENDIF }

{$R *.res}

begin
  // GlobalUseSkia := True;
  ReportMemoryLeaksOnShutdown := True;

  Application.Initialize;
  Application.CreateForm(TFMain, FMain);
  Application.CreateForm(TDM, DM);
  Application.Run;

end.
