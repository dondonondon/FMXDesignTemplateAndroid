unit BFA.GoFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.Objects,
  System.Rtti, System.Threading, System.Generics.Collections;

type
  TFrameClass = class of TFrame;
  TExec = procedure of object;

  TFrameHelper = class helper for TFrame
    procedure Show(FProc : TProc = nil);
    procedure Hide(FProc : TProc = nil);
    procedure Close;
    function CallFrame(FParent : TControl; FClass : TFrameClass; FName : String) : TFrame;
  end;

  TListFrame = class
    LFrame : TList<TControl>;
    LList  : TStringList;

    procedure HideAll;
    procedure Show(LName : String);
    function getFrame(LName : String) : TControl;

    constructor Create;
    destructor Destroy; override;
  end;

var
  LListFrame : TListFrame;

implementation

{ TFrameHelper }

function TFrameHelper.CallFrame(FParent: TControl;
  FClass: TFrameClass; FName : String): TFrame;

begin
  if not Assigned(LListFrame) then
    LListFrame := TListFrame.Create;

  if not Assigned(Self) then begin
    try
      Self := FClass.Create(nil);
      Self.Parent := FParent;
      Self.Visible := True;

      Self.Align := TAlignLayout.None;
      Self.Width := FParent.Width;
      Self.Height := FParent.Height;
      Self.Anchors := [TAnchorKind.akLeft, TAnchorKind.akTop, TAnchorKind.akRight, TAnchorKind.akBottom];

      Self.Position.X := 0;
      Self.Position.Y := 0;

      LListFrame.LFrame.Add(Self);
      LListFrame.LList.Add(FName);

      Result := Self;
    except
      on E : Exception do begin
        ShowMessage(E.Message + ''#13 + E.ClassName);
      end;
    end;
  end else begin
    Result := Self;
  end;
end;

procedure TFrameHelper.Close;
begin
  if Assigned(LListFrame) then begin

  end;
  Self.DisposeOf;
end;

procedure TFrameHelper.Hide(FProc: TProc);
begin
  if Assigned(Self) then begin
    Self.Visible := False;

    if Assigned(FProc) then
      FProc;
  end;
end;

procedure TFrameHelper.Show(FProc: TProc);
var
  Routine : TMethod;
  Exec : TExec;
begin
  if Assigned(Self) then begin
    Self.Visible := True;

    if Assigned(FProc) then
      FProc;

    Routine.Data := Pointer(Self);
    Routine.Code := Self.MethodAddress('FirstShow');
    if not Assigned(Routine.Code) then
      Exit;

    Exec := TExec(Routine);
    Exec;
  end;
end;


{ TListFrame }

constructor TListFrame.Create;
begin
  LFrame := TList<TControl>.Create;
  LList := TStringList.Create;
end;

destructor TListFrame.Destroy;
begin
  LFrame.DisposeOf;
  LList.DisposeOf;
  inherited;
end;

function TListFrame.getFrame(LName: String): TControl;
begin
  Result := nil;

  if LName = '' then
    Exit;

  for var i := 0 to LList.Count - 1 do begin
    if LowerCase(LName) = LowerCase(LList[i]) then begin
      Result := LFrame[i];
      Break;
    end;
  end;

  if Result = nil then
    ShowMessage('Frame ' + LName + ' not found!');
end;

procedure TListFrame.HideAll;
begin
  var FFrame : TControl;
  for FFrame in LListFrame.LFrame do begin
    FFrame.Visible := False;
  end;
end;

procedure TListFrame.Show(LName: String);
var
  Routine : TMethod;
  Exec : TExec;
  LFrame : TControl;
begin
  if LName = '' then
    Exit;

  LFrame := getFrame(LName);

  if not Assigned(LFrame) then
    Exit;

  LFrame.Visible := True;

  Routine.Data := Pointer(LFrame);
  Routine.Code := LFrame.MethodAddress('FirstShow');
  if NOT Assigned(Routine.Code) then
    Exit;

  Exec := TExec(Routine);
  Exec;
end;

end.
