unit UOPCItem;

interface

uses
  Classes, OPCDA, OPCtypes;

type

  TOPCItem = class
  private
    itemName     : string;
    active       : boolean;
    accessPath   : string;
    clientHandle : OPCHANDLE; // ID number of item
    itemValue    : string;
    itemQuality  : Word;
    timeStamp    : TDateTime;
    dataType     : TVarType;
  public
    ItemHandle   : OPCHANDLE; // serverhandle
    ItemType     : TVarType;  // Canonical type
    // constructor
    constructor create(itemName : string; clientHandle : OPCHANDLE;
      active : boolean; accessPath : string; dataType : TVarType);
    // GET
    function getItemName : string;
    function isActive : boolean;
    function getAccessPath : string;
    function getClientHandle : OPCHANDLE;
    function getDataType : TVarType;
    function getItemValue : string;
    function getItemQuality : Word;
    function getTimeStamp : TDateTime;
    // SET
    procedure setItemValue(value : string);
    procedure setTimeStamp(timeStamp : TDateTime);
    procedure setItemQuality(quality : Word);
    procedure setActive(active : boolean);
  end;

implementation

{ TOPCItem }

constructor TOPCItem.create(itemName: string; clientHandle: OPCHANDLE;
  active: boolean; accessPath: string; dataType: TVarType);
begin
  self.itemName := itemName;
  self.clientHandle := clientHandle;
  self.active := active;
  self.accessPath := accessPath;
  self.dataType := dataType;
end;

function TOPCItem.getItemValue: string;
begin
  Result := itemValue;
end;

function TOPCItem.getDataType: TVarType;
begin
  Result := dataType;
end;

function TOPCItem.getItemQuality: Word;
begin
  Result := itemQuality;
end;

function TOPCItem.getClientHandle: OPCHANDLE;
begin
  Result := clientHandle;
end;

function TOPCItem.getTimeStamp: TDateTime;
begin
  Result := timeStamp;
end;

function TOPCItem.getItemName: string;
begin
  Result := itemName;
end;

function TOPCItem.getAccessPath: string;
begin
  Result := accessPath;
end;

function TOPCItem.isActive: boolean;
begin
  Result := active;
end;

procedure TOPCItem.setItemValue(value: string);
begin
  itemValue := value;
end;

procedure TOPCItem.setItemQuality(quality: Word);
begin
  itemQuality := quality;
end;

procedure TOPCItem.setTimeStamp(timeStamp: TDateTime);
begin
  self.timeStamp := timeStamp;
end;

procedure TOPCItem.setActive(active: boolean);
begin
  self.active := active;
end;

end.
