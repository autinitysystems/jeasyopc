unit UEasyOPC;
////////////////////////////////////////////
// JEasyOPC - OLE for Process Control     //
//                                        //
// Author:  Ing. Antonín Fischer          //
// Date:    6.2.2006                      //
// Version: 2.0                           //
////////////////////////////////////////////

interface

uses Variants, Classes, Windows, Forms, ComObj, ActiveX, SysUtils, UReport,
     OPCtypes, OPCDA, OPCutils, OPCCOMN;

const
  TRYREPEAT = 10;         // repeat connection or add items (problem reality)
  CONNTIMEOUT = 3;        // seconds - OPC connectivity test
  TRYCONNECT  = 3000;     // ms - try to reconnect to OPC server
  LOOPTIME    = 50;       // ms - test condition for OPC connectivity
  TEST_TIME_ACTIVITY = 3; // seconds - timeout for external test server activity
  STREMPTY = 'EMPTY';

  // standard time
  OneSecond = 1 / (24 * 60 * 60); // for waiting

  // FOR EXAMPLE:
  // these are for use with the Matrikon sample server
  SERVERNAME   = 'localhost';
  SERVERPROGID = 'Matrikon.OPC.Simulation';
  ItemName0    = 'Triangle Waves.Real8';

type
  // OPC client exception
  OPClientException = class(Exception);

  // types for organization groups and items
  GroupItems = record
    ItemName     : string;
    ClientHandle : OPCHANDLE; // ID number of item
    ItemHandle   : OPCHANDLE; // serverhandle
    ItemType     : TVarType;
    ItemValue    : string;
    ItemQuality  : Word;
    TimeStamp    : TDateTime;
  end;
  GroupItemsArray = array of GroupItems;

  POPCGroup = ^OPCGroup;
  OPCGroup = record
    GroupName    : string;
    GroupIf      : IOPCItemMgt;
    ClientHandle : OPCHANDLE;         // clienthandle (ID number of group)
    GroupHandle  : OPCHANDLE;         // serverhandle
    Active       : boolean;           // activity of group
    TimeInterval : Cardinal;          // time of data read
    TimeIntervalByControl : Cardinal; // time of data read by control
    ControlActivity       : boolean;  // control Active or TimeInterval
    ItemCount    : integer;           // number of items in group
    Items        : GroupItemsArray;
  end;
  GroupsArray = array of OPCGroup;

  // events
  TOPCitem  = procedure (IDGroup, IDItem : Cardinal; Quality : Word;
    IType : Word; DTime : TDateTime; Value : string) of object;
  TOPCgroup = procedure (IDGroup : Cardinal) of object; // only internal
  TDownOPCgroup = procedure (IDGroup : Cardinal; DownOPCGroup : OPCGroup) of object;
  TDownPointerOPCgroup = procedure (IDGroup : Cardinal; PDownOPCGroup : Pointer) of object;
  TGroupInfo = procedure(GroupInfo : TStringList) of object;

  // class to receive IDataObject data change advises
  TOPCAdviseSink = class(TInterfacedObject, IAdviseSink)
  public
    OnDownloadedItem  : TOPCitem;
    OnDownloadedGroup : TOPCgroup;
    procedure OnDataChange(const formatetc: TFormatEtc;
                             const stgmed: TStgMedium); stdcall;
    procedure OnViewChange(dwAspect: Longint; lindex: Longint); stdcall;
    procedure OnRename(const mk: IMoniker); stdcall;
    procedure OnSave; stdcall;
    procedure OnClose; stdcall;
  end;

  // class to receive IConnectionPointContainer data change callbacks
  TOPCDataCallback = class(TInterfacedObject, IOPCDataCallback)
  public
    OnDownloadedItem  : TOPCitem;
    OnDownloadedGroup : TOPCgroup;
    function OnDataChange(dwTransid: DWORD; hGroup: OPCHANDLE;
      hrMasterquality: HResult; hrMastererror: HResult; dwCount: DWORD;
      phClientItems: POPCHANDLEARRAY; pvValues: POleVariantArray;
      pwQualities: PWordArray; pftTimeStamps: PFileTimeArray;
      pErrors: PResultList): HResult; stdcall;
    function OnReadComplete(dwTransid: DWORD; hGroup: OPCHANDLE;
      hrMasterquality: HResult; hrMastererror: HResult; dwCount: DWORD;
      phClientItems: POPCHANDLEARRAY; pvValues: POleVariantArray;
      pwQualities: PWordArray; pftTimeStamps: PFileTimeArray;
      pErrors: PResultList): HResult; stdcall;
    function OnWriteComplete(dwTransid: DWORD; hGroup: OPCHANDLE;
      hrMastererr: HResult; dwCount: DWORD; pClienthandles: POPCHANDLEARRAY;
      pErrors: PResultList): HResult; stdcall;
    function OnCancelComplete(dwTransid: DWORD; hGroup: OPCHANDLE):
      HResult; stdcall;
  end;

  // callback methods
  OPCMethods = (M_AdviseSink, M_OPCDataCallback);

//====================================================================

  /////////////////////////////////
  // Main CLASS for OPC standard //
  // public OPC Client           //
  /////////////////////////////////
  TEasyOPC = class(TThread)
  protected
    serverActivity     : boolean;         // server activity
    testServerActivity : boolean;         // test server activity
    host               : string;          // network host
    ServerProgID       : string;          // OPC server name: ProgID
    ServerClientHandle : string;          // OPC Client Handle
    ServerIf         : IOPCServer;        // server information
    ppServerStatus   : POPCSERVERSTATUS;  // server status
    Active           : boolean;           // live cycle - running thread
    Paused           : boolean;           // client is temporary paused
    ControlActivity  : boolean;           // control activity of groups
    HR               : HResult;           // status of responses
    OPCDataCallback  : TOPCDataCallback;  // reference TOPCDataCallback
    AsyncConnection  : Longint;           // type of communication
    StartTime        : TDateTime;         // start connection time
    GroupCount       : integer;           // number of Groups OPC
    OPCGroups        : GroupsArray;       // structures of groups
    OPCMethod        : OPCMethods;        // method for OPC data
    // report
    Report           : TReport;           // logging
    // events handle
    FOPCitem         : TOPCitem;          // events downloaded item
    FOPCgroup        : TOPCgroup;         // events downloaded group
    FDownOPCgroup    : TDownOPCgroup;     // events get group structure
    // Methods
    AdviseSink       : TOPCAdviseSink;    // reference TOPCAdviseSink
    procedure  Execute; override;                     // activation thread
    function   ConnectToOPCServer : IOPCServer;       // connection
    function   AddMyGroupsToOPCServer : HResult;      // try to set groups to OPC
    function   SignGroup(var OPCG : OPCGroup) : HResult;  // try to set group to OPC
    // try to set item to group
    function   SignItem(OPCG: OPCGroup; var Item : GroupItems): HResult;
    function   Run_AdviseSink(var OPCG: OPCGroup) : boolean;      // run method AdviseSink
    function   Run_OPCDataCallback(var OPCG: OPCGroup) : boolean; // run method OPCDataCallback
    procedure  DeactivateOPCGroupsReading;
    procedure  DeactivateOPCGroupReading(OG : OPCGroup);
    // main function for external control by DM, MMS6000, or OPC etc. - use UseControlByQueue
    function   ControlByGroup(grouphandle : integer; conditionActive : boolean) : HResult;
    function   SetOPCGroupActivity(OG : OPCGroup; Active: bool) : HResult;
    function   SetOPCGroupUpdateTime(OG : OPCGroup; UpdateTime : DWORD): HResult;
    function   RemoveGroupOPC(OG : OPCGroup) : HResult;
    function   RemoveGroupsOPC : HResult;
    procedure  DownloadedItems(IDGroup, IDItem : Cardinal; Quality : Word;
                  IType : Word; DTime : TDateTime; Value : string);
    procedure  DownloadedGroup(IDGroup : Cardinal);
    procedure  ControlActivityGroups;
  public
    // create OPC client
    constructor Create(host, ServerProgID, ServerClientHandle : string; OPCmethod : OPCmethods);
    procedure   DefineGroup(GroupName : string; TimeInterval : Cardinal); overload;
    procedure   DefineGroup(GroupName : string; TimeInterval : Cardinal;
      Active : boolean; ControlActivity: boolean; TimeIntervalByControl : Cardinal); overload;
    procedure   SetItem(GroupName, ItemName : string);
    function    isActive : boolean;           // running live cycle
    procedure   Disactivate;                  // death thread
    // GET
    function    GetServerStatus : HResult;    // get OPC server status info
    function    GetServerActivity: boolean;   // get server activity
    function    GetGroupCount : integer;      // count of groups
    function    GetGroupClientHandleByName(gname : string) : OPCHANDLE;
    function    GetStartTime : TDateTime;     // time running connection with OPC
    function    GetGroups : GroupsArray;      // get all groups
    function    GetInfoAboutGroupFromOPC(OG: OPCGroup) : string;
    function    GetFullOPCName : string;
    function    GetInfoAboutMyOPC : TStringList;
    function    isPaused : boolean;
    procedure   PauseClient;
    procedure   PlayClient;
    function    getReport : TReport; // get logger
    // set status message
    procedure   setStatusMessage(const idReport : integer; const report: string);

    // testing
    procedure test1;
    function test2 : boolean;
  published
    // EVENTS //
    //- get actual item from OPC
    property OnDownloadedItem: TOPCitem read FOPCitem write FOPCitem;
    //- get actual groups from OPC
    property OnDownloadedGroup: TDownOPCgroup read FDownOPCgroup write FDownOPCgroup;
  end;

//======================================================================

implementation

uses UOPCBrowser;

// empty string for localhost connection
function GetHostName(str: string): string;
begin
  if (str = '127.0.0.1') or
     (str = 'localhost') or
     (str = 'local') then Result := ''
                     else Result := str;
end;

{ TOPCAdviseSink }

procedure TOPCAdviseSink.OnDataChange(const formatetc: TFormatEtc;
  const stgmed: TStgMedium);
var
  PG           : POPCGROUPHEADER;
  PI1          : POPCITEMHEADER1ARRAY;
  PI2          : POPCITEMHEADER2ARRAY;
  PV           : POleVariant;
  Time         : TFileTime;
  STime        : TSystemTime;
  DT           : TDateTime;
  I            : Integer;
  PStr         : PWideChar;
  NewValue     : string;
  WithTime     : Boolean;
  ClientHandle : OPCHANDLE;
  ClientGroup  : OPCHANDLE;
  Quality      : Word;
begin
  // the rest of this method assumes that the item header array uses
  // OPCITEMHEADER1 or OPCITEMHEADER2 records,
  // so check this first to be defensive
  if (formatetc.cfFormat <> OPCSTMFORMATDATA) and
      (formatetc.cfFormat <> OPCSTMFORMATDATATIME) then Exit;
  // does the data stream provide timestamps with each value?
  WithTime := formatetc.cfFormat = OPCSTMFORMATDATATIME;

  PG := GlobalLock(stgmed.hGlobal);
  if PG <> nil then
  begin
    // we will only use one of these two values, according to whether
    // WithTime is set:
    PI1 := Pointer(PChar(PG) + SizeOf(OPCGROUPHEADER));
    PI2 := Pointer(PI1);
    if Succeeded(PG.hrStatus) then
    begin
      for I := 0 to PG.dwItemCount - 1 do
      begin
        if WithTime then
        begin
          PV := POleVariant(PChar(PG) + PI1[I].dwValueOffset);
          // convert timestamp to localtime
          Time := PI1[I].ftTimeStampItem;
          FileTimeToLocalFileTime(Time,Time);
          FileTimeToSystemTime(Time,STime);
          DT := SystemTimeToDateTime(STime);
          // handles and qualities
          ClientGroup  := PG.hClientGroup;
          ClientHandle := PI1[I].hClient;
          Quality      := (PI1[I].wQuality and OPC_QUALITY_MASK);
        end
        else begin
          PV := POleVariant(PChar(PG) + PI2[I].dwValueOffset);
          ClientHandle := PI2[I].hClient;
          Quality      := (PI2[I].wQuality and OPC_QUALITY_MASK);
        end;
        if Quality = OPC_QUALITY_GOOD then
        begin
          // this test assumes we're not dealing with array data
          if TVarData(PV^).VType <> VT_BSTR then
          begin
            NewValue := VarToStr(PV^);
          end
          else begin
            // for BSTR data, the BSTR image follows immediately in the data
            // stream after the variant union;  the BSTR begins with a DWORD
            // character count, which we skip over as the BSTR is also
            // NULL-terminated
            PStr := PWideChar(PChar(PV) + SizeOf(OleVariant) + 4);
            NewValue := WideString(PStr);
          end;
          if not WithTime then DT := Now;
        end;
        // aktual downloaded value
        OnDownloadedItem(
         ClientGroup,
         ClientHandle,
         Quality,
         TVarData(PV^).VType,
         DT,
         NewValue
        );
      end;
      // activate group
      OnDownloadedGroup(ClientGroup);
    end;
    GlobalUnlock(stgmed.hGlobal);
  end;
end;

procedure TOPCAdviseSink.OnRename(const mk: IMoniker);
begin
  // not used
end;

procedure TOPCAdviseSink.OnSave;
begin
  // not used
end;

procedure TOPCAdviseSink.OnClose;
begin
  // not used
end;

procedure TOPCAdviseSink.OnViewChange(dwAspect, lindex: Integer);
begin
  // not used
end;

{ TOPCDataCallback }

function TOPCDataCallback.OnDataChange(dwTransid: DWORD; hGroup: OPCHANDLE;
  hrMasterquality, hrMastererror: HResult; dwCount: DWORD;
  phClientItems: POPCHANDLEARRAY; pvValues: POleVariantArray;
  pwQualities: PWordArray; pftTimeStamps: PFileTimeArray;
  pErrors: PResultList): HResult;
var
  ClientItems : POPCHANDLEARRAY;
  Values      : POleVariantArray;
  Qualities   : PWORDARRAY;
  I           : Integer;
  NewValue    : string;
  STime       : TSystemTime;
  DT          : TDateTime;
  ATimes      : PFileTimeArray;
  Time        : TFileTime;
begin
  Result      := S_OK;
  ClientItems := POPCHANDLEARRAY(phClientItems);
  Values      := POleVariantArray(pvValues);
  Qualities   := PWORDARRAY(pwQualities);
  ATimes      := PFileTimeArray(pftTimeStamps);
  for I := 0 to dwCount - 1 do
  begin
    if Qualities[I] = OPC_QUALITY_GOOD then
    begin
      NewValue := VarToStr(Values[I]);
      // convert timestamp to localtime
      Time := ATimes[I];
      FileTimeToLocalFileTime(Time,Time);
      FileTimeToSystemTime(Time,STime);
      DT := SystemTimeToDateTime(STime);
    end;
    // aktual downloaded value
    OnDownloadedItem(
     hGroup,
     ClientItems[I],
     Qualities[I],
     0,
     DT,
     NewValue
    );
  end;
  // activate group
  OnDownloadedGroup(hGroup);
end;

function TOPCDataCallback.OnReadComplete(dwTransid: DWORD; hGroup: OPCHANDLE;
  hrMasterquality, hrMastererror: HResult; dwCount: DWORD;
  phClientItems: POPCHANDLEARRAY; pvValues: POleVariantArray;
  pwQualities: PWordArray; pftTimeStamps: PFileTimeArray;
  pErrors: PResultList): HResult;
begin
  Result := OnDataChange(dwTransid, hGroup, hrMasterquality, hrMastererror,
    dwCount, phClientItems, pvValues, pwQualities, pftTimeStamps, pErrors);
end;

function TOPCDataCallback.OnCancelComplete(dwTransid: DWORD;
  hGroup: OPCHANDLE): HResult;
begin
  // we don't use this facility
  Result := S_OK;
end;

function TOPCDataCallback.OnWriteComplete(dwTransid: DWORD; hGroup: OPCHANDLE;
  hrMastererr: HResult; dwCount: DWORD; pClienthandles: POPCHANDLEARRAY;
  pErrors: PResultList): HResult;
begin
  // we don't use this facility
  Result := S_OK;
end;

//============================================================================

{ TEasyOPC }

constructor TEasyOPC.Create(host, ServerProgID, ServerClientHandle: string;
  OPCmethod : OPCmethods);
begin
  Self.host               := host;
  Self.ServerProgID       := ServerProgID;
  Self.ServerClientHandle := ServerClientHandle;
  GroupCount              := 0; // number of groups
  testServerActivity      := false;
  ServerActivity          := false;
  Self.OPCmethod          := OPCmethod;
  Report                  := TReport.Create;
  inherited Create(True); // thread is prepared for after activation
end;

function TEasyOPC.ConnectToOPCServer: IOPCServer;
begin
  try
    // among other things, this call makes sure that COM is initialized
    Application.Initialize;
    CoInitialize(nil);

    Result := nil;
    // we will use the custom OPC interfaces, and OPCProxy.dll will handle
    // marshaling for us automatically (if registered)
    if GetHostName(Host) = '' // local
    then Result := CreateComObject(ProgIDToClassID(ServerProgID)) as IOPCServer
    else Result := CreateRemoteComObject(Host, ProgIDToClassID(ServerProgID)) as IOPCServer;
  except
    on E:EOleSysError do
    begin
      SetStatusMessage(-1, E.Message);
      Result := nil;
    end;
  end;
  // result connection
  if Result <> nil
  then begin
    SetStatusMessage(ID200, host + '//' + ServerProgID);
    StartTime := Now; // start connection time
  end
  else SetStatusMessage(ID100, host + '//' + ServerProgID);
end;

procedure TEasyOPC.SetStatusMessage(const idReport : integer; const report: string);
begin
  self.Report.setStatusMessage(idReport, report);
end;

procedure TEasyOPC.DefineGroup(GroupName: string; TimeInterval: Cardinal);
begin
  // only define group
  SetLength(OPCGroups, GroupCount + 1);
  OPCGroups[GroupCount].Active       := true;
  OPCGroups[GroupCount].GroupName    := GroupName;
  OPCGroups[GroupCount].ClientHandle := GroupCount;
  OPCGroups[GroupCount].ItemCount    := 0;
  OPCGroups[GroupCount].ControlActivity := True;
  OPCGroups[GroupCount].TimeInterval    := TimeInterval;
  OPCGroups[GroupCount].TimeIntervalByControl := 0;
  GroupCount := GroupCount + 1;
end;

procedure TEasyOPC.DefineGroup(GroupName: string; TimeInterval: Cardinal;
  Active : boolean; ControlActivity: boolean; TimeIntervalByControl: Cardinal);
begin
  DefineGroup(GroupName, TimeInterval);
  OPCGroups[GroupCount-1].Active                := Active;
  OPCGroups[GroupCount-1].ControlActivity       := ControlActivity;
  OPCGroups[GroupCount-1].TimeIntervalByControl := TimeIntervalByControl;
end;

procedure TEasyOPC.SetItem(GroupName, ItemName : string);
var idx : integer;
    itc : integer;
begin
  // only define item of group
  for idx:=0 to GroupCount-1 do
    if OPCGroups[idx].GroupName = GroupName
    then begin
      // set item to group
      itc := OPCGroups[idx].ItemCount;
      SetLength(OPCGroups[idx].Items, itc+1);
      OPCGroups[idx].Items[itc].ClientHandle := itc;
      OPCGroups[idx].Items[itc].ItemName     := ItemName;
      inc(OPCGroups[idx].ItemCount);
      break;
    end;
end;

function TEasyOPC.SignGroup(var OPCG: OPCGroup): HResult;
var idx : integer;
begin
  for idx:=0 to TRYREPEAT do
  begin // the group is automatically started
    Result := ServerAddGroup(ServerIf, OPCG.GroupName, OPCG.Active, OPCG.TimeInterval,
      OPCG.ClientHandle, OPCG.GroupIf, OPCG.GroupHandle);
    if Succeeded(Result) then break;
  end;
end;

function TEasyOPC.SignItem(OPCG: OPCGroup; var Item: GroupItems): HResult;
var idx : integer;
begin
  for idx:=0 to TRYREPEAT do
  begin
    Result := GroupAddItem(OPCG.GroupIf, Item.ItemName, Item.ClientHandle, VT_EMPTY,
      Item.ItemHandle, Item.ItemType);
    if Succeeded(Result) then break;
  end;
end;

function TEasyOPC.AddMyGroupsToOPCServer : HResult;
var idx, idxit : integer;
begin
  for idx:=0 to GroupCount-1 do
  begin
    Result := SignGroup(OPCGroups[idx]);
    if Succeeded(Result)
    then begin
      SetStatusMessage(ID201, OPCGroups[idx].GroupName);
      // set items to group
      for idxit:=0 to OPCGroups[idx].ItemCount-1 do
      begin
        Result := SignItem(OPCGroups[idx], OPCGroups[idx].Items[idxit]);
        if Succeeded(Result)
        then SetStatusMessage(ID202, OPCGroups[idx].GroupName +
          '.' + OPCGroups[idx].Items[idxit].ItemName)
        else begin
           SetStatusMessage(ID102, OPCGroups[idx].GroupName +
             '.' + OPCGroups[idx].Items[idxit].ItemName);
           Exit;
        end;
      end;
    end
    else begin
      SetStatusMessage(ID101, OPCGroups[idx].GroupName);
      Exit;
    end;
  end;
end;

function TEasyOPC.GetStartTime: TDateTime;
begin
  Result := StartTime;
end;

function TEasyOPC.GetInfoAboutMyOPC: TStringList;
begin
  Result := TStringList.Create;
  Result.Add('OPC Server = ' + ServerProgID);
  Result.Add('Host = ' + host);
  Result.Add('Server Client Handle = ' + ServerClientHandle);
  Result.Add('Active = ' + BoolToStr(Active));
  Result.Add('Start Time = ' + DateTimeToStr(StartTime));
  Result.Add('Group Count = ' + IntToStr(GroupCount));
end;

function TEasyOPC.Run_AdviseSink(var OPCG: OPCGroup): boolean;
begin
  // create data object and active thread of group
  AdviseSink := TOPCAdviseSink.Create;
  AdviseSink.OnDownloadedItem  := DownloadedItems;
  AdviseSink.OnDownloadedGroup := DownloadedGroup;
  HR := GroupAdviseTime(OPCG.GroupIf, AdviseSink, AsyncConnection);
  if Failed(HR)
  then SetStatusMessage(ID103, '')
  else SetStatusMessage(ID203, '');
end;

function TEasyOPC.Run_OPCDataCallback(var OPCG: OPCGroup): boolean;
begin
  // create data object and active thread of group
  OPCDataCallback := TOPCDataCallback.Create;
  OPCDataCallback.OnDownloadedItem  := DownloadedItems;
  OPCDataCallback.OnDownloadedGroup := DownloadedGroup;
  HR := GroupAdvise2(OPCG.GroupIf, OPCDataCallback, AsyncConnection);
  if Failed(HR)
  then SetStatusMessage(ID104, '')
  else SetStatusMessage(ID204, '');
end;

function TEasyOPC.ControlByGroup(grouphandle: integer;
  conditionActive: boolean): HResult;
var OG : OPCGroup;
begin
  // EXTERNAL CONTROL
  if (grouphandle >= 0) and (grouphandle <= Length(OPCGroups)-1)
  then begin
    OG := OPCGroups[grouphandle];
    if OG.ControlActivity
    then begin // control active
      if conditionActive
      then Result := SetOPCGroupActivity(OG, True)
      else Result := SetOPCGroupActivity(OG, False);
    end
    else begin // control timeinterval
      if conditionActive
      then Result := SetOPCGroupUpdateTime(OG, OG.TimeIntervalByControl)
      else Result := SetOPCGroupUpdateTime(OG, OG.TimeInterval);
    end;
  end
  else Result := 0;
end;

function TEasyOPC.GetGroupCount: integer;
begin
  Result := GroupCount;
end;

procedure TEasyOPC.Disactivate;
begin
  Active := False;
end;

function TEasyOPC.isActive: boolean;
begin
  Result := Active;
end;

function TEasyOPC.GetGroups: GroupsArray;
begin
  Result := OPCGroups;
end;

function TEasyOPC.GetGroupClientHandleByName(gname: string): OPCHANDLE;
var idx   : integer;
    Found : boolean;
begin
  Found := False;
  for idx:=Low(OPCGroups) to High(OPCGroups) do
    if  OPCGroups[idx].GroupName = gname
    then begin
      Result := OPCGroups[idx].ClientHandle;
      Found  := True;
      break;
    end;
  if not Found
  then raise OPClientException.Create('OPCgroup error!');
end;

function TEasyOPC.GetFullOPCName: string;
begin
  Result := ServerClientHandle + '-' + ServerProgID;
end;

function TEasyOPC.SetOPCGroupActivity(OG: OPCGroup; Active: bool): HResult;
begin
  Result := SetGroupActivity(OG.GroupIf, Active);
end;

function TEasyOPC.SetOPCGroupUpdateTime(OG: OPCGroup; UpdateTime: DWORD): HResult;
begin
  Result := SetGroupUpdateTime(OG.GroupIf as IOPCItemMgt, UpdateTime);
end;

function TEasyOPC.GetInfoAboutGroupFromOPC(OG: OPCGroup) : string;
var GInfo : string;
begin
  Result := '';
  HR := GetGroupInfo(OG.GroupIf, GInfo);
  if Succeeded(HR) then Result := GInfo;
end;

procedure TEasyOPC.DownloadedItems(IDGroup, IDItem : Cardinal; Quality : Word;
  IType : Word; DTime : TDateTime; Value : string);
begin
  with OPCGroups[IDGroup].Items[IDItem] do
  begin
    ClientHandle := IDItem;
    ItemQuality  := Quality;
    ItemType     := IType;
    ItemValue    := Value;
    TimeStamp    := DTime;
  end;
  // call user event
  if Assigned(OnDownloadedItem)
  then FOPCitem(IDGroup, IDItem, Quality, IType, DTime, Value);
end;

procedure TEasyOPC.DownloadedGroup(IDGroup: Cardinal);
begin
  if not Self.Suspended // not use event that the thread is suspended
  then begin
    // call user event for downloaded IDGroup
    if Assigned(OnDownloadedGroup)
    then FDownOPCgroup(IDGroup, OPCGroups[IDGroup]); // get OPCGroups
  end;
end;

function TEasyOPC.GetServerStatus: HResult;
begin
  Result := ServerIf.GetStatus(ppServerStatus);
end;

function TEasyOPC.GetServerActivity: boolean;
var
 testTime : TDateTime;
begin
  if not Active
  then begin Result := false; exit; end;
  // test server activity 
  testServerActivity := true;
  testTime := Now;
  // wait to response
  while testServerActivity and
        ((Now - testTime) <= (TEST_TIME_ACTIVITY * OneSecond)) do
  begin
    Sleep(LOOPTIME); // no procesor
    testTime := Now;
  end;
  Result := serverActivity;
end;

function TEasyOPC.RemoveGroupOPC(OG: OPCGroup): HResult;
begin
  // now cleanup
  Result := ServerIf.RemoveGroup(OG.GroupHandle, False);
  if Succeeded(Result)
  then SetStatusMessage(ID205, OG.GroupName)
  else SetStatusMessage(ID106, OG.GroupName);
end;

function TEasyOPC.RemoveGroupsOPC: HResult;
var idx : integer;
begin
  for idx:=0 to GroupCount-1 do
  begin
    Result := RemoveGroupOPC(OPCGroups[idx]);
    if not Succeeded(Result) then break;
  end;
end;

procedure TEasyOPC.DeactivateOPCGroupReading(OG : OPCGroup);
begin
  // use deactivate method
  SetStatusMessage(ID206, OG.GroupName);
  case OPCmethod of
    M_AdviseSink:       // end the IDataObject advise callback
      GroupUnadvise(OG.GroupIf, AsyncConnection);
    M_OPCDataCallback:  // end the IConnectionPointContainer data callback
      GroupUnadvise2(OG.GroupIf, AsyncConnection);
  end;
end;

procedure TEasyOPC.DeactivateOPCGroupsReading;
var idx : integer;
begin
  for idx:=0 to GroupCount-1 do
    DeactivateOPCGroupReading(OPCGroups[idx]);
end;

function TEasyOPC.isPaused: boolean;
begin
  Result := paused;
end;


procedure TEasyOPC.PauseClient;
begin
  ControlActivity := true;
  paused := true;
end;

procedure TEasyOPC.PlayClient;
begin
  ControlActivity := true;
  paused := false;
end;

function TEasyOPC.getReport: TReport;
begin
  Result := Report;
end;

procedure TEasyOPC.ControlActivityGroups;
var idx : integer;
begin
  if ControlActivity
  then
    for idx:=0 to GroupCount-1 do
      ControlByGroup(idx, not paused);
end;

procedure TEasyOPC.Execute;
var idx : integer;
    ConnIntervalTime : TDateTime;
begin
  Active := True;
  while Active do
  begin
    try
      // try connect to OPC server
      ServerIf := ConnectToOPCServer;

      if ServerIf = nil // check connection
      then raise OPClientException.Create(Report.StatusMessage.report)
      else begin // set activity property
        serverActivity := Succeeded(GetServerStatus);
        testServerActivity := false;
      end;

      // add groups and items
      HR := AddMyGroupsToOPCServer;
      if not Succeeded(HR) // exception's text was created in AddMyGroupsToOPCServer
      then raise OPClientException.Create(Report.StatusMessage.report);

      // activate data reading
      case OPCmethod of
        M_AdviseSink:
          for idx:=0 to GroupCount-1 do
            Run_AdviseSink(OPCGroups[idx]);
        M_OPCDataCallback:
          for idx:=0 to GroupCount-1 do
            Run_OPCDataCallback(OPCGroups[idx]);
      end;

      // LIFE CYCLE
      ConnIntervalTime := Now;
      while Active do
      begin
        Sleep(LOOPTIME);
        Application.ProcessMessages;
        // external check server activity
        if testServerActivity
        then begin // death lock safe
          serverActivity := Succeeded(GetServerStatus);
          testServerActivity := false;
        end;
        // automatic control
        if (Now - ConnIntervalTime) > (CONNTIMEOUT * OneSecond)
        then begin // try OPC connectivity //
          ConnIntervalTime := Now;
          ControlActivityGroups; // possible stop/play groups
          if not Succeeded(GetServerStatus) // status of OPC Server
          then begin
            SetStatusMessage(ID105, ServerProgID);
            raise OPClientException.Create(Report.StatusMessage.report);
          end;
        end;
      end;

    except // OPC_ConnectException
      on E:OPClientException do
      begin
        Sleep(TRYCONNECT);
        SetStatusMessage(ID107, host + '//' + ServerProgID);
      end;
    end;

  end; // while ACTIVE

  // stop reading groups
  DeactivateOPCGroupsReading;

  // remove groups
  HR := RemoveGroupsOPC;

  SetStatusMessage(ID207, '');
end;

procedure TEasyOPC.test1;
begin
  // try connect to OPC server
  ServerIf := ConnectToOPCServer;
end;

function TEasyOPC.test2: boolean;
begin
  //Result := serverIf <> nil;
  Result := Succeeded(ServerIf.GetStatus(ppServerStatus));
end;


end.
