unit UOPCBrowser;

interface

uses
  Classes, SysUtils, ActiveX, IdIcmpClient, UCustomOPC, OPCEnum, OPCDA,
  OPCutils, Windows;

const
  WAITIME = 300;

  // exceptions text
  UnableBrowseBranchExceptionText = 'Unable to browse a branch.';
  UnableIBrowseExceptionText = 'Unable to initialize IBrowse.';
  ConnectivityExceptionText = 'Browser initialization error.';
  HostExceptionText = 'Host not found: ';
  NotFoundServersExceptionText = 'OPC servers not found on ';

type
  // Browser methods
  TBrowser = class(TCustomOPC)
  private
    IdIcmpClient : TIdIcmpClient;
    HR           : HResult;
    Browse       : IOPCBrowseServerAddressSpace;
    SpaceType    : OPCNAMESPACETYPE;
  public
    // connect to server
    procedure connect; override;
    // find opc server on host (OPCEnum)
    function findOPCServers(host : string) : TStringList;
    // get branch by its name (list part of the opc tree browser)
    function getOPCBranch(branch: string) : TStringList;

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
  CoInitialize(nil);
  SetLength(CATIDs, 2);
  CATIDs[0] := CATID_OPCDAServer20;
  CATIDs[1] := CATID_OPCDAServer30; // new version of servers
  OPCServerList := TOPCServerList.create(host, False, CATIDs);
  try
    try
      OPCServerList.Update; // run finding by OPCEnum
      Result.addStrings(OPCServerList.Items);
    except
      on E: Exception do
        raise NotFoundServersException.create(NotFoundServersExceptionText + host);
    end
  finally
    CoUninitialize; // free COM environment
  end;
  if Result.Count = 0
  then raise NotFoundServersException.create(NotFoundServersExceptionText + host);
end;

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



end.
