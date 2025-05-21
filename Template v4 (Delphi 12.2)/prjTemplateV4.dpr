program prjTemplateV4;

uses
  System.StartUpCopy,
  FMX.Forms,
  frMain in 'frMain.pas' {Form3},
  frDetail in 'frames\frDetail.pas' {FDetail: TFrame},
  frLoading in 'frames\frLoading.pas' {FLoading: TFrame},
  frLogin in 'frames\frLogin.pas' {FLogin: TFrame},
  frTemp in 'frames\frTemp.pas' {FTemp: TFrame},
  BFA.Control.Frame.Old in 'sources\controls\BFA.Control.Frame.Old.pas',
  BFA.Control.Frame in 'sources\controls\BFA.Control.Frame.pas',
  BFA.Resource.Message in 'sources\resources\BFA.Resource.Message.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;

  Application.Initialize;
  Application.CreateForm(TFMain, FMain);
  Application.Run;
end.
