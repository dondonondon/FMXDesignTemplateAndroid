unit frHome;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects, FMX.Layouts, System.Threading,
  FMX.Edit, FMX.Effects, System.ImageList, FMX.ImgList,
  FMX.ListBox;

type
  TFHome = class(TFrame)
    loMain: TLayout;
    loHeader: TLayout;
    reHeader: TRectangle;
    seHeader: TShadowEffect;
    btnMenu: TCornerButton;
    lblWarehouseName: TLabel;
    lblWarehouseCode_: TLabel;
    lblName: TLabel;
    lblRole: TLabel;
    lbHeader: TListBox;
    ListBoxItem1: TListBoxItem;
    Rectangle1: TRectangle;
    lblHeaderNeedQC: TLabel;
    Label5: TLabel;
    ListBoxItem2: TListBoxItem;
    Rectangle2: TRectangle;
    lblHeaderPending: TLabel;
    Label8: TLabel;
    ListBoxItem3: TListBoxItem;
    Rectangle3: TRectangle;
    lblHeaderPosted: TLabel;
    Label10: TLabel;
    loTitleTransaction: TLayout;
    Glyph1: TGlyph;
    Label1: TLabel;
    img: TImageList;
    lbTransaction: TListBox;
    ListBoxItem4: TListBoxItem;
    loTempTransaction: TLayout;
    reTempTransaction: TRectangle;
    ciTempTransaction: TCircle;
    lblTempTransaction: TLabel;
    imgTempTransaction: TImage;
    ListBoxItem5: TListBoxItem;
    Layout1: TLayout;
    Rectangle4: TRectangle;
    Circle1: TCircle;
    Label2: TLabel;
    Image1: TImage;
    ListBoxItem6: TListBoxItem;
    Layout2: TLayout;
    Rectangle5: TRectangle;
    Circle2: TCircle;
    Label3: TLabel;
    Image2: TImage;
    ListBoxItem7: TListBoxItem;
    Layout3: TLayout;
    Rectangle6: TRectangle;
    Circle3: TCircle;
    Label4: TLabel;
    Image3: TImage;
    ListBoxItem8: TListBoxItem;
    Layout4: TLayout;
    Rectangle7: TRectangle;
    Circle4: TCircle;
    Label6: TLabel;
    Image4: TImage;
    background: TRectangle;
    loTitleApproval: TLayout;
    Glyph2: TGlyph;
    Label7: TLabel;
    lbApproval: TListBox;
    vsMain: TVertScrollBox;
    ListBoxItem9: TListBoxItem;
    loTempApproval: TLayout;
    Rectangle8: TRectangle;
    lblTempApprovalTitle: TLabel;
    reTempBackgroundImage: TRectangle;
    imgTempApproval: TImage;
    lblTempApprovalDetail: TLabel;
    reTempApprovalNotifCount: TRectangle;
    lblTempApprovalNotifCount: TLabel;
    ListBoxItem10: TListBoxItem;
    Layout5: TLayout;
    Rectangle9: TRectangle;
    Label9: TLabel;
    Rectangle10: TRectangle;
    Image5: TImage;
    Label11: TLabel;
    Rectangle11: TRectangle;
    Label12: TLabel;
    procedure btnMenuClick(Sender: TObject);
  private
    procedure SetupFrame;
  public
  published
    procedure ShowFrame;
    procedure BackFrame;

    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
  end;

var
  FHome: TFHome;

implementation

{$R *.fmx}

uses BFA.Helper.Main, uDM, BFA.App.Types;

{ TFTemp }

procedure TFHome.BackFrame;
begin
  TAppHelper.Back;
end;

procedure TFHome.btnMenuClick(Sender: TObject);
begin
  TAppHelper.ShowSidebar;
end;

constructor TFHome.Create(AOwner: TComponent);
begin
  inherited;
  vsMain.AniCalculations.BoundsAnimation := True;
end;

destructor TFHome.Destroy;
begin

  inherited;
end;

procedure TFHome.SetupFrame;
begin
  TAppHelper.SelectedMenuSidebar(TView.HOME); //highlight menu sideber Home
  TAppHelper.ChangeColorStatusBar($FFF7F9FB, False);
end;

procedure TFHome.ShowFrame;
begin
  SetupFrame;
end;

end.
