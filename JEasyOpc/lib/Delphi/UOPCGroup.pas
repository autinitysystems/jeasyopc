unit UOPCGroup;

interface

uses
  Classes, Windows, SysUtils, OPCtypes, OPCDA, UOPCItem, JNI, UOPCExceptions,
  ActiveX;

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
    constructor create(PEnv: PJNIEnv; group: JObject); overload;
    constructor create(group : TOPCGroup); overload;
    // desctructor
    destructor Destroy; override;
    // update methods
    procedure update(PEnv: PJNIEnv; group: JObject); overload; // update from OPC groups
    // commit methods
    procedure commit(PEnv : PJNIEnv; group : JObject);
    // clone java instance => output: OPCGroup
    function clone(PEnv : PJNIEnv; group : JObject) : JObject;
    function cloneNative : TOPCGroup;
    // GET
    function getGroupName : string;
    function getItems : TList;
    function getItemByClientHandle(clientHandle : integer) : TOPCItem;
    function getItemByJavaCode(PEnv: PJNIEnv; item: JObject): TOPCItem;
    function isActive : boolean;
    function getUpdateRate : DWORD;
    function getClientHandle : OPCHANDLE;
    function getPercentDeadBand : Single;
    function getItemCount : integer;
    // SET
    procedure addItem(item : TOPCItem);
    function  removeItem(item : TOPCItem) : TOPCItem;
    procedure setActive(active : boolean);
    procedure setUpdateRate(updateRate : DWORD);
    procedure setPercentDeadBand(percentDeadBand : Single);
  end;

implementation

{ TOPCGroup }

constructor TOPCGroup.create(PEnv: PJNIEnv; group: JObject);
begin
  Items := TList.create;
  update(PEnv, group);
end;

constructor TOPCGroup.create(group: TOPCGroup);
var i : integer;
begin
  groupName       := group.groupName;
  active          := group.active;
  updateRate      := group.updateRate;
  clientHandle    := group.clientHandle;
  percentDeadBand := group.percentDeadBand;
  GroupIf         := group.GroupIf;
  GroupHandle     := group.GroupHandle;

  Items := TList.create;
  for i:=0 to group.getItemCount-1 do
    addItem(TOPCItem(group.getItems[i]).cloneNative);
end;

function TOPCGroup.getClientHandle: OPCHANDLE;
begin
  Result := clientHandle;
end;

function TOPCGroup.getItems: TList;
begin
  Result := Items;
end;

function TOPCGroup.getItemByClientHandle(clientHandle : integer) : TOPCItem;
var i : integer;
begin
  for i:=0 to getItemCount-1 do
    if TOPCItem(Items[i]).getClientHandle = clientHandle
    then begin
      Result := Items[i];
      exit;
    end;
  Result := nil;
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

function TOPCGroup.getItemByJavaCode(PEnv: PJNIEnv; item: JObject): TOPCItem;
var
  JVM        : TJNIEnv;
  FID        : JFieldID;
  itemClass  : JClass;
  ich        : integer;
  itemNative : TOPCItem;
begin
  JVM := TJNIEnv.Create(PEnv);

  // get classes
  itemClass := JVM.GetObjectClass(item);

  // get clientHandles
  FID := JVM.GetFieldID(itemClass, 'clientHandle', 'I');
  ich := JVM.GetIntField(item, FID);

  JVM.Free;

  // get native objects
  itemNative := getItemByClientHandle(ich);

  if itemNative = nil
  then raise ComponentNotFoundException.create(ComponentNotFoundExceptionText)
  else Result := itemNative;
end;

procedure TOPCGroup.setUpdateRate(updateRate: DWORD);
begin
  self.updateRate := updateRate;
end;

procedure TOPCGroup.setPercentDeadBand(percentDeadBand: Single);
begin
  self.percentDeadBand := percentDeadBand;
end;

function TOPCGroup.removeItem(item : TOPCItem) : TOPCItem;
var i : integer;
begin
  for i:=0 to Items.count-1 do
    if Items[i] = item
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

//------------------------------------------------------------------------------
//--- JAVA CODE CONNECTION

// update from JAVA code
procedure TOPCGroup.update(PEnv: PJNIEnv; group: JObject);
var
  getItemsAsArray : JMethodID;
  JVM         : TJNIEnv;
  FID         : JFieldID;
  groupClass  : JClass;
  jgroupName  : JString;
  aitems      : JObjectArray;
  item        : JObject;
  itemNative  : TOPCItem;
  itemClass   : JClass;
  itemsCount  : integer;
  i           : integer;
  j           : integer;
  itemCHandle : integer;
  cha         : array of integer;
  exists      : boolean;
begin
  JVM := TJNIEnv.Create(PEnv);

  // get group class
  groupClass := JVM.GetObjectClass(group);

  // attribute: clientHandle
  FID := JVM.GetFieldID(groupClass, 'clientHandle', 'I');
  self.clientHandle := JVM.GetIntField(group, FID);

  // attribute: groupName
  FID := JVM.GetFieldID(groupClass, 'groupName', 'Ljava/lang/String;');
  jgroupName := JVM.GetObjectField(group, FID);
  self.groupName := JVM.JStringToString(jgroupName);

  // attribute: updateRate
  FID := JVM.GetFieldID(groupClass, 'updateRate', 'I');
  self.updateRate := JVM.GetIntField(group, FID);

  // attribute: active
  FID := JVM.GetFieldID(groupClass, 'active', 'Z');
  self.active := JVM.GetBooleanField(group, FID);

  // attribute: percentDeadBand
  FID := JVM.GetFieldID(groupClass, 'percentDeadBand', 'F');
  self.percentDeadBand := JVM.GetFloatField(group, FID);

  // update items
  // get group from groups map by its clientHandle
  getItemsAsArray := JVM.GetMethodID(groupClass, 'getItemsAsArray',
    '()[Ljavafish/clients/opc/component/OpcItem;');
  aitems := JArray(JVM.CallObjectMethodA(group, getItemsAsArray, nil));
  itemsCount := JVM.GetArrayLength(aitems);
  setLength(cha, itemsCount);

  for i:=0 to itemsCount-1 do
  begin
    // get item from Java
    item := JVM.GetObjectArrayElement(aitems, i);

    // attribute: clientHandle
    itemClass := JVM.GetObjectClass(item);

    FID := JVM.GetFieldID(itemClass, 'clientHandle', 'I');

    itemCHandle := JVM.GetIntField(item, FID);
    cha[i] := itemCHandle; // set to memory

    itemNative := getItemByClientHandle(itemCHandle);
    if itemNative <> nil
    then itemNative.update(PEnv, item) // update item
    else addItem(TOPCItem.create(PEnv, item)); // create new item
  end;

  // delete items
  i:=0;
  while i <= getItemCount-1 do
  begin
    exists := false;
    for j:=Low(cha) to High(cha) do
      if cha[j] = TOPCItem(Items[i]).getClientHandle
      then begin
        exists := true;
        break;
      end;
    if not exists
    then removeItem(Items[i])
    else i := i + 1;
  end;

  JVM.Free;
end;

procedure TOPCGroup.commit(PEnv: PJNIEnv; group: JObject);
var
  JVM         : TJNIEnv;
  groupClass  : JClass;
  FID         : JFieldID;
  i           : integer;
  aitems      : JObjectArray;
  itemsCount  : integer;
  item        : JObject;
  itemClass   : JClass;
  itemCHandle : integer;
  itemNative  : TOPCItem;
  getItemsAsArray : JMethodID;
begin
  JVM := TJNIEnv.Create(PEnv);
  // get group class
  groupClass := JVM.GetObjectClass(group);

  // attribute: active
  FID := JVM.GetFieldID(groupClass, 'active', 'Z');
  JVM.SetBooleanField(group, FID, active);

  // attribute: updateRate
  FID := JVM.GetFieldID(groupClass, 'updateRate', 'I');
  JVM.SetIntField(group, FID, updateRate);

  // attribute: percentDeadBand
  FID := JVM.GetFieldID(groupClass, 'percentDeadBand', 'F');
  JVM.SetFloatField(group, FID, percentDeadBand);

  // commit to items
  getItemsAsArray := JVM.GetMethodID(groupClass, 'getItemsAsArray',
    '()[Ljavafish/clients/opc/component/OpcItem;');
  aitems := JArray(JVM.CallObjectMethodA(group, getItemsAsArray, nil));
  itemsCount := JVM.GetArrayLength(aitems);

  for i:=0 to itemsCount-1 do
  begin
    // get item from Java
    item := JVM.GetObjectArrayElement(aitems, i);

    // attribute: clientHandle
    itemClass := JVM.GetObjectClass(item);

    FID := JVM.GetFieldID(itemClass, 'clientHandle', 'I');

    itemCHandle := JVM.GetIntField(item, FID);
    itemNative := getItemByClientHandle(itemCHandle);

    if itemNative <> nil // commit changes
    then itemNative.commit(PEnv, item);
  end;

  JVM.Free;
end;

//------------------------------------------------------------------------------

function TOPCGroup.clone(PEnv: PJNIEnv; group: JObject): JObject;
var
  JVM         : TJNIEnv;
  groupClass  : JClass;
  cloneMethod : JMethodID;
begin
  JVM := TJNIEnv.Create(PEnv);
  // get item class
  groupClass := JVM.GetObjectClass(group);
  // call clone method
  cloneMethod := JVM.GetMethodID(groupClass, 'clone', '()Ljava/lang/Object;');
  Result := JVM.CallObjectMethodA(group, cloneMethod, nil);
  JVM.Free;
end;

//------------------------------------------------------------------------------

function TOPCGroup.cloneNative: TOPCGroup;
begin
  Result := TOPCGroup.create(self);
end;

//------------------------------------------------------------------------------

destructor TOPCGroup.Destroy;
var i : integer;
    item : TOPCItem;
begin
  // destroy items instances
  i := 0;
  while getItemCount > 0 do
  begin
    item := Items[i];
    Items.Delete(i);
    item.Free;
  end;
  Items.Free;

  inherited;
end;

end.
