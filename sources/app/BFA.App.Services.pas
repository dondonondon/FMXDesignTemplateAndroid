{*******************************************************************************
  Copyright (c) 2026 Fajar Donny Bachtiar (Blangkon FA)
  Licensed under the Apache License, Version 2.0.
  See the LICENSE file in the project root for license details.
*******************************************************************************}

unit BFA.App.Services;

interface

uses
  System.SysUtils,
  FMX.Forms, FMX.Layouts,
  BFA.App.Types,
  BFA.Control.Keyboard,
  BFA.Control.Frame,
  BFA.Control.Form.Message,
  BFA.Control.PushNotification,
  BFA.Helper.SAF;

type
  TAppServices = class
  private
    FForm: TForm;
    FKeyboard: TKeyboardShow;
    FLayout: TLayout;
    FMainHelper: TMainHelper;
    FPushNotification: TPushNotificationService;
    FRouter: TFrameRouter;
    FSAF: TBFASAF;
    FVertScroll: TVertScrollBox;

    procedure ConfigureContext(AForm: TForm; AVertScroll: TVertScrollBox;
      ALayout: TLayout);
    function BuildLocalSAFFilePath(const AUri: string): string;
    procedure InitFrame;
    procedure InitKeyboard(AAutoSetEvent: Boolean);
    procedure InitPushNotification;
    procedure InitSAF;
    procedure InitSidebar;
    procedure InitToastMessage;
    procedure ReleaseKeyboard;
    procedure ReleaseMainHelper;
    procedure ReleasePushNotification;
    procedure ReleaseRouter;
    procedure ReleaseSAF;
    procedure SAFError(Sender: TObject; const AMessage: string);
    procedure SAFFilePicked(Sender: TObject; const AUri: string);
    procedure SAFFolderPicked(Sender: TObject; const AUri: string);
    procedure SAFSaveAsPicked(Sender: TObject; const AUri: string);
    procedure SAFCancel(Sender: TObject; APickMode: TBFASAFPickMode);
    procedure ShowSAFMessage(const AMessage: string;
      AMessageType: TTypeMessage = TTypeMessage.Information);
  public
    destructor Destroy; override;

    procedure Initialize(AForm: TForm; AVertScroll: TVertScrollBox;
      ALayout: TLayout; AAutoSetEvent: Boolean = True);

    property Keyboard: TKeyboardShow read FKeyboard;
    property MainHelper: TMainHelper read FMainHelper;
    property PushNotification: TPushNotificationService read FPushNotification;
    property Router: TFrameRouter read FRouter;
    property SAF: TBFASAF read FSAF;
  end;

implementation

uses
  System.IOUtils,
  frDetail, frLoading, frLogin;

{ TAppServices }

function TAppServices.BuildLocalSAFFilePath(const AUri: string): string;
var
  LFileName: string;
begin
  LFileName := '';

  if Assigned(FSAF) then begin
    LFileName := FSAF.GetDisplayName(AUri).Trim;
  end;

  if LFileName.IsEmpty then begin
    LFileName := 'file_' + TGUID.NewGuid.ToString.Replace('{', '').Replace('}', '');
  end;

  Result := TPath.Combine(TPath.GetDocumentsPath, LFileName);
end;

procedure TAppServices.ConfigureContext(AForm: TForm;
  AVertScroll: TVertScrollBox; ALayout: TLayout);
begin
  if not Assigned(AForm) then
    raise EArgumentNilException.Create('Main form is required.');

  if not Assigned(AVertScroll) then
    raise EArgumentNilException.Create('Main scroll container is required.');

  if not Assigned(ALayout) then
    raise EArgumentNilException.Create('Main frame layout is required.');

  FForm := AForm;
  FVertScroll := AVertScroll;
  FLayout := ALayout;
end;

destructor TAppServices.Destroy;
begin
  ReleaseSAF;
  ReleasePushNotification;
  ReleaseKeyboard;
  ReleaseMainHelper;
  ReleaseRouter;
  inherited;
end;

procedure TAppServices.Initialize(AForm: TForm; AVertScroll: TVertScrollBox;
  ALayout: TLayout; AAutoSetEvent: Boolean);
begin
  ConfigureContext(AForm, AVertScroll, ALayout);

  InitKeyboard(AAutoSetEvent);
  InitToastMessage;
  InitFrame;
  InitSidebar;
  InitPushNotification;
  InitSAF;

  if Assigned(FRouter) then
    FRouter.NavigateTo(TView.LOADING);
end;

procedure TAppServices.InitFrame;
begin
  ReleaseRouter;

  FRouter := TFrameRouter.Create(nil);
  FRouter.Container := FLayout;
  FRouter.RegisterFrame(TFLogin, TView.LOGIN);
  FRouter.RegisterFrame(TFDetail, TView.DETAIL);
  FRouter.RegisterFrame(TFLoading, TView.LOADING);
end;

procedure TAppServices.InitKeyboard(AAutoSetEvent: Boolean);
begin
  ReleaseKeyboard;
  FKeyboard := TKeyboardShow.Create(FForm, FVertScroll, FLayout, AAutoSetEvent);
end;

procedure TAppServices.InitPushNotification;
begin
  ReleasePushNotification;

  {$IF DEFINED(ANDROID) OR DEFINED(IOS)}
  FPushNotification := TPushNotificationService.Create;
  if Assigned(FPushNotification) and FPushNotification.IsSupported then begin
    FPushNotification.ServiceConnectionStatus(True);
  end;
  {$ENDIF}
end;

procedure TAppServices.InitSAF;
begin
  ReleaseSAF;

  FSAF := TBFASAF.Create;
  FSAF.OnFilePicked := SAFFilePicked;
  FSAF.OnFolderPicked := SAFFolderPicked;
  FSAF.OnSaveAsPicked := SAFSaveAsPicked;
  FSAF.OnError := SAFError;
  FSAF.OnCancel := SAFCancel;
end;

procedure TAppServices.InitSidebar;
begin
end;

procedure TAppServices.InitToastMessage;
begin
  ReleaseMainHelper;
  FMainHelper := TMainHelper.Create(FForm);
end;

procedure TAppServices.ReleaseKeyboard;
begin
  FreeAndNil(FKeyboard);
end;

procedure TAppServices.ReleaseMainHelper;
begin
  FreeAndNil(FMainHelper);
end;

procedure TAppServices.ReleasePushNotification;
begin
  FreeAndNil(FPushNotification);
end;

procedure TAppServices.ReleaseRouter;
begin
  FreeAndNil(FRouter);
end;

procedure TAppServices.ReleaseSAF;
begin
  FreeAndNil(FSAF);
end;

procedure TAppServices.SAFError(Sender: TObject; const AMessage: string);
begin
  ShowSAFMessage(AMessage, TTypeMessage.Error);
end;

procedure TAppServices.SAFFilePicked(Sender: TObject; const AUri: string);
var
  LTargetPath: string;
begin
  if not Assigned(FSAF) then exit;

  LTargetPath := BuildLocalSAFFilePath(AUri);
  if FSAF.CopyToLocalFile(AUri, LTargetPath) then begin
    ShowSAFMessage('File tersimpan ke: ' + LTargetPath);
  end else begin
    ShowSAFMessage('Gagal copy file.', TTypeMessage.Error);
  end;
end;

procedure TAppServices.SAFFolderPicked(Sender: TObject; const AUri: string);
begin
  ShowSAFMessage('Folder dipilih: ' + AUri);
end;

procedure TAppServices.SAFSaveAsPicked(Sender: TObject; const AUri: string);
begin
  ShowSAFMessage('File berhasil dibuat: ' + AUri);
end;

procedure TAppServices.SAFCancel(Sender: TObject; APickMode: TBFASAFPickMode);
begin
  case APickMode of
    TBFASAFPickMode.safPickFile:
      ShowSAFMessage('Pilih file dibatalkan.');
    TBFASAFPickMode.safPickFolder:
      ShowSAFMessage('Pilih folder dibatalkan.');
    TBFASAFPickMode.safSaveAs:
      ShowSAFMessage('Simpan file dibatalkan.');
  end;
end;

procedure TAppServices.ShowSAFMessage(const AMessage: string;
  AMessageType: TTypeMessage);
begin
  if Assigned(FMainHelper) then begin
    FMainHelper.ShowToastMessage(AMessage, AMessageType);
  end;
end;

end.
