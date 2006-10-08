unit UOPCExceptions;

interface

uses SysUtils;

type // NATIVE CODE EXCEPTIONS
  // Global exceptions
  ConnectivityException = class(Exception);       // error connection
  HostException = class(Exception);               // no host found
  NotFoundServersException = class(Exception);    // no opc servers found
  UnableIBrowseException = class(Exception);      // IBrowse not initialize
  UnableBrowseBranchException = class(Exception); // browse branch error
  UnableBrowseLeafException = class(Exception);   // browse leaf (item) error
  UnableAddGroupException = class(Exception);     // add group error
  UnableAddItemException = class(Exception);      // add item to group error
  UnableRemoveGroupException = class(Exception);  // remove group error
  UnableRemoveItemException = class(Exception);   // remove item error
  ComponentNotFoundException = class(Exception);  // group/item not found
  SynchReadException = class(Exception);          // synch read error
  SynchWriteException = class(Exception);         // synch write error

const // NATIVE CODE EXCEPTIONS TEXT
  // exceptions text
  UnableBrowseBranchExceptionText = 'Unable to browse a branch.';
  UnableBrowseLeafExceptionText = 'Unable to browse a leaf (item).';
  UnableIBrowseExceptionText = 'Unable to initialize IBrowse.';
  ConnectivityExceptionText = 'Connection fails to OPC Server.';
  HostExceptionText = 'Host not found: ';
  NotFoundServersExceptionText = 'OPC servers not found on ';
  UnableAddGroupExceptionText = 'Unable to add group to server:';
  ComponentNotFoundExceptionText = 'Component doesn''t found exception.';
  SynchReadExceptionText = 'Synchronous reading error.';
  SynchWriteExceptionText = 'Synchronous writing error.';

const // JAVA CODE EXCEPTIONS
  EXCPKG = 'javafish/clients/opc/exception/'; // standard exception package

  // java exceptions definition
  SConnectivityException = EXCPKG + 'ConnectivityException';
  SHostException = EXCPKG + 'HostException';
  SNotFoundServersException = EXCPKG + 'NotFoundServersException';
  SUnableIBrowseException = EXCPKG + 'UnableIBrowseException';
  SUnableBrowseBranchException = EXCPKG + 'UnableBrowseBranchException';
  SUnableBrowseLeafException = EXCPKG + 'UnableBrowseLeafException';
  SUnableAddGroupException = EXCPKG + 'UnableAddGroupException';
  SUnableAddItemException = EXCPKG + 'UnableAddItemException';
  SUnableRemoveGroupException = EXCPKG + 'UnableRemoveGroupException';
  SUnableRemoveItemException = EXCPKG + 'UnableRemoveItemException';
  SComponentNotFoundException = EXCPKG + 'ComponentNotFoundException';
  SSynchReadException = EXCPKG + 'SynchReadException';
  SSynchWriteException = EXCPKG + 'SynchWriteException';

implementation

end.
