{*******************************************************************************
  Copyright (c) 2026 Fajar Donny Bachtiar (Blangkon FA)
  Licensed under the Apache License, Version 2.0.
  See the LICENSE file in the project root for license details.
*******************************************************************************}

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
  TOnRouterMessage = procedure(const AMessage: string) of object;

  TFrameItem = class
  public
    Alias: string;
    FrameClass: TFrameContainer;
    Instance: TFrame;
  end;

  TFrameRouter = class(TComponent)
  private
    FBackTapCount: Integer;
    FContainer: TControl;
    FDoubleTapExitEnabled: Boolean;
    FIsNavigatingBack: Boolean;
    FLockedBackAliases: TList<string>;
    FRegistry: TObjectDictionary<string, TFrameItem>;
    FRoutes: TList<string>;
    FCurrentAlias: string;
    FOnMessage: TOnRouterMessage;

    function Normalize(const S: string): string;
    function GetCurrentFrame: TFrame;
    procedure InvokeFrameMethod(AFrame: TFrame; const MethodName: string);
    procedure ShowMessage(const Msg: string);
    procedure HideCurrent;
    procedure UpdateRoute;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure LockBack(const AAliases: array of string;
      AActiveDoubleTapExit: Boolean = False);
    procedure RegisterFrame(AClass: TFrameContainer; const Alias: string);
    procedure NavigateTo(const Alias: string);
    procedure Back;

    property Container: TControl read FContainer write FContainer;
    property CurrentFrame: TFrame read GetCurrentFrame;
    property CurrentAlias: string read FCurrentAlias;
    property Routes: TList<string> read FRoutes;
    property OnMessage: TOnRouterMessage read FOnMessage write FOnMessage;
  end;

implementation

uses
  BFA.Exception.Base,
  BFA.Resource.Message;

constructor TFrameRouter.Create(AOwner: TComponent);
begin
  inherited;

  FBackTapCount := 0;
  FDoubleTapExitEnabled := False;
  FIsNavigatingBack := False;
  FLockedBackAliases := TList<string>.Create;
  FRegistry := TObjectDictionary<string, TFrameItem>.Create([doOwnsValues]);
  FRoutes := TList<string>.Create;
end;

destructor TFrameRouter.Destroy;
begin
  FLockedBackAliases.Free;
  FRegistry.Free;
  FRoutes.Free;
  inherited;
end;

procedure TFrameRouter.LockBack(const AAliases: array of string;
  AActiveDoubleTapExit: Boolean);
var
  LAliasName: string;
  LKey: string;
begin
  FLockedBackAliases.Clear;

  if Length(AAliases) = 0 then
    raise EFrameRouterAliasListEmptyException.Create(RS_ROUTER_ALIAS_LIST_EMPTY);

  for LAliasName in AAliases do
  begin
    LKey := Normalize(LAliasName);
    if not FRegistry.ContainsKey(LKey) then
      raise EFrameRouterAliasNotRegisteredException.CreateFmt(
        RS_ROUTER_ALIAS_NOT_REGISTERED, [LAliasName]);

    FLockedBackAliases.Add(LKey);
  end;

  FDoubleTapExitEnabled := AActiveDoubleTapExit;
end;

function TFrameRouter.Normalize(const S: string): string;
begin
  Result := Trim(LowerCase(S));
end;

procedure TFrameRouter.RegisterFrame(AClass: TFrameContainer; const Alias: string);
var
  Item: TFrameItem;
  Key: string;
begin
  Key := Normalize(Alias);

  if FRegistry.ContainsKey(Key) then
    raise EFrameRouterAliasAlreadyRegisteredException.CreateFmt(
      RS_ROUTER_ALIAS_ALREADY_REGISTERED, [Alias]);

  Item := TFrameItem.Create;
  Item.Alias := Alias;
  Item.FrameClass := AClass;
  Item.Instance := nil;

  FRegistry.Add(Key, Item);
  RegisterClass(AClass);
end;

procedure TFrameRouter.InvokeFrameMethod(AFrame: TFrame; const MethodName: string);
var
  Routine: TMethod;
  Exec: TMethodExec;
begin
  if not Assigned(AFrame) then
    Exit;

  Routine.Data := Pointer(AFrame);
  Routine.Code := AFrame.MethodAddress(MethodName);
  if not Assigned(Routine.Code) then
    Exit;

  Exec := TMethodExec(Routine);
  Exec;
end;

procedure TFrameRouter.NavigateTo(const Alias: string);
var
  Key: string;
  Item: TFrameItem;
begin
  try
    try
      if not Assigned(FContainer) then
        raise EFrameRouterContainerNotAssignedException.Create(
          RS_ROUTER_CONTAINER_NOT_ASSIGNED);

      Key := Normalize(Alias);

      if not FRegistry.TryGetValue(Key, Item) then begin
        raise EFrameRouterFrameNotFoundException.CreateFmt(
          RS_ROUTER_FRAME_NOT_FOUND, [Alias]);
      end;

      if SameText(FCurrentAlias, Alias) then
        Exit;

      HideCurrent;

      if not Assigned(Item.Instance) then begin
        Item.Instance := Item.FrameClass.Create(FContainer);
        Item.Instance.Parent := FContainer;
        Item.Instance.Align := TAlignLayout.Contents;
      end;

      Item.Instance.Visible := True;

      FCurrentAlias := Alias;
      if not FIsNavigatingBack then
        FRoutes.Add(Alias);
      InvokeFrameMethod(Item.Instance, 'ShowFrame');

      UpdateRoute;
    except
      on E: Exception do
        ShowMessage(E.Message);
    end;
  finally
    FBackTapCount := 0;
    FIsNavigatingBack := False;
  end;
end;

procedure TFrameRouter.Back;
var
  LCurrentAlias: string;
  LTargetAlias: string;
begin
  if FRoutes.Count = 0 then
    Exit;

  LCurrentAlias := Normalize(FRoutes.Last);

  if FDoubleTapExitEnabled and (FLockedBackAliases.IndexOf(LCurrentAlias) >= 0) then
  begin
    if FBackTapCount >= 1 then
    begin
      ShowMessage(RS_ROUTER_EXIT_APPLICATION);
      Application.Terminate;
      Exit;
    end;

    Inc(FBackTapCount);
    ShowMessage(RS_ROUTER_DOUBLE_TAP_EXIT);
    Exit;
  end;

  if FRoutes.Count <= 1 then
    Exit;

  LTargetAlias := FRoutes[FRoutes.Count - 2];
  FRoutes.Delete(FRoutes.Count - 1);

  FIsNavigatingBack := True;
  NavigateTo(LTargetAlias);
end;

procedure TFrameRouter.HideCurrent;
var
  Item: TFrameItem;
begin
  if FRegistry.TryGetValue(Normalize(FCurrentAlias), Item) then
    if Assigned(Item.Instance) then
      Item.Instance.Visible := False;
end;

function TFrameRouter.GetCurrentFrame: TFrame;
var
  Item: TFrameItem;
begin
  Result := nil;
  if FRegistry.TryGetValue(Normalize(FCurrentAlias), Item) then
    Result := Item.Instance;
end;

procedure TFrameRouter.ShowMessage(const Msg: string);
begin
  if Assigned(FOnMessage) then
    FOnMessage(Msg)
  else
    FMX.Dialogs.ShowMessage(Msg);
end;

procedure TFrameRouter.UpdateRoute;
var
  LRoutes: string;
  LMessage: string;
begin
  if FRoutes.Count = 0 then LRoutes := '(empty)'
  else LRoutes := string.Join(' -> ', FRoutes.ToArray);

  LMessage := Format('[Router] Current=%s | Count=%d | Routes=%s',
    [FCurrentAlias, FRoutes.Count, LRoutes]);

  if Assigned(FOnMessage) then
    FOnMessage(LMessage);
end;

end.
