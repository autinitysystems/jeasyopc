unit UOPCGroup;

interface

uses
  Classes, Windows, OPCtypes, OPCDA, UOPCItem;

type

  TOPCGroup = class
  private
    groupName       : string;
    Items           : TList;
    active          : boolean;    // activity of group
    updateRate      : DWORD;      // time of data read
    clientHandle    : OPCHANDLE;  // clienthandle (ID number of group)
    percentDeadBand : Single;     // percentation of dead band
  public
    GroupIf         : IOPCItemMgt;
    GroupHandle     : OPCHANDLE;  // serverhandle
    // constructor
    constructor create(groupName : string; active : boolean;
      updateRate: DWORD; clientHandle: OPCHANDLE; percentDeadBand: Single);
    // GET
    function getGroupName : string;
    function getItems : TList;
    function getItemBy(clientHandle : OPCHANDLE) : TOPCItem;
    function isActive : boolean;
    function getUpdateRate : DWORD;
    function getClientHandle : OPCHANDLE;
    function getPercentDeadBand : Single;
    function getItemCount : integer;
    // SET
    procedure addItem(item : TOPCItem);
    function  removeItem(itemName: string) : TOPCItem;
    procedure setActive(active : boolean);
    procedure setUpdateRate(updateRate : DWORD);
    procedure setPercentDeadBand(percentDeadBand : Single);
  end;

implementation

{ TOPCGroup }

constructor TOPCGroup.create(groupName : string; active : boolean;
  updateRate: DWORD; clientHandle: OPCHANDLE; percentDeadBand: Single);
begin
  Items := TList.create;
  self.groupName := groupName;
  self.active := active;
  self.updateRate := updateRate;
  self.clientHandle := clientHandle;
  self.percentDeadBand := percentDeadBand;
end;

function TOPCGroup.getClientHandle: OPCHANDLE;
begin
  Result := clientHandle;
end;

function TOPCGroup.getItems: TList;
begin
  Result := Items;
end;

function TOPCGroup.isActive: boolean;
begin
  Result := active;
end;

function TOPCGroup.getGroupName: string;
begin
  Result := groupName;
end;

function TOPCGroup.getUpdateRate: DWORD;
begin
  Result := updateRate;
end;

function TOPCGroup.getPercentDeadBand: Single;
begin
  Result := percentDeadBand;
end;

procedure TOPCGroup.addItem(item: TOPCItem);
begin
  Items.add(item);
end;

function TOPCGroup.getItemCount: integer;
begin
  Result := Items.count;
end;

function TOPCGroup.getItemBy(clientHandle: OPCHANDLE): TOPCItem;
var i : integer;
begin
  for i:=0 to items.count-1 do
    if TOPCItem(items[i]).getClientHandle = clientHandle
    then begin
      Result := items[i];
      exit;
    end;
end;

procedure TOPCGroup.setUpdateRate(updateRate: DWORD);
begin
  self.updateRate := updateRate;
end;

procedure TOPCGroup.setPercentDeadBand(percentDeadBand: Single);
begin
  self.percentDeadBand := percentDeadBand;
end;

function TOPCGroup.removeItem(itemName: string) : TOPCItem;
var i : integer;
begin
  for i:=0 to Items.count-1 do
    if TOPCItem(Items[i]).getItemName = itemName
    then begin
      Result := Items[i];
      Items.Delete(i);
      exit;
    end;
  Result := nil;
end;

procedure TOPCGroup.setActive(active: boolean);
begin
  self.active := active;
end;

end.
