unit UOPCBrowser;

interface

uses
  Classes, SysUtils, ActiveX, IdIcmpClient, UCustomOPC, OPCEnum, OPCDA,
  OPCutils, Windows, OPCtypes, UOPCExceptions, Variants;

const
  WAITIME = 300;

type
  PTStringList = ^TStringList;

  // Browser methods
  TBrowser = class(TCustomOPC)
  private
    IdIcmpClient : TIdIcmpClient;
    Browse       : IOPCBrowseServerAddressSpace;
    SpaceType    : OPCNAMESPACETYPE;
    // show item value, if download is true
    function ShowValues(Path : string; PVarList: PTStringList;
      download : boolean) : TStringList;
  public
    // connect to server
    procedure connect; override;
    // find opc server on host (OPCEnum)
    function findOPCServers(host : string) : TStringList;
    // get branch by its name (list part of the opc tree browser)
    function getOPCBranch(branch: string) : TStringList;
    // get item of a leaf, if download is true, you get a actual value of item
    function getOPCItems(leaf: string; download : boolean): TStringList;
  end;

implementation

{ TBrowser }

procedure TBrowser.connect;
begin
  inherited connect;
  try
    Sleep(WAITIME); // wait for preparation of server
    // BROWSER INTERFACE
    Browse := ServerIf as IOPCBrowseServerAddressSpace;
    // Ensure hierarchy
    HR := Browse.QueryOrganization(SpaceType);
  except
    on E:Exception do
      raise ConnectivityException.Create(ConnectivityExceptionText);
  end;
end;

//------------------------------------------------------------------------------

function TBrowser.findOPCServers(host : string) : TStringList;
var
  CATIDs        : array of TGUID;
  OPCServerList : TOPCServerList;
begin
  IdIcmpClient := TIdIcmpClient.create;
  IdIcmpClient.host := host;
  Result := TStringList.create;

  // ping server
  try
    try
      IdIcmpClient.ping; // ping host
    except
      on E: Exception do
        raise HostException.Create(HostExceptionText + host);
    end;
  finally
    IdIcmpClient.free;
  end;
  // find opc servers
  SetLength(CATIDs, 2);
  CATIDs[0] := CATID_OPCDAServer20;
  CATIDs[1] := CATID_OPCDAServer30; // new version of servers
  OPCServerList := TOPCServerList.create(host, False, CATIDs);
  try
    OPCServerList.Update; // run finding by OPCEnum
    Result.addStrings(OPCServerList.Items);
  except
    on E: Exception do
      raise NotFoundServersException.create(NotFoundServersExceptionText + host);
  end;
  if Result.Count = 0
  then raise NotFoundServersException.create(NotFoundServersExceptionText + host);
end;

//------------------------------------------------------------------------------

function TBrowser.getOPCBranch(branch: string) : TStringList;
var
  IES     : IEnumString;
  Pattern : POleStr;
  Fetched : UInt;
begin
  Result := nil;

  if Browse <> nil
  then begin
    HR := ChangePosTo(Browse, branch);

    if Succeeded(HR)
    then begin
      if SpaceType = OPC_NS_HIERARCHIAL
      then begin
        HR := Browse.BrowseOPCItemIDs(OPC_BRANCH, StringToOleStr('*'),
                                       VT_EMPTY, OPC_READABLE, IES);
        if Succeeded(HR)
        then begin
          try
            Result := TStringList.Create;
            while Succeeded(IES.Next(1, Pattern, @Fetched)) and (Fetched = 1) do
               Result.Add(Pattern);
            if Result.Count = 0
            then raise UnableBrowseBranchException.create(UnableBrowseBranchExceptionText);
          except
            on E:Exception do
              raise UnableBrowseBranchException.create(UnableBrowseBranchExceptionText);
          end;
        end
        else raise UnableBrowseBranchException.create(UnableBrowseBranchExceptionText);
      end;
    end
    else raise UnableBrowseBranchException.create(UnableBrowseBranchExceptionText);
  end
  else raise UnableIBrowseException.create(UnableIBrowseExceptionText);
end;

//------------------------------------------------------------------------------

function TBrowser.getOPCItems(leaf: string; download : boolean): TStringList;
var
  IES     : IEnumString;
  Pattern : POleStr;
  Fetched : UInt;
  PVarList: PTStringList;
begin
  Result := nil;
  if Browse <> nil then
  begin
    HR := ChangePosTo(Browse, leaf);

    if Succeeded(HR)
    then begin
      // Read opc-items
      New(PVarList);
      PVarList^ := TStringList.Create;
      if SpaceType = OPC_NS_HIERARCHIAL
      then HR := Browse.BrowseOPCItemIDs(OPC_LEAF, StringToOleStr('*'),
                                          VT_EMPTY, OPC_READABLE, IES)
      else HR := Browse.BrowseOPCItemIDs(OPC_FLAT, StringToOleStr('*'),
                                          VT_EMPTY, OPC_READABLE, IES);
      if Succeeded(HR)
      then begin
        while Succeeded(IES.Next(1, Pattern, @Fetched)) and (Fetched = 1) do
          PVarList^.Add(Pattern);
        Result := ShowValues(leaf, PVarList, download);
      end
      else raise UnableBrowseLeafException.create(UnableBrowseLeafExceptionText);
    end
    else raise UnableBrowseLeafException.create(UnableBrowseLeafExceptionText);
  end
  else raise UnableIBrowseException.create(UnableIBrowseExceptionText);
end;

//------------------------------------------------------------------------------

function TBrowser.ShowValues(Path : string; PVarList: PTStringList;
  download : boolean) : TStringList;
var
  ItemName     : POleStr;
  ItemHandle   : OPCHANDLE;
  ItemType     : TVarType;
  ItemValue    : Variant;
  ItemQuality  : Word;
  GroupIf      : IOPCItemMgt;
  GroupHandle  : OPCHANDLE;
  IHandles     : array of OPCHANDLE;
  i,j          : integer;
  val          : string;
  dimension    : integer;
begin
  Result := nil;
  // Define opc-group
  HR := ServerAddGroup(ServerIf, 'GroupTemp', True, 500, 0, 0.0, GroupIf, GroupHandle);
  if not Succeeded(HR)
  then raise UnableAddGroupException.Create('GroupTemp');

  // Find path of opc-items
  Result := TStringList.Create;
  SetLength(IHandles, PTStringList(PVarList)^.Count);

  for i:=0 to PTStringList(PVarList)^.Count-1 do begin
    HR := Browse.GetItemID(StringToOleStr(PTStringList(PVarList)^.Strings[i]), ItemName);
    // estimate path
    if not Succeeded(HR) then ItemName := StringToOleStr(Path + '.' +
                                          PTStringList(PVarList)^.Strings[i]);
    // get opc-item to group, get ItemType and ItemHandle
    HR := GroupAddItem(GroupIf, ItemName, 0, VT_EMPTY, true, '', ItemHandle, ItemType);

    if not Succeeded(HR)
    then begin
      // end downloading leaf
      raise UnableAddItemException.create('GroupTemp -> Item');
    end
    else begin
      IHandles[i] := ItemHandle;
      // prepare output structure: fullItemName, itemType, itemName
      Result.Add(PTStringList(PVarList)^.Strings[i] + '; ' +
                 VarTypeAsText(ItemType) + '; ' +
                 ItemName);
    end;
  end;

  // possible download values from server
  if download and (PTStringList(PVarList)^.Count > 0)
  then begin
    Sleep(WAITIME * 7); // Need long time, empiric constants :-)

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
          then begin
            if not VarIsArray(ItemValue)
            then val := VarToStr(ItemValue)
            else begin
              dimension := VarArrayDimCount(ItemValue);
              val := '[';
              for j:=VarArrayLowBound(ItemValue, dimension)
                  to VarArrayHighBound(ItemValue, dimension) do
              begin
                val := val + VarToStr(ItemValue[j]);
                if (j < VarArrayHighBound(ItemValue, dimension))
                then val := val + ',';
              end;
              val := val + ']';
            end;
          end else val := 'bad quality';
          VarClear(ItemValue);
        end
        else begin
          Result[i] := Result[i] + '; ' + '---';
        end;
        // write value to Result
        Result[i] := Result[i] + '; ' + val;
      end;
    end;
  end; // download values

  // remove group
  HR := ServerIf.RemoveGroup(GroupHandle, False);
end;

end.
