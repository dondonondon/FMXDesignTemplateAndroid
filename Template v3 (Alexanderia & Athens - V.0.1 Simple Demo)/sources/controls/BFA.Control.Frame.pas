unit BFA.Control.Frame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.Objects,
  System.Rtti, System.Threading, System.Generics.Collections, BFA.Control.Form.Message;

type
  TFrameClass = class of TFrame;
  TExec = procedure of object;

  TGoFrame = class
  private
    FListFrame : TList<TPersistentClass>;
    FListAlias, FListDoubleTapBackAlias : TList<String>;
    FListIdleFrame : TList<TControl>;

    FListMoveFrame : TList<String>;

    FParentControl: TControl;
    FLastControl: TControl;
    FOldControl: TControl;
    FSetIdle: Boolean;
    FIsBack : Boolean;
    FIsUsesDoubleTapBack : Boolean;

    FTapBack : Integer;
    FToastMessage: TMainHelper;
    FCloseAppWhenDoubleTap: Boolean;
    FFrameAliasNow: String;
    FFrameAliasBefore: String;

    FTempAlias : String;

    procedure CallFrame(FFrame : TFrameClass; FParent : TControl; out FControl : TControl; IsIdle : Boolean); overload;

    procedure CallFrame(FFrameName : String); overload;
    procedure CallFrame(FFrame : TFrameClass); overload;

    function CheckAvailableList(FControl : TControl) : Boolean;
    function GetControlFromList(FClassName : String) : TControl;

    function GetAliasName(FClassName : String) : String;

    procedure ShowFrame(FControl : TControl);
    procedure ShowMessages(FText : String; FType : TTypeMessage = Information);
  public
    property ControlParent : TControl read FParentControl write FParentControl;
    property LastControl : TControl read FLastControl;
    property OldControl : TControl read FOldControl;

    property SetIdle : Boolean read FSetIdle write FSetIdle;
    property CloseAppWhenDoubleTap : Boolean read FCloseAppWhenDoubleTap write FCloseAppWhenDoubleTap;
    property MainHelper : TMainHelper read FToastMessage write FToastMessage;

    property FrameAliasNow : String read FFrameAliasNow;
    property FrameAliasBefore : String read FFrameAliasBefore;

    procedure RegisterClassesFrame(const AClass : array of TPersistentClass; AliasClass : array of String);
    procedure RegisterClassFrame(const AClass : TPersistentClass; AliasClass : String);

    procedure AddDoubleTapBackExit(AliasClass : array of String);

    procedure GoFrame(Alias : String); overload;
    procedure GoFrame(FFrame : TFrameClass); overload;

    function GetFrame(Alias : String) : TControl; overload;
    function GetFrame(FFrame : TFrameClass) : TControl; overload;

    function Back : Boolean;

    procedure ShowLastControl;

    constructor Create;

    destructor Destroy; override;
  end;

implementation

{ TGoFrame }

procedure TGoFrame.CallFrame(FFrame: TFrameClass; FParent: TControl;
  out FControl: TControl; IsIdle : Boolean);
var
  LFrame : TControl;
begin
  try

    LFrame := GetControlFromList(FFrame.ClassName);

    if Assigned(FControl) then begin
      FControl.Visible := True;
      if FControl.ClassName = FFrame.ClassName then
        Exit;
    end;

    if Assigned(FControl) then begin
      if not CheckAvailableList(FControl) then
        FControl.DisposeOf
      else
        FControl.Visible := False;
    end;

    if not Assigned(LFrame) then begin
      LFrame := FFrame.Create(nil);
      LFrame.Align := TAlignLayout.Contents;
      FParent.AddObject(LFrame);

      if IsIdle then
        FListIdleFrame.Add(LFrame)
      else
        ShowFrame(LFrame);

    end else begin

      ShowFrame(LFrame);
    end;

    FOldControl := FControl;

    FControl := LFrame;
  except
    on E : Exception do
      MainHelper.ShowToastMessage(E.Message);
//      raise Exception.Create(E.Message);
  end;
end;

procedure TGoFrame.AddDoubleTapBackExit(AliasClass: array of String);
var
  FIndex : Integer;
begin
  if Length(AliasClass) = 0 then
    raise Exception.Create('Please input Alias Class');

  for var i := 0 to Length(AliasClass) - 1 do begin
    FIndex := FListAlias.IndexOf(AliasClass[i]);
    if FIndex < 0 then Break;
  end;

  if FIndex < 0 then
    raise Exception.Create('Alias not match!');

  for var i := 0 to Length(AliasClass) - 1 do begin
    FListDoubleTapBackAlias.Add(AliasClass[i]);
  end;

  FIsUsesDoubleTapBack := True;
end;

function TGoFrame.Back : Boolean;
begin
  if FListMoveFrame.Count = 0 then Exit;

  if FIsUsesDoubleTapBack then begin
    var FAlias : String;
    FAlias := FListMoveFrame.Last;
    if FListDoubleTapBackAlias.IndexOf(FAlias) >= 0 then begin
      if FTapBack >= 1 then begin
        ShowMessages('Bye bye');
        Result := True;

        if CloseAppWhenDoubleTap then
          Application.Terminate;

        Exit;
      end;

      Inc(FTapBack);
      ShowMessages('Tap twice to exit application');
      Exit;
    end;
  end;

  if FListMoveFrame.Count <= 1 then Exit;

  FIsBack := True;

  GoFrame(FListMoveFrame[FListMoveFrame.Count - 2]);
  FListMoveFrame.Delete(FListMoveFrame.Count - 1);
end;

procedure TGoFrame.CallFrame(FFrame: TFrameClass);
begin
  if not Assigned(FParentControl) then
    raise Exception.Create('Control Parent Not Set!');

  CallFrame(FFrame, FParentControl, FLastControl, SetIdle);
end;

function TGoFrame.CheckAvailableList(FControl: TControl): Boolean;
begin
  Result := False;

  for var Frame in FListIdleFrame do begin
    if FLastControl.ClassName = Frame.ClassName then begin
      Result := True;
      Break;
    end;
  end;
end;

constructor TGoFrame.Create;
begin
  FListIdleFrame := TList<TControl>.Create;
  FListFrame := TList<TPersistentClass>.Create;
  FListAlias := TList<String>.Create;
  FListMoveFrame := TList<String>.Create;

  FListDoubleTapBackAlias := TList<String>.Create;

  SetIdle := True; //if set false get report mem leak using madexcept
end;

destructor TGoFrame.Destroy;
begin
  FListIdleFrame.DisposeOf;
  FListFrame.DisposeOf;
  FListAlias.DisposeOf;
  FListMoveFrame.DisposeOf;
  FListDoubleTapBackAlias.DisposeOf;

  inherited;
end;

function TGoFrame.GetAliasName(FClassName: String): String;
var
  FIndex : Integer;
begin
  if FListFrame.Count = 0 then Exit;

  for var Frame in FListFrame do begin
    if FClassName = Frame.ClassName then begin
      FIndex := FListFrame.IndexOf(Frame);
      Result := FListAlias[FIndex];
      Break;
    end;
  end;
end;

function TGoFrame.GetControlFromList(FClassName : String): TControl;
begin
  Result := nil;

  if FListIdleFrame.Count = 0 then Exit;

  for var Frame in FListIdleFrame do begin
    if FClassName = Frame.ClassName then begin
      Result := Frame;
      Break;
    end;
  end;
end;

function TGoFrame.GetFrame(FFrame: TFrameClass): TControl;
begin
  Result := GetControlFromList(FFrame.ClassName);
end;

function TGoFrame.GetFrame(Alias: String): TControl;
begin
  Result := GetControlFromList(FListFrame[FListAlias.IndexOf(Alias)].ClassName);
end;

procedure TGoFrame.GoFrame(FFrame: TFrameClass);
begin
  FTempAlias := GetAliasName(FFrame.ClassName);
  CallFrame(FFrame);
end;

procedure TGoFrame.GoFrame(Alias: String);
begin
  var FIndex := FListAlias.IndexOf(Alias);
  if FIndex < 0 then
    raise Exception.Create('Alias not found');

  FTempAlias := Alias;
  CallFrame(FListFrame[FListAlias.IndexOf(Alias)].ClassName);
end;

procedure TGoFrame.RegisterClassFrame(const AClass: TPersistentClass;
  AliasClass: String);
begin
  FListFrame.Add(AClass);
  FListAlias.Add(AliasClass);

  RegisterClass(AClass);

  CallFrame(AClass.ClassName);
  LastControl.Visible := False;
end;

procedure TGoFrame.ShowFrame(FControl: TControl);
var
  Routine : TMethod;
  Exec : TExec;
begin
  if not Assigned(FControl) then
    raise Exception.Create('Object not found');

  FControl.Visible := True;

  if not FIsBack then
    FListMoveFrame.Add(GetAliasName(FControl.ClassName));

  FIsBack := False;
  FTapBack := 0;

  FFrameAliasBefore := FrameAliasNow;
  FFrameAliasNow := FTempAlias;

  Routine.Data := Pointer(FControl);
  Routine.Code := FControl.MethodAddress('Show');
  if Assigned(Routine.Code) then begin
    Exec := TExec(Routine);
    Exec;
  end;
end;

procedure TGoFrame.ShowLastControl;
var
  Routine : TMethod;
  Exec : TExec;
begin
  if not Assigned(LastControl) then
    raise Exception.Create('Object not found');

  LastControl.Visible := True;

  Routine.Data := Pointer(LastControl);
  Routine.Code := LastControl.MethodAddress('Show');
  if not Assigned(Routine.Code) then
    raise Exception.Create('Method "Show" not found.');

  Exec := TExec(Routine);
  Exec;
end;

procedure TGoFrame.ShowMessages(FText: String; FType: TTypeMessage);
begin
  if Assigned(TForm(Screen.ActiveForm)) then begin
    if Assigned(MainHelper) then
      MainHelper.ShowToastMessage(FText, FType);
  end;
end;

procedure TGoFrame.RegisterClassesFrame(const AClass: array of TPersistentClass; AliasClass : array of String);
begin
  if Length(AClass) <> Length(AliasClass) then
    raise Exception.Create('Total Class && AliasClass not match!');

  for var i := 0 to Length(AClass) - 1 do begin
    FListFrame.Add(AClass[i]);
    FListAlias.Add(AliasClass[i]);

    RegisterClass(AClass[i]);

    CallFrame(AClass[i].ClassName);
    LastControl.Visible := False;
  end;
end;

procedure TGoFrame.CallFrame(FFrameName: String);
begin
  if not Assigned(FParentControl) then
    raise Exception.Create('Control Parent Not Set!');

  try
    FindClass(FFrameName);

    var LClass := TFrameClass(GetClass(FFrameName));
    CallFrame(LClass, FParentControl, FLastControl, SetIdle);
  except on E: Exception do
    raise Exception.Create('Class Not Found / Not Register');
  end;
end;

end.
