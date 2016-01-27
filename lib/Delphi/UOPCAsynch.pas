unit UOPCAsynch;

interface

uses
  Classes, Windows, SysUtils, ActiveX, Variants, OPCDA, OPCTypes, UOPCGroup, UOPCItem,
  JNI;

type

  // define events
  EVENT_OPCItem  = procedure (cHandle_Group, cHandle_Item : OPCHANDLE; Quality : Word;
    IType : Word; DTime : TDateTime; Value : Variant) of object;
  EVENT_OPCGroup = procedure (cHandle_Group : OPCHANDLE) of object;
  EVENT_DownOPCGroup = procedure (cHandle_Group : OPCHANDLE; DownOPCGroup : TOPCGroup) of object;

//------------------------------------------------------------------------------

  // Asynch 2.0
  // class to receive IConnectionPointContainer data change callbacks
  TOPCDataCallback = class(TInterfacedObject, IOPCDataCallback)
  public
    // EVENTS
    OnDownloadedItem  : EVENT_OPCItem;
    OnDownloadedGroup : EVENT_OPCGroup;
    // Interface implementation
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

//------------------------------------------------------------------------------

  // Asynch 1.0 (older version)
  // class to receive IDataObject data change advises
  TOPCAdviseSink = class(TInterfacedObject, IAdviseSink)
  public
    OnDownloadedItem  : EVENT_OPCItem;
    OnDownloadedGroup : EVENT_OPCGroup;
    procedure OnDataChange(const formatetc: TFormatEtc;
                           const stgmed: TStgMedium); stdcall;
    procedure OnViewChange(dwAspect: Longint; lindex: Longint); stdcall;
    procedure OnRename(const mk: IMoniker); stdcall;
    procedure OnSave; stdcall;
    procedure OnClose; stdcall;
  end;

//------------------------------------------------------------------------------

  TAsynchConsumer = class
  private
    counter : integer;
  public
    PEnv: PJNIEnv;
    Obj: JObject;
    procedure downloadGroup(cHandle_Group : OPCHANDLE; DownOPCGroup : TOPCGroup);
    procedure storeGroupToFile(group : TOPCGroup; fn: string);
  end;

//------------------------------------------------------------------------------

implementation

{ TOPCDataCallback }

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

function TOPCDataCallback.OnReadComplete(dwTransid: DWORD; hGroup: OPCHANDLE;
  hrMasterquality, hrMastererror: HResult; dwCount: DWORD;
  phClientItems: POPCHANDLEARRAY; pvValues: POleVariantArray;
  pwQualities: PWordArray; pftTimeStamps: PFileTimeArray;
  pErrors: PResultList): HResult;
begin
  Result := OnDataChange(dwTransid, hGroup, hrMasterquality, hrMastererror,
    dwCount, phClientItems, pvValues, pwQualities, pftTimeStamps, pErrors);
end;

function TOPCDataCallback.OnDataChange(dwTransid: DWORD; hGroup: OPCHANDLE;
  hrMasterquality, hrMastererror: HResult; dwCount: DWORD;
  phClientItems: POPCHANDLEARRAY; pvValues: POleVariantArray;
  pwQualities: PWordArray; pftTimeStamps: PFileTimeArray;
  pErrors: PResultList): HResult;
var
  ClientItems : POPCHANDLEARRAY;
  Values      : POleVariantArray;
  Qualities   : PWORDARRAY;
  i           : Integer;
  NewValue    : Variant;
  STime       : TSystemTime;
  DT          : TDateTime;
  ATimes      : PFileTimeArray;
  Time        : TFileTime;
begin
  // allocate variables
  Result      := S_OK;
  ClientItems := POPCHANDLEARRAY(phClientItems);
  Values      := POleVariantArray(pvValues);
  Qualities   := PWORDARRAY(pwQualities);
  ATimes      := PFileTimeArray(pftTimeStamps);

  // cycle items of group
  for i:=0 to dwCount-1 do
  begin
    if Qualities[i] = OPC_QUALITY_GOOD then
    begin
      // get Variant type
      NewValue := Values[i];

      // convert timestamp to localtime
      Time := ATimes[I];
      FileTimeToLocalFileTime(Time,Time);
      FileTimeToSystemTime(Time,STime);
      DT := SystemTimeToDateTime(STime);
    end;
    // call event for item
    OnDownloadedItem(
     hGroup,
     ClientItems[i],
     Qualities[i],
     0,
     DT,
     NewValue
    );
  end;
  // call event for group = group is ready
  OnDownloadedGroup(hGroup);
end;

//------------------------------------------------------------------------------

{ TOPCAdviseSink }

procedure TOPCAdviseSink.OnRename(const mk: IMoniker);
begin
  // not implemented
end;

procedure TOPCAdviseSink.OnSave;
begin
  // not implemented
end;

procedure TOPCAdviseSink.OnClose;
begin
  // not implemented
end;

procedure TOPCAdviseSink.OnViewChange(dwAspect, lindex: Integer);
begin
  // not implemented
end;


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
  NewValue     : Variant;
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
      for I:=0 to PG.dwItemCount-1 do
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
          NewValue := PV^;
          // this test assumes we're not dealing with array data
          {
          if TVarData(PV^).VType <> VT_BSTR then
          begin
            NewValue := VarToStr(PV^); // convert to string
          end
          else begin
            // for BSTR data, the BSTR image follows immediately in the data
            // stream after the variant union;  the BSTR begins with a DWORD
            // character count, which we skip over as the BSTR is also
            // NULL-terminated
            PStr := PWideChar(PChar(PV) + SizeOf(OleVariant) + 4);
            NewValue := WideString(PStr);
          end;
          }
          if not WithTime then DT := Now;
        end;
        // call event of item
        OnDownloadedItem(
         ClientGroup,
         ClientHandle,
         Quality,
         TVarData(PV^).VType,
         DT,
         NewValue
        );
      end;
      // call event of group = group is ready
      OnDownloadedGroup(ClientGroup);
    end;
    GlobalUnlock(stgmed.hGlobal);
  end;
end;

//------------------------------------------------------------------------------

{ TAsynchConsumer }

procedure TAsynchConsumer.downloadGroup(cHandle_Group: OPCHANDLE;
  downOPCGroup: TOPCGroup);
var
  JVM         : TJNIEnv;
  FID         : JFieldID;
  opcClass    : JClass;
  arrayListClass : JClass;
  gch         : integer;
  groupNative : TOPCGroup;
  arrayList   : JObject;
  groupName   : string;
  add         : JMethodID;
  args        : array[0..0] of JValue;

  getGroupsAsArray : JMethodID;
  agroups      : JArray;
  group        : JObject;
  groupClass   : JClass;
  groupsCount  : integer;
  i : integer;
  groupCHandle : integer;
  clone : JObject;
begin
  JVM := TJNIEnv.Create(PEnv);

  // get classes
  opcClass := JVM.GetObjectClass(Obj);

  // get group from groups map by its clientHandle
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

    if (groupCHandle = downOPCGroup.getClientHandle)
    then break;
  end;

  // attribute: groupName
  FID := JVM.GetFieldID(opcClass, 'stack', 'Ljava/util/ArrayList;');
  arrayList := JVM.GetObjectField(Obj, FID);
  arrayListClass := JVM.GetObjectClass(arrayList);

  add := JVM.GetMethodID(arrayListClass, 'add', '(Ljava/lang/Object;)Z');

  // create new clone
  clone := DownOPCGroup.clone(PEnv, group);
  DownOPCGroup.commit(PEnv, clone);

  args[0].l := clone;

  // call method
  JVM.CallObjectMethodA(arrayList, add, @args);

  JVM.Free;
end;

procedure TAsynchConsumer.storeGroupToFile(group : TOPCGroup; fn: string);
var foo : TStringList;
    i,j   : integer;
    item  : TOPCItem;
    items : TList;
begin
  foo := TStringList.Create;
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
  // store to file
  foo.SaveToFile(fn);
  foo.Free;
end;


end.
