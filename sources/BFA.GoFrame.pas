unit BFA.GoFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.Objects,
  System.Rtti, System.Threading,
  FMX.ListView.Adapters.Base,
  {$IFDEF ANDROID}
    Androidapi.Helpers, FMX.Platform.Android, System.Android.Service, System.IOUtils,
    FMX.Helpers.Android, Androidapi.JNI.PlayServices, Androidapi.JNI.Os,
  {$ENDIF}
  System.Generics.Collections;

type
  TFrameClass = class of TFrame;
  TExec = procedure of object;

procedure fnCallFrame(FParent: TLayout; FFClass: TFrameClass);
procedure createFrame;

procedure fnGetFrame(FState, FTrans : String);
procedure fnShowFrame;

var
  genFrame: TFrame;
  VFRFrom, VFRGo, tFR : TControl;

const
  C_BACK = 'BACK';
  C_GO = 'DESTINATION';
  C_FROM = 'FROM';
  C_DESTINATION = 'DESTIONATION';

implementation

uses BFA.Func, BFA.Helper.Control, BFA.Helper.Main, frMain, frHome, frLoading,
  BFA.Main, frDetail;

procedure fnCallFrame(FParent: TLayout; FFClass: TFrameClass);
begin
  try
    genFrame := FFClass.Create(FMain);
    genFrame.Parent := FParent;
    genFrame.Visible := False;
    //genFrame.Align := TAlignLayout.Contents;
    genFrame.setAnchorContent;
  except
    on E : Exception do begin
      ShowMessage(E.Message + ''#13 + E.ClassName);
    end;
  end;
end;

procedure createFrame;
begin
  try
    fnCallFrame(FMain.loFrame, frLoading.TFLoading);
    FLoading := TFLoading(genFrame);

    fnCallFrame(FMain.loFrame, frHome.TFHome);
    FHome := TFHome(genFrame);

    fnCallFrame(FMain.loFrame, frDetail.TFDetail);
    FDetail := TFDetail(genFrame);
  except

  end;
end;

procedure fnGetFrame(FState, FTrans : String);
begin
  if FTrans = '' then
    Exit;

  if FTrans = C_LOADING then
    tFR := FLoading
  else if FTrans = C_HOME then
    tFR := FHome
  else if FTrans = C_DETAIL then
    tFR := FDetail;

  if FState = C_FROM then
    VFRFrom := tFR
  else if FState = C_DESTINATION then
    VFRGo := tFR;
end;

procedure fnShowFrame;
var
  Routine : TMethod;
  Exec : TExec;
begin
  Routine.Data := Pointer(VFRGo);
  Routine.Code := VFRGo.MethodAddress('FirstShow');
  if NOT Assigned(Routine.Code) then
    Exit;

  Exec := TExec(Routine);
  Exec;
end;

end.

