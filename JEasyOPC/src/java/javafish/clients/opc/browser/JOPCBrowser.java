package javafish.clients.opc.browser;

import javafish.clients.opc.JCustomOPC;
import javafish.clients.opc.exception.HostException;
import javafish.clients.opc.exception.NotFoundServersException;
import javafish.clients.opc.exception.UnableBrowseBranchException;
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


}
