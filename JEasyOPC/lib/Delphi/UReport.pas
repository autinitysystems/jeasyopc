unit UReport;

interface

uses
 SysUtils, Classes, Contnrs;

// DEFINE OPC Client Reports
//--------------------------
// 100 - 199 = error message
// 200 - 299 = info  message
// 300 - 399 = debug message

const
  ID100 = 100; // Unable to connect to OPC server:
  ID101 = 101; // Unable to add group to server:
  ID102 = 102; // Unable to add item to group:
  ID103 = 103; // Failed to set up IDataObject advise callback.
  ID104 = 104; // Failed to set up IConnectionPointContainer advise callback.
  ID105 = 105; // OPC server connection error:
  ID106 = 106; // Unable to remove group:
  ID107 = 107; // Try to reconnect OPC Server:
  ID108 = 108; // Can't FindClass(javafish.clients.opc.OPCItem)
  ID109 = 109; // Can't get MethodID for OPCItem constructor.
  ID110 = 110; // Can't FindClass(javafish.clients.opc.OPCGroup)
  ID111 = 111; // Can't get MethodID for OPCGroup constructor.
  ID112 = 112; // Can't FindClass(javafish.clients.opc.OPCReport)
  ID113 = 113; // Can't get MethodID for OPCReport constructor.

  ID200 = 200; // Connected to OPC server:
  ID201 = 201; // Group was added to server:
  ID202 = 202; // Item was added to group:
  ID203 = 203; // IDataObject advise callback established.
  ID204 = 204; // IConnectionPointContainer data callback established.
  ID205 = 205; // Removed group:
  ID206 = 206; // Stop reading group:
  ID207 = 207; // OPC Client thread finished.

const
 MAXELEMENTS = 1000; // groups

type
  // status message record
  TStatusMessage = record
    report   : string;
    idReport : integer;
  end;

  // report class
  TReport = class
  public
    procedure SetStatusMessage(const idReport : integer; const report: string);
  private
    FStatusMessage   : TStatusMessage;
    FOnStatusMessage : TNotifyEvent;
  published
    property OnStatusMessage: TNotifyEvent read FOnStatusMessage write FOnStatusMessage;
    property StatusMessage: TStatusMessage read FStatusMessage; // read status message
  end;

 // class of element of report queue
 TReportElement = class
 private
   report   : string;
   idReport : integer;
 public
   constructor Create(idReport : integer; report : string);
   function GetReport : string;
   function GetIDReport : integer;
 end;

 // report queue class
 TReportQueue = class
 protected
   MyQueue : TObjectQueue;    // internal object of Queue
 public
   constructor Create();
   procedure DestroyQueue;
   function  Count : integer;
   function  Pop : TReportElement;
   procedure StatusMessage(Sender: TObject);
 end;

implementation

{TReport}

procedure TReport.SetStatusMessage(const idReport : integer; const report: string);
begin
  // use for state of object
  FStatusMessage.idReport := idReport;
  FStatusMessage.report := report;
  // run event
  if Assigned(FOnStatusMessage) then FOnStatusMessage(Self);
end;

{ TReportElement }

constructor TReportElement.Create(idReport : integer; report : string);
begin
  Self.idReport := idReport;
  Self.report   := report;
end;

function TReportElement.GetReport: string;
begin
  Result := report;
end;

function TReportElement.GetIDReport: integer;
begin
  Result := idReport;
end;

{ TEasyOPCQueue }

constructor TReportQueue.Create();
begin
  MyQueue := TObjectQueue.Create;
end;

function TReportQueue.Count: integer;
begin
  Result := MyQueue.Count;
end;

procedure TReportQueue.DestroyQueue;
var Em : TReportElement;
begin
  while MyQueue.Count > 0 do
  begin
    Em := TReportElement(MyQueue.Pop);
    Em.Free;
  end;
  MyQueue.Free;
end;

function TReportQueue.Pop : TReportElement;
begin
  if MyQueue.Count > 0
  then Result := TReportElement(MyQueue.Pop)
  else Result := nil;
end;

procedure TReportQueue.StatusMessage(Sender: TObject);
var Em       : TReportElement;
    idReport : integer;
    report   : string;
begin
  if MyQueue.Count > MAXELEMENTS
  then begin
    Em := TReportElement(MyQueue.Pop);
    Em.Free; // free memory
  end;
  idReport := TReport(Sender).StatusMessage.idReport;
  report   := TReport(Sender).StatusMessage.report;
  MyQueue.Push(TReportElement.Create(idReport, report)); // push to queue
end;

end.
