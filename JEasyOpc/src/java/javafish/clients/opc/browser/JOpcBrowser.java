package javafish.clients.opc.browser;

import javafish.clients.opc.JCustomOpc;
import javafish.clients.opc.exception.HostException;
import javafish.clients.opc.exception.NotFoundServersException;
import javafish.clients.opc.exception.UnableAddGroupException;
import javafish.clients.opc.exception.UnableAddItemException;
import javafish.clients.opc.exception.UnableBrowseBranchException;
import javafish.clients.opc.exception.UnableBrowseLeafException;
import javafish.clients.opc.exception.UnableIBrowseException;
import javafish.clients.opc.lang.Translate;

/**
 * OPC Browser: browses brances and items of OPC Server.
 * Uses OPCEnum to find OPC Servers on a specific host.
 */
public class JOpcBrowser extends JCustomOpc {
  
  /**
   * Create new opc-browser
   * 
   * @param host String - server / personal computer tcp/ip address (name)
   * @param serverProgID String - OPC Server full name
   * @param serverClientHandle - user description of opc-browser
   */
  public JOpcBrowser(String host, String serverProgID, String serverClientHandle) {
    super(host, serverProgID, serverClientHandle);
  }
  
  private static native String[] getOpcServersNative(String host)
    throws HostException, NotFoundServersException;
  
  private native String[] getOpcBranchNative(String branch)
    throws UnableBrowseBranchException, UnableIBrowseException;
  
  private native String[] getOpcItemsNative(String leaf, boolean download)
    throws UnableBrowseLeafException, UnableIBrowseException,
    UnableAddGroupException, UnableAddItemException;
  
  /**
   * STATIC: Get OPC-Servers from host computer
   * 
   * @param host String - computer name (tcp/ip)
   * @return servers String[] - returned array with names of OPC Servers
   * 
   * @throws HostException
   * @throws NotFoundServersException
   */
  public static String[] getOpcServers(String host) throws HostException, NotFoundServersException {
    try {
      return getOpcServersNative(host);
    }
    catch (HostException e) {
      throw new HostException(Translate.getString("HOST_EXCEPTION") + " " + host);
    }
    catch (NotFoundServersException e) {
      throw new NotFoundServersException(Translate.getString("NOT_FOUND_SERVERS_EXCEPTION")
          + " " + host);
    }
  }
  
  /**
   * Get branch of OPC browser tree
   * 
   * @param branch String
   * @return items of branch String[]
   * 
   * @throws UnableBrowseBranchException
   * @throws UnableIBrowseException
   */
  public String[] getOpcBranch(String branch) throws UnableBrowseBranchException, UnableIBrowseException {
    try {
      return getOpcBranchNative(branch);
    }
    catch (UnableBrowseBranchException e) {
      throw new UnableBrowseBranchException(Translate.getString("UNABLE_BROWSE_BRANCH_EXCEPTION"));
    }
    catch (UnableIBrowseException e) {
      throw new UnableIBrowseException(Translate.getString("UNABLE_IBROWSE_EXCEPTION"));
    }
  }
  
  /**
   * Get items descriptions.
   * <p>
   * Structure of response: Array of items, each row is divided to the sections by <i>;</i> <br>
   * Structure: <i>fullItemName; itemType; itemName; [itemValue]</i>
   * 
   * @param leaf of branch (items) String
   * @param download - if is true, Client downloads last value of items
   * @return description of items String[]
   * 
   * @throws UnableBrowseLeafException
   * @throws UnableIBrowseException
   * @throws UnableAddGroupException
   * @throws UnableAddItemException
   */
  public String[] getOpcItems(String leaf, boolean download) throws UnableBrowseLeafException,
      UnableIBrowseException, UnableAddGroupException, UnableAddItemException{
    try {
      return getOpcItemsNative(leaf, download);
    }
    catch (UnableBrowseLeafException e) {
      throw new UnableBrowseLeafException(Translate.getString("UNABLE_BROWSE_LEAF_EXCEPTION"));
    }
    catch (UnableIBrowseException e) {
      throw new UnableIBrowseException(Translate.getString("UNABLE_IBROWSE_EXCEPTION"));
    }
    catch (UnableAddGroupException e) {
      throw new UnableAddGroupException(Translate.getString("UNABLE_ADD_GROUP_EXCEPTION") + " " +
          host + "->" + serverProgID);
    }
    catch (UnableAddItemException e) {
      throw new UnableAddItemException(Translate.getString("UNABLE_ADD_ITEM_EXCEPTION") + " " +
          host + "->" + serverProgID);
    }
  }
  
}
