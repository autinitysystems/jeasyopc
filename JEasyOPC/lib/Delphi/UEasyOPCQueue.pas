unit UEasyOPCQueue;

interface

uses SysUtils, Contnrs, UEasyOPC;

const
  MAXELEMENTS = 1000; // groups

type
// class of element of queue
TElement = class
private
  package : integer;
  data    : OPCGroup;
public
  constructor Create(NumPackage : integer; data : OPCGroup);
  destructor  Destroy; override;
  function  GetData : OPCGroup;
  procedure SetData(data : OPCGroup);
  function  GetNumPackage : integer;
end;

// MAIN CLASS
TEasyOPCQueue = class
protected
  EasyOPC     : TEasyOPC;
  MyQueue     : TObjectQueue;    // internal object of Queue
  counter     : Cardinal;
  procedure DownloadOPCgroup(IDGroup : Cardinal; DownOPCGroup : OPCGroup);
public
  constructor Create(EasyOPC : TEasyOPC);
  function  GetEasyOPC : TEasyOPC;
  procedure DestroyQueue;
  function  Count : integer;
  function  Pop : TElement;
end;

implementation

{ TEasyOPCQueue }

constructor TEasyOPCQueue.Create(EasyOPC: TEasyOPC);
begin
  MyQueue := TObjectQueue.Create;
  counter := 0;
  // connect to EasyOPC
  Self.EasyOPC := EasyOPC;
  EasyOPC.OnDownloadedGroup := DownloadOPCgroup;
end;

procedure TEasyOPCQueue.DownloadOPCgroup(IDGroup: Cardinal; DownOPCGroup: OPCGroup);
var Em : TElement;
begin
  if MyQueue.Count > MAXELEMENTS
  then begin
    Em := TElement(MyQueue.Pop);
    Em.Free; // free memory
  end;
  MyQueue.Push(TElement.Create(counter, DownOPCGroup)); // push to queue
  Inc(counter);
end;

function TEasyOPCQueue.Count: integer;
begin
  Result := MyQueue.Count;
end;

function TEasyOPCQueue.GetEasyOPC: TEasyOPC;
begin
  Result := EasyOPC;
end;

procedure TEasyOPCQueue.DestroyQueue;
var Em : TElement;
begin
  while MyQueue.Count > 0 do
  begin
    Em := TElement(MyQueue.Pop);
    Em.Free;
  end;
  MyQueue.Free;
end;

function TEasyOPCQueue.Pop : TElement;
begin
  if MyQueue.Count > 0
  then Result := TElement(MyQueue.Pop)
  else Result := nil;
end;


{ TElement }

constructor TElement.Create(NumPackage: integer; data: OPCGroup);
begin
  package   := NumPackage;
  Self.data := data;
  Self.data.Items := Copy(data.Items); // dynamic array
end;

destructor TElement.Destroy;
begin
  SetLength(data.Items, 0);
  inherited;
end;

procedure TElement.SetData(data: OPCGroup);
begin
  Self.data := data;
end;

function TElement.GetNumPackage: integer;
begin
  Result := package;
end;

function TElement.GetData: OPCGroup;
begin
  Result := data;
end;

end.
