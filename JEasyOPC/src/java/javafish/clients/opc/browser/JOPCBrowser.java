package javafish.clients.opc.browser;

import javafish.clients.opc.JCustomOPC;
import javafish.clients.opc.exception.HostException;
import javafish.clients.opc.exception.NotFoundServersException;
import javafish.clients.opc.exception.UnableAddGroupException;
import javafish.clients.opc.exception.UnableAddItemException;
import javafish.clients.opc.exception.UnableBrowseBranchException;
import javafish.clients.opc.exception.UnableBrowseLeafException;
import javafish.clients.opc.exception.UnableIBrowseException;

public class JOPCBrowser extends JCustomOPC {
  
  public JOPCBrowser(String host, String serverProgID, String serverClientHandle) {
    super(host, serverProgID, serverClientHandle);
  }
  
  /**
   * Get OPC-Servers from host computer
   * 
   * @param host
   * @return String[]
   */
  public static native String[] getOPCServers(String host) throws HostException, NotFoundServersException;
  
  /**
   * Get branch of OPC browser tree
   * 
   * @param branch String
   * @return items of branch String[]
   * 
   * @throws UnableBrowseBranchException
   * @throws UnableIBrowseException
   */
  public native String[] getOPCBranch(String branch) throws UnableBrowseBranchException, UnableIBrowseException;
  
  /**
   * Get items descriptions.
   * <p>
   * Structure of response:
   *   Array of items, each row is divided to the sections by <i>;</i> <br>
   *   Structure: <i>fullItemName; itemType; itemName; [itemValue]</i>
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
  public native String[] getOPCItems(String leaf, boolean download) throws UnableBrowseLeafException,
    UnableIBrowseException, UnableAddGroupException, UnableAddItemException;
  
}
