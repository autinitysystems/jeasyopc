unit UOPCItem;

interface

uses
  Classes, SysUtils, OPCDA, OPCtypes, JNI;

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
    constructor create(PEnv : PJNIEnv; item : JObject);
    // update methods
    procedure update(PEnv : PJNIEnv; item : JObject);
    // commit methods
    procedure commit(PEnv : PJNIEnv; item : JObject);
    // clone java instance => output: OPCItem
    function clone(PEnv : PJNIEnv; item : JObject) : JObject;
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
    procedure setItemType(itemType : TVarType);
  end;

implementation

{ TOPCItem }

constructor TOPCItem.create(PEnv : PJNIEnv; item : JObject);
begin
  // init fixed attributes
  timeStamp := -1;
  itemQuality := 0;
  // update attributes from Java
  update(PEnv, item);
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

procedure TOPCItem.setItemType(itemType: TVarType);
begin
  self.ItemType := itemType;
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

//------------------------------------------------------------------------------
//--- JAVA CODE CONNECTION

procedure TOPCItem.update(PEnv: PJNIEnv; item: JObject);
var
  getGroupByClientHandle : JMethodID;
  JVM        : TJNIEnv;
  Cls        : JClass;
  FID        : JFieldID;
  itemClass  : JClass;
  jstr       : JString;
begin
  JVM := TJNIEnv.Create(PEnv);

  // get item class
  itemClass := JVM.GetObjectClass(item);

  // attribute: clientHandle
  FID := JVM.GetFieldID(itemClass, 'clientHandle', 'I');
  self.clientHandle := JVM.GetIntField(item, FID);

  // attribute: itemName
  FID := JVM.GetFieldID(itemClass, 'itemName', 'Ljava/lang/String;');
  jstr := JVM.GetObjectField(item, FID);
  self.itemName := JVM.JStringToString(jstr);

  // attribute: accessPath
  FID := JVM.GetFieldID(itemClass, 'accessPath', 'Ljava/lang/String;');
  jstr := JVM.GetObjectField(item, FID);
  self.accessPath := JVM.JStringToString(jstr);

  // attribute: itemValue
  FID := JVM.GetFieldID(itemClass, 'itemValue', 'Ljava/lang/String;');
  jstr := JVM.GetObjectField(item, FID);
  self.itemValue := JVM.JStringToString(jstr);

  // attribute: dataType
  FID := JVM.GetFieldID(itemClass, 'dataType', 'I');
  self.dataType := JVM.GetIntField(item, FID);

  // attribute: active
  FID := JVM.GetFieldID(itemClass, 'active', 'Z');
  self.active := JVM.GetBooleanField(item, FID);

  // NOTE: timeStamp, quality are not updated (not reason)

  JVM.Free;
end;

procedure TOPCItem.commit(PEnv: PJNIEnv; item: JObject);
var
  JVM        : TJNIEnv;
  itemClass  : JClass;
  FID        : JFieldID;
  JDate      : JObject;
  ClsDate    : JClass;
  MidDate    : JMethodID;
  ArgsDate   : array[0..5] of JValue;
  Y, M, D, HH, MM, SS, MS : word;
begin
  JVM := TJNIEnv.Create(PEnv);
  // get item class
  itemClass := JVM.GetObjectClass(item);

  // attribute: itemValue
  FID := JVM.GetFieldID(itemClass, 'itemValue', 'Ljava/lang/String;');
  JVM.SetObjectField(item, FID, JVM.StringToJString(PAnsiChar(itemValue)));

  // attribute: active
  FID := JVM.GetFieldID(itemClass, 'active', 'Z');
  JVM.SetBooleanField(item, FID, active);

  // attribute: quality
  FID := JVM.GetFieldID(itemClass, 'itemQuality', 'Z');
  JVM.SetBooleanField(item, FID,
    (itemQuality and OPC_QUALITY_MASK) = OPC_QUALITY_GOOD);

  // attribute: timeStamp
  if timeStamp <> -1
  then begin
    DecodeDate(timeStamp, Y, M, D);
    DecodeTime(timeStamp, HH, MM, SS, MS);
    ClsDate := JVM.FindClass('java/util/GregorianCalendar');
    MidDate := JVM.GetMethodID(ClsDate, '<init>', '(IIIIII)V');
    // set Date parameters
    ArgsDate[0].i := Y;
    ArgsDate[1].i := M-1;
    ArgsDate[2].i := D;
    ArgsDate[3].i := HH;
    ArgsDate[4].i := MM;
    ArgsDate[5].i := SS;
    // create Calendar date
    JDate := JVM.NewObjectA(ClsDate, MidDate, @argsDate);
  end
  else JDate := nil;
  // set date to java
  FID := JVM.GetFieldID(itemClass, 'timeStamp', 'Ljava/util/GregorianCalendar;');
  JVM.SetObjectField(item, FID, JDate);

  JVM.Free;
end;

function TOPCItem.clone(PEnv: PJNIEnv; item: JObject) : JObject;
var
  JVM         : TJNIEnv;
  itemClass   : JClass;
  cloneMethod : JMethodID;
begin
  JVM := TJNIEnv.Create(PEnv);
  // get item class
  itemClass := JVM.GetObjectClass(item);
  // call clone method
  cloneMethod := JVM.GetMethodID(itemClass, 'clone', '()Ljava/lang/Object;');
  Result := JVM.CallObjectMethodA(item, cloneMethod, nil);
  JVM.Free;
end;

end.
