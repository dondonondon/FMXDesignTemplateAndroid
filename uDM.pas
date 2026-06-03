unit uDM;

interface

uses
  System.SysUtils, System.Classes, Data.DB, DBAccess, Uni, System.ImageList,
  FMX.ImgList;

type
  TDM = class(TDataModule)
    ListImage: TImageList;
    ListIcon: TImageList;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DM: TDM;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

end.
