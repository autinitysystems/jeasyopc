unit UOPCExceptions;

interface

uses SysUtils;

type // NATIVE CODE EXCEPTIONS
  // Global exceptions
  ConnectivityException       = class(Exception); // error connection
  HostException               = class(Exception); // no host found
  NotFoundServersException    = class(Exception); // no opc servers found
  UnableIBrowseException      = class(Exception); // IBrowse not initialize
  UnableBrowseBranchException = class(Exception); // browse branch error
  UnableBrowseLeafException   = class(Exception); // browse leaf (item) error
  UnableAddGroupException     = class(Exception); // add group error
  UnableAddItemException      = class(Exception); // add item to group error
  UnableRemoveGroupException  = class(Exception); // remove group error
  UnableRemoveItemException   = class(Exception); // remove item error
  ComponentNotFoundException  = class(Exception); // group/item not found
  SynchReadException          = class(Exception); // synch read error
  SynchWriteException         = class(Exception); // synch write error
  Asynch10ReadException       = class(Exception); // asynch 1.0 read error
  Asynch20ReadException       = class(Exception); // asynch 2.0 read error
  Asynch10UnadviseException   = class(Exception); // asynch 1.0 unadvise error
  Asynch20UnadviseException   = class(Exception); // asynch 2.0 unadvise error
  GroupUpdateTimeException    = class(Exception); // change updateTime group error
  GroupActivityException      = class(Exception); // change activity of group
  ItemActivityException       = class(Exception); // change activity of item
  VariantInternalException    = class(Exception); // variant error

const // NATIVE CODE EXCEPTIONS TEXT
  // exceptions text
  UnableBrowseBranchExceptionText = 'Unable to browse a branch.';
  UnableBrowseLeafExceptionText   = 'Unable to browse a leaf (item).';
  UnableIBrowseExceptionText      = 'Unable to initialize IBrowse.';
  ConnectivityExceptionText       = 'Connection fails to OPC Server.';
  HostExceptionText               = 'Host not found: ';
  NotFoundServersExceptionText    = 'OPC servers not found on ';
  UnableAddGroupExceptionText     = 'Unable to add group to server:';
  ComponentNotFoundExceptionText  = 'Component doesn''t found exception.';
  SynchReadExceptionText          = 'Synchronous reading error.';
  SynchWriteExceptionText         = 'Synchronous writing error.';
  Asynch10ReadExceptionText       = 'Asynchronous read error (register AdviseSink).';
  Asynch20ReadExceptionText       = 'Asynchronous read error (register CallBack).';
  Asynch10UnadviseExceptionText   = 'Asynchronous unadvise 1.0 error.';
  Asynch20UnadviseExceptionText   = 'Asynchronous unadvise 2.0 error.';
  GroupUpdateTimeExceptionText    = 'Update time of group cannot be changed.';
  GroupActivityExceptionText      = 'Activity of group cannot be changed.';
  ItemActivityExceptionText       = 'Activity of item cannot be changed.';
  VariantInternalExceptionText    = 'Variant native exception.'; // variant error

const // JAVA CODE EXCEPTIONS
  EXCPKG = 'javafish/clients/opc/exception/'; // standard exception package

  // java exceptions definition
  SConnectivityException        = EXCPKG + 'ConnectivityException';
  SCoInitializeException        = EXCPKG + 'CoInitializeException';
  SCoUninitializeException      = EXCPKG + 'CoUninitializeException';
  SHostException                = EXCPKG + 'HostException';
  SNotFoundServersException     = EXCPKG + 'NotFoundServersException';
  SUnableIBrowseException       = EXCPKG + 'UnableIBrowseException';
  SUnableBrowseBranchException  = EXCPKG + 'UnableBrowseBranchException';
  SUnableBrowseLeafException    = EXCPKG + 'UnableBrowseLeafException';
  SUnableAddGroupException      = EXCPKG + 'UnableAddGroupException';
  SUnableAddItemException       = EXCPKG + 'UnableAddItemException';
  SUnableRemoveGroupException   = EXCPKG + 'UnableRemoveGroupException';
  SUnableRemoveItemException    = EXCPKG + 'UnableRemoveItemException';
  SComponentNotFoundException   = EXCPKG + 'ComponentNotFoundException';
  SSynchReadException           = EXCPKG + 'SynchReadException';
  SSynchWriteException          = EXCPKG + 'SynchWriteException';
  SAsynch10ReadException        = EXCPKG + 'Asynch10ReadException';
  SAsynch20ReadException        = EXCPKG + 'Asynch20ReadException';
  SAsynch10UnadviseException    = EXCPKG + 'Asynch10UnadviseException';
  SAsynch20UnadviseException    = EXCPKG + 'Asynch20UnadviseException';
  SGroupUpdateTimeException     = EXCPKG + 'GroupUpdateTimeException';
  SGroupActivityException       = EXCPKG + 'GroupActivityException';
  SItemActivityException        = EXCPKG + 'ItemActivityException';
  SVariantInternalException     = EXCPKG + 'VariantInternalException';

implementation

end.
