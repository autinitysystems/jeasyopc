unit UOPCQueue;

interface

uses SysUtils, Contnrs, UOPCGroup, OPCtypes;

const
  MAXELEMENTS = 1000; // groups

type
// class of element of queue
TElement = class
private
  package : integer;
  data    : TOPCGroup;
public
  constructor create(NumPackage : integer; data : TOPCGroup);
  destructor  destroy; override;
  function  getData : TOPCGroup;
  function  getNumPackage : integer;
end;

// MAIN CLASS
TOPCQueue = class
protected
  MyQueue : TObjectQueue; // internal object of Queue
  counter : Cardinal;
public
  constructor create();
  procedure destroyQueue;
  function  count : integer;
  function  pop : TElement;
  procedure downloadOPCGroup(cHandle_Group : OPCHANDLE; DownOPCGroup : TOPCGroup);
end;

implementation

{ TOPCQueue }

constructor TOPCQueue.create();
begin
  MyQueue := TObjectQueue.Create;
  counter := 0;
end;

procedure TOPCQueue.downloadOPCGroup(cHandle_Group : OPCHANDLE; DownOPCGroup : TOPCGroup);
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

function TOPCQueue.count: integer;
begin
  Result := MyQueue.Count;
end;

procedure TOPCQueue.destroyQueue;
var Em : TElement;
begin
  while MyQueue.Count > 0 do
  begin
    Em := TElement(MyQueue.Pop);
    Em.Free;
  end;
  MyQueue.Free;
end;

function TOPCQueue.Pop : TElement;
begin
  if MyQueue.Count > 0
  then Result := TElement(MyQueue.Pop)
  else Result := nil;
end;


{ TElement }

constructor TElement.create(NumPackage: integer; data: TOPCGroup);
begin
  package   := NumPackage;
  Self.data := data.cloneNative; // use clone to the element
end;

destructor TElement.destroy;
begin
  if Assigned(data)
  then data.free;
  inherited;
end;

function TElement.getNumPackage: integer;
begin
  Result := package;
end;

function TElement.getData: TOPCGroup;
begin
  Result := data;
end;

end.
