//////////////////////////////////////
//  JCustomOpc.dll                  //
//  Author:  Ing. Antonín Fischer   //
//  Date:    24.9.2006              //
//  Version: 2.0                    //
//////////////////////////////////////

library JCustomOpc;

uses
  SysUtils,
  Classes,
  ActiveX,
  Forms,
  JNI in 'JNI.pas',
  OPCDA in 'OPCDA.pas',
  JUtils in 'JUtils.pas',
  OPCtypes in 'OPCtypes.pas',
  OPCutils in 'OPCutils.pas',
  OPCCOMN in 'OPCCOMN.pas',
  UCustomOPC in 'UCustomOPC.pas',
  UOPCBrowser in 'UOPCBrowser.pas',
  OPCenum in 'OPCenum.pas',
  UOPC in 'UOPC.pas',
  UOPCGroup in 'UOPCGroup.pas',
  UOPCItem in 'UOPCItem.pas',
  UOPCExceptions in 'UOPCExceptions.pas',
  UOPCAsynch in 'UOPCAsynch.pas',
  UOPCQueue in 'UOPCQueue.pas',
  UVariant in 'UVariant.pas';

const
  ID = 'id'; // signification of id client

  // java JCustomOPC classes => Delphi class representations
  JCustomOpc_ClassName = 'javafish.clients.opc.JCustomOpc';
  JOpcBrowser_ClassName = 'javafish.clients.opc.browser.JOpcBrowser';
  JOpc_ClassName = 'javafish.clients.opc.JOpc';

type
  TAOPC = array of TCustomOPC;

var
  countOPC : integer = 0;
  aopc     : TAOPC;

//////////////////////////
// DELPHI - JAVA Bridge //
//////////////////////////

//------------------------------------------------------------------------------
//---------------------------- CUSTOM OPC METHODS ------------------------------

// Creates native representation by Java ClassName information
procedure createNativeCodeRepresentation(_className, _host, _serverProgID,
  _serverClientHandle : string);
begin
  if _className = JCustomOPC_ClassName // JCustomOPC
  then begin
    // create TCustomOPC
    aopc[countOPC] := TCustomOPC.Create(_host, _serverProgID, _serverClientHandle);
  end else
  if _className = JOPCBrowser_ClassName // JOPCBrowser
  then begin
    // create TCustomOPC
    aopc[countOPC] := TBrowser.Create(_host, _serverProgID, _serverClientHandle);
  end else
  if _className = JOPC_ClassName // JOPC
  then begin
    // create TCustomOPC
    aopc[countOPC] := TOPC.Create(_host, _serverProgID, _serverClientHandle);
  end;
end;

//------------------------------------------------------------------------------

procedure Java_javafish_clients_opc_JCustomOpc_newInstance(PEnv: PJNIEnv;
  Obj: JObject; className : JString; host : JString; serverProgID : JString;
  serverClientHandle : JString); stdcall;
var
  JVM  : TJNIEnv;
  _className : string;
  _host : string;
  _serverProgID : string;
  _serverClientHandle : string;
begin
  JVM                 := TJNIEnv.Create(PEnv);
  _className          := JVM.JStringToString(className);
  _host               := JVM.JStringToString(host);
  _serverProgID       := JVM.JStringToString(serverProgID);
  _serverClientHandle := JVM.JStringToString(serverClientHandle);
  JVM.Free;

  // set arrays
  SetLength(aopc, countOPC + 1);

  // create specific native representation by className
  createNativeCodeRepresentation(_className, _host, _serverProgID, _serverClientHandle);

  // Set id-thread to java object
  SetInt(ID, countOPC, PEnv, Obj);
  Inc(countOPC);
end;

//------------------------------------------------------------------------------

procedure Java_javafish_clients_opc_JCustomOpc_coInitializeNative(PEnv: PJNIEnv;
  Obj: JObject); stdcall;
begin
  try
    // enable MULTI THREAD support
    IsMultiThread := True;
    // among other things, this call makes sure that COM is initialized
    Application.Initialize;
    CoInitializeEx(nil, COINIT_MULTITHREADED);
  except
    on E:Exception do
      throwException(PEnv, SCoInitializeException, PAnsiChar(E.Message));
  end;
end;

//------------------------------------------------------------------------------

procedure Java_javafish_clients_opc_JCustomOpc_coUninitializeNative(PEnv: PJNIEnv;
  Obj: JObject); stdcall;
begin
  try
    CoUninitialize;
  except
    on E:Exception do
      throwException(PEnv, SCoUninitializeException, PAnsiChar(E.Message));
  end;
end;

//------------------------------------------------------------------------------

procedure Java_javafish_clients_opc_JCustomOpc_connectServer(PEnv: PJNIEnv;
  Obj: JObject); stdcall;
begin
  try
    aopc[GetInt(ID, PEnv, Obj)].connect;
  except
    on E:ConnectivityException do
      throwException(PEnv, SConnectivityException, PAnsiChar(E.Message));
  end;
end;

//------------------------------------------------------------------------------

function Java_javafish_clients_opc_JCustomOpc_getStatus(PEnv: PJNIEnv;
  Obj: JObject) : JBoolean; stdcall;
begin
  Result := aopc[GetInt(ID, PEnv, Obj)].getServerStatus;
end;

//------------------------------------------------------------------------------
//----------------------------- BROWSER METHODS --------------------------------

function Java_javafish_clients_opc_browser_JOpcBrowser_getOpcServersNative(PEnv: PJNIEnv;
  Obj: JObject; host : JString) : JObjectArray; stdcall;
var
  ClsItem : JClass;
  JVM     : TJNIEnv;
  JOArray : JObjectArray;
  count   : integer;
  I       : integer;
  Lists   : TStringList;
  Browser : TBrowser;
begin
  // Create an instance of the Java environment
  JVM := TJNIEnv.Create(PEnv);
  Browser := TBrowser.create('', '', ''); // empty object
  Result := nil;
  count := 0;

  try
    try
      Lists := Browser.findOPCServers(JVM.JStringToString(host));
      count := lists.count;

      // Allocate the array of Strings
      ClsItem := JVM.findClass('java/lang/String');
      JOArray := JVM.newObjectArray(count, ClsItem, nil);

      // Now initialize each OPC Server name
      for I:=0 to count-1 do
        JVM.setObjectArrayElement(JOArray, I, JVM.StringToJString(PAnsiChar(Lists[I])));

      // Return group to java
      Result := JOArray;

      Lists.free; // free memory
    except
      on E:HostException do
        throwException(PEnv, SHostException, PAnsiChar(E.Message));
      on E:NotFoundServersException do
        throwException(PEnv, SNotFoundServersException, PAnsiChar(E.Message));
    end;
  finally
    JVM.free;
    Browser.free;
  end;
end;

//------------------------------------------------------------------------------

function Java_javafish_clients_opc_browser_JOpcBrowser_getOpcBranchNative(PEnv: PJNIEnv;
  Obj: JObject; branch : JString) : JObjectArray; stdcall;
var
  ClsItem : JClass;
  JVM     : TJNIEnv;
  JOArray : JObjectArray;
  count   : integer;
  I       : integer;
  lists   : TStringList;
begin
  Result := nil;
  // Create an instance of the Java environment
  JVM := TJNIEnv.Create(PEnv);
  try
    try
      lists := TBrowser(aopc[GetInt(ID, PEnv, Obj)]).getOPCBranch(JVM.JStringToString(branch));

      if lists <> nil
      then begin // transform to string array
        count := lists.Count;

        // Allocate the array of Strings
        ClsItem := JVM.FindClass('java/lang/String');
        JOArray := JVM.NewObjectArray(count, ClsItem, nil);

        // Now initialize each OPC Server name
        for I:=0 to count-1 do
          JVM.SetObjectArrayElement(JOArray, I, JVM.StringToJString(PAnsiChar(lists[I])));

        // Return group to java
        Result := JOArray;
        lists.Free;
      end;

    except
      on E:UnableBrowseBranchException do
        throwException(PEnv, SUnableBrowseBranchException, PAnsiChar(E.Message));
      on E:UnableIBrowseException do
        throwException(PEnv, SUnableIBrowseException, PAnsiChar(E.Message));
    end;
  finally
    JVM.Free;
  end;
end;

//------------------------------------------------------------------------------

function Java_javafish_clients_opc_browser_JOpcBrowser_getOpcItemsNative(PEnv: PJNIEnv;
  Obj: JObject; leaf: JString; download : JBoolean) : JObjectArray; stdcall;
var
  ClsItem : JClass;
  JVM     : TJNIEnv;
  JOArray : JObjectArray;
  count   : integer;
  I       : integer;
  lists   : TStringList;
begin
  Result := nil;
  count  := 0;

  // Create an instance of the Java environment
  JVM := TJNIEnv.Create(PEnv);

  try
    try
      lists := TBrowser(aopc[GetInt(ID, PEnv, Obj)]).getOPCItems(
        JVM.JStringToString(leaf), download);

      if lists <> nil
      then begin
        count := lists.Count;

        // Allocate the array of Strings
        ClsItem := JVM.FindClass('java/lang/String');
        JOArray := JVM.NewObjectArray(count, ClsItem, nil);

        // Now initialize each OPC Server name
        for I:=0 to count-1 do
          JVM.SetObjectArrayElement(JOArray, I, JVM.StringToJString(PAnsiChar(lists[I])));

        // Return group to java
        Result := JOArray;
        lists.Free;
      end;
    except
      on E:UnableBrowseLeafException do
        throwException(PEnv, SUnableBrowseLeafException, PAnsiChar(E.Message));
      on E:UnableIBrowseException do
        throwException(PEnv, SUnableIBrowseException, PAnsiChar(E.Message));
      on E:UnableAddGroupException do
        throwException(PEnv, SUnableAddGroupException, PAnsiChar(E.Message));
      on E:UnableAddItemException do
        throwException(PEnv, SUnableAddItemException, PAnsiChar(E.Message));
    end;
  finally
    JVM.Free;
  end;
end;

//------------------------------------------------------------------------------
//----------------------------- OPC METHODS ------------------------------------

procedure Java_javafish_clients_opc_JOpc_addNativeGroup(PEnv: PJNIEnv;
  Obj: JObject; group : JObject); stdcall;
begin
  try
    // create native group representation and add to OPC instance
    TOPC(aopc[GetInt(ID, PEnv, Obj)]).addGroup(TOPCGroup.create(PEnv, group));
  except
    on E:VariantInternalException do
      throwException(PEnv, SVariantInternalException, PAnsiChar(E.Message));
  end;
end;

//------------------------------------------------------------------------------

procedure Java_javafish_clients_opc_JOpc_updateNativeGroups(PEnv: PJNIEnv;
  Obj: JObject); stdcall;
begin
  try
    // update native groups of opc-client from JAVA code
    TOPC(aopc[GetInt(ID, PEnv, Obj)]).updateGroups(PEnv, Obj);
  except
    on E:VariantInternalException do
      throwException(PEnv, SVariantInternalException, PAnsiChar(E.Message));
  end;
end;

//------------------------------------------------------------------------------

function Java_javafish_clients_opc_JOpc_synchReadItemNative(PEnv: PJNIEnv;
  Obj: JObject; group : JObject; item : JObject) : JObject; stdcall;
begin
  try
    Result := TOPC(aopc[GetInt(ID, PEnv, Obj)]).synchReadItem(PEnv, group, item);
  except
    on E:ComponentNotFoundException do
      throwException(PEnv, SComponentNotFoundException, PAnsiChar(E.Message));
    on E:SynchReadException do
      throwException(PEnv, SSynchReadException, PAnsiChar(E.Message));
    on E:VariantInternalException do
      throwException(PEnv, SVariantInternalException, PAnsiChar(E.Message));
  end;
end;

//------------------------------------------------------------------------------

procedure Java_javafish_clients_opc_JOpc_synchWriteItemNative(PEnv: PJNIEnv;
  Obj: JObject; group : JObject; item : JObject); stdcall;
begin
  try
    TOPC(aopc[GetInt(ID, PEnv, Obj)]).synchWriteItem(PEnv, group, item);
  except
    on E:ComponentNotFoundException do
      throwException(PEnv, SComponentNotFoundException, PAnsiChar(E.Message));
    on E:SynchWriteException do
      throwException(PEnv, SSynchWriteException, PAnsiChar(E.Message));
    on E:VariantInternalException do
      throwException(PEnv, SVariantInternalException, PAnsiChar(E.Message));
  end;
end;

//------------------------------------------------------------------------------

function Java_javafish_clients_opc_JOpc_synchReadGroupNative(PEnv: PJNIEnv;
  Obj: JObject; group : JObject) : JObject; stdcall;
begin
  try
    Result := TOPC(aopc[GetInt(ID, PEnv, Obj)]).synchReadGroup(PEnv, group);
  except
    on E:ComponentNotFoundException do
      throwException(PEnv, SComponentNotFoundException, PAnsiChar(E.Message));
    on E:SynchReadException do
      throwException(PEnv, SSynchReadException, PAnsiChar(E.Message));
    on E:VariantInternalException do
      throwException(PEnv, SVariantInternalException, PAnsiChar(E.Message));
  end;
end;

//------------------------------------------------------------------------------

procedure Java_javafish_clients_opc_JOpc_registerGroupNative(PEnv: PJNIEnv;
  Obj: JObject; group : JObject); stdcall;
var OPC : TOPC;
    groupNative : TOPCGroup;
begin
  // register group to the opc-server
  OPC := TOPC(aopc[GetInt(ID, PEnv, Obj)]);
  try
    groupNative := OPC.getGroupByJavaCode(PEnv, group);
    OPC.registerGroup(groupNative);
  except
    on E:ComponentNotFoundException do
      throwException(PEnv, SComponentNotFoundException, PAnsiChar(E.Message));
    on E:UnableAddGroupException do
      throwException(PEnv, SUnableAddGroupException, PAnsiChar(E.Message));
  end;
end;

//------------------------------------------------------------------------------

procedure Java_javafish_clients_opc_JOpc_registerItemNative(PEnv: PJNIEnv;
  Obj: JObject; group : JObject; item : JObject); stdcall;
var OPC : TOPC;
    groupNative : TOPCGroup;
    itemNative  : TOPCItem;
begin
  // register group to the opc-server
  OPC := TOPC(aopc[GetInt(ID, PEnv, Obj)]);
  try
    groupNative := OPC.getGroupByJavaCode(PEnv, group);
    itemNative  := groupNative.getItemByJavaCode(PEnv, item);
    OPC.registerItem(groupNative, itemNative);
  except
    on E:ComponentNotFoundException do
      throwException(PEnv, SComponentNotFoundException, PAnsiChar(E.Message));
    on E:UnableAddItemException do
      throwException(PEnv, SUnableAddItemException, PAnsiChar(E.Message));
  end;
end;

//------------------------------------------------------------------------------

procedure Java_javafish_clients_opc_JOpc_registerGroupsNative(PEnv: PJNIEnv;
  Obj: JObject); stdcall;
var OPC : TOPC;
begin
  OPC := TOPC(aopc[GetInt(ID, PEnv, Obj)]);
  try
    // register all groups
    OPC.updateGroups(PEnv, Obj);
    OPC.registerGroups;
  except
    on E:UnableAddGroupException do
      throwException(PEnv, SUnableAddGroupException, PAnsiChar(E.Message));
    on E:UnableAddItemException do
      throwException(PEnv, SUnableAddItemException, PAnsiChar(E.Message));
    on E:VariantInternalException do
      throwException(PEnv, SVariantInternalException, PAnsiChar(E.Message));
  end;
end;

//------------------------------------------------------------------------------

procedure Java_javafish_clients_opc_JOpc_unregisterGroupNative(PEnv: PJNIEnv;
  Obj: JObject; group : JObject); stdcall;
var OPC : TOPC;
    groupNative : TOPCGroup;
begin
  // register group to the opc-server
  OPC := TOPC(aopc[GetInt(ID, PEnv, Obj)]);
  try
    groupNative := OPC.getGroupByJavaCode(PEnv, group);
    OPC.unregisterGroup(groupNative);
  except
    on E:ComponentNotFoundException do
      throwException(PEnv, SComponentNotFoundException, PAnsiChar(E.Message));
    on E:UnableRemoveGroupException do
      throwException(PEnv, SUnableRemoveGroupException, PAnsiChar(E.Message));
  end;
end;

//------------------------------------------------------------------------------

procedure Java_javafish_clients_opc_JOpc_unregisterItemNative(PEnv: PJNIEnv;
  Obj: JObject; group : JObject; item : JObject); stdcall;
var OPC : TOPC;
    groupNative : TOPCGroup;
    itemNative  : TOPCItem;
begin
  // register group to the opc-server
  OPC := TOPC(aopc[GetInt(ID, PEnv, Obj)]);
  try
    groupNative := OPC.getGroupByJavaCode(PEnv, group);
    itemNative  := groupNative.getItemByJavaCode(PEnv, item);
    OPC.unregisterItem(groupNative, itemNative);
  except
    on E:ComponentNotFoundException do
      throwException(PEnv, SComponentNotFoundException, PAnsiChar(E.Message));
    on E:UnableRemoveItemException do
      throwException(PEnv, SUnableRemoveItemException, PAnsiChar(E.Message));
  end;
end;

//------------------------------------------------------------------------------

procedure Java_javafish_clients_opc_JOpc_unregisterGroupsNative(PEnv: PJNIEnv;
  Obj: JObject); stdcall;
var OPC : TOPC;
begin
  OPC := TOPC(aopc[GetInt(ID, PEnv, Obj)]);
  try
    // register all groups
    OPC.updateGroups(PEnv, Obj);
    OPC.unregisterGroups;
  except
    on E:UnableRemoveGroupException do
      throwException(PEnv, SUnableRemoveGroupException, PAnsiChar(E.Message));
    on E:VariantInternalException do
      throwException(PEnv, SVariantInternalException, PAnsiChar(E.Message));
  end;
end;

//------------------------------------------------------------------------------

procedure Java_javafish_clients_opc_JOpc_asynch10ReadNative(PEnv: PJNIEnv;
  Obj: JObject; group : JObject); stdcall;
var OPC : TOPC;
    groupNative : TOPCGroup;
begin
  // register group to the opc-server
  OPC := TOPC(aopc[GetInt(ID, PEnv, Obj)]);
  try
    groupNative := OPC.getGroupByJavaCode(PEnv, group);
    OPC.asynch10Read(groupNative);
  except
    on E:ComponentNotFoundException do
      throwException(PEnv, SComponentNotFoundException, PAnsiChar(E.Message));
    on E:Asynch10ReadException do
      throwException(PEnv, SAsynch10ReadException, PAnsiChar(E.Message));
  end;
end;

//------------------------------------------------------------------------------

procedure Java_javafish_clients_opc_JOpc_asynch20ReadNative(PEnv: PJNIEnv;
  Obj: JObject; group : JObject); stdcall;
var OPC : TOPC;
    groupNative : TOPCGroup;
begin
  // register group to the opc-server
  OPC := TOPC(aopc[GetInt(ID, PEnv, Obj)]);
  try
    groupNative := OPC.getGroupByJavaCode(PEnv, group);
    OPC.asynch20Read(groupNative);
  except
    on E:ComponentNotFoundException do
      throwException(PEnv, SComponentNotFoundException, PAnsiChar(E.Message));
    on E:Asynch20ReadException do
      throwException(PEnv, SAsynch20ReadException, PAnsiChar(E.Message));
  end;
end;

//------------------------------------------------------------------------------

procedure Java_javafish_clients_opc_JOpc_asynch10UnadviseNative(PEnv: PJNIEnv;
  Obj: JObject; group : JObject); stdcall;
var OPC : TOPC;
    groupNative : TOPCGroup;
begin
  // register group to the opc-server
  OPC := TOPC(aopc[GetInt(ID, PEnv, Obj)]);
  try
    groupNative := OPC.getGroupByJavaCode(PEnv, group);
    OPC.asynch10Unadvise(groupNative);
  except
    on E:ComponentNotFoundException do
      throwException(PEnv, SComponentNotFoundException, PAnsiChar(E.Message));
    on E:Asynch10UnadviseException do
      throwException(PEnv, SAsynch10UnadviseException, PAnsiChar(E.Message));
  end;
end;

//------------------------------------------------------------------------------

procedure Java_javafish_clients_opc_JOpc_asynch20UnadviseNative(PEnv: PJNIEnv;
  Obj: JObject; group : JObject); stdcall;
var OPC : TOPC;
    groupNative : TOPCGroup;
begin
  // register group to the opc-server
  OPC := TOPC(aopc[GetInt(ID, PEnv, Obj)]);
  try
    groupNative := OPC.getGroupByJavaCode(PEnv, group);
    OPC.asynch20Unadvise(groupNative);
  except
    on E:ComponentNotFoundException do
      throwException(PEnv, SComponentNotFoundException, PAnsiChar(E.Message));
    on E:Asynch20UnadviseException do
      throwException(PEnv, SAsynch20UnadviseException, PAnsiChar(E.Message));
  end;
end;

//------------------------------------------------------------------------------

function Java_javafish_clients_opc_JOpc_getDownloadGroupNative(PEnv: PJNIEnv;
  Obj: JObject) : JObject; stdcall;
var
  queue        : TOPCQueue;
  groupNative  : TOPCGroup;
  JVM          : TJNIEnv;
  FID          : JFieldID;
  element      : TElement;
  opcClass     : JClass;
  agroups      : JArray;
  groupsCount  : integer;
  i            : integer;
  group        : JObject;
  groupClass   : JClass;
  groupCHandle : integer;
  getGroupsAsArray : JMethodID;
begin
  Result := nil;

  queue := TOPC(aopc[GetInt(ID, PEnv, Obj)]).getDefaultQueue;

  if queue.count > 0
  then begin
    // get downloaded group
    element := queue.pop;
    groupNative := element.getData;

    JVM := TJNIEnv.Create(PEnv);
    opcClass := JVM.GetObjectClass(Obj);

    // find correct instance of group for clone
    getGroupsAsArray := JVM.GetMethodID(opcClass, 'getGroupsAsArray',
      '()[Ljavafish/clients/opc/component/OpcGroup;');
    agroups := JArray(JVM.CallObjectMethodA(Obj, getGroupsAsArray, nil));

    groupsCount := JVM.GetArrayLength(agroups);

    for i:=0 to groupsCount-1 do
    begin
      // get group from Java
      group := JVM.GetObjectArrayElement(agroups, i);

      // attribute: clientHandle
      groupClass := JVM.GetObjectClass(group);
      FID := JVM.GetFieldID(groupClass, 'clientHandle', 'I');
      groupCHandle := JVM.GetIntField(group, FID);

      if (groupCHandle = groupNative.getClientHandle)
      then break;
    end;

    try
      // clone and commit result group
      Result := groupNative.clone(PEnv, group);
      groupNative.commit(PEnv, Result);
      //groupNative.Free;
    except
      on E:VariantInternalException do
      begin
        throwException(PEnv, SVariantInternalException, PAnsiChar(E.Message));
        exit;
      end;
    end;

    // free memory, important!
    JVM.free;
    element.free;
  end;
end;

//------------------------------------------------------------------------------

procedure Java_javafish_clients_opc_JOpc_setGroupUpdateTimeNative(PEnv: PJNIEnv;
  Obj: JObject; group : JObject; updateTime : JInt); stdcall;
var OPC : TOPC;
    groupNative : TOPCGroup;
begin
  // change update time of group
  OPC := TOPC(aopc[GetInt(ID, PEnv, Obj)]);
  try
    groupNative := OPC.getGroupByJavaCode(PEnv, group);
    OPC.setOPCGroupUpdateTime(groupNative, updateTime);
    // change updateTime in Java code
    groupNative.commit(PEnv, group);
  except
    on E:ComponentNotFoundException do
      throwException(PEnv, SComponentNotFoundException, PAnsiChar(E.Message));
    on E:GroupUpdateTimeException do
      throwException(PEnv, SGroupUpdateTimeException, PAnsiChar(E.Message));
    on E:VariantInternalException do
      throwException(PEnv, SVariantInternalException, PAnsiChar(E.Message));
  end;
end;

//------------------------------------------------------------------------------

procedure Java_javafish_clients_opc_JOpc_setGroupActivityNative(PEnv: PJNIEnv;
  Obj: JObject; group : JObject; active : JBoolean); stdcall;
var OPC : TOPC;
    groupNative : TOPCGroup;
begin
  // change activity of group
  OPC := TOPC(aopc[GetInt(ID, PEnv, Obj)]);
  try
    groupNative := OPC.getGroupByJavaCode(PEnv, group);
    OPC.setOPCGroupActivity(groupNative, active);
    // change active in Java code
    groupNative.commit(PEnv, group);
  except
    on E:ComponentNotFoundException do
      throwException(PEnv, SComponentNotFoundException, PAnsiChar(E.Message));
    on E:GroupActivityException do
      throwException(PEnv, SGroupActivityException, PAnsiChar(E.Message));
    on E:VariantInternalException do
      throwException(PEnv, SVariantInternalException, PAnsiChar(E.Message));
  end;
end;

//------------------------------------------------------------------------------

procedure Java_javafish_clients_opc_JOpc_setItemActivityNative(PEnv: PJNIEnv;
  Obj: JObject; group : JObject; item : JObject; active : JBoolean); stdcall;
var OPC : TOPC;
    groupNative : TOPCGroup;
    itemNative  : TOPCItem;
begin
  // change activity of group
  OPC := TOPC(aopc[GetInt(ID, PEnv, Obj)]);
  try
    groupNative := OPC.getGroupByJavaCode(PEnv, group);
    itemNative  := groupNative.getItemByJavaCode(PEnv, item);
    OPC.setOPCItemActivity(groupNative, itemNative, active);
    // change active in Java code
    itemNative.commit(PEnv, item);
  except
    on E:ComponentNotFoundException do
      throwException(PEnv, SComponentNotFoundException, PAnsiChar(E.Message));
    on E:ItemActivityException do
      throwException(PEnv, SItemActivityException, PAnsiChar(E.Message));
    on E:VariantInternalException do
      throwException(PEnv, SVariantInternalException, PAnsiChar(E.Message));
  end;
end;

(*******************************************************************************
  Make these routines available to Java.
*******************************************************************************)
exports
  // JCustomOpc methods
  Java_javafish_clients_opc_JCustomOpc_newInstance,
  Java_javafish_clients_opc_JCustomOpc_coInitializeNative,
  Java_javafish_clients_opc_JCustomOpc_coUninitializeNative,
  Java_javafish_clients_opc_JCustomOpc_connectServer,
  Java_javafish_clients_opc_JCustomOpc_getStatus,

  // JOpcBrowser methods
  Java_javafish_clients_opc_browser_JOpcBrowser_getOpcServersNative,
  Java_javafish_clients_opc_browser_JOpcBrowser_getOpcBranchNative,
  Java_javafish_clients_opc_browser_JOpcBrowser_getOpcItemsNative,

  // JOpc methods
  Java_javafish_clients_opc_JOpc_addNativeGroup,
  Java_javafish_clients_opc_JOpc_updateNativeGroups,
  Java_javafish_clients_opc_JOpc_registerGroupNative,
  Java_javafish_clients_opc_JOpc_registerItemNative,
  Java_javafish_clients_opc_JOpc_registerGroupsNative,
  Java_javafish_clients_opc_JOpc_unregisterGroupNative,
  Java_javafish_clients_opc_JOpc_unregisterItemNative,
  Java_javafish_clients_opc_JOpc_unregisterGroupsNative,
  Java_javafish_clients_opc_JOpc_synchReadItemNative,
  Java_javafish_clients_opc_JOpc_synchWriteItemNative,
  Java_javafish_clients_opc_JOpc_synchReadGroupNative,
  Java_javafish_clients_opc_JOpc_asynch10ReadNative,
  Java_javafish_clients_opc_JOpc_asynch20ReadNative,
  Java_javafish_clients_opc_JOpc_asynch10UnadviseNative,
  Java_javafish_clients_opc_JOpc_asynch20UnadviseNative,
  Java_javafish_clients_opc_JOpc_getDownloadGroupNative,
  Java_javafish_clients_opc_JOpc_setGroupUpdateTimeNative,
  Java_javafish_clients_opc_JOpc_setGroupActivityNative,
  Java_javafish_clients_opc_JOpc_setItemActivityNative;
begin
end.
