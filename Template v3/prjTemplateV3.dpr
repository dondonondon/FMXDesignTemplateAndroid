program prjTemplateV3;

uses
  System.StartUpCopy,
  FMX.Forms,
  frMain in 'frMain.pas' {FMain},
  BFA.Keyboard in 'sources\helper\BFA.Keyboard.pas',
  BFA.Frame in 'sources\helper\BFA.Frame.pas',
  frLoading in 'frames\frLoading.pas' {FLoading: TFrame},
  frLogin in 'frames\frLogin.pas' {FLogin: TFrame},
  BFA.PushNotification in 'sources\helper\BFA.PushNotification.pas',
  BFA.Permission in 'sources\helper\BFA.Permission.pas',
  BFA.Form.Message in 'sources\helper\BFA.Form.Message.pas',
  frHome in 'frames\frHome.pas' {FHome: TFrame};

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;

  Application.Initialize;
  Application.CreateForm(TFMain, FMain);
  Application.Run;

end.
