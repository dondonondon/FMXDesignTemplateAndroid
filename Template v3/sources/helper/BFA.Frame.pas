unit BFA.Frame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.Objects,
  System.Rtti, System.Threading, System.Generics.Collections;

type
  TFrameClass = class of TFrame;
  TExec = procedure of object;

  TGoFrame = class
  private
    FListFrame : TList<TPersistentClass>;
    FListAlias : TList<String>;
    FListIdleFrame : TList<TControl>;

    FParentControl: TControl;
    FLastControl: TControl;
    FOldControl: TControl;
    FSetIdle: Boolean;

    procedure CallFrame(FFrame : TFrameClass; FParent : TControl; out FControl : TControl; IsIdle : Boolean); overload;

    procedure CallFrame(FFrameName : String); overload;
    procedure CallFrame(FFrame : TFrameClass); overload;

    function CheckAvailableList(FControl : TControl) : Boolean;
    function GetControlFromList(FClassName : String) : TControl;

    procedure ShowFrame(FControl : TControl);
  public
    property ControlParent : TControl read FParentControl write FParentControl;
    property LastControl : TControl read FLastControl;
    property OldControl : TControl read FOldControl;

    property SetIdle : Boolean read FSetIdle write FSetIdle;

    procedure RegisterClassesFrame(const AClass : array of TPersistentClass; AliasClass : array of String);
    procedure RegisterClassFrame(const AClass : TPersistentClass; AliasClass : String);

    procedure GoFrame(Alias : String); overload;
    procedure GoFrame(FFrame : TFrameClass); overload;

    function GetFrame(Alias : String) : TControl; overload;
    function GetFrame(FFrame : TFrameClass) : TControl; overload;

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
        FListIdleFrame.Add(LFrame);

    end else begin
      ShowFrame(LFrame);
//      LFrame.Visible := True;
    end;

    FOldControl := FControl;

    FControl := LFrame;
  except
    on E : Exception do
      raise Exception.Create(E.Message);
  end;
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
  if not Assigned(FListIdleFrame) then
    FListIdleFrame := TList<TControl>.Create;

  if not Assigned(FListFrame) then
    FListFrame := TList<TPersistentClass>.Create;

  if not Assigned(FListAlias) then
    FListAlias := TList<String>.Create;
end;

destructor TGoFrame.Destroy;
begin
  if Assigned(FListIdleFrame) then
    FListIdleFrame.DisposeOf;

  if Assigned(FListFrame) then
    FListFrame.DisposeOf;

  if Assigned(FListAlias) then
    FListAlias.DisposeOf;

  inherited;
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
  CallFrame(FFrame);
end;

procedure TGoFrame.GoFrame(Alias: String);
begin
  var FIndex := FListAlias.IndexOf(Alias);
  if FIndex < 0 then
    raise Exception.Create('Alias not found');

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

  Routine.Data := Pointer(FControl);
  Routine.Code := FControl.MethodAddress('Show');
  if not Assigned(Routine.Code) then
    raise Exception.Create('Method "Show" not found.');

  Exec := TExec(Routine);
  Exec;
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
