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
  frListMenu in 'frames\controls\frListMenu.pas' {FListMenu: TFrame},
  frAccount in 'frames\frAccount.pas' {FAccount: TFrame},
  frDashboard in 'frames\frDashboard.pas' {FDashboard: TFrame},
  frDetail in 'frames\frDetail.pas' {FDetail: TFrame},
  frFavorite in 'frames\frFavorite.pas' {FFavorite: TFrame},
  frHelp in 'frames\frHelp.pas' {FHelp: TFrame},
  frHome in 'frames\frHome.pas' {FHome: TFrame},
  frInventory in 'frames\frInventory.pas' {FInventory: TFrame},
  frLoading in 'frames\frLoading.pas' {FLoading: TFrame},
  frLogin in 'frames\frLogin.pas' {FLogin: TFrame},
  frOrder in 'frames\frOrder.pas' {FOrder: TFrame},
  frPayment in 'frames\frPayment.pas' {FPayment: TFrame},
  frRecord in 'frames\frRecord.pas' {FRecord: TFrame},
  frReport in 'frames\frReport.pas' {FReport: TFrame},
  frSubMenuTemp in 'frames\frSubMenuTemp.pas' {FSubMenuTemp: TFrame},
  frTemp in 'frames\frTemp.pas' {FTemp: TFrame},
  frCalender in 'frames\controls\frCalender.pas' {FCalender: TFrame},
  BFA.Helper.Bitmap in 'sources\helpers\BFA.Helper.Bitmap.pas',
  BFA.Log in 'sources\helpers\BFA.Log.pas',
  BFA.OpenUrl in 'sources\helpers\BFA.OpenUrl.pas',
  BFA.Helper.OpenDialog in 'sources\helpers\BFA.Helper.OpenDialog.pas';

//  {$IF DEFINED (ANDROID)}
//  FMX.MediaLibrary.Android in 'sources\libraries\FMX.MediaLibrary.Android.pas',
//  {$ENDIF }

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;

  Application.Initialize;
  Application.CreateForm(TFMain, FMain);
  Application.CreateForm(TDM, DM);
  Application.Run;

end.
