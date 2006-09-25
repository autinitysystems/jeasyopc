unit UOPCBrowser;

interface

uses
  Classes, SysUtils, ActiveX, IdIcmpClient, UCustomOPC, OPCEnum, OPCDA;

type

  // Browser methods
  TBrowser = class(TCustomOPC)
  private
    IdIcmpClient : TIdIcmpClient;
  public
    // find opc server on host (OPCEnum)
    function findOPCServers(host : string) : TStringList;
  end;

implementation

{ TBrowser }

function TBrowser.findOPCServers(host : string) : TStringList;
var
  CATIDs        : array of TGUID;
  OPCServerList : TOPCServerList;
begin
  IdIcmpClient := TIdIcmpClient.create;
  IdIcmpClient.host := host;
  Result := TStringList.create;

  // ping server
  try
    try
      IdIcmpClient.ping; // ping host
    except
      on E: Exception do
        raise HostException.Create('Host ' + host + ' not found.');
    end;
  finally
    IdIcmpClient.free;
  end;
  // find opc servers
  CoInitialize(nil);
  SetLength(CATIDs, 2);
  CATIDs[0] := CATID_OPCDAServer20;
  CATIDs[1] := CATID_OPCDAServer30; // new version of servers
  OPCServerList := TOPCServerList.create(host, False, CATIDs);
  try
    try
      OPCServerList.Update; // run finding by OPCEnum
      Result.addStrings(OPCServerList.Items);
    except
      on E: Exception do
        raise NotFoundServers.create('OPC servers not found on ' + host);
    end
  finally
    CoUninitialize; // free COM environment
  end;
  if Result.Count = 0
  then raise NotFoundServers.create('OPC servers not found on ' + host);
end;

end.
