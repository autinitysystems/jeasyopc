unit UOPCGroup;

interface

uses
  Classes, Windows, SysUtils, OPCtypes, OPCDA, UOPCItem, JNI;

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
    constructor create(PEnv: PJNIEnv; Obj: JObject; clientHandle: OPCHANDLE);
    // update methods
    procedure update(PEnv: PJNIEnv; Obj: JObject); overload; // update from OPC groups
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

constructor TOPCGroup.create(PEnv: PJNIEnv; Obj: JObject; clientHandle: OPCHANDLE);
begin
  Items := TList.create;
  self.clientHandle := clientHandle;
  update(PEnv, Obj);
  {
  self.groupName := groupName;
  self.active := active;
  self.updateRate := updateRate;
  self.percentDeadBand := percentDeadBand;
  }
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

//------------------------------------------------------------------------------
//--- JAVA CODE CONNECTION

// update from JAVA code
procedure TOPCGroup.update(PEnv: PJNIEnv; Obj: JObject);
var
  JVM: TJNIEnv;
  Cls: JClass;
  FID: JFieldID;

  getGroupByClientHandle : JMethodID;
  group : JObject;
  groupClass : JClass;
  args: array[0..0] of JValue;
  chandle : JInt;

  jgroupName : JString;
  groupName  : string;

  foo : TStringList;
begin
  JVM := TJNIEnv.Create(PEnv);
  Cls := JVM.GetObjectClass(Obj);

  // get group from groups map by its clientHandle
  getGroupByClientHandle := JVM.GetMethodID(Cls, 'getGroupByClientHandle',
    '(I)Ljavafish/clients/opc/component/OPCGroup;');
  args[0].i := clientHandle;
  group := JVM.CallObjectMethodA(Obj, getGroupByClientHandle, @args);
  groupClass := JVM.GetObjectClass(group);
  // get clientHandle
  FID := JVM.GetFieldID(groupClass, 'clientHandle', 'I');
  chandle := JVM.GetIntField(group, FID);

  FID := JVM.GetFieldID(groupClass, 'groupName', 'Ljava/lang/String;');
  jgroupName := JVM.GetObjectField(group, FID);
  groupName := JVM.JStringToString(jgroupName);

  foo := TStringList.Create;
  foo.Add('handle: ' + IntToStr(chandle));
  foo.Add('groupName: ' + groupName);
  foo.SaveToFile('opcGroupTest.txt');

  foo.Free;
  JVM.Free;
end;

end.
