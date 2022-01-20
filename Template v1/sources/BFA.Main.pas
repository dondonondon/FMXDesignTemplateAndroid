unit BFA.Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.Objects,
  System.ImageList, FMX.ImgList, System.Rtti, FMX.Grid.Style, FMX.ScrollBox,
  FMX.Grid,FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListBox, FMX.Ani, System.Threading,
  FMX.ListView.Adapters.Base, FMX.ListView, FMX.Memo, FMX.Edit, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  {$IFDEF ANDROID}
    Androidapi.Helpers, FMX.Platform.Android, System.Android.Service, System.IOUtils,
    FMX.Helpers.Android, Androidapi.JNI.PlayServices, Androidapi.JNI.Os,
  {$ELSEIF Defined(MSWINDOWS)}

  {$ENDIF}
  System.Generics.Collections, System.Net.URLClient, System.Net.HttpClient,
  System.Net.HttpClientComponent, REST.Types;

const
  //FRAME
  C_LOADING = 'LOADING';
  C_HOME = 'HOME';
  C_LOGIN = 'LOGIN';
  C_DETAIL = 'DETAIL';

  CIdle = 400;
  CFontS = 12.5;

procedure fnLoading(FState : Boolean = False);
procedure fnShowMessage(FMessage : String);
procedure fnTransitionFrame(FFrom, FGo : TControl; FFAFrom, FFAGo : TFloatAnimation; isBack : Boolean);
procedure fnGoFrame(FFrom, FGo : String; isBack : Boolean = False);
procedure fnHideFrame(FFrom : String);
procedure fnBack(FProc : TProc = nil);

function fnParsingJSON(req : String; mem : TFDMemTable; FMethod : TRESTRequestMethod = TRESTRequestMethod.rmPOST): Boolean; overload;
function fnParsingJSON(req : String; FMethod : TRESTRequestMethod = TRESTRequestMethod.rmPOST): Boolean; overload;

var
  FListGo : TStringList;
  goFrame, fromFrame, FToken : String;
  tabCount : Integer;
  FPopUp : Boolean;

implementation

uses BFA.Func, BFA.GoFrame, BFA.Rest, frMain, uDM, BFA.Helper.Main;

procedure fnLoading(FState : Boolean);
begin
  TThread.Synchronize(nil, procedure begin
    FMain.heLoading(FState);
  end);
end;

procedure fnShowMessage(FMessage : String);
begin
  TThread.Synchronize(nil, procedure
  begin
    //FMain.TM.Toast(FMessage);
  end);
end;

procedure fnTransitionFrame(FFrom, FGo : TControl; FFAFrom, FFAGo : TFloatAnimation; isBack : Boolean);
begin
  with FMain do begin
    if Assigned(FFrom) then begin
      FFrom.Visible := True;
    end;

    if isBack then begin
      FFAGo.Inverse := True;
      FFAFrom.Inverse := True;

      FGo.SendToBack;

      FFAGo.Parent := FFrom;
      FFAFrom.Parent := FFrom;
    end else begin
      FFAGo.Inverse := False;
      FFAFrom.Inverse := False;

      FGo.BringToFront;
      FGo.Opacity := 0;

      FFAGo.Parent := FGo;
      FFAFrom.Parent := FGo;
    end;

    FFAGo.PropertyName := 'Position.Y';
    FFAFrom.PropertyName := 'Opacity';

    FFAGo.StartValue := 75;
    FFAGo.StopValue := 0;

    FFAFrom.StartValue := 0.035;
    FFAFrom.StopValue := 1;

    FFAGo.Duration := 0.25;
    FFAFrom.Duration := 0.2;

    FFAFrom.Interpolation := TInterpolationType.Quadratic;
    FFAGo.Interpolation := TInterpolationType.Quadratic;

    fnShowFrame;

    Sleep(100);

    FGo.Visible := True;

    FFAGo.Enabled := True;
    FFAFrom.Enabled := True;
  end;
end;

procedure fnGoFrame(FFrom, FGo : String; isBack : Boolean = False);
begin
  fnGetFrame(C_FROM, FFrom);
  fnGetFrame(C_DESTINATION, FGo);

  if not Assigned(VFRGo) then begin
    fnShowMessage('Mohon maaf, terjadi kesalahan');
    Exit;
  end;

  fromFrame := FFrom;
  goFrame := FGo;

  {FMain.loFooter.Visible := True;
  if (goFrame = C_LOADING) or (goFrame = C_LOGIN) or (goFrame = C_CHAT) or (goFrame = C_PREDIKSI) or (goFrame = C_SEARCH) or (goFrame = C_NEWS_DETAIL) then
    FMain.loFooter.Visible := False;}

  tabCount := 0;

  if isBack then
    FListGo.Delete(FListGo.Count - 1)
  else
    FListGo.Add(goFrame);

  fnTransitionFrame(VFRFrom, VFRGo, FMain.faFromX, FMain.faGoX, isBack);
end;

procedure fnHideFrame(FFrom : String);
begin
  if fromFrame <> '' then
    VFRFrom.Visible := False;

  VFRFrom := nil;
  VFRGo := nil;
end;

procedure fnBack(FProc : TProc = nil);
begin
  try
    if goFrame = C_LOADING then
      Exit;

    if FListGo.Count <= 2 then begin
      if (goFrame = C_HOME) or (goFrame = C_HOME) then begin
        if tabCount < 1 then
          fnShowMessage('Tap Dua Kali Untuk Keluar')
        else
          fnShowMessage('Sampai Jumpa Kembali');

        Inc(TabCount);
      end;
    end;

    if FPopUp then begin
      if Assigned(FProc) then
        FProc;
    end else begin
      if Assigned(FProc) then
        FProc;

      if FListGo.Count > 2 then begin
        fnGoFrame(FListGo[FListGo.Count - 1], FListGo[FListGo.Count - 2], True)
      end;
    end;

    if ((goFrame = C_HOME) or (goFrame = C_HOME)) AND (TabCount >= 2) then
    begin
      Application.Terminate;
    end;
  except

  end;
end;

function fnParsingJSON(req : String; mem : TFDMemTable; FMethod : TRESTRequestMethod = TRESTRequestMethod.rmPOST) : Boolean;
begin
  Result := fnParseJSON(DM.RClient, DM.RReq, DM.RResp, DM.rRespAdapter, req, mem, FMethod);
end;

function fnParsingJSON(req : String; FMethod : TRESTRequestMethod = TRESTRequestMethod.rmPOST): Boolean;
begin
  Result := fnParseJSON(DM.RClient, DM.RReq, DM.RResp, DM.rRespAdapter, req, DM.memData, FMethod);
end;


end.
