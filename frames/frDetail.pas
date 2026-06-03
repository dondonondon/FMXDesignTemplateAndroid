unit frDetail;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects, FMX.Layouts, System.Threading,
  FMX.Memo.Types, FMX.ScrollBox, FMX.Memo, FMX.Effects, FMX.ImgList, FMX.ListBox;

type
  TFDetail = class(TFrame)
    background: TRectangle;
    loMain: TLayout;
    loHeader: TLayout;
    reHeader: TRectangle;
    seHeader: TShadowEffect;
    btnMenu: TCornerButton;
    LabelTitle: TLabel;
    lbData: TListBox;
    ListBoxItem1: TListBoxItem;
    ListBoxItem2: TListBoxItem;
    ListBoxItem3: TListBoxItem;
    ListBoxItem4: TListBoxItem;
    ListBoxItem5: TListBoxItem;
    ListBoxItem6: TListBoxItem;
    ListBoxItem7: TListBoxItem;
    procedure btnMenuClick(Sender: TObject);
    procedure lbDataItemClick(const Sender: TCustomListBox;
      const Item: TListBoxItem);
  private
    procedure SetupFrame;
    procedure LoadingIndicator;
    procedure ToastMessage;
  public
  published
    procedure ShowFrame;
    procedure BackFrame;

    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
  end;

var
  FDetail: TFDetail;

const
  TOAST_MESSAGE = 0;
  LOADING_INDIDICATOR = 1;

implementation

{$R *.fmx}

uses
  BFA.Helper.Main, uDM, BFA.Control.Form.Message;

{ TFDetail }

procedure TFDetail.BackFrame;
begin
  TAppHelper.Back;
end;

procedure TFDetail.btnMenuClick(Sender: TObject);
begin
  TAppHelper.ShowSidebar;
end;

constructor TFDetail.Create(AOwner: TComponent);
begin
  inherited;

end;

destructor TFDetail.Destroy;
begin

  inherited;
end;

procedure TFDetail.lbDataItemClick(const Sender: TCustomListBox;
  const Item: TListBoxItem);
begin
  if Item.Tag < 0 then begin
    TAppHelper.NavigateTo(Item.ItemData.Detail);
  end else begin
    if Item.Tag = LOADING_INDIDICATOR then begin
      LoadingIndicator;
    end else if Item.Tag = TOAST_MESSAGE then begin
      ToastMessage;
    end;
  end;
end;

procedure TFDetail.LoadingIndicator;
begin
  TTask.Run(procedure begin
    TAppHelper.StartLoading('This is loading indicator');
    try
      Sleep(1500);
    finally
      TAppHelper.StopLoading;
    end;
  end);
end;

procedure TFDetail.SetupFrame;
begin

end;

procedure TFDetail.ShowFrame;
begin
  SetupFrame;
end;

procedure TFDetail.ToastMessage;
begin
  Randomize;
  var LInteger : Integer;

  LInteger := Random(6);
  if LInteger = 0 then TAppHelper.ToastMessage('This is toast message information', Information)
  else if LInteger = 1 then TAppHelper.ToastMessage('This is toast message Success', Success)
  else if LInteger = 2 then TAppHelper.ToastMessage('This is toast message Fail / Error', Error)
  else if LInteger = 3 then TAppHelper.PopupMessage('This is popup message information', Information)
  else if LInteger = 4 then TAppHelper.PopupMessage('This is popup message Success', Success)
  else if LInteger = 5 then TAppHelper.PopupMessage('This is popup message Fail / Error', Error)

end;

end.
