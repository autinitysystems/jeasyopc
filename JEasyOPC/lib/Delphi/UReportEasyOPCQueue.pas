unit UReportEasyOPCQueue;

interface

uses SysUtils, Contnrs, UEasyOPC;

const
  MAXELEMENTS = 1000; // groups

type
// class of element of queue
TReportElement = class
private
  report   : string;
  idReport : integer;
public
  constructor Create(idReport : integer; report : string);
  function GetReport : string;
  function GetIDReport : integer;
end;

// MAIN CLASS
TReportEasyOPCQueue = class
protected
  EasyOPC     : TEasyOPC;
  MyQueue     : TObjectQueue;    // internal object of Queue
  procedure StatusMessage(Sender: TObject);
public
  constructor Create(EasyOPC : TEasyOPC);
  function  GetEasyOPC : TEasyOPC;
  procedure DestroyQueue;
  function  Count : integer;
  function  Pop : TReportElement;
end;

implementation

{ TEasyOPCQueue }

constructor TReportEasyOPCQueue.Create(EasyOPC: TEasyOPC);
begin
  MyQueue := TObjectQueue.Create;
  // connect to EasyOPC
  Self.EasyOPC := EasyOPC;
  EasyOPC.OnStatusMessage := StatusMessage;
end;

function TReportEasyOPCQueue.Count: integer;
begin
  Result := MyQueue.Count;
end;

function TReportEasyOPCQueue.GetEasyOPC: TEasyOPC;
begin
  Result := EasyOPC;
end;

procedure TReportEasyOPCQueue.DestroyQueue;
var Em : TReportElement;
begin
  while MyQueue.Count > 0 do
  begin
    Em := TReportElement(MyQueue.Pop);
    Em.Free;
  end;
  MyQueue.Free;
end;

function TReportEasyOPCQueue.Pop : TReportElement;
begin
  if MyQueue.Count > 0
  then Result := TReportElement(MyQueue.Pop)
  else Result := nil;
end;

procedure TReportEasyOPCQueue.StatusMessage(Sender: TObject);
var Em       : TReportElement;
    idReport : integer;
    report   : string;
begin
  if MyQueue.Count > MAXELEMENTS
  then begin
    Em := TReportElement(MyQueue.Pop);
    Em.Free; // free memory
  end;
  idReport := TEasyOPC(Sender).StatusMessage.idReport;
  report   := TEasyOPC(Sender).StatusMessage.report;
  MyQueue.Push(TReportElement.Create(idReport, report)); // push to queue
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

end.
