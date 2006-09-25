unit UOPCBrowser2;

interface

uses OPCEnum, SysUtils, Classes, IdIcmpClient, OPCDA, ComObj, UReport,
     ActiveX, OPCutils, Windows, OPCtypes, Forms, UCustomOPC;

const
  WAITIME = 300;

type
  PTStringList = ^TStringList;

  // List of OPC servers
  TOPCList = class
  private
    host         : string;
    ServerList   : TStringList;
    IdIcmpClient : TIdIcmpClient;
    errormsg     : string;
  public
    error        : boolean;
    constructor Create(host : string);
    procedure   FindOPCServers;
    function    GetServerList : TStringList;
  end;
  // exception
  OPCListNotFoundServers = class(Exception);


  TBrowser = class
  private
    host      : string;
    OPCServer : string;
    HR        : HResult;
    ServerIf  : IOPCServer;
    Browse    : IOPCBrowseServerAddressSpace;
    SpaceType : OPCNAMESPACETYPE;
    Report    : TReport;
    procedure setStatusMessage(const idReport : integer; const report: string);
    function ShowValues(Path : string; PVarList: PTStringList;
      download : boolean) : TStringList;
  public
    constructor Create(host : string; opcServerName : string);
    function getHost : string;
    function getOPCServerName : string;
    function getOPCBranch(branch : string) : TStringList;
    function getOPCItems(leaf : string; download : boolean) : TStringList;
    function getReport : TReport;
  end;

implementation

//------------------------------------------------------------------------------

{ TOPCList }

constructor TOPCList.create(host: string);
begin
  IdIcmpClient := TIdIcmpClient.create;
  ServerList := TStringList.create;
  error := true;
  Self.host := getHostName(host);
end;

function TOPCList.getServerList: TStringList;
begin
  if not error
  then Result := ServerList
  else raise OPCListNotFoundServers.Create(errormsg);
end;

procedure TOPCList.findOPCServers;
var
  CATIDs        : array of TGUID;
  OPCServerList : TOPCServerList;
  Status        : string;
begin
  // ping server
  CoInitialize(nil);
  IdIcmpClient.Host := Self.host;
  try
    IdIcmpClient.Ping;
    error := false;
  except
    on E: Exception do
    begin
      errormsg := 'Host ' + host + ' is inaccessible!';
      error := true;
    end;
  end;
  // FIND SERVERS
  if not error
  then begin
    SetLength(CATIDs, 2);
    CATIDs[0] := CATID_OPCDAServer20;
    CATIDs[1] := CATID_OPCDAServer30; // new version of servers
    OPCServerList := TOPCServerList.Create(host, False, CATIDs);
    try
      OPCServerList.Update;
      ServerList.AddStrings(OPCServerList.Items);
    finally
      OPCServerList.Free;
    end;
    Status := 'OPC DA 2.0 servers: '#13#10;
    if ServerList.Count = 0
    then begin
      Status := Status + ' - no server found at ' + host;
      errormsg := Status;
      error := true;
    end;
  end;
end;

//******************************************************************************

{ TBrowser }

constructor TBrowser.Create(host: string; opcServerName : string);
begin
  self.host := host;
  Self.OPCServer := opcServerName;
  Report := TReport.Create;

  // CONNECT OPC
  try
    // we will use the custom OPC interfaces, and OPCProxy.dll will handle
    // marshaling for us automatically (if registered)
    CoInitialize(nil);
    if GetHostName(host) = ''
    then // local server
      ServerIf := CreateComObject(ProgIDToClassID(opcServerName)) as IOPCServer
    else // network server
      ServerIf := CreateRemoteComObject(host, ProgIDToClassID(opcServerName)) as IOPCServer;
  except
    ServerIf := nil;
  end;

  if ServerIf <> nil
  then Sleep(WAITIME) // wait for preparation of server
  else begin
    SetStatusMessage(-1, 'Unable to connect to OPC server!');
    Exit;
  end;

  // BROWSER INTERFACE
  try
    Browse := ServerIf as IOPCBrowseServerAddressSpace;
  except
    Browse := nil;
    SetStatusMessage(-1, 'Cannot create interface IBrowse!');
    Exit;
  end;

  // Ensure hierarchy
  HR := Browse.QueryOrganization(SpaceType);

  // prepare GUI and run TreeView method
  if not Succeeded(HR)
  then SetStatusMessage(-1, 'Cannot get OPC hierarchy!');
end;

function TBrowser.getReport: TReport;
begin
  Result := Report;
end;

function TBrowser.getOPCBranch(branch: string) : TStringList;
var
  IES     : IEnumString;
  Pattern : POleStr;
  Fetched : UInt;
  Res     : HRESULT;
begin
  Result := nil;

  if Browse <> nil
  then begin
    Res := ChangePosTo(Browse, branch);

    if Succeeded(Res)
    then begin
      if SpaceType = OPC_NS_HIERARCHIAL
      then begin
        Res := Browse.BrowseOPCItemIDs(OPC_BRANCH, StringToOleStr('*'),
                                       VT_EMPTY, OPC_READABLE, IES);
        if Succeeded(Res)
        then begin
          Result := TStringList.Create;
          while Succeeded(IES.Next(1, Pattern, @Fetched)) and (Fetched = 1) do
             Result.Add(Pattern);
        end
        else
          if branch <> ''
          then SetStatusMessage(-1, 'Unable to browse branches of ' + branch)
          else SetStatusMessage(-1, 'Unable to browse branches of root');
      end;
    end;
  end
  else SetStatusMessage(-1, 'Unable to activate interface for IBrowse.');
end;

function TBrowser.getOPCItems(leaf: string; download : boolean): TStringList;
var
  IES     : IEnumString;
  Pattern : POleStr;
  Fetched : UInt;
  Res     : HRESULT;
  PVarList: PTStringList;
begin
  Result := nil;
  if Browse <> nil then
  begin
    Res := ChangePosTo(Browse, leaf);

    if Succeeded(Res)
    then begin
      // Read opc-items
      New(PVarList);
      PVarList^ := TStringList.Create;
      if SpaceType = OPC_NS_HIERARCHIAL
      then Res := Browse.BrowseOPCItemIDs(OPC_LEAF, StringToOleStr('*'),
                                          VT_EMPTY, OPC_READABLE, IES)
      else Res := Browse.BrowseOPCItemIDs(OPC_FLAT, StringToOleStr('*'),
                                          VT_EMPTY, OPC_READABLE, IES);
      if Succeeded(Res)
      then begin
        while Succeeded(IES.Next(1, Pattern, @Fetched)) and (Fetched = 1) do
          PVarList^.Add(Pattern);
        Result := ShowValues(leaf, PVarList, download);
      end
      else SetStatusMessage(-1, 'Unable to browse leafs of ' + leaf);
    end
    else SetStatusMessage(-1, 'Cannot set position in OPC-server!');
  end
  else SetStatusMessage(-1, 'Browse interface not available!');
end;


function TBrowser.ShowValues(Path : string; PVarList: PTStringList;
  download : boolean) : TStringList;
var
  ItemName    : POleStr;
  ItemHandle  : OPCHANDLE;
  ItemType    : TVarType;
  ItemValue   : string;
  ItemQuality : Word;
  HR          : HResult;
  GroupIf     : IOPCItemMgt;
  GroupHandle : OPCHANDLE;
  IHandles    : array of OPCHANDLE;
  i           : integer;
  val         : string;
begin
  Result := nil;
  // Define opc-group
  HR := ServerAddGroup(ServerIf, 'GroupTemp', True, 500, 0, GroupIf, GroupHandle);
  if not Succeeded(HR)
  then begin
    SetStatusMessage(-1, 'Unable to add group to server: GroupTemp');
    Exit;
  end;

  // Find path of opc-items
  Result := TStringList.Create;
  SetLength(IHandles, PTStringList(PVarList)^.Count);
  for i:=0 to PTStringList(PVarList)^.Count-1 do begin
    HR := Browse.GetItemID(StringToOleStr(PTStringList(PVarList)^.Strings[i]), ItemName);
    // estimate path
    if not Succeeded(HR) then ItemName := StringToOleStr(Path + '.' +
                                          PTStringList(PVarList)^.Strings[i]);
    // get opc-item to group, get ItemType and ItemHandle
    HR := GroupAddItem(GroupIf, ItemName, 0, VT_EMPTY, ItemHandle, ItemType);

    if not Succeeded(HR)
    then begin
      IHandles[i] := 0;
      SetStatusMessage(-1, 'Unable to add item to temp-group.');
    end
    else begin
      IHandles[i] := ItemHandle;
      Result.Add(PTStringList(PVarList)^.Strings[i] + '; ' +
                 DataType(ItemType) + '; ' +
                 ItemName);
    end;
  end;

  // possible download values from server
  if download and (PTStringList(PVarList)^.Count > 0)
  then begin
    Sleep(WAITIME * 7); // Need long time

    for i:=0 to PTStringList(PVarList)^.Count-1 do
    begin
      val := '';
      ItemHandle := IHandles[i];
      if ItemHandle <> 0
      then begin
        // read value of item
        try
          HR := ReadOPCGroupItemValue(GroupIf, ItemHandle, ItemValue, ItemQuality);
        except
        end;
        if Succeeded(HR)
        then begin
          if (ItemQuality and OPC_QUALITY_MASK) = OPC_QUALITY_GOOD
          then val := ItemValue
          else val := 'bad quality';
        end
        else begin
          Result[i] := Result[i] + '; ' + '---';
          SetStatusMessage(-1, 'Failed to read item.');
        end;
        // write value to Result
        Result[i] := Result[i] + '; ' + (val);
      end;
    end;
  end; // download values

  // remove group
  HR := ServerIf.RemoveGroup(GroupHandle, False);
  if not Succeeded(HR)
  then SetStatusMessage(-1, 'Unable to remove group.');
end;

function TBrowser.getHost: string;
begin
  Result := host;
end;

function TBrowser.getOPCServerName: string;
begin
  Result := OPCServer;
end;

procedure TBrowser.setStatusMessage(const idReport : integer; const report: string);
begin
  self.Report.setStatusMessage(idReport, report);
end;

end.
