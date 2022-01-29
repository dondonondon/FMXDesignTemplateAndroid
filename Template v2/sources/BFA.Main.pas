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
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, REST.Client, REST.Response.Adapter,
  {$IFDEF ANDROID}
    Androidapi.Helpers, FMX.Platform.Android, System.Android.Service, System.IOUtils,
    FMX.Helpers.Android, Androidapi.JNI.PlayServices, Androidapi.JNI.Os,
  {$ELSEIF Defined(MSWINDOWS)}

  {$ENDIF}
  System.Generics.Collections, System.Net.URLClient, System.Net.HttpClient,
  System.Net.HttpClientComponent, Rest.Types;

procedure fnLoading(FState : Boolean = False);
procedure fnShowMessage(FText : String);
procedure fnTransitionFrame(FFrom, FGo : TControl; FLFrom, FLGo : TFloatAnimation; FIsBack : Boolean);
procedure fnGoFrame(FFrom, FGo : String; FIsBack : Boolean = False);
procedure fnBack(FProc : TProc = nil);
procedure fnCreateFrame;

function fnParsingJSON(req : String; mem : TFDMemTable; FMethod : TRESTRequestMethod = TRESTRequestMethod.rmPOST): Boolean; overload;
function fnParsingJSON(req : String; FMethod : TRESTRequestMethod = TRESTRequestMethod.rmPOST): Boolean; overload;

implementation

uses BFA.Env, BFA.GoFrame, frMain, frDetail, frHome, frLoading, frLogin, frTemp,
  BFA.Rest, uDM, BFA.Helper.Main, frAccount;

procedure fnLoading(FState : Boolean);
begin
  TThread.Synchronize(nil, procedure begin
    FMain.heLoading(FState);
  end);
end;

procedure fnShowMessage(FText : String);
begin
  TThread.Synchronize(nil, procedure begin
    ShowMessage(FText);
  end);
end;

procedure fnTransitionFrame(FFrom, FGo : TControl; FLFrom, FLGo : TFloatAnimation; FIsBack : Boolean);
begin
  with FMain do begin
    if Assigned(FFrom) then begin
      FFrom.Visible := True;
    end;

    if FIsBack then begin
      FLGo.Inverse := True;
      FLFrom.Inverse := True;

      FGo.SendToBack;

      FLGo.Parent := FFrom;
      FLFrom.Parent := FFrom;
    end else begin
      FLGo.Inverse := False;
      FLFrom.Inverse := False;

      FGo.BringToFront;
      FGo.Opacity := 0;

      FLGo.Parent := FGo;
      FLFrom.Parent := FGo;
    end;

    FLGo.PropertyName := 'Position.Y';
    FLFrom.PropertyName := 'Opacity';

    FLGo.StartValue := 75;
    FLGo.StopValue := 0;

    FLFrom.StartValue := 0.035;
    FLFrom.StopValue := 1;

    FLGo.Duration := 0.25;
    FLFrom.Duration := 0.2;

    FLFrom.Interpolation := TInterpolationType.Quadratic;
    FLGo.Interpolation := TInterpolationType.Quadratic;

    LListFrame.Show(goFrame);

    FLGo.Enabled := True;
    FLFrom.Enabled := True;
  end;
end;

procedure fnGoFrame(FFrom, FGo : String; FIsBack : Boolean = False);
begin
  if not Assigned(LListFrame.getFrame(FGo)) then begin
    fnShowMessage('Mohon maaf, terjadi kesalahan');
    Exit;
  end;

  goFrame := FGo;
  fromFrame := FFrom;

  FTabCount := 0;

  if not FIsBack then
    FListGo.Add(goFrame);

  fnTransitionFrame(LListFrame.getFrame(FFrom), LListFrame.getFrame(FGo), FMain.faFromX, FMain.faGoX, FIsBack);
end;

procedure fnBack(FProc : TProc = nil);
begin
  if (goFrame = C_HOME) OR (goFrame = C_LOADING) OR (goFrame = C_LOGIN) then begin //customize
    if FTabCount < 1 then begin
      fnShowMessage('Tap Dua Kali Untuk Keluar')
    end else begin
      fnShowMessage('Sampai Jumpa Kembali');
      Application.Terminate;
    end;

    Inc(FTabCount);
    Exit;
  end;

  if FPopUp then begin
    if Assigned(FProc) then
      FProc;
  end else begin
    if Assigned(FProc) then
      FProc;

    fnGoFrame(FListGo[FListGo.Count - 1], FListGo[FListGo.Count - 2], True);
    FListGo.Delete(FListGo.Count - 1);
  end;

end;

procedure fnCreateFrame;
begin
  FLoading := TFLoading(FLoading.CallFrame(FMain.loFrame, TFLoading, C_LOADING));
  FHome := TFHome(FHome.CallFrame(FMain.loFrame, TFHome, C_HOME));
  FLogin := TFLogin(FLogin.CallFrame(FMain.loFrame, TFLogin, C_LOGIN));
  FDetail := TFDetail(FDetail.CallFrame(FMain.loFrame, TFDetail, C_DETAIL));
  FTemp := TFTemp(FTemp.CallFrame(FMain.loFrame, TFTemp, C_TEMP));
  FAccount := TFAccount(FAccount.CallFrame(FMain.loFrame, TFAccount, C_ACCOUNT));

  LListFrame.HideAll;
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
