unit frConfirmation;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Layouts, FMX.Controls.Presentation, BFA.Control.Form.Message;

type

  TFConfirmation = class(TFrame)
    background: TRectangle;
    loMain: TLayout;
    reMain: TRectangle;
    lblTitle: TLabel;
    lblCaption: TLabel;
    loDesc: TLayout;
    loButton: TLayout;
    btnNo: TCornerButton;
    btnYes: TCornerButton;
    reColor: TRectangle;
    reSideColor: TRectangle;
    lblDesc: TLabel;
    procedure btnYesClick(Sender: TObject);
    procedure btnNoClick(Sender: TObject);
  private
    ProcOK : TProc;
    FCancelProcedure: TProc;
    procedure SetTitle(const Value: String);
    procedure SetCaption(const Value: String);
    procedure SetDescription(const Value: String);
    procedure SetType(const Value: TTypeMessage);
    procedure SetButtonCancel(const Value: String);
    procedure SetButtonConfirmationCaption(const Value: String);
    procedure SetVisibleButtonCancel(const Value: Boolean);
  public
    procedure Show(AProc : TProc = nil);

    property CancelProcedure : TProc read FCancelProcedure write FCancelProcedure;
    property Title : String write SetTitle;
    property Caption : String write SetCaption;
    property Description : String write SetDescription;
    property TypePopup : TTypeMessage write SetType;
    property ButtonConfirmationCaption : String write SetButtonConfirmationCaption;
    property ButtonCancel : String write SetButtonCancel;
    property VisibleButtonCancel : Boolean write SetVisibleButtonCancel;

    constructor Create(AOwner : TComponent); override;
  end;

var FConfirmation : TFConfirmation;

implementation

{$R *.fmx}

{ TFConfirmation }

procedure TFConfirmation.btnNoClick(Sender: TObject);
begin
  if Assigned(CancelProcedure) then CancelProcedure;
  Self.Visible := False;
//  Self.DisposeOf;
end;

procedure TFConfirmation.btnYesClick(Sender: TObject);
begin
  if Assigned(ProcOK) then ProcOK;
  Self.Visible := False;
//  Self.DisposeOf;
end;

constructor TFConfirmation.Create(AOwner: TComponent);
begin
  inherited;
  reSideColor.Fill.Color := $FF4BC961;
  reColor.Fill.Color := $FF4BC961;

  Self.Visible := False;
end;

procedure TFConfirmation.SetButtonCancel(const Value: String);
begin
  btnNo.Text := Value;
end;

procedure TFConfirmation.SetButtonConfirmationCaption(const Value: String);
begin
  btnYes.Text := Value;
end;

procedure TFConfirmation.SetCaption(const Value: String);
begin
  lblCaption.Text := Value;
end;

procedure TFConfirmation.SetDescription(const Value: String);
begin
  lblDesc.Text := Value;
end;

procedure TFConfirmation.SetTitle(const Value: String);
begin
  lblTitle.Text := Value;
end;

procedure TFConfirmation.SetType(const Value: TTypeMessage);
var
  FColor : Cardinal;
begin
  if Value = TTypeMessage.Success then begin
    FColor := $FF4BC961;
    btnYes.StyleLookup := 'btnGreen';
  end else if Value = TTypeMessage.Error then begin
    FColor := $FFFF6969;
    btnYes.StyleLookup := 'btnRed';
  end else if Value = TTypeMessage.Information then begin
    FColor := $FF36414A;
  end;

  reSideColor.Fill.Color := FColor;
  reColor.Fill.Color := FColor;
end;

procedure TFConfirmation.SetVisibleButtonCancel(const Value: Boolean);
begin
  btnNo.Visible := Value;
end;

procedure TFConfirmation.Show(AProc: TProc);
var
  ActiveForm : TForm;
begin
  ActiveForm := TForm(Screen.ActiveForm);
  if not Assigned(ActiveForm) then begin
    ShowMessage('Active Form Not Found!');
    Self.Visible := False;
//    Self.DisposeOf;
  end else begin
    if Assigned(AProc) then ProcOk := AProc;
    Self.Visible := True;
    Self.Parent := ActiveForm;
    Self.Align := TAlignLayout.Contents;
  end;
end;

end.
