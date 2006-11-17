unit OPCutils;

{$IFDEF VER150}
{$WARN UNSAFE_CODE OFF}
{$WARN UNSAFE_TYPE OFF}
{$ENDIF}
{$IFDEF VER170}
{$WARN UNSAFE_CODE OFF}
{$ENDIF}

interface

uses
{$IFDEF VER140}
  Variants,
{$ENDIF}
{$IFDEF VER150}
  Variants,
{$ENDIF}
{$IFDEF VER170}
  Variants,
{$ENDIF}
  Classes, Windows, ActiveX, OPCtypes, OPCDA, SysUtils, Dialogs, UOPCGroup,
  UOPCItem;

// Wrappers

// register group on opc-server
function ServerAddGroup(ServerIf: IOPCServer; Name: string; Active: BOOL;
           UpdateRate: DWORD; ClientHandle: OPCHANDLE; PercentDeadBand: Single;
           var GroupIf: IOPCItemMgt; var ServerHandle: OPCHANDLE): HResult;

// register group item on opc-server
function GroupAddItem(GroupIf: IOPCItemMgt; ItemID: string;
           ClientHandle: OPCHANDLE; DataType: TVarType;
           active : boolean; accessPath : string;
           var ServerHandle: OPCHANDLE; var CanonicalType: TVarType): HResult;

// unregister item on opc-server
function GroupRemoveItem(GroupIf: IOPCItemMgt; ServerHandle: OPCHANDLE): HResult;

// synch read item value
function ReadOPCGroupItemValue(GroupIf: IUnknown; ItemServerHandle: OPCHANDLE;
           var ItemValue: Variant; var ItemQuality: Word): HResult;

// synch write item value
function WriteOPCGroupItemValue(GroupIf: IUnknown; ItemServerHandle: OPCHANDLE;
          ItemValue: OleVariant): HResult;

// synch read of group: IOPCSyncIO.Read
function ReadOPCGroupValues(OPCGroup : TOPCGroup): HResult;

// asynch 1.0 (AdviseSink) reading
function GroupAdviseTime(GroupIf: IUnknown; Sink: IAdviseSink;
          var AsyncConnection: Longint): HResult;

// asynch 2.0 (Callbask) reading
function GroupAdvise2(GroupIf: IUnknown; OPCDataCallback: IOPCDataCallback;
          var AsyncConnection: Longint): HResult;

// asynch 1.0 unadvise reading
function GroupUnAdvise(GroupIf: IUnknown; AsyncConnection: Longint): HResult;

// asynch 2.0 unadvise reading
function GroupUnadvise2(GroupIf: IUnknown; var AsyncConnection: Longint): HResult;

// change activity of group
function SetGroupActivity(GroupIf: IUnknown; Active: bool): HRESULT;

// change update time of group
function SetGroupUpdateTime(GroupIf: IUnknown; UpdateTime : DWORD): HRESULT;

// change activity of item
function SetItemActivity(GroupIf: IUnknown; ItemHandle: OPCHANDLE; Active : boolean): HRESULT;

// change position in tree of OPC Browser
function ChangePosTo(Browse: IOPCBrowseServerAddressSpace; Path: string): HRESULT;

//=============================================================================

// added functions
function GetGroupActive(GroupIf: IUnknown; var Active: boolean): HRESULT;
function GetGroupInfo(GroupIf: IUnknown; var GInfo : string): HRESULT;
function DataType(Dtype: TVarType): string;

implementation

// utility functions wrapping OPC methods

// wrapper for IOPCServer.AddGroup
function ServerAddGroup(ServerIf: IOPCServer; Name: string; Active: BOOL;
          UpdateRate: DWORD; ClientHandle: OPCHANDLE; PercentDeadBand: Single;
          var GroupIf: IOPCItemMgt; var ServerHandle: OPCHANDLE): HResult;
var
  RevisedUpdateRate: DWORD;
begin
  Result := E_FAIL;
  if ServerIf <> nil then
  begin
    Result := ServerIf.AddGroup(PWideChar(WideString(Name)), Active, UpdateRate,
                            ClientHandle, nil, @PercentDeadBand, 0,
                            ServerHandle, RevisedUpdateRate, IOPCItemMgt,
                            IUnknown(GroupIf));
  end;
  if Failed(Result) then GroupIf := nil;
end;

// wrapper for IOPCItemMgt.AddItems (single item only)
function GroupAddItem(GroupIf: IOPCItemMgt; ItemID: string;
          ClientHandle: OPCHANDLE; DataType: TVarType;
          active : boolean; accessPath : string;
          var ServerHandle: OPCHANDLE; var CanonicalType: TVarType): HResult;
var
  ItemDef: OPCITEMDEF;
  Results: POPCITEMRESULTARRAY;
  Errors: PResultList;
begin
  if GroupIf = nil then
  begin
    Result := E_FAIL;
    Exit;
  end;
  with ItemDef do
  begin
    szAccessPath := PWideChar(WideString(accessPath));
    szItemID := PWideChar(WideString(ItemID));
    bActive := active;
    hClient := ClientHandle;
    dwBlobSize := 0;
    pBlob := nil;
    vtRequestedDataType := DataType;
  end;
  Result := GroupIf.AddItems(1, @ItemDef, Results, Errors);
  if Succeeded(Result) then
  begin
    Result := Errors[0];
    try
      if Succeeded(Result) then
      begin
        ServerHandle := Results[0].hServer;
        CanonicalType := Results[0].vtCanonicalDataType;
      end;
    finally
      CoTaskMemFree(Results[0].pBlob);
      CoTaskMemFree(Results);
      CoTaskMemFree(Errors);
    end;
  end;
end;

// wrapper for IOPCItemMgt.RemoveItems (single item only)
function GroupRemoveItem(GroupIf: IOPCItemMgt;
          ServerHandle: OPCHANDLE): HResult;
var
  Errors: PResultList;
begin
  if GroupIf = nil then
  begin
    Result := E_FAIL;
    Exit;
  end;
  Result := GroupIf.RemoveItems(1, @ServerHandle, Errors);
  if Succeeded(Result) then
  begin
    Result := Errors[0];
    CoTaskMemFree(Errors);
  end;
end;

// wrapper for IDataObject.DAdvise on an OPC group object
function GroupAdviseTime(GroupIf: IUnknown; Sink: IAdviseSink;
          var AsyncConnection: Longint): HResult;
var
  DataIf: IDataObject;
  Fmt: TFormatEtc;
begin
  Result := E_FAIL;
  try
    DataIf := GroupIf as IDataObject;
  except
    DataIf := nil;
  end;
  if DataIf <> nil then
  begin
    with Fmt do
    begin
      cfFormat := OPCSTMFORMATDATATIME;
      dwAspect := DVASPECT_CONTENT;
      ptd := nil;
      tymed := TYMED_HGLOBAL;
      lindex := -1;
    end;
    AsyncConnection := 0;
    Result := DataIf.DAdvise(Fmt, ADVF_PRIMEFIRST, Sink, AsyncConnection);
    if Failed(Result) then
    begin
      AsyncConnection := 0;
    end;
  end;
end;

// wrapper for IDataObject.DUnadvise on an OPC group object
function GroupUnAdvise(GroupIf: IUnknown; AsyncConnection: Longint): HResult;
var
  DataIf: IDataObject;
begin
  Result := E_FAIL;
  try
    DataIf := GroupIf as IDataObject;
  except
    DataIf := nil;
  end;
  if DataIf <> nil then
  begin
    Result := DataIf.DUnadvise(AsyncConnection);
  end;
end;

// wrapper for setting up an IOPCDataCallback connection
function GroupAdvise2(GroupIf: IUnknown; OPCDataCallback: IOPCDataCallback;
          var AsyncConnection: Longint): HResult;
var
  ConnectionPointContainer: IConnectionPointContainer;
  ConnectionPoint: IConnectionPoint;
begin
  Result := E_FAIL;
  try
    ConnectionPointContainer := GroupIf as IConnectionPointContainer;
  except
    ConnectionPointContainer := nil;
  end;
  if ConnectionPointContainer <> nil then
  begin
    Result := ConnectionPointContainer.FindConnectionPoint(IID_IOPCDataCallback,
      ConnectionPoint);
    if Succeeded(Result) and (ConnectionPoint <> nil) then
    begin
      Result := ConnectionPoint.Advise(OPCDataCallback as IUnknown,
        AsyncConnection);
    end;
  end;
end;

// wrapper for cancelling up an IOPCDataCallback connection
function GroupUnadvise2(GroupIf: IUnknown;
          var AsyncConnection: Longint): HResult;
var
  ConnectionPointContainer: IConnectionPointContainer;
  ConnectionPoint: IConnectionPoint;
begin
  Result := E_FAIL;
  try
    ConnectionPointContainer := GroupIf as IConnectionPointContainer;
  except
    ConnectionPointContainer := nil;
  end;
  if ConnectionPointContainer <> nil then
  begin
    Result := ConnectionPointContainer.FindConnectionPoint(IID_IOPCDataCallback,
      ConnectionPoint);
    if Succeeded(Result) and (ConnectionPoint <> nil) then
    begin
      Result := ConnectionPoint.Unadvise(AsyncConnection);
    end;
  end;
end;

// wrapper for IOPCSyncIO.Read (single item only)
function ReadOPCGroupItemValue(GroupIf: IUnknown; ItemServerHandle: OPCHANDLE;
          var ItemValue: Variant; var ItemQuality: Word): HResult;
var
  SyncIOIf: IOPCSyncIO;
  Errors: PResultList;
  ItemValues: POPCITEMSTATEARRAY;
begin
  Result := E_FAIL;
  try
    SyncIOIf := GroupIf as IOPCSyncIO;
  except
    SyncIOIf := nil;
  end;
  if SyncIOIf <> nil then
  begin
    Result := SyncIOIf.Read(OPC_DS_CACHE, 1, @ItemServerHandle, ItemValues, Errors);

    if Succeeded(Result) then
    begin
      try
        Result := Errors[0];
        CoTaskMemFree(Errors);
        try
          ItemValue := ItemValues[0].vDataValue;
        except
          ItemValue := VT_ERROR;
        end;
        ItemQuality := ItemValues[0].wQuality;
        VariantClear(ItemValues[0].vDataValue);
        CoTaskMemFree(ItemValues);
      except
      end;
    end;
  end;
end;

// wrapper for IOPCSyncIO.Write (single item only)
function WriteOPCGroupItemValue(GroupIf: IUnknown; ItemServerHandle: OPCHANDLE;
          ItemValue: OleVariant): HResult;
var
  SyncIOIf: IOPCSyncIO;
  Errors: PResultList;
begin
  Result := E_FAIL;
  try
    SyncIOIf := GroupIf as IOPCSyncIO;
  except
    SyncIOIf := nil;
  end;
  if SyncIOIf <> nil then
  begin
    Result := SyncIOIf.Write(1, @ItemServerHandle, @ItemValue, Errors);
    if Succeeded(Result) then
    begin
      Result := Errors[0];
      CoTaskMemFree(Errors);
    end;
  end;
end;

// wrapper for IOPCSyncIO.Read (group)
function ReadOPCGroupValues(OPCGroup : TOPCGroup): HResult;
var
  SyncIOIf   : IOPCSyncIO;
  Errors     : PResultList;
  ItemValues : POPCITEMSTATEARRAY;
  i          : integer;
  items      : TList;
  ItemServerHandles : POPCHANDLEARRAY;
begin
  Result := E_FAIL;
  try
    SyncIOIf := OPCGroup.GroupIf as IOPCSyncIO;
  except
    SyncIOIf := nil;
  end;
  if SyncIOIf <> nil then
  begin
    // prepare server handles of items
    New(ItemServerHandles);
    items := OPCGroup.getItems;
    for i:=0 to items.count-1 do
      ItemServerHandles[i] := TOPCItem(items[i]).ItemHandle;

    Result := SyncIOIf.Read(OPC_DS_CACHE, items.count, ItemServerHandles,
      ItemValues, Errors);

    // free memory
    Dispose(ItemServerHandles);

    if Succeeded(Result) then
    begin
      for i:=0 to items.count-1 do
      begin
        if Succeeded(Errors[i])
        then begin
          TOPCItem(items[i]).setItemValue(ItemValues[i].vDataValue);
          TOPCItem(items[i]).setItemQuality(ItemValues[i].wQuality);
          TOPCItem(items[i]).setTimeStamp(Now); // set actual timeStamp (System time)
        end // Error in communication (different from bad quality of item)
        else Result := Errors[i];
        // clear variant type
        VariantClear(ItemValues[i].vDataValue);
      end;

      // clear memory
      CoTaskMemFree(Errors);
      CoTaskMemFree(ItemValues);
    end;
  end;
end;

//=============================================================================

function GetGroupActive(GroupIf: IUnknown; var Active: boolean): HRESULT;
var
  pUpdateRate:                DWORD;
  pActive:                    BOOL;
  ppName:                     POleStr;
  pTimeBias:                  Longint;
  pPercentDeadband:           Single;
  pLCID:                      TLCID;
  phClientGroup:              OPCHANDLE;
  phServerGroup:              OPCHANDLE;
  OPCGroupStateMgt:           IOPCGroupStateMgt;
begin
  OPCGroupStateMgt := GroupIf as IOPCGroupStateMgt;
  Result := OPCGroupStateMgt.GetState(pUpdateRate, pActive, ppName, pTimeBias, pPercentDeadband, pLCID, phClientGroup, phServerGroup);
  Active := pActive;
end;

function SetGroupActivity(GroupIf: IUnknown; Active: bool): HRESULT;
var
  pUpdateRate:                DWORD;
  ppName:                     POleStr;
  phServerGroup:              OPCHANDLE;
  gpActive:                   BOOL;
  gpTimeBias:                 Longint;
  gpPercentDeadband:          Single;
  gpLCID:                     TLCID;
  gphClientGroup:             OPCHANDLE;
  pRevisedUpdateRate:         DWORD;
  OPCGroupStateMgt:           IOPCGroupStateMgt;
begin
  OPCGroupStateMgt := GroupIf as IOPCGroupStateMgt;
  // read group
  Result := OPCGroupStateMgt.GetState(pUpdateRate, gpActive, ppName, gpTimeBias,
    gpPercentDeadband, gpLCID, gphClientGroup, phServerGroup);
  // set group
  Result := OPCGroupStateMgt.SetState(@pUpdateRate, pRevisedUpdateRate,
    @Active, @gpTimeBias, @gpPercentDeadband, @gpLCID, @gphClientGroup);
end;

function SetGroupUpdateTime(GroupIf: IUnknown; UpdateTime : DWORD): HRESULT;
var
  pUpdateRate:                DWORD;
  ppName:                     POleStr;
  phServerGroup:              OPCHANDLE;
  gpActive:                   BOOL;
  gpTimeBias:                 Longint;
  gpPercentDeadband:          Single;
  gpLCID:                     TLCID;
  gphClientGroup:             OPCHANDLE;
  pRequestedUpdateRate:       PDWORD;
  pRevisedUpdateRate:         DWORD;
  OPCGroupStateMgt:           IOPCGroupStateMgt;
begin
  OPCGroupStateMgt := GroupIf as IOPCGroupStateMgt;
  // read group
  Result := OPCGroupStateMgt.GetState(pUpdateRate, gpActive, ppName, gpTimeBias,
    gpPercentDeadband, gpLCID, gphClientGroup, phServerGroup);
  // set group
  pRequestedUpdateRate := @UpdateTime;
  Result := OPCGroupStateMgt.SetState(pRequestedUpdateRate, pRevisedUpdateRate,
    @gpActive, @gpTimeBias, @gpPercentDeadband, @gpLCID, @gphClientGroup);
end;

function GetGroupInfo(GroupIf: IUnknown; var GInfo : string): HRESULT;
var
  pUpdateRate:                DWORD;
  pActive:                    BOOL;
  ppName:                     POleStr;
  pTimeBias:                  Longint;
  pPercentDeadband:           Single;
  pLCID:                      TLCID;
  phClientGroup:              OPCHANDLE;
  phServerGroup:              OPCHANDLE;
  OPCGroupStateMgt:           IOPCGroupStateMgt;
  ActiveStr:                  string;
begin
  OPCGroupStateMgt := GroupIf as IOPCGroupStateMgt;
  Result := OPCGroupStateMgt.GetState(pUpdateRate, pActive, ppName, pTimeBias, pPercentDeadband, pLCID, phClientGroup, phServerGroup);
  if Succeeded(Result)
  then begin
    if pActive then ActiveStr := 'True' else ActiveStr := 'False';
    GInfo := 'Name of Group: ' + ppName + #13#10 +
             'Activity: ' + ActiveStr   + #13#10 +
             'ClientGroup: ' + IntToStr(phClientGroup) + #13#10 +
             'Update Rate: ' + IntToStr(pUpdateRate);
  end;
end;

function SetItemActivity(GroupIf: IUnknown; ItemHandle: OPCHANDLE; Active : boolean): HRESULT;
var
  ppErrors:    PResultList;
  OPCItemMgt:  IOPCItemMgt;
begin
  OPCItemMgt := GroupIf as IOPCItemMgt;
  OPCItemMgt.SetActiveState(1, @ItemHandle, Active, ppErrors);
  Result := ppErrors[0];
end;

function ChangePosTo(Browse: IOPCBrowseServerAddressSpace; Path: string): HRESULT;
var
  Res, Resx, HR: HRESULT;
  SpaceType: OPCNAMESPACETYPE;
begin
  Resx := S_OK;
  if Browse <> nil then begin
    HR := Browse.QueryOrganization(SpaceType);
    if Failed(HR) then begin
      Resx := E_FAIL;
      Exit;
    end;

    Res := 0;
    while Res = 0 do begin
      Res := Browse.ChangeBrowsePosition(OPC_BROWSE_UP, '');
    end;
    if SpaceType = OPC_NS_HIERARCHIAL then begin
      while Pos('.', Path) > 0 do begin
        Res := Browse.ChangeBrowsePosition(OPC_BROWSE_DOWN, StringToOleStr(Copy(Path, 1, Pos('.', Path)-1)));
        if Res <> 0 then Resx := E_FAIL;
        Delete(Path, 1, Pos('.', Path));
      end;
      if length(Path) > 0 then begin
        Res := Browse.ChangeBrowsePosition(OPC_BROWSE_DOWN, StringToOleStr(Path));
        if Res <> 0 then Resx := E_FAIL;
      end;
    end;
  end
  else
    Resx := E_FAIL;

  Result := Resx;
end;


function DataType(Dtype: TVarType): string;
begin
  case Dtype of
   varEmpty    : Result := 'Empty';
   varNull     : Result := 'Null';   varSmallint : Result := 'Smallint';   varInteger  : Result := 'Integer';   varSingle   : Result := 'Single';   varDouble   : Result := 'Double';   varCurrency : Result := 'Currency';   varDate     : Result := 'Date';   varOleStr   : Result := 'OleStr';   varDispatch : Result := 'Dispatch';   varError    : Result := 'Error';   varBoolean  : Result := 'Boolean';   varVariant  : Result := 'Variant';   varUnknown  : Result := 'Unknown';   varShortInt : Result := 'Shortint';   varByte     : Result := 'Byte';   varWord     : Result := 'Word';   varLongWord : Result := 'Longword';   varInt64    : Result := 'Int64';   varStrArg   : Result := 'StrArg';   varString   : Result := 'String';   varAny      : Result := 'Any';   varTypeMask : Result := 'TypeMask';   varArray    : Result := 'Array';   varByRef    : Result := 'ByRef';
   else          Result := '???';
  end;
end;


end.
