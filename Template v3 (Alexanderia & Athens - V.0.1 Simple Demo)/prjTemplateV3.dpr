program prjTemplateV3;

uses
  System.StartUpCopy,
  FMX.Forms,
  FMX.Skia,
  frMain in 'frMain.pas' {FMain},
  frLoading in 'frames\frLoading.pas' {FLoading: TFrame},
  frHome in 'frames\frHome.pas' {FHome: TFrame},
  uDM in 'uDM.pas' {DM: TDataModule},
  BFA.Global.Variable in 'sources\BFA.Global.Variable.pas',
  BFA.Global.Func in 'sources\BFA.Global.Func.pas',
  BFA.Control.Form.Message in 'sources\controls\BFA.Control.Form.Message.pas',
  BFA.Control.Frame in 'sources\controls\BFA.Control.Frame.pas',
  BFA.Control.Keyboard in 'sources\controls\BFA.Control.Keyboard.pas',
  BFA.Control.Permission in 'sources\controls\BFA.Control.Permission.pas',
  BFA.Control.PushNotification in 'sources\controls\BFA.Control.PushNotification.pas',
  BFA.Helper.Main in 'sources\helpers\BFA.Helper.Main.pas',
  BFA.Helper.TFDMemTable in 'sources\helpers\BFA.Helper.TFDMemTable.pas',
  BFA.Init in 'sources\BFA.Init.pas',
  frAccount in 'frames\frAccount.pas' {FAccount: TFrame},
  frFavorite in 'frames\frFavorite.pas' {FFavorite: TFrame},
  frDetail in 'frames\frDetail.pas' {FDetail: TFrame},
  frLogin in 'frames\frLogin.pas' {FLogin: TFrame},
  frTemp in 'frames\frTemp.pas' {FTemp: TFrame};

//  {$IF DEFINED (ANDROID)}
//  FMX.MediaLibrary.Android in 'sources\libraries\FMX.MediaLibrary.Android.pas',
//  {$ENDIF }

{$R *.res}

begin
  GlobalUseSkia := True;
  ReportMemoryLeaksOnShutdown := True;

  Application.Initialize;
  Application.CreateForm(TFMain, FMain);
  Application.CreateForm(TDM, DM);
  Application.Run;

end.
