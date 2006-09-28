unit UOPC;

interface

uses
  Classes, SysUtils, Windows, UCustomOPC, OPCUtils, UOPCGroup, UOPCItem,
  OPCTypes;

type

TOPC = class(TCustomOPC)
private
  groups : TList;
public
  // constructor (override)
  constructor create(host, ServerProgID, ServerClientHandle : string);
  // add group
  procedure addGroup(group : TOPCGroup);
  // remove group
  function  removeGroup(groupName : string) : TOPCGroup;
  // get count of groups
  function getGroupCount : integer;
  // get group by clientHandle
  function getGroupBy(clientHandle : OPCHANDLE) : TOPCGroup;
  //************************************************
  // register group to server, throws UnableAddGroupException
  procedure registerGroup(group : TOPCGroup);
  // register all groups to server, throws UnableAddGroupException
  procedure registerGroups;
  // register item in specific group, throws UnableAddItemException
  procedure registerGroupItems(group : TOPCGroup; item : TOPCItem); overload;
  // register items in specific group, throws UnableAddItemException
  procedure registerGroupItems(group : TOPCGroup); overload;
  // register all items all groups, throws UnableAddItemException
  procedure registerAllGroupItems;
  // unregister group, throws UnableRemoveGroupException
  procedure unregisterGroup(group : TOPCGroup);
  // unregister all groups, throws UnableRemoveGroupException
  procedure unregisterGroups;
  // unregister item
  procedure unregisterItem(group : TOPCGroup; item : TOPCItem);
  //************************************************
end;

implementation

{ TOPC }

constructor TOPC.create(host, ServerProgID, ServerClientHandle: string);
begin
  inherited create(host, ServerProgID, ServerClientHandle);
  groups := TList.create;
end;

procedure TOPC.addGroup(group: TOPCGroup);
begin
  groups.add(group);
end;

function TOPC.removeGroup(groupName: string): TOPCGroup;
var i : integer;
begin
  for i:=0 to groups.count-1 do
    if TOPCGroup(groups[i]).getGroupName = groupName
    then begin
      Result := groups[i];
      groups.delete(i);
      exit;
    end;
  Result := nil;
end;

function TOPC.getGroupBy(clientHandle: OPCHANDLE): TOPCGroup;
var i : integer;
begin
  for i:=0 to groups.count-1 do
    if TOPCGroup(groups[i]).getClientHandle = clientHandle
    then begin
      Result := groups[i];
      exit;
    end;
end;

function TOPC.getGroupCount: integer;
begin
  Result := groups.count;
end;

procedure TOPC.registerGroup(group: TOPCGroup);
begin
  // use wrapper
  HR := ServerAddGroup(ServerIf, group.getGroupName, group.isActive, group.getUpdateRate,
    group.getClientHandle, group.getPercentDeadBand, group.GroupIf, group.GroupHandle);
  if not Succeeded(HR)
  then raise UnableAddGroupException.create(group.getGroupName);
end;

procedure TOPC.registerGroups;
var i : integer;
begin
  for i:=0 to groups.count-1 do registerGroup(groups[i]);
end;

procedure TOPC.registerGroupItems(group: TOPCGroup);
var i : integer;
begin
  // register all items in a specific group
  for i:=0 to group.getItemCount-1 do
    registerGroupItems(group, TOPCItem(group.getItems[i]));
end;

procedure TOPC.registerGroupItems(group : TOPCGroup; item : TOPCItem);
begin
  HR := GroupAddItem(group.GroupIf, item.getItemName, item.getClientHandle,
    item.getDataType, item.isActive, item.getAccessPath,
    item.ItemHandle, item.ItemType);
  if not Succeeded(HR)
  then raise UnableAddItemException.create(item.getItemName);
end;

procedure TOPC.registerAllGroupItems;
var i : integer;
begin
  for i:=0 to groups.count-1 do registerGroupItems(TOPCGroup(groups[i]));
end;

procedure TOPC.unregisterGroup(group: TOPCGroup);
begin
  HR := ServerIf.RemoveGroup(group.GroupHandle, False);
  if not Succeeded(HR)
  then raise UnableRemoveGroupException.create(group.getGroupName);
end;

procedure TOPC.unregisterGroups;
var i : integer;
begin
  for i:=0 to groups.count-1 do
    unregisterGroup(groups[i]);
end;

procedure TOPC.unregisterItem(group: TOPCGroup; item: TOPCItem);
begin
  HR := GroupRemoveItem(group.GroupIf, item.ItemHandle);
  if not Succeeded(HR)
  then raise UnableRemoveGroupException.create(group.getGroupName);
end;

end.
