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

  TListFrame = class
  private
    FPersistentClass: TList<TPersistentClass>;
    FAlias: TList<String>;
    FContainerName: TList<String>;
    FFrame: TList<TFrame>;
  public
    property PersistentClass : TList<TPersistentClass> read FPersistentClass write FPersistentClass;
    property Alias : TList<String> read FAlias write FAlias;
    property ContainerName : TList<String> read FContainerName write FContainerName;
    property Frame : TList<TFrame> read FFrame write FFrame;

    function Find(AAlias : String; out AFound : Boolean) : Integer;
    function Count : Integer;

    constructor Create;
    destructor Destroy; override;
  end;

  TFrameCollection = class(TComponent)
  private
    CountTap : Integer;
    List : TListFrame;
    ListLockFrame : TList<String>;
    IsBack : Boolean;
    IsActiveDoubleTapExit : Boolean;

    FContainer: TControl;
    FRoutes: TList<String>;
    FRouteNavigation: String;
    FCurrentFrame: TControl;
    FPreviousAlias: String;
    FCurrentAlias: String;
    FPreviousFrame: TControl;

    procedure UpdateRouteNavigation;
    procedure CreateNew(AAlias : String);
    procedure DisplayMessage(AMessage : String);
    procedure Hide;
  public
    property Container : TControl read FContainer write FContainer;
    property Routes : TList<String> read FRoutes;
    property RouteNavigation : String read FRouteNavigation;

    property CurrentFrame : TControl read FCurrentFrame;
    property PreviousFrame : TControl read FPreviousFrame;
    property CurrentAlias : String read FCurrentAlias;
    property PreviousAlias : String read FPreviousAlias;

    procedure LockBack(ATargetAliases : array of string; AActiveDoubleTapExit : Boolean = False);
    procedure RegisterFrame(const AClass : TPersistentClass; AAliasClass : String);
    procedure NavigateTo(ATargetAlias : String);
    procedure Back;

    constructor Create;
    destructor Destroy; override;
  published

  end;

implementation

uses BFA.Resource.Message;

procedure TFrameCollection.Back;
var
  LLastAlias : String;
begin
  if Routes.Count = 0 then Exit;

  if IsActiveDoubleTapExit then begin
    LLastAlias := Routes.Last;

    if ListLockFrame.IndexOf(LLastAlias) >= 0 then begin
      if CountTap >= 1 then begin
        DisplayMessage('Bye bye');
        if IsActiveDoubleTapExit then
          Application.Terminate;

        Exit;
      end;

      Inc(CountTap);
      DisplayMessage('Tap twice to exit application');
      Exit;
    end;
  end;

  if Routes.Count <= 1 then Exit;

  IsBack := True;
  if Routes.Count > 1 then
    NavigateTo(Routes[Routes.Count - 2]) else
    NavigateTo(Routes[Routes.Count - 1]);

  Routes.Delete(Routes.Count - 1);
  UpdateRouteNavigation;
end;

constructor TFrameCollection.Create;
begin
  List := TListFrame.Create;
  ListLockFrame := TList<String>.Create;

  FRoutes := TList<String>.Create;
end;

procedure TFrameCollection.CreateNew(AAlias: String);
var
  LFound : Boolean;
  LIndex : Integer;
  LClass : TFrameContainer;
  LFrame : TFrame;
begin
  if not Assigned(Container) then raise Exception.Create('Container Not Set!');

  LIndex := List.Find(AAlias, LFound);
  if not LFound then begin
    DisplayMessage(RS_FRAME_NOT_FOUND);
    Exit;
  end;

  LClass := TFrameContainer(List.PersistentClass[LIndex]);
  LFrame := List.Frame[LIndex];

  if LFrame = nil then begin
    LFrame := LClass.Create(nil);
    LFrame.Align := TAlignLayout.Contents;
    Container.AddObject(LFrame);

    LFrame.Visible := False;
    List.Frame[LIndex] := LFrame;
  end;
end;

destructor TFrameCollection.Destroy;
begin
  List.Free;
  ListLockFrame.Free;

  FRoutes.Free;

  inherited;
end;

procedure TFrameCollection.DisplayMessage(AMessage: String);
begin
  ShowMessage(AMessage);
end;

procedure TFrameCollection.Hide;
var
  L : TFrame;
begin
  for L in List.Frame do begin
    if L <> nil then L.Visible := False;
  end;
end;

procedure TFrameCollection.LockBack(ATargetAliases: array of string;
  AActiveDoubleTapExit: Boolean);
var
  LIndex : Integer;
  LFound : Boolean;
begin
  ListLockFrame.Clear;

  if Length(ATargetAliases) = 0 then raise Exception.Create('Please input Alias Class');

  for var i := 0 to Length(ATargetAliases) - 1 do begin
    LIndex := List.Find(ATargetAliases[i], LFound);
    if LFound then Break;
  end;

  if not LFound then raise Exception.Create('Alias not match!');
  for var i := 0 to Length(ATargetAliases) - 1 do ListLockFrame.Add(ATargetAliases[i]);

  IsActiveDoubleTapExit := AActiveDoubleTapExit;
end;

procedure TFrameCollection.NavigateTo(ATargetAlias: String);
var
  LFound : Boolean;
  LIndex : Integer;
  LNewURL : String;
begin
  try
    try
      LIndex := List.Find(ATargetAlias, LFound);
      if not LFound then begin
        DisplayMessage(RS_FRAME_NOT_FOUND);
        Exit;
      end;

      if Assigned(CurrentFrame) and (List.Frame[LIndex] <> nil) then
        if CurrentFrame.ClassName = List.Frame[LIndex].ClassName then Exit;

      Hide;

      CreateNew(ATargetAlias);

      if List.Frame[LIndex] <> nil then begin
        List.Frame[LIndex].Visible := True;

        if not IsBack then Routes.Add(ATargetAlias);
      end;

      UpdateRouteNavigation;
    except on E: Exception do
      DisplayMessage(E.Message);
    end;
  finally
    IsBack := False;
    CountTap := 0;
  end;
end;

procedure TFrameCollection.RegisterFrame(const AClass: TPersistentClass;
  AAliasClass: String);
var
  LContainerName : String;
begin
  LContainerName := StringReplace(AAliasClass, ' ', '', [rfReplaceAll, rfIgnoreCase]);

  List.PersistentClass.Add(AClass);
  List.Alias.Add(AAliasClass);
  List.ContainerName.Add(LContainerName);
  List.Frame.Add(nil);

  RegisterClass(AClass);
end;

procedure TFrameCollection.UpdateRouteNavigation;
var
  LFound : Boolean;
  LIndex : Integer;
begin
  FCurrentFrame := nil;
  FPreviousFrame := nil;

  FRouteNavigation := '';
  FCurrentAlias := '';

  if Routes.Count = 0 then Exit;

  var LTempList := TStringList.Create;
  try
    for var LText in Routes do
      LTempList.Add(LText);

    FRouteNavigation := LTempList.DelimitedText;
    FRouteNavigation := StringReplace(FRouteNavigation, ',', ' -> ', [rfReplaceAll]);

    FCurrentAlias := LTempList[LTempList.Count - 1];

    LIndex := List.Find(FCurrentAlias, LFound);
    if LFound then
      FCurrentFrame := List.Frame[LIndex];

    if LTempList.Count > 1 then begin
      FPreviousAlias := LTempList[LTempList.Count - 2];

      LIndex := List.Find(FPreviousAlias, LFound);
      if LFound then
        FPreviousFrame := List.Frame[LIndex];
    end;
  finally
    LTempList.Free;
  end;
end;

function TListFrame.Count: Integer;
begin
  Result := Alias.Count;
end;

{ TListWebForm }

constructor TListFrame.Create;
begin
  FPersistentClass := TList<TPersistentClass>.Create;
  FAlias := TList<String>.Create;
  FContainerName := TList<String>.Create;
  FFrame := TList<TFrame>.Create;
end;

destructor TListFrame.Destroy;
begin
  FPersistentClass.Free;
  FAlias.Free;
  FContainerName.Free;
  FFrame.Free;

  inherited;
end;

function TListFrame.Find(AAlias: String; out AFound: Boolean): Integer;
begin
  Result := Alias.IndexOf(AAlias);
  AFound := Result >= 0;
end;

end.
