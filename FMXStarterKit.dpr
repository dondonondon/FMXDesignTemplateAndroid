{*******************************************************************************
  Copyright (c) 2026 Fajar Donny Bachtiar (Blangkon FA)
  Licensed under the Apache License, Version 2.0.
  See the LICENSE file in the project root for license details.
*******************************************************************************}

program FMXStarterKit;

uses
  System.StartUpCopy,
  FMX.Forms,
  frMain in 'frMain.pas' {Form3},
  frDetail in 'frames\frDetail.pas' {FDetail: TFrame},
  frLoading in 'frames\frLoading.pas' {FLoading: TFrame},
  frLogin in 'frames\frLogin.pas' {FLogin: TFrame},
  frTemp in 'frames\frTemp.pas' {FTemp: TFrame},
  BFA.App.Types in 'sources\app\BFA.App.Types.pas',
  BFA.App.Services in 'sources\app\BFA.App.Services.pas',
  BFA.App.Context in 'sources\app\BFA.App.Context.pas',
  BFA.Resource.Message in 'sources\resources\BFA.Resource.Message.pas',
  BFA.Exception.Base in 'sources\exceptions\BFA.Exception.Base.pas',
  BFA.Control.Frame in 'sources\controls\BFA.Control.Frame.pas',
  BFA.Control.Form.Message in 'sources\controls\BFA.Control.Form.Message.pas',
  BFA.Control.Keyboard in 'sources\controls\BFA.Control.Keyboard.pas',
  BFA.Control.Permission in 'sources\controls\BFA.Control.Permission.pas',
  BFA.Control.PushNotification in 'sources\controls\BFA.Control.PushNotification.pas',
  BFA.Helper.Main in 'sources\helpers\BFA.Helper.Main.pas',
  BFA.Helper.Bitmap in 'sources\helpers\BFA.Helper.Bitmap.pas',
  BFA.Helper.Dataset in 'sources\helpers\BFA.Helper.Dataset.pas',
  BFA.Helper.APIRequest in 'sources\helpers\BFA.Helper.APIRequest.pas',
  BFA.Helper.OpenURL in 'sources\helpers\BFA.Helper.OpenURL.pas',
  BFA.Android.SAF.Modern in 'sources\helpers\SAF\BFA.Android.SAF.Modern.pas',
  BFA.iOS.SAF.Modern in 'sources\helpers\SAF\BFA.iOS.SAF.Modern.pas',
  BFA.Helper.SAF in 'sources\helpers\BFA.Helper.SAF.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;

  Application.Initialize;
  Application.CreateForm(TFMain, FMain);
  Application.Run;
end.
