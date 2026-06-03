{*******************************************************************************
  Copyright (c) 2026 Fajar Donny Bachtiar (Blangkon FA)
  Licensed under the Apache License, Version 2.0.
  See the LICENSE file in the project root for license details.
*******************************************************************************}

unit BFA.App.Services;

interface

uses
  System.Classes,
  System.SysUtils,
  FMX.Forms, FMX.Layouts, FMX.MultiView, FMX.Types,
  BFA.App.Types,
  BFA.Control.Keyboard,
  BFA.Control.Frame,
  BFA.Control.Form.Message,
  BFA.Control.PushNotification,
  BFA.Helper.SAF, frListMenu;

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
    FSidebar: TFListMenu;

    procedure ConfigureContext(AForm: TForm; AVertScroll: TVertScrollBox;
      ALayout: TLayout);
    function BuildLocalSAFFilePath(const AUri: string): string;
    procedure InitFrame;
    procedure InitKeyboard(AAutoSetEvent: Boolean);
    procedure InitPushNotification;
    procedure InitSAF;
    procedure InitSidebar(AForm: TForm);
    procedure InitToastMessage;
    function FindLayout(AForm: TForm; const AName: string): TLayout;
    function FindMultiView(AForm: TForm; const AName: string): TMultiView;
    procedure ReleaseKeyboard;
    procedure ReleaseMainHelper;
    procedure ReleasePushNotification;
    procedure ReleaseRouter;
    procedure ReleaseSAF;
    procedure ReleaseSidebar;
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

    property Sidebar: TFListMenu read FSidebar;
    property Keyboard: TKeyboardShow read FKeyboard;
    property MainHelper: TMainHelper read FMainHelper;
    property PushNotification: TPushNotificationService read FPushNotification;
    property Router: TFrameRouter read FRouter;
    property SAF: TBFASAF read FSAF;
  end;

implementation

uses
  System.IOUtils,
  frDetail, frLoading, frLogin, frHome,
  {DEMO SAMPLE}
  frDemoJSONToDataset, frDemoPermission,
  frDemoPushNotif, frDemoRestAPI, frDemoSAF
  {DEMO SAMPLE}
  ;

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
  ReleaseSidebar;
  ReleaseMainHelper;
  ReleaseRouter;
  inherited;
end;

function TAppServices.FindLayout(AForm: TForm; const AName: string): TLayout;
var
  LComponent: TComponent;
begin
  if not Assigned(AForm) then
    raise EArgumentNilException.Create('Form is required.');

  LComponent := AForm.FindComponent(AName);
  if not (LComponent is TLayout) then begin
    raise Exception.CreateFmt('%s layout is not available on %s.',
      [AName, AForm.Name]);
  end;

  Result := TLayout(LComponent);
end;

function TAppServices.FindMultiView(AForm: TForm;
  const AName: string): TMultiView;
var
  LComponent: TComponent;
begin
  if not Assigned(AForm) then
    raise EArgumentNilException.Create('Form is required.');

  LComponent := AForm.FindComponent(AName);
  if not (LComponent is TMultiView) then begin
    raise Exception.CreateFmt('%s multiview is not available on %s.',
      [AName, AForm.Name]);
  end;

  Result := TMultiView(LComponent);
end;

procedure TAppServices.Initialize(AForm: TForm; AVertScroll: TVertScrollBox;
  ALayout: TLayout; AAutoSetEvent: Boolean);
begin
  ConfigureContext(AForm, AVertScroll, ALayout);

  InitKeyboard(AAutoSetEvent);
  InitToastMessage;
  InitFrame;
  InitSidebar(FForm);
  //InitPushNotification;    //remove comment to enabled
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
  FRouter.RegisterFrame(TFHome, TView.HOME);
  FRouter.RegisterFrame(TFLoading, TView.LOADING);

  {DEMO SAMPLE}
  FRouter.RegisterFrame(TFDemoSAF, TView.DEMOSAF);
  FRouter.RegisterFrame(TFDemoRestAPI, TView.DEMORESTAPI);
  FRouter.RegisterFrame(TFDemoPushNotif, TView.DEMOPUSHNOTIF);
  FRouter.RegisterFrame(TFDemoPermission, TView.DEMOPERMISSION);
  FRouter.RegisterFrame(TFDemoJSONToDataset, TView.DEMOLOADJSONDATASET);
  {DEMO SAMPLE}
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

procedure TAppServices.InitSidebar(AForm: TForm);
var
  LMultiView: TMultiView;
  LSidebarHost: TLayout;
begin
  ReleaseSidebar;

  LSidebarHost := FindLayout(AForm, 'loSidebar');
  LMultiView := FindMultiView(AForm, 'MultiView');

  FSidebar := TFListMenu.Create(AForm);
  FSidebar.Parent := LSidebarHost;
  FSidebar.Align := TAlignLayout.Contents;
  FSidebar.MultiView := LMultiView;
  FSidebar.AddShadow := False;

  if not FSidebar.JSONListMenu.Trim.IsEmpty then begin
    FSidebar.LoadListMenu;
  end;

  LMultiView.MasterButton := nil;
  LMultiView.Enabled := False;
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

procedure TAppServices.ReleaseSidebar;
begin
  FreeAndNil(FSidebar);
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
