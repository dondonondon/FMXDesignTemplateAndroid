unit BFA.App.Context;

interface

uses
  System.SysUtils,
  BFA.App.Services;

type
  TAppContext = class
  private
    FServices: TAppServices;
    procedure SetServices(AValue: TAppServices);
  public
    destructor Destroy; override;

    property Services: TAppServices read FServices write SetServices;
  end;

var
  AppContext: TAppContext;

implementation

{ TAppContext }

destructor TAppContext.Destroy;
begin
  FreeAndNil(FServices);
  inherited;
end;

procedure TAppContext.SetServices(AValue: TAppServices);
begin
  if FServices = AValue then
    Exit;

  FreeAndNil(FServices);
  FServices := AValue;
end;

end.
