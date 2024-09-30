unit BFA.Helper.Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, System.Generics.Collections, System.Net.URLClient, System.Net.HttpClient,
  System.Net.HttpClientComponent, FireDAC.Stan.Intf, FireDAC.Stan.Option, System.Json, System.NetEncoding, Data.DBXJsonCommon,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs, FireDAC.FMXUI.Wait,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, FMX.ListView.Types,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, System.DateUtils,
  FMX.Objects, System.IniFiles, System.IOUtils, FMX.Grid.Style, FMX.Grid, REST.Json, FMX.ListBox, System.RegularExpressions,
  BFA.Control.Rest, Rest.Types,
  BFA.Control.Form.Message,
  System.Threading;

type
  HelperFunction = class
    class procedure MoveToFrame(AAlias : String);

    class procedure ShowToastMessage(AMessage : String; ATypeMessage : TTypeMessage = TTypeMessage.Information);
    class procedure ShowPopUpMessage(AMessage : String; ATypeMessage : TTypeMessage = TTypeMessage.Information); overload;
    class procedure ShowPopUpMessage(AMessage : String; ATypeMessage : TTypeMessage; AProc : TProc); overload;

    class procedure Loading(AState : Boolean = False; AMessage : String = '');
    class procedure StartLoading(AMessage : String = '');
    class procedure StopLoading;

    class procedure ShowSidebar;
    class procedure SetSelectedMenuSidebar(AAlias : String);
  end;

  HelperRest = class
    class function Request(AData : TFDMemTable; AURL, ABodyJSON : String) : Boolean;
  end;

implementation

uses frMain, BFA.Global.Variable, BFA.Control.Frame, BFA.Control.Keyboard,
  BFA.Control.Permission, BFA.Control.PushNotification, BFA.Global.Func,
  BFA.Helper.MemoryTable, BFA.Helper.Bitmap, uDM;

{ Helper }

class procedure HelperFunction.StartLoading(AMessage: String);
begin
  Loading(True, AMessage);
end;

class procedure HelperFunction.StopLoading;
begin
  Loading(False);
end;

class procedure HelperFunction.Loading(AState: Boolean; AMessage: String);
begin
  TThread.Synchronize(nil, procedure begin
    Helper.Loading(AState, AMessage);
  end);
end;

class procedure HelperFunction.MoveToFrame(AAlias: String);
begin
  TThread.Synchronize(nil, procedure begin
    Frame.GoFrame(AAlias);
  end);
end;

class procedure HelperFunction.ShowSidebar;
begin
{$REGION 'ADD FRAME SIDEBAR'}
  if Assigned(FSidebar) then begin
    if not FSidebar.MultiView.Enabled then
      FSidebar.MultiView.Enabled := True;

    if FSidebar.MultiView.IsShowed then
      FSidebar.MultiView.HideMaster
    else
      FSidebar.MultiView.ShowMaster;
  end;
{$ENDREGION}
end;

class procedure HelperFunction.SetSelectedMenuSidebar(AAlias: String);
begin
{$REGION 'ADD FRAME SIDEBAR'}
  if Assigned(FSidebar) then
    FSidebar.SetSelectedMenu(AAlias);
{$ENDREGION}
end;

class procedure HelperFunction.ShowPopUpMessage(AMessage: String;
  ATypeMessage: TTypeMessage; AProc: TProc);
begin
  TThread.Synchronize(nil, procedure begin
    Helper.ShowPopUpMessage(AMessage, ATypeMessage, AProc);
  end);
end;

class procedure HelperFunction.ShowPopUpMessage(AMessage: String;
  ATypeMessage: TTypeMessage);
begin
  TThread.Synchronize(nil, procedure begin
    Helper.ShowPopUpMessage(AMessage, ATypeMessage);
  end);
end;

class procedure HelperFunction.ShowToastMessage(AMessage: String;
  ATypeMessage: TTypeMessage);
begin
  TThread.Synchronize(nil, procedure begin
    Helper.ShowToastMessage(AMessage, ATypeMessage);
  end);
end;

{ HelperRest }

class function HelperRest.Request(AData: TFDMemTable;
  AURL, ABodyJSON: String): Boolean;
begin
  Result := False;

  var Rest := TRequestAPI.Create;
  var TempData := TFDMemTable.Create(nil);
  try
    try
      Rest.Request.Timeout := 15000;
      Rest.Request.ConnectTimeout := 15000;

      Rest.URL := AURL;
      Rest.Method := TRESTRequestMethod.rmPOST;
      Rest.Data := TempData;

      Rest.AddBody(ABodyJSON, TRESTContentType.ctAPPLICATION_JSON);

      Rest.Execute(True);

      AData.FillDataFromString(Rest.Content);

      if Rest.StatusCode = 200 then begin
        if AData.FieldByName('status').AsString = '200' then begin
          Result := True;
          AData.FillDataFromString(AData.FieldByName('data').AsString);
        end;
      end;
    except on E: Exception do
      begin
        Result := False;
        TFDMemTableHelperFunction.FillErrorParse(AData, E.Message, E.ClassName, False);
      end;
    end;
  finally
    TempData.DisposeOf;
    Rest.DisposeOf;
  end;
end;

end.

