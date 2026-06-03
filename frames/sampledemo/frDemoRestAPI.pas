unit frDemoRestAPI;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects, FMX.Layouts, System.Threading,
  FMX.Edit, FMX.Effects, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  FMX.Memo.Types, FMX.ScrollBox, FMX.Memo;

type
  TFDemoRestAPI = class(TFrame)
    background: TRectangle;
    loMain: TLayout;
    loHeader: TLayout;
    reHeader: TRectangle;
    seHeader: TShadowEffect;
    btnMenu: TCornerButton;
    LabelTitle: TLabel;
    QData: TFDMemTable;
    memData: TMemo;
    btnGet: TCornerButton;
    btnPostBody: TCornerButton;
    btnPostFormData: TCornerButton;
    imgSample: TImage;
    procedure btnMenuClick(Sender: TObject);
    procedure btnGetClick(Sender: TObject);
    procedure btnPostBodyClick(Sender: TObject);
    procedure btnPostFormDataClick(Sender: TObject);
  private
    procedure SetupFrame;
    procedure FillData;
  public
  published
    procedure ShowFrame;
    procedure BackFrame;

    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
  end;

var
  FDemoRestAPI: TFDemoRestAPI;

implementation

{$R *.fmx}

uses BFA.Helper.APIRequest, BFA.Helper.Main, REST.Types, BFA.App.Func;

{ TFTemp }

procedure TFDemoRestAPI.BackFrame;
begin
  TAppHelper.Back;
end;

procedure TFDemoRestAPI.btnGetClick(Sender: TObject);
var
  LURL : String;
  LFileName : String;
begin
  imgSample.Visible := True;
  Randomize;
  memData.Lines.Clear;
  memData.Lines.Add('Loading GET...');

  LURL := 'https://lorem-api.com/api/user/' + (Random(100) + 1).ToString;

  TTask.Run(procedure begin
    TAppHelper.StartLoading('Get Data from URL');
    try
      if not TRESTRequestHelper.Request(QData, LURL) then begin
        FillData;
        memData.Lines.Insert(0, 'GET request failed');
        Exit;
      end;

      LFileName := TGlobalFunction.LoadFile('temp.jpg');
      LURL := QData.FieldByName('avatar').AsString;

      TAppHelper.StartLoading('Download image');
      TNetAPIRequest.DownloadFile(LURL, LFileName);
      if FileExists(LFileName) then begin
        TThread.Synchronize(nil, procedure begin
          imgSample.Bitmap.LoadFromFile(LFileName);
        end);
      end;

      FillData;
    finally
      TAppHelper.StopLoading;
    end;
  end);
end;

procedure TFDemoRestAPI.btnMenuClick(Sender: TObject);
begin
  BackFrame;
end;

procedure TFDemoRestAPI.btnPostBodyClick(Sender: TObject);
const
  LURL = 'https://lorem-api.com/api/jwt';
  LBody =
    '{' +
    '  "username": "string",' +
    '  "password": "string",' +
    '  "role": "string"' +
    '}';
begin
  imgSample.Visible := False;
  memData.Lines.Clear;
  memData.Lines.Add('Loading POST JSON...');

  if not TRESTRequestHelper.Request(QData, LURL, LBody,
    TRESTRequestMethod.rmPOST) then begin
    FillData;
    memData.Lines.Insert(0, 'POST JSON request failed');
    Exit;
  end;

  FillData;
end;

procedure TFDemoRestAPI.btnPostFormDataClick(Sender: TObject);
const
  LURL = 'https://lorem-api.com/api/jwt';
var
  LFormData: TAPIRequest;
begin
  imgSample.Visible := False;
  memData.Lines.Clear;
  memData.Lines.Add('Loading POST form-data...');

  LFormData := TAPIRequest.Create;
  try
    LFormData.Method := TRESTRequestMethod.rmPOST;
    LFormData.AddParameter('username', 'string',
      TRESTRequestParameterKind.pkGETorPOST);
    LFormData.AddParameter('password', 'string',
      TRESTRequestParameterKind.pkGETorPOST);
    LFormData.AddParameter('role', 'string',
      TRESTRequestParameterKind.pkGETorPOST);

    if not TRESTRequestHelper.Request(LFormData, QData, LURL) then begin
      FillData;
      memData.Lines.Insert(0, 'POST form-data request failed');
      Exit;
    end;

    FillData;
  finally
    FreeAndNil(LFormData);
  end;

end;

constructor TFDemoRestAPI.Create(AOwner: TComponent);
begin
  inherited;

end;

destructor TFDemoRestAPI.Destroy;
begin

  inherited;
end;

procedure TFDemoRestAPI.FillData;
begin
  TThread.Queue(nil, procedure begin
    memData.Lines.Clear;

    if not Assigned(QData) then
      Exit;

    if not QData.Active then begin
      memData.Lines.Add('Dataset not active');
      Exit;
    end;

    if QData.IsEmpty then begin
      memData.Lines.Add('No data found');
      Exit;
    end;

    for var LField in QData.Fields do begin
      if LField.IsNull then
        memData.Lines.Add(LField.FieldName + ' : null')
      else
        memData.Lines.Add(LField.FieldName + ' : ' + LField.AsString);
    end;
  end);
end;

procedure TFDemoRestAPI.SetupFrame;
begin

end;

procedure TFDemoRestAPI.ShowFrame;
begin
  SetupFrame;
end;

end.
