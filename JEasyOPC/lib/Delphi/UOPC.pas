unit UOPC;

interface

uses
  Classes, SysUtils, Windows, UCustomOPC, OPCUtils, UOPCGroup, UOPCItem,
  OPCTypes, JNI;

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
  function  removeGroup(group : TOPCGroup) : TOPCGroup;
  // get count of groups
  function getGroupCount : integer;
  // get group by clientHandle
  function getGroupByClientHandle(clientHandle : OPCHANDLE) : TOPCGroup;
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
  // update groups from JAVA
  procedure updateGroups(PEnv: PJNIEnv; Obj: JObject);
  // store structure of opc to file
  procedure storeStructureToFile(fn : string);
  //************************************************
  // read item (Synch)
  function synchReadItem(PEnv: PJNIEnv; group: JObject; item: JObject) : JObject;
  // write item (Synch)
  procedure synchWriteItem(PEnv: PJNIEnv; group: JObject; item: JObject);
end;

implementation

{ TOPC }

constructor TOPC.create(host, ServerProgID, ServerClientHandle: string);
begin
  inherited create(host, ServerProgID, ServerClientHandle);
  groups := TList.create;
end;

//------------------------------------------------------------------------------

procedure TOPC.addGroup(group: TOPCGroup);
begin
  groups.add(group);
end;

//------------------------------------------------------------------------------

function TOPC.removeGroup(group : TOPCGroup): TOPCGroup;
var i : integer;
begin
  for i:=0 to groups.count-1 do
    if groups[i] = group
    then begin
      Result := groups[i];
      groups.delete(i);
      exit;
    end;
  Result := nil;
end;

//------------------------------------------------------------------------------

function TOPC.getGroupByClientHandle(clientHandle: OPCHANDLE): TOPCGroup;
var i : integer;
begin
  for i:=0 to groups.count-1 do
    if TOPCGroup(groups[i]).getClientHandle = clientHandle
    then begin
      Result := groups[i];
      exit;
    end;
  Result := nil;
end;

//------------------------------------------------------------------------------

function TOPC.getGroupCount: integer;
begin
  Result := groups.count;
end;

//------------------------------------------------------------------------------

procedure TOPC.registerGroup(group: TOPCGroup);
begin
  // use wrapper
  HR := ServerAddGroup(ServerIf, group.getGroupName, group.isActive, group.getUpdateRate,
    group.getClientHandle, group.getPercentDeadBand, group.GroupIf, group.GroupHandle);
  if not Succeeded(HR)
  then raise UnableAddGroupException.create(group.getGroupName);
end;

//------------------------------------------------------------------------------

procedure TOPC.registerGroups;
var i : integer;
begin
  for i:=0 to groups.count-1 do registerGroup(groups[i]);
end;

//------------------------------------------------------------------------------

procedure TOPC.registerGroupItems(group: TOPCGroup);
var i : integer;
begin
  // register all items in a specific group
  for i:=0 to group.getItemCount-1 do
    registerGroupItems(group, TOPCItem(group.getItems[i]));
end;

//------------------------------------------------------------------------------

procedure TOPC.registerGroupItems(group : TOPCGroup; item : TOPCItem);
begin
  HR := GroupAddItem(group.GroupIf, item.getItemName, item.getClientHandle,
    item.getDataType, item.isActive, item.getAccessPath,
    item.ItemHandle, item.ItemType);
  if not Succeeded(HR)
  then raise UnableAddItemException.create(item.getItemName);
end;

//------------------------------------------------------------------------------

procedure TOPC.registerAllGroupItems;
var i : integer;
begin
  for i:=0 to groups.count-1 do registerGroupItems(TOPCGroup(groups[i]));
end;

//------------------------------------------------------------------------------

procedure TOPC.unregisterGroup(group: TOPCGroup);
begin
  HR := ServerIf.RemoveGroup(group.GroupHandle, False);
  if not Succeeded(HR)
  then raise UnableRemoveGroupException.create(group.getGroupName);
end;

//------------------------------------------------------------------------------

procedure TOPC.unregisterGroups;
var i : integer;
begin
  for i:=0 to groups.count-1 do
    unregisterGroup(groups[i]);
end;

//------------------------------------------------------------------------------

procedure TOPC.unregisterItem(group: TOPCGroup; item: TOPCItem);
begin
  HR := GroupRemoveItem(group.GroupIf, item.ItemHandle);
  if not Succeeded(HR)
  then raise UnableRemoveGroupException.create(group.getGroupName);
end;

//------------------------------------------------------------------------------

procedure TOPC.updateGroups(PEnv: PJNIEnv; Obj: JObject);
var
  getGroupsAsArray : JMethodID;
  JVM          : TJNIEnv;
  Cls          : JClass;
  FID          : JFieldID;
  agroups      : JArray;
  group        : JObject;
  groupNative  : TOPCGroup;
  groupClass   : JClass;
  groupsCount  : integer;
  i            : integer;
  j            : integer;
  groupCHandle : integer;
  cha          : array of integer;
  exists       : boolean;
begin
  JVM := TJNIEnv.Create(PEnv);

  // update groups
  Cls := JVM.GetObjectClass(Obj);

  // get group from groups map by its clientHandle
  getGroupsAsArray := JVM.GetMethodID(Cls, 'getGroupsAsArray',
    '()[Ljavafish/clients/opc/component/OPCGroup;');
  agroups := JArray(JVM.CallObjectMethodA(Obj, getGroupsAsArray, nil));

  groupsCount := JVM.GetArrayLength(agroups);
  setLength(cha, groupsCount);

  for i:=0 to groupsCount-1 do
  begin
    // get group from Java
    group := JVM.GetObjectArrayElement(agroups, i);

    // attribute: clientHandle
    groupClass := JVM.GetObjectClass(group);
    FID := JVM.GetFieldID(groupClass, 'clientHandle', 'I');
    groupCHandle := JVM.GetIntField(group, FID);
    cha[i] := groupCHandle; // set to memory

    groupNative := getGroupByClientHandle(groupCHandle);
    if groupNative <> nil
    then groupNative.update(PEnv, group) // update group
    else addGroup(TOPCGroup.create(PEnv, group)); // create new group
  end;

  // delete items
  i:=0;
  while i <= getGroupCount-1 do
  begin
    exists := false;
    for j:=Low(cha) to High(cha) do
      if cha[j] = TOPCGroup(Groups[i]).getClientHandle
      then begin
        exists := true;
        break;
      end;
    if not exists
    then removeGroup(Groups[i])
    else i := i + 1;
  end;

  JVM.Free;
end;

//------------------------------------------------------------------------------

procedure TOPC.storeStructureToFile(fn: string);
var foo   : TStringList;
    i,j   : integer;
    group : TOPCGroup;
    item  : TOPCItem;
    items : TList;
begin
  foo := TStringList.Create;
  for i:=0 to getGroupCount-1 do
  begin
    group := TOPCGroup(Groups[i]);
    foo.Add('GROUP: ' + group.getGroupName);
    foo.Add('GROUP clientHandle: ' + IntToStr(group.getClientHandle));
    foo.Add('GROUP updateRate: ' + IntToStr(group.getUpdateRate));
    foo.Add('GROUP active: ' + BoolToStr(group.isActive, true));
    foo.Add('GROUP percentDeadBand: ' + FloatToStr(group.getPercentDeadBand));

    items := group.getItems;
    if items <> nil
    then begin
      if items.Count > 0
      then begin
        for j:=0 to items.Count-1 do
        begin
          item := TOPCItem(items[j]);
          foo.Add('GROUP.Item: ' + item.getItemName);
          foo.Add('GROUP.Item clientHandle: ' + IntToStr(item.getClientHandle));
          foo.Add('GROUP.Item accessPath: ' + item.getAccessPath);
          foo.Add('GROUP.Item itemValue: ' + item.getItemValue);
          foo.Add('GROUP.Item active: ' + BoolToStr(item.isActive, true));
          foo.Add('GROUP.Item dataType: ' + IntToStr(item.getDataType));
          //foo.Add('GROUP.Item quality: ' + BoolToStr(item.getItemQuality, true));
        end;
      end else foo.Add('ITEMS: empty group');
    end
    else foo.Add('ITEMS: empty group');
  end;
  // store to file
  foo.SaveToFile(fn);
  foo.Free;
end;

//------------------------------------------------------------------------------

function TOPC.synchReadItem(PEnv: PJNIEnv; group, item: JObject): JObject;
var
  JVM         : TJNIEnv;
  FID         : JFieldID;
  groupClass  : JClass;
  itemClass   : JClass;
  gch         : integer;
  ich         : integer;
  groupNative : TOPCGroup;
  itemNative  : TOPCItem;
  value       : string;
  quality     : word;
  itm         : JObject;
begin
  JVM := TJNIEnv.Create(PEnv);

  // get classes
  groupClass := JVM.GetObjectClass(group);
  itemClass := JVM.GetObjectClass(item);

  // get clientHandles
  FID := JVM.GetFieldID(groupClass, 'clientHandle', 'I');
  gch := JVM.GetIntField(group, FID);
  FID := JVM.GetFieldID(itemClass, 'clientHandle', 'I');
  ich := JVM.GetIntField(item, FID);

  // get native objects
  groupNative := getGroupByClientHandle(gch);
  itemNative := groupNative.getItemByClientHandle(ich);

  if ((groupNative = nil) or (itemNative = nil))
  then begin
    // throw exception
    exit;
  end;

  HR := ReadOPCGroupItemValue(groupNative.GroupIf, itemNative.ItemHandle, value, quality);
  if Succeeded(HR)
  then begin
    itemNative.setItemValue(value);
    itemNative.setItemQuality(quality);
    itm := itemNative.clone(PEnv, item);
    itemNative.commit(PEnv, itm);
    Result := itm;
  end
  else begin
    // throw exception
    exit;
  end;
end;

//------------------------------------------------------------------------------

procedure TOPC.synchWriteItem(PEnv: PJNIEnv; group, item: JObject);
begin
  // not yet
end;

end.
