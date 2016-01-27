unit UCustomOPC;

interface

uses
  Classes, SysUtils, Forms, ActiveX, ComObj, OPCDA, UOPCExceptions;

type

  ///////////////////////////////
  // Main CLASS: OPC standard  //
  // OPC Client library        //
  ///////////////////////////////
  TCustomOPC = class
  protected
    host               : string;           // network host
    serverProgID       : string;           // OPC server name: ProgID
    serverClientHandle : string;           // OPC Client Handle
    HR                 : HResult;          // COM results
    // COM object of OPC server
    ServerIf           : IOPCServer;       // server information
  public
    // create OPC client
    constructor Create(host, ServerProgID, ServerClientHandle : string);
    // connect to server
    procedure connect; virtual;
    // get ServerIf interface
    function getServerIf : IOPCServer;
    // get server status
    function getServerStatus : boolean;
  end;

implementation

uses IdIcmpClient;

// empty string for localhost connection
function getHostName(str: string): string;
begin
  if (str = '127.0.0.1') or
     (str = 'localhost') or
     (str = 'local') then Result := ''
                     else Result := str;
end;

{ TCustomOPC }

constructor TCustomOPC.Create(host, serverProgID, serverClientHandle: string);
begin
  Self.host               := host;
  Self.serverProgID       := serverProgID;
  Self.serverClientHandle := serverClientHandle;
end;

procedure TCustomOPC.connect;
begin
  try
    // we will use the custom OPC interfaces, and OPCProxy.dll will handle
    // marshaling for us automatically (if registered)
    if getHostName(Host) = '' // local
    then ServerIf := CreateComObject(ProgIDToClassID(ServerProgID)) as IOPCServer
    else ServerIf := CreateRemoteComObject(Host, ProgIDToClassID(ServerProgID)) as IOPCServer;

    // check COM object
    if ServerIf = nil
    then raise ConnectivityException.Create(ConnectivityExceptionText);
  except
    on E:Exception do
      raise ConnectivityException.Create(ConnectivityExceptionText);
  end;
end;

function TCustomOPC.getServerStatus : boolean;
var ppServerStatus : POPCSERVERSTATUS; // server status
begin
  try
    Result := Succeeded(ServerIf.getStatus(ppServerStatus));
    CoTaskMemFree(ppServerStatus.szVendorInfo);
    CoTaskMemFree(ppServerStatus);
  except
    on E:Exception do Result := false;
  end;
end;

function TCustomOPC.getServerIf: IOPCServer;
begin
  Result := ServerIf;
end;

end.
