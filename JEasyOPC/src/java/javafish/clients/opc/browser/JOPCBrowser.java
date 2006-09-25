package javafish.clients.opc.browser;

import javafish.clients.opc.JCustomOPC;
import javafish.clients.opc.exception.HostException;
import javafish.clients.opc.exception.NotFoundServers;

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
  public static native String[] getOPCServers(String host) throws HostException, NotFoundServers;

}
