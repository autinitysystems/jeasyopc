package javafish.clients.opc.browser;

import javafish.clients.opc.JCustomOPC;
import javafish.clients.opc.exception.HostException;
import javafish.clients.opc.exception.NotFoundServersException;
import javafish.clients.opc.exception.UnableAddGroupException;
import javafish.clients.opc.exception.UnableAddItemException;
import javafish.clients.opc.exception.UnableBrowseBranchException;
import javafish.clients.opc.exception.UnableBrowseLeafException;
import javafish.clients.opc.exception.UnableIBrowseException;
import javafish.clients.opc.lang.Translate;

/**
 * OPC browser: browses brances and items of opc-server. Uses OPCEnum to find opc-servers on specific host.
 */
public class JOPCBrowser extends JCustomOPC {
  
  /**
   * Create new opc-browser
   * 
   * @param host String
   * @param serverProgID String - opc-server full name
   * @param serverClientHandle - user description of opc-browser
   */
  public JOPCBrowser(String host, String serverProgID, String serverClientHandle) {
    super(host, serverProgID, serverClientHandle);
  }
  
  private static native String[] getOPCServersNative(String host)
    throws HostException, NotFoundServersException;
  
  private native String[] getOPCBranchNative(String branch)
    throws UnableBrowseBranchException, UnableIBrowseException;
  
  private native String[] getOPCItemsNative(String leaf, boolean download)
    throws UnableBrowseLeafException, UnableIBrowseException,
    UnableAddGroupException, UnableAddItemException;
  
  /**
   * STATIC: Get OPC-Servers from host computer
   * 
   * @param host String
   * @return servers String[]
   * @throws HostException
   * @throws NotFoundServersException
   */
  public static String[] getOPCServers(String host) throws HostException, NotFoundServersException {
    try {
      return getOPCServersNative(host);
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
   * @throws UnableBrowseBranchException
   * @throws UnableIBrowseException
   */
  public String[] getOPCBranch(String branch) throws UnableBrowseBranchException, UnableIBrowseException {
    try {
      return getOPCBranchNative(branch);
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
   * @param download, if is true, Client downloads last value of items
   * @return description of items String[]
   * 
   * @throws UnableBrowseLeafException
   * @throws UnableIBrowseException
   * @throws UnableAddGroupException
   * @throws UnableAddItemException
   */
  public String[] getOPCItems(String leaf, boolean download) throws UnableBrowseLeafException,
      UnableIBrowseException, UnableAddGroupException, UnableAddItemException{
    try {
      return getOPCItemsNative(leaf, download);
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
