//////////////////////////////////////
//  JCustomOPC.dll                  //
//  Author:  Ing. Antonín Fischer   //
//  Date:    24.9.2006              //
//  Version: 2.0                    //
//////////////////////////////////////

library JCustomOPC;

uses
  SysUtils,
  Classes,
  ActiveX,
  JNI in 'JNI.pas',
  UEasyOPC in 'UEasyOPC.pas',
  UEasyOPCQueue in 'UEasyOPCQueue.pas',
  OPCDA in 'OPCDA.pas',
  JUtils in 'JUtils.pas',
  OPCtypes in 'OPCtypes.pas',
  OPCutils in 'OPCutils.pas',
  OPCCOMN in 'OPCCOMN.pas',
  UEasyOPCThread in 'UEasyOPCThread.pas',
  UReport in 'UReport.pas',
  UCustomOPC in 'UCustomOPC.pas',
  UOPCBrowser in 'UOPCBrowser.pas',
  OPCenum in 'OPCenum.pas',
  UOPC in 'UOPC.pas',
  UOPCGroup in 'UOPCGroup.pas',
  UOPCItem in 'UOPCItem.pas',
  UOPCExceptions in 'UOPCExceptions.pas',
  UOPCAsynch in 'UOPCAsynch.pas';

const
  ID = 'id'; // signification of id client

  // java JCustomOPC classes => Delphi class representations
  JCustomOPC_ClassName = 'javafish.clients.opc.JCustomOPC';
  JOPCBrowser_ClassName = 'javafish.clients.opc.browser.JOPCBrowser';
  JOPC_ClassName = 'javafish.clients.opc.JOPC';

type
  TAOPC = array of TCustomOPC;
  TAQReport = array of TReportQueue;

  TAQOUT = array of TEasyOPCQueue;
  TABrowser = array of TBrowser;

var
  countOPC : integer = 0;
  aopc     : TAOPC;
  aqreport : TAQReport;

  abrowser : TABrowser;
  aqout    : TAQOUT;

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

    // create and link logger
    aqreport[countOPC] := TReportQueue.Create;
    aopc[countOPC].getReport.OnStatusMessage := aqreport[countOPC].StatusMessage;

  end else
  if _className = JOPCBrowser_ClassName // JOPCBrowser
  then begin
    // create TCustomOPC
    aopc[countOPC] := TBrowser.Create(_host, _serverProgID, _serverClientHandle);

    // create and link logger
    aqreport[countOPC] := TReportQueue.Create;
    aopc[countOPC].getReport.OnStatusMessage := aqreport[countOPC].StatusMessage;
  end else
  if _className = JOPC_ClassName // JOPC
  then begin
    // create TCustomOPC
    aopc[countOPC] := TOPC.Create(_host, _serverProgID, _serverClientHandle);

    // create and link logger
    aqreport[countOPC] := TReportQueue.Create;
    aopc[countOPC].getReport.OnStatusMessage := aqreport[countOPC].StatusMessage;
  end;
end;

//------------------------------------------------------------------------------

procedure Java_javafish_clients_opc_JCustomOPC_newInstance(PEnv: PJNIEnv;
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
  SetLength(aqreport, countOPC + 1);

  // create specific native representation by className
  createNativeCodeRepresentation(_className, _host, _serverProgID, _serverClientHandle);

  // Set id-thread to java object
  SetInt(ID, countOPC, PEnv, Obj);
  Inc(countOPC);
end;

//------------------------------------------------------------------------------

procedure Java_javafish_clients_opc_JCustomOPC_connectServer(PEnv: PJNIEnv;
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

procedure Java_javafish_clients_opc_JCustomOPC_disconnectServer(PEnv: PJNIEnv;
  Obj: JObject); stdcall;
begin
  aopc[GetInt(ID, PEnv, Obj)].disconnect;
end;

//------------------------------------------------------------------------------

function Java_javafish_clients_opc_JCustomOPC_getStatus(PEnv: PJNIEnv;
  Obj: JObject) : JBoolean; stdcall;
begin
  Result := aopc[GetInt(ID, PEnv, Obj)].getServerStatus;
end;

//------------------------------------------------------------------------------
//----------------------------- BROWSER METHODS --------------------------------

function Java_javafish_clients_opc_browser_JOPCBrowser_getOPCServersNative(PEnv: PJNIEnv;
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

function Java_javafish_clients_opc_browser_JOPCBrowser_getOPCBranchNative(PEnv: PJNIEnv;
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

function Java_javafish_clients_opc_browser_JOPCBrowser_getOPCItemsNative(PEnv: PJNIEnv;
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

procedure Java_javafish_clients_opc_JOPC_addNativeGroup(PEnv: PJNIEnv;
  Obj: JObject; group : JObject); stdcall;
begin
  // create native group representation and add to OPC instance
  TOPC(aopc[GetInt(ID, PEnv, Obj)]).addGroup(TOPCGroup.create(PEnv, group));
end;

//------------------------------------------------------------------------------

procedure Java_javafish_clients_opc_JOPC_updateNativeGroups(PEnv: PJNIEnv;
  Obj: JObject); stdcall;
begin
  // update native groups of opc-client from JAVA code
  TOPC(aopc[GetInt(ID, PEnv, Obj)]).updateGroups(PEnv, Obj);
end;

//------------------------------------------------------------------------------

function Java_javafish_clients_opc_JOPC_synchReadItemNative(PEnv: PJNIEnv;
  Obj: JObject; group : JObject; item : JObject) : JObject; stdcall;
begin
  try
    Result := TOPC(aopc[GetInt(ID, PEnv, Obj)]).synchReadItem(PEnv, group, item);
  except
    on E:ComponentNotFoundException do
      throwException(PEnv, SComponentNotFoundException, PAnsiChar(E.Message));
    on E:SynchReadException do
      throwException(PEnv, SSynchReadException, PAnsiChar(E.Message));
  end;
end;

//------------------------------------------------------------------------------

procedure Java_javafish_clients_opc_JOPC_synchWriteItemNative(PEnv: PJNIEnv;
  Obj: JObject; group : JObject; item : JObject); stdcall;
begin
  try
    TOPC(aopc[GetInt(ID, PEnv, Obj)]).synchWriteItem(PEnv, group, item);
  except
    on E:ComponentNotFoundException do
      throwException(PEnv, SComponentNotFoundException, PAnsiChar(E.Message));
    on E:SynchWriteException do
      throwException(PEnv, SSynchWriteException, PAnsiChar(E.Message));
  end;
end;

//------------------------------------------------------------------------------

procedure Java_javafish_clients_opc_JOPC_registerGroupNative(PEnv: PJNIEnv;
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

procedure Java_javafish_clients_opc_JOPC_registerItemNative(PEnv: PJNIEnv;
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

procedure Java_javafish_clients_opc_JOPC_registerGroupsNative(PEnv: PJNIEnv;
  Obj: JObject; group : JObject; item : JObject); stdcall;
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
  end;
end;

//------------------------------------------------------------------------------

procedure Java_javafish_clients_opc_JOPC_unregisterGroupNative(PEnv: PJNIEnv;
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

procedure Java_javafish_clients_opc_JOPC_unregisterItemNative(PEnv: PJNIEnv;
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

procedure Java_javafish_clients_opc_JOPC_unregisterGroupsNative(PEnv: PJNIEnv;
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
  end;
end;

//------------------------------------------------------------------------------
//!!!!!!!!!!!!!!!!!!!!!!!!!!

function Java_javafish_clients_opc_JOPC_commitTest(PEnv: PJNIEnv;
  Obj: JObject; group : JObject) : JObject; stdcall;
var
  itm : TOPCGroup;
  itmClone : JObject;
  i : integer;
begin
  // update native groups of opc-client from JAVA code
  itm := TOPCGroup.create(PEnv, group);
  itmClone := itm.clone(PEnv, group);

  itm.setActive(false);
  itm.setUpdateRate(5000);
  itm.setPercentDeadBand(0.321);

  for i:=0 to itm.getItems.Count-1 do
  begin
    TOPCItem(itm.getItems[i]).setItemValue('321.0');
    TOPCItem(itm.getItems[i]).setTimeStamp(StrToDateTime('7.10.2006 22:36:01'));
  end;

  itm.commit(PEnv, itmClone);

  Result := itmClone;
end;

//------------------------------------------------------------------------------

procedure Java_javafish_clients_opc_JCustomOPC_createCustomOPC(PEnv: PJNIEnv;
  Obj: JObject; host : JString; serverProgID : JString;
  serverClientHandle : JString); stdcall;
var
  JVM  : TJNIEnv;
  _host : string;
  _serverProgID : string;
  _serverClientHandle : string;
begin
  JVM                 := TJNIEnv.Create(PEnv);
  _host               := JVM.JStringToString(host);
  _serverProgID       := JVM.JStringToString(serverProgID);
  _serverClientHandle := JVM.JStringToString(serverClientHandle);
  JVM.Free;

  // set arrays
  SetLength(aopc, countOPC + 1);
  SetLength(aqout, countOPC + 1);
  SetLength(aqreport, countOPC + 1);
  SetLength(abrowser, countOPC + 1);

  // create TEasyOPC
  //aopc[countOPC] := TCustomOPC.Create(_host, _serverProgID, _serverClientHandle);

  // create queues
  //aqout[countOPC] := TEasyOPCQueue.Create(aopc[countOPC]);

  // create browser
  //abrowser[countOPC] := TBrowser.Create(_host, _serverProgID);

  // create and link logger
  aqreport[countOPC] := TReportQueue.Create;
  aopc[countOPC].getReport.OnStatusMessage := aqreport[countOPC].StatusMessage;
  //abrowser[countOPC].getReport.OnStatusMessage := aqreport[countOPC].StatusMessage;

  // Set id-thread to java object
  SetInt(ID, countOPC, PEnv, Obj);
  Inc(countOPC);
end;

//------------------------------------------------------------------------------

procedure Java_javafish_clients_opc_JCustomOPC_startCustomOPC(PEnv: PJNIEnv;
  Obj: JObject); stdcall;
begin
  // activate client
  //aopc[GetInt(ID, PEnv, Obj)].resume;
end;

//-------------------------------------------------------------------------------

procedure Java_javafish_clients_opc_JCustomOPC_terminateCustomOPC(PEnv: PJNIEnv;
  Obj: JObject); stdcall;
begin
  // kill thread
  //aopc[GetInt(ID, PEnv, Obj)].disactivate;
end;

//--------------------------------------------------------------------------------

procedure Java_javafish_clients_opc_JCustomOPC_addCustomGroup(PEnv: PJNIEnv;
  Obj: JObject; name : JString; sleepTime : JInt); stdcall;
var
  JVM  : TJNIEnv;
  _name : string;
begin
  JVM   := TJNIEnv.Create(PEnv);
  _name := JVM.JStringToString(name);
  JVM.Free;

  // define opc-group
  //aopc[GetInt(ID, PEnv, Obj)].defineGroup(_name, sleepTime);
end;

//------------------------------------------------------------------------------

procedure Java_javafish_clients_opc_JCustomOPC_addCustomItem(PEnv: PJNIEnv;
  Obj: JObject; groupName : JString;
  itemName : JString); stdcall;
var
  JVM  : TJNIEnv;
  _groupName : string;
  _itemName  : string;
begin
  JVM   := TJNIEnv.Create(PEnv);
  _groupName := JVM.JStringToString(groupName);
  _itemName  := JVM.JStringToString(itemName);
  JVM.Free;

  // define opc-item
  //aopc[GetInt(ID, PEnv, Obj)].SetItem(_groupName, _itemName);
end;

//------------------------------------------------------------------------------

function Java_javafish_clients_opc_JCustomOPC_getDownloadGroup(PEnv: PJNIEnv;
  Obj: JObject) : JObject; stdcall;
  //*******************************
  // create Java OPC item object
  function createOPCItem(JVM: TJNIEnv; item : GroupItems) : JObject;
  var Cls, ClsDate: JClass;
      Mid, MidDate: JMethodID;
      Args: array[0..3] of JValue;
      ArgsDate: array[0..5] of JValue;
      JDate : JObject;
      Y, M, D, HH, MM, SS, MS : word;
  begin
    // Find the OPCItem class
    Cls := JVM.FindClass('javafish/clients/opc/OPCItem');
    if Cls = nil then
    begin
      //aopc[GetInt(ID, PEnv, Obj)].setStatusMessage(ID108, '');
      Result := nil;
      exit;
    end;
    // Get its constructor (the one that takes 4 integers)
    Mid := JVM.GetMethodID(Cls, '<init>',
      '(Ljava/lang/String;Ljava/util/GregorianCalendar;Ljava/lang/String;Z)V');
    if Mid = nil then
    begin
      //aopc[GetInt(ID, PEnv, Obj)].setStatusMessage(ID109, '');
      Result := nil;
      exit;
    end;

    // timeStamp
    DecodeDate(item.TimeStamp, Y, M, D);
    DecodeTime(item.TimeStamp, HH, MM, SS, MS);
    ClsDate := JVM.FindClass('java/util/GregorianCalendar');
    MidDate := JVM.GetMethodID(ClsDate, '<init>', '(IIIIII)V');

    // set Date parameters
    ArgsDate[0].i := Y;
    ArgsDate[1].i := M-1;
    ArgsDate[2].i := D;
    ArgsDate[3].i := HH;
    ArgsDate[4].i := MM;
    ArgsDate[5].i := SS;

    JDate := JVM.NewObjectA(ClsDate, MidDate, @argsDate);

    // set parameters, to create java object OPCItem
    Args[0].l := JVM.StringToJString(PAnsiChar(item.ItemName));
    Args[1].l := JDate;
    Args[2].l := JVM.StringToJString(PAnsiChar(item.ItemValue));
    Args[3].z := (item.ItemQuality and OPC_QUALITY_MASK) = OPC_QUALITY_GOOD;

    Result := JVM.NewObjectA(Cls, Mid, @args);
  end;
  //*********************************************
var
  Cls: JClass;
  ClsItem : JClass;
  Mid: JMethodID;
  JOGroup: JObject;
  Args: array[0..2] of JValue;
  JVM: TJNIEnv;
  JOArray : JObjectArray;
  element : TElement;
  I : integer;
begin
  Result := nil;

  if aqout[GetInt(ID, PEnv, Obj)].Count > 0
  then begin
    // get downloaded group
    element := aqout[GetInt(ID, PEnv, Obj)].Pop;

    // Create an instance of the Java environment
    JVM := TJNIEnv.Create(PEnv);

    // Find the OPCGroup class
    Cls := JVM.FindClass('javafish/clients/opc/OPCGroup');
    if Cls = nil then
    begin
      //aopc[GetInt(ID, PEnv, Obj)].setStatusMessage(ID110, '');
      Result := nil;
      exit;
    end;

    // OPCGroup Constructor
    Mid := JVM.GetMethodID(Cls, '<init>',
      '(Ljava/lang/String;I[Ljavafish/clients/opc/OPCItem;)V');
    if Mid = nil then
    begin
      //aopc[GetInt(ID, PEnv, Obj)].setStatusMessage(ID111, '');
      Result := nil;
      exit;
    end;

    // create OPCItems Array //
    // Allocate the array of Rectangles
    ClsItem := JVM.FindClass('javafish/clients/opc/OPCItem');
    JOArray := JVM.NewObjectArray(element.getData.ItemCount, ClsItem, nil);

    // Now initialize each one to a OPC Item
    for I:=0 to element.getData.ItemCount - 1 do
    begin
      // Assign the item to an element of the array
      JVM.SetObjectArrayElement(JOArray, I,
        createOPCItem(JVM, element.getData.Items[I]));
    end;

    // OPCGroup //
    // set parameters a create java object
    Args[0].l := JVM.StringToJString(PAnsiChar(element.getData.GroupName));
    Args[1].i := element.getData.ItemCount;
    Args[2].l := JOArray;

    // create OPC Group
    JOGroup := JVM.NewObjectA(Cls, Mid, @args);

    // Return group to java
    Result := JOGroup;

    JVM.Free;
    element.Free; // downloaded package from opc
  end;
end;

//-------------------------------------------------------------------------------

function Java_javafish_clients_opc_JCustomOPC_getReport(PEnv: PJNIEnv; Obj: JObject) : JString; stdcall;
var
  JVM : TJNIEnv;
  Cls : JClass;
  Mid: JMethodID;
  element  : TReportElement;
  Args: array[0..1] of JValue;
begin
  Result := nil;

  if aqreport[GetInt(ID, PEnv, Obj)].Count > 0
  then begin
    // get opc report
    element := aqreport[GetInt(ID, PEnv, Obj)].Pop;

    JVM := TJNIEnv.Create(PEnv);
    Cls := JVM.FindClass('javafish/clients/opc/OPCReport');
    if Cls = nil then
    begin
      //aopc[GetInt(ID, PEnv, Obj)].setStatusMessage(ID112, '');
      Result := nil;
      exit;
    end;

    Mid := JVM.GetMethodID(Cls, '<init>', '(ILjava/lang/String;)V');
    if Mid = nil then
    begin
      //aopc[GetInt(ID, PEnv, Obj)].setStatusMessage(ID113, '');
      Result := nil;
      exit;
    end;

    // OPCGroup //
    // set parameters a create java object
    Args[0].i := element.GetIDReport;
    Args[1].l := JVM.StringToJString(PAnsiChar(element.GetReport));

    // Return report to java
    Result := JVM.NewObjectA(Cls, Mid, @args);

    JVM.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure Java_javafish_clients_opc_JCustomOPC_pauseClient(PEnv: PJNIEnv; Obj: JObject); stdcall;
begin
  //aopc[GetInt(ID, PEnv, Obj)].PauseClient;
end;

//------------------------------------------------------------------------------

procedure Java_javafish_clients_opc_JCustomOPC_playClient(PEnv: PJNIEnv; Obj: JObject); stdcall;
begin
  //aopc[GetInt(ID, PEnv, Obj)].PlayClient;
end;


(*******************************************************************************
  Make these routines available to Java.
*******************************************************************************)
exports
  // old methods
  Java_javafish_clients_opc_JCustomOPC_createCustomOPC,
  Java_javafish_clients_opc_JCustomOPC_startCustomOPC,
  Java_javafish_clients_opc_JCustomOPC_terminateCustomOPC,
  Java_javafish_clients_opc_JCustomOPC_addCustomGroup,
  Java_javafish_clients_opc_JCustomOPC_addCustomItem,
  Java_javafish_clients_opc_JCustomOPC_getDownloadGroup,
  Java_javafish_clients_opc_JCustomOPC_getReport,
  Java_javafish_clients_opc_JCustomOPC_pauseClient,
  Java_javafish_clients_opc_JCustomOPC_playClient,

  // JCustomOPC methods
  Java_javafish_clients_opc_JCustomOPC_newInstance,
  Java_javafish_clients_opc_JCustomOPC_connectServer,
  Java_javafish_clients_opc_JCustomOPC_disconnectServer,
  Java_javafish_clients_opc_JCustomOPC_getStatus,

  // JOPCBrowser methods
  Java_javafish_clients_opc_browser_JOPCBrowser_getOPCServersNative,
  Java_javafish_clients_opc_browser_JOPCBrowser_getOPCBranchNative,
  Java_javafish_clients_opc_browser_JOPCBrowser_getOPCItemsNative,

  // JOPC methods
  Java_javafish_clients_opc_JOPC_addNativeGroup,
  Java_javafish_clients_opc_JOPC_updateNativeGroups,
  Java_javafish_clients_opc_JOPC_registerGroupNative,
  Java_javafish_clients_opc_JOPC_registerItemNative,
  Java_javafish_clients_opc_JOPC_registerGroupsNative,
  Java_javafish_clients_opc_JOPC_unregisterGroupNative,
  Java_javafish_clients_opc_JOPC_unregisterItemNative,
  Java_javafish_clients_opc_JOPC_unregisterGroupsNative,
  Java_javafish_clients_opc_JOPC_synchReadItemNative,
  Java_javafish_clients_opc_JOPC_synchWriteItemNative;
begin
end.
