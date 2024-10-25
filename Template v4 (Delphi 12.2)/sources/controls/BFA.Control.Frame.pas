unit BFA.Control.Frame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.Objects,
  System.Rtti, System.Threading, System.Generics.Collections;

type
  TFrameContainer = class of TFrame;
  TMethodExec = procedure of object;

  TFrameCollection = class(TComponent)
  private
    ListFrame : TList<TPersistentClass>;
    ListAlias : TList<String>;
    ListDoubleTapBackAlias : TList<String>;

    ListAvailableFrame : TList<TControl>;
    ListRoute : TList<String>;

    FPreviousFrame: TControl;
    FCurrentFrame: TControl;
    FFrameContainer: TControl;

    IsInitFrame : Boolean;

    FIsBack : Boolean;
    FTapBack : Integer;
    FIsUsesDoubleTapBack : Boolean;

    FPreviousAlias: String;
    FCurrentAlias: String;
    FCloseAppWhenDoubleTap: Boolean;
//    FDestroyAfterClose: Boolean;

    function InitFrame(AFrame : TFrameContainer; AParent : TControl) : TControl;
    function CallingFrame(AClassName : String) : TControl; overload;
    function CallingFrame(AFrame : TFrameContainer): TControl; overload;

    function GetFrameFromList(AClassName : String) : TControl;
    function IsFrameAvailable(AFrame : TControl) : Boolean;
    function GetAliasName(AClassName : String) : String;

    procedure Show(AControl : TControl);
    procedure SetVisible(const Value: Boolean);
  public
    property FrameContainer : TControl read FFrameContainer write FFrameContainer;

    property CurrentFrame : TControl read FCurrentFrame;
    property PreviousFrame : TControl read FPreviousFrame;

    property CurrentAlias : String read FCurrentAlias;
    property PreviousAlias : String read FPreviousAlias;

    property CloseAppWhenDoubleTap : Boolean read FCloseAppWhenDoubleTap write FCloseAppWhenDoubleTap;

    property Visible : Boolean write SetVisible;

//    property DestroyAfterClose : Boolean read FDestroyAfterClose write FDestroyAfterClose;

    procedure RegisterFrame(const AClass : TPersistentClass; AAliasClass : String); overload;
    procedure RegisterFrame(const AClass : array of TPersistentClass; AAliasClasses : array of String); overload;

    procedure SetDoubleTapBackExit(AAliasClass : array of String);

    procedure MoveTo(AAlias : String); overload;
    procedure MoveTo(AFrame : TFrameContainer); overload;

    function GetFrame(AAlias : String) : TControl; overload;
    function GetFrame(AFrame : TFrameContainer) : TControl; overload;

    function Back : Boolean;

    constructor Create;
    destructor Destroy; override;
  published

  end;

implementation

{ TFrameCollection }

function TFrameCollection.CallingFrame(AClassName: String): TControl;
begin
  Result := nil;
  try
    FindClass(AClassName);

    var LClass := TFrameContainer(GetClass(AClassName));
    Result := InitFrame(LClass, FrameContainer);
  except on E: Exception do
    raise Exception.Create('Class Not Found / Not Register');
  end;
end;

function TFrameCollection.Back: Boolean;
begin
  if ListRoute.Count = 0 then Exit;

  if FIsUsesDoubleTapBack then begin
    var FAlias : String;
    FAlias := ListRoute.Last;
    if ListDoubleTapBackAlias.IndexOf(FAlias) >= 0 then begin
      if FTapBack >= 1 then begin
//        ShowMessages('Bye bye');
        Result := True;

        if CloseAppWhenDoubleTap then
          Application.Terminate;

        Exit;
      end;

      Inc(FTapBack);
//      ShowMessages('Tap twice to exit application');
      Exit;
    end;
  end;

  if ListRoute.Count <= 1 then Exit;

  FIsBack := True;

  if ListRoute.Count > 1 then MoveTo(ListRoute[ListRoute.Count - 2]) else
    MoveTo(ListRoute[ListRoute.Count - 1]);

  ListRoute.Delete(ListRoute.Count - 1);
end;

function TFrameCollection.CallingFrame(AFrame: TFrameContainer): TControl;
begin
  if not Assigned(FrameContainer) then
    raise Exception.Create('Control Parent Not Set!');

  InitFrame(AFrame, FrameContainer);
end;

constructor TFrameCollection.Create;
begin
  ListFrame := TList<TPersistentClass>.Create;
  ListAlias := TList<String>.Create;
  ListRoute := TList<String>.Create;
  ListDoubleTapBackAlias := TList<String>.Create;
  ListAvailableFrame := TList<TControl>.Create;
end;

destructor TFrameCollection.Destroy;
begin
  ListFrame.Free;
  ListAlias.Free;
  ListRoute.Free;
  ListDoubleTapBackAlias.Free;
  ListAvailableFrame.Free;
  inherited;
end;

function TFrameCollection.GetAliasName(AClassName: String): String;
var
  FIndex : Integer;
begin
  if ListFrame.Count = 0 then Exit;

  for var Frame in ListFrame do begin
    if AClassName = Frame.ClassName then begin
      FIndex := ListFrame.IndexOf(Frame);
      Result := ListAlias[FIndex];
      Break;
    end;
  end;
end;

function TFrameCollection.GetFrame(AFrame: TFrameContainer): TControl;
begin
  Result := GetFrameFromList(AFrame.ClassName);
end;

function TFrameCollection.GetFrame(AAlias: String): TControl;
begin
  Result := GetFrameFromList(ListFrame[ListAlias.IndexOf(AAlias)].ClassName);
end;

function TFrameCollection.GetFrameFromList(AClassName: String): TControl;
begin
  Result := nil;
  if ListAvailableFrame.Count = 0 then Exit;

  for var Frame in ListAvailableFrame do begin
    if AClassName = Frame.ClassName then begin
      Result := Frame;
      Break;
    end;
  end;
end;

function TFrameCollection.InitFrame(AFrame: TFrameContainer; AParent: TControl): TControl;
var
  LFrame : TControl;
begin
  Result := nil;
  try
    LFrame := GetFrameFromList(AFrame.ClassName);

    if Assigned(CurrentFrame) then begin
      CurrentFrame.Visible := True;
      if CurrentFrame.ClassName = AFrame.ClassName then Exit;

//      if not IsFrameAvailable(CurrentFrame) then CurrentFrame.Free else  //DestroyAfterClose
      CurrentFrame.Visible := False;
    end;

    if not Assigned(LFrame) then begin
      LFrame := AFrame.Create(nil);
      LFrame.Align := TAlignLayout.Contents;
      FrameContainer.AddObject(LFrame);

      LFrame.Visible := False;
    end;

    FPreviousFrame := FCurrentFrame;
    FCurrentFrame := LFrame;

    if not IsInitFrame then
      Show(LFrame);

    IsInitFrame := False;
  except on E : Exception do
//      MainHelper.ShowToastMessage(E.Message);
      raise Exception.Create(E.Message);
  end;
end;

function TFrameCollection.IsFrameAvailable(AFrame: TControl): Boolean;
begin
  Result := False;

  for var Frame in ListAvailableFrame do begin
    if AFrame.ClassName = Frame.ClassName then begin
      Result := True;
      Break;
    end;
  end;
end;

procedure TFrameCollection.MoveTo(AFrame: TFrameContainer);
begin
  CallingFrame(GetAliasName(AFrame.ClassName));
end;

procedure TFrameCollection.MoveTo(AAlias: String);
begin
  var FIndex := ListAlias.IndexOf(AAlias);
  if FIndex < 0 then
    raise Exception.Create('Alias not found');

  CallingFrame(ListFrame[ListAlias.IndexOf(AAlias)].ClassName);
end;

procedure TFrameCollection.RegisterFrame(
  const AClass: array of TPersistentClass; AAliasClasses: array of String);
begin
  if Length(AClass) <> Length(AAliasClasses) then
    raise Exception.Create('Total Class && AliasClass not match!');

  for var i := 0 to Length(AClass) - 1 do begin
    RegisterFrame(AClass[i], AAliasClasses[i]);
  end;
end;

procedure TFrameCollection.SetDoubleTapBackExit(AAliasClass: array of String);
var
  FIndex : Integer;
begin
  if Length(AAliasClass) = 0 then
    raise Exception.Create('Please input Alias Class');

  for var i := 0 to Length(AAliasClass) - 1 do begin
    FIndex := ListAlias.IndexOf(AAliasClass[i]);
    if FIndex < 0 then Break;
  end;

  if FIndex < 0 then
    raise Exception.Create('Alias not match!');

  for var i := 0 to Length(AAliasClass) - 1 do begin
    ListDoubleTapBackAlias.Add(AAliasClass[i]);
  end;

  FIsUsesDoubleTapBack := True;
end;

procedure TFrameCollection.SetVisible(const Value: Boolean);
begin
//  for var TempFrame in ListFrame do begin
//    GetFrameFromList(TempFrame.ClassName).Visible := Value;
//  end;
end;

procedure TFrameCollection.Show(AControl: TControl);
var
  Routine : TMethod;
  Exec : TMethodExec;
begin
  if not Assigned(AControl) then
    raise Exception.Create('Object not found');

  AControl.Visible := True;

  if not FIsBack then ListRoute.Add(GetAliasName(AControl.ClassName));

  FIsBack := False;
  FTapBack := 0;

  FPreviousAlias := CurrentAlias;
  FCurrentAlias := GetAliasName(AControl.ClassName);

  Routine.Data := Pointer(AControl);
  Routine.Code := AControl.MethodAddress('Show');
  if Assigned(Routine.Code) then begin
    Exec := TMethodExec(Routine);
    Exec;
  end;
end;

procedure TFrameCollection.RegisterFrame(const AClass: TPersistentClass;
  AAliasClass: String);
begin
  ListFrame.Add(AClass);
  ListAlias.Add(AAliasClass);
  RegisterClass(AClass);

  FIsBack := True;
  IsInitFrame := True;

  FCurrentFrame := CallingFrame(AClass.ClassName);
  if Assigned(CurrentFrame) then CurrentFrame.Visible := False;
end;

end.
