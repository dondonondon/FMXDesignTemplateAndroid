program prjTemplate;

uses
  System.StartUpCopy,
  FMX.Forms,
  frMain in 'frMain.pas' {FMain},
  frHome in 'frames\frHome.pas' {FHome: TFrame},
  frLogin in 'frames\frLogin.pas' {FLogin: TFrame},
  frDetail in 'frames\frDetail.pas' {FDetail: TFrame},
  frLoading in 'frames\frLoading.pas' {FLoading: TFrame},
  BFA.Env in 'sources\BFA.Env.pas',
  BFA.Func in 'sources\BFA.Func.pas',
  BFA.GoFrame in 'sources\BFA.GoFrame.pas',
  BFA.Helper.Main in 'sources\BFA.Helper.Main.pas',
  BFA.Helper.MemTable in 'sources\BFA.Helper.MemTable.pas',
  BFA.Main in 'sources\BFA.Main.pas',
  BFA.OpenUrl in 'sources\BFA.OpenUrl.pas',
  BFA.Rest in 'sources\BFA.Rest.pas',
  uFontSetting in 'sources\uFontSetting.pas',
  uDM in 'uDM.pas' {DM: TDataModule},
  BFA.Helper.Control in 'sources\BFA.Helper.Control.pas',
  frAccount in 'frames\frAccount.pas' {FAccount: TFrame},
  frTemp in 'frames\frTemp.pas' {FTemp: TFrame};

{$R *.res}

begin
  //ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.CreateForm(TFMain, FMain);
  Application.CreateForm(TDM, DM);
  Application.Run;
end.
