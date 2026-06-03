unit frLogin;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects, FMX.Layouts, System.Threading,
  FMX.Edit, FMX.Effects, IdGlobal, FMX.ImgList;

type
  TFLogin = class(TFrame)
    loMain: TLayout;
    background: TRectangle;
    reCenter: TRectangle;
    seCenter: TShadowEffect;
    logo: TImage;
    ShadowEffect1: TShadowEffect;
    LabelTitle: TLabel;
    LabelWelcome: TLabel;
    Label1: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    Label2: TLabel;
    Edit3: TEdit;
    Label3: TLabel;
    pwIcon: TPasswordEditButton;
    CheckBox1: TCheckBox;
    btnSignIn: TCornerButton;
    LabelVersion: TLabel;
    Glyph1: TGlyph;
    Glyph2: TGlyph;
    Glyph3: TGlyph;
    Glyph4: TGlyph;
    procedure btnSignInClick(Sender: TObject);
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
  FLogin: TFLogin;

implementation

{$R *.fmx}

uses
  BFA.App.Types,
  BFA.Helper.Main, uDM, BFA.App.Context;

{ TFTemp }

procedure TFLogin.BackFrame;
begin

end;

procedure TFLogin.btnSignInClick(Sender: TObject);
begin
  TTask.Run(procedure begin
    TAppHelper.StartLoading('Sign in user');
    try
      Sleep(1250);
      TAppHelper.NavigateTo(TView.HOME);
      TAppHelper.EnabledSidebar(True);
    finally
      TAppHelper.StopLoading;
    end;
  end);
end;

constructor TFLogin.Create(AOwner: TComponent);
begin
  inherited;
end;

destructor TFLogin.Destroy;
begin

  inherited;
end;

procedure TFLogin.SetupFrame;
begin

end;

procedure TFLogin.ShowFrame;
begin
  SetupFrame;
end;

end.
