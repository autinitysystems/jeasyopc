unit UCustomOPC;

interface

uses
  Classes, SysUtils, Forms, ActiveX, ComObj, UReport, OPCDA;

type
  // Global exceptions
  ConnectivityException = class(Exception);       // error connection
  HostException = class(Exception);               // no host found
  NotFoundServersException = class(Exception);    // no opc servers found
  UnableIBrowseException = class(Exception);      // IBrowse not initialize
  UnableBrowseBranchException = class(Exception); // browse branch error
  UnableBrowseLeafException = class(Exception);   // browse leaf (item) error
  UnableAddGroupException = class(Exception);     // add group error
  UnableAddItemException = class(Exception);      // add item to group error
  UnableRemoveGroupException = class(Exception);  // remove group error
  UnableRemoveItemException = class(Exception);   // remove item error

const
  // exceptions text
  UnableBrowseBranchExceptionText = 'Unable to browse a branch.';
  UnableBrowseLeafExceptionText = 'Unable to browse a leaf (item).';
  UnableIBrowseExceptionText = 'Unable to initialize IBrowse.';
  ConnectivityExceptionText = 'Connection fails to OPC Server.';
  HostExceptionText = 'Host not found: ';
  NotFoundServersExceptionText = 'OPC servers not found on ';
  UnableAddGroupExceptionText = 'Unable to add group to server:';

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
    ppServerStatus     : POPCSERVERSTATUS; // server status
    HR                 : HResult;          // COM results
    // COM object of OPC server
    ServerIf           : IOPCServer;       // server information
    // report information
    Report             : TReport;          // logging
    // set status message
    procedure setStatusMessage(const idReport : integer; const report: string);
  public
    // create OPC client
    constructor Create(host, ServerProgID, ServerClientHandle : string);
    // get logger
    function getReport : TReport;
    // connect to server
    procedure connect; virtual;
    // disconnect server
    procedure disconnect;
    // get server status
    function getServerStatus : boolean;
  end;

implementation

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
  Report                  := TReport.Create;
end;

procedure TCustomOPC.connect;
begin
  try
    // among other things, this call makes sure that COM is initialized
    Application.Initialize;
    CoInitialize(nil);

    // we will use the custom OPC interfaces, and OPCProxy.dll will handle
    // marshaling for us automatically (if registered)
    if getHostName(Host) = '' // local
    then ServerIf := CreateComObject(ProgIDToClassID(ServerProgID)) as IOPCServer
    else ServerIf := CreateRemoteComObject(Host, ProgIDToClassID(ServerProgID)) as IOPCServer;

    // check COM object
    if ServerIf = nil
    then raise ConnectivityException.Create(ConnectivityExceptionText);
  except
    on E:EOleSysError do
      raise ConnectivityException.Create(ConnectivityExceptionText);
  end;
end;

procedure TCustomOPC.disconnect;
begin
  CoUninitialize;
end;

function TCustomOPC.getServerStatus : boolean;
begin
  Result := Succeeded(ServerIf.getStatus(ppServerStatus));
end;

function TCustomOPC.getReport: TReport;
begin
  Result := Report;
end;

procedure TCustomOPC.setStatusMessage(const idReport: integer;
  const report: string);
begin
  self.Report.setStatusMessage(idReport, report);
end;

end.
