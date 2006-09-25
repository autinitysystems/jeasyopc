unit UEasyOPCThread;

interface

uses
  Classes, ActiveX, OPCDA, ComObj, SysUtils, UReport;

const
  TRYCONNECT  = 3000;  // ms - try to reconnect to OPC server

type
  // EasyOPCThread exception
  EasyOPCThreadException = class(Exception);

  // parent of OPC client classes
  EasyOPCThread = class(TThread)
  public
    constructor create(host, ServerProgID, ServerClientHandle : string);
    function getReport : TReport;
  protected
    // attributes
    host           : string;
    serverProgID   : string;
    active         : boolean;
    hr             : HResult;
    ppServerStatus : POPCSERVERSTATUS;  // server status
    serverIf       : IOPCServer;
    Report         : TReport;

    // thread action
    procedure execute; override;
    // abstract method for opc processing
    procedure process; virtual; abstract;
    // make opc connection:
    function connect(host, serverProgID : string) : IOPCServer;
    // get connection activity
    function getServerStatus: HResult;
    // set status message
    procedure setStatusMessage(const idReport : integer; const report: string);
  end;

implementation

{ UEasyOPCThread }

constructor EasyOPCThread.Create(host, ServerProgID, ServerClientHandle: string);
begin
  self.host := host;
  self.ServerProgID := ServerProgID;
  active := false;
end;

procedure EasyOPCThread.execute;
begin
  active := true;
  while active do
  begin
    try
      // try connect to OPC server
      serverIf := connect(host, serverProgID);

      while active do // life-cycle
      begin
        process; // make process
        suspend; // sleep thread

        if not Succeeded(getServerStatus) // status of OPC Server
        then begin
          SetStatusMessage(ID105, ServerProgID);
          raise EasyOPCThreadException.Create('');
        end;
      end;

    except // EasyOPCThreadException
      on E:EasyOPCThreadException do
      begin
        sleep(TRYCONNECT);
        setStatusMessage(ID107, host + '//' + ServerProgID);
      end;
    end;
  end; // while ACTIVE

  SetStatusMessage(ID207, '');
end;

function GetHostName(str: string): string;
begin
  if (str = '127.0.0.1') or
     (str = 'localhost') or
     (str = 'local')
  then Result := ''
  else Result := str;
end;

function EasyOPCThread.getServerStatus: HResult;
begin
  Result := serverIf.getStatus(ppServerStatus);
end;

function EasyOPCThread.connect(host, serverProgID : string) : IOPCServer;
begin
  try
    CoInitialize(nil);
    if GetHostName(host) = ''
    then // local server
      Result := CreateComObject(ProgIDToClassID(ServerProgID)) as IOPCServer
    else // network server
      Result := CreateRemoteComObject(host, ProgIDToClassID(ServerProgID)) as IOPCServer;
  except
    on E:EOleSysError do raise EasyOPCThreadException.Create('');
  end;
end;

function EasyOPCThread.getReport: TReport;
begin
  Result := Report;
end;

procedure EasyOPCThread.setStatusMessage(const idReport: integer;
  const report: string);
begin
  self.Report.setStatusMessage(idReport, report);
end;

end.
