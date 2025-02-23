unit frLoading;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects, FMX.Layouts, FMX.Effects, FMX.Ani, System.Threading,
  FMX.Memo.Types, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, FMX.ScrollBox, FMX.Memo,
  System.Rtti, FMX.Grid.Style, FMX.Grid, System.JSON, XMLDoc, XMLIntf, System.StrUtils,
  FMX.Edit;

type
  TFLoading = class(TFrame)
    loMain: TLayout;
    background: TRectangle;
    logo: TImage;
    ShadowEffect1: TShadowEffect;
    Image1: TImage;
    ShadowEffect2: TShadowEffect;
    Image2: TImage;
    ShadowEffect3: TShadowEffect;
    Image3: TImage;
    ShadowEffect4: TShadowEffect;
    Label1: TLabel;
    tiMove: TTimer;
    faOpa: TFloatAnimation;
    Layout1: TLayout;
    memXML: TMemo;
    memResult: TMemo;
    QData: TFDMemTable;
    StringGrid1: TStringGrid;
    btnCheck: TCornerButton;
    Edit1: TEdit;
    procedure tiMoveTimer(Sender: TObject);
    procedure faOpaFinish(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure btnCheckClick(Sender: TObject);
  private
    function FindNode(AXML : IXMLNode; ANode : String) : IXMLNode;
  public
  published
    procedure Show;

    constructor Create(AOwner : TComponent); override;
  end;

var
  FLoading: TFLoading;

implementation

{$R *.fmx}

uses frMain, BFA.Global.Variable,
  BFA.Control.Form.Message, BFA.Control.Frame, BFA.Control.Keyboard,
  BFA.Control.Permission, BFA.Control.PushNotification, BFA.Global.Func,
  BFA.Helper.Main, BFA.Helper.MemoryTable;

procedure TFLoading.btnCheckClick(Sender: TObject);
var
  XMLDoc: IXMLDocument;
  RootNode, TempNode: IXMLNode;
begin
  XMLDoc := LoadXMLData(memXML.Text);
  RootNode := XMLDoc.DocumentElement;

  var SL := TStringList.Create;
  try  
    TempNode := RootNode;
    TempNode := FindNode(TempNode, Edit1.Text);

    if TempNode.AttributeNodes.Count > 0 then begin
      SL.Add('Start Load AttributeNodes');
      for var i := 0 to TempNode.AttributeNodes.Count - 1 do begin
        SL.Add(TempNode.AttributeNodes[i].NodeName);  //field
        SL.Add('==================================');
          SL.Add(TempNode.Attributes[TempNode.AttributeNodes[i].NodeName]); //value
        SL.Add('==================================');
      end;     
      SL.Add('End Load AttributeNodes');
    end;
          
    SL.Add('');
    if TempNode.IsTextElement then
      SL.Add('Value : ' + TempNode.Text) else
      SL.Add('XML : ' + TempNode.XML);  


    SL.Add('');
    SL.Add('Start Load Nodes');
    for var i := 0 to TempNode.ChildNodes.Count - 1 do begin
      SL.Add(TempNode.ChildNodes[i].NodeName);
    end;       
    SL.Add('End Load Nodes');

  
//    TempNode := RootNode;
//    TempNode := FindNode(TempNode, 'METADATA.FIELDS.FIELD[1].PARAM');  
//
//    SL.Add(TempNode.XML);
//    for var i := 0 to TempNode.AttributeNodes.Count - 1 do begin
//      SL.Add(TempNode.AttributeNodes[i].NodeName);  //field
//      SL.Add('==================================');
//        SL.Add(TempNode.Attributes[TempNode.AttributeNodes[i].NodeName]); //value
//      SL.Add('==================================');
//    end;
//    
//    TempNode := RootNode;
//    TempNode := FindNode(TempNode, 'METADATA.FIELDS.FIELD[2]');  
//
//    SL.Add(TempNode.XML);
//    for var i := 0 to TempNode.AttributeNodes.Count - 1 do begin
//      SL.Add(TempNode.AttributeNodes[i].NodeName);  //field
//      SL.Add('==================================');
//        SL.Add(TempNode.Attributes[TempNode.AttributeNodes[i].NodeName]); //value
//      SL.Add('==================================');
//    end;


    //TEST=========================================================

    
//    SL.Add(RootNode.XML);
//    for var i := 0 to RootNode.ChildNodes.Count - 1 do begin
//      SL.Add(RootNode.ChildNodes[i].NodeName);
//    end;


//    for var i := 0 to RootNode.AttributeNodes.Count - 1 do begin
//      SL.Add(RootNode.AttributeNodes[i].NodeName);  //field
//      SL.Add('==================================');
//        SL.Add(RootNode.Attributes[RootNode.AttributeNodes[i].NodeName]); //value
//      SL.Add('==================================');
//    end;
//
//    for var i := 0 to RootNode.ChildNodes.Count - 1 do begin
//      SL.Add(RootNode.ChildNodes[i].NodeName);
//      SL.Add('==================================');
//        var LNode := RootNode.ChildNodes.FindNode(RootNode.ChildNodes[i].NodeName);
//        SL.Add(LNode.XML);
//      SL.Add('==================================');
//    end;
    memResult.Text := SL.Text;
  finally
    SL.Free;
  end;
end;

function TFLoading.FindNode(AXML : IXMLNode; ANode: String): IXMLNode;
var
  ArrayNode : TArray<String>;
  LNode : IXMLNode;
begin
  memResult.Lines.Clear;
  ArrayNode := SplitString(ANode, '.');
  LNode := AXML;
  for var i := 0 to Length(ArrayNode) - 1 do begin
    if ContainsStr(ArrayNode[i], '[') AND ContainsStr(ArrayNode[i], ']') then begin
      var LIndex := Copy(ArrayNode[i], Pos('[', ArrayNode[i]) + 1, Pos(']', ArrayNode[i]) - Pos('[', ArrayNode[i]) - 1);
      var LField := Copy(ArrayNode[i], 1, Pos('[', ArrayNode[i]) - 1);
//      LNode := LNode.ChildNodes.FindNode(LField);
//      var LSubNode := LNode;
      for var ii := 0 to LNode.ChildNodes.Count - 1 do begin
        if ii = StrToInt(LIndex) then begin
          LNode := LNode.ChildNodes[ii];
          Break;
        end;
      end;
    end else begin
      LNode := LNode.ChildNodes.FindNode(ArrayNode[i]);
    end;
  end;

  Result := LNode;
end;

constructor TFLoading.Create(AOwner: TComponent);
begin
  inherited;
end;

procedure TFLoading.faOpaFinish(Sender: TObject);
begin
  TFloatAnimation(Sender).Enabled := False;

{$REGION 'ADD FRAME SIDEBAR'}
  if Assigned(FSidebar) then begin
    FSidebar.LoadListMenu;
    FSidebar.MultiView.Enabled := False;
  end;
{$ENDREGION}

  tiMove.Enabled := True;
end;

procedure TFLoading.Label1Click(Sender: TObject);
begin
  ShowMessage(TFLoading.ClassName);
end;

procedure TFLoading.Show;
begin
  loMain.Visible := False;
  TTask.Run(procedure begin
    Sleep(Round(250));
    TThread.Synchronize(TThread.CurrentThread, procedure begin
      loMain.Opacity := 0;
      loMain.Visible := True;
      faOpa.Enabled := True;
    end);
  end).Start;
end;

procedure TFLoading.tiMoveTimer(Sender: TObject);
begin
  tiMove.Enabled := False;
  Frame.GoFrame(View.DETAIL);
//  Frame.GoFrame(View.LOGIN);
end;

end.
