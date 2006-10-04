package javafish.clients.opc;

import java.util.LinkedHashMap;

import javafish.clients.opc.component.OPCGroup;

/**
 * Java OPC class
 * implements OPCDA standard (2.0, 3.0) 
 */
public class JOPC extends JCustomOPC implements Runnable {
  
  /* thread instance */
  protected Thread thread;
  
  /* opc groups storage */
  protected LinkedHashMap<Integer, OPCGroup> groups;

  /**
   * Create new instance of OPC Client
   * 
   * @param host String 
   * @param serverProgID String
   * @param serverClientHandle String
   */
  public JOPC(String host, String serverProgID, String serverClientHandle) {
    super(host, serverProgID, serverClientHandle);
    groups = new LinkedHashMap<Integer, OPCGroup>();
    thread = new Thread(this);
  }
  
  /**
   * Add opc group to native source (by its client handle)
   * NOTE: Group has to be in groups map.
   * 
   * @param groupClientHandle int
   */
  private native void addNativeGroup(int groupClientHandle);
  
  /**
   * Add opc group to the client
   * 
   * @param group OPCGroup
   */
  public void addGroup(OPCGroup group) {
    groups.put(new Integer(group.getClientHandle()), group);    
    addNativeGroup(group.getClientHandle()); // group must be in groups map!
  }
  
  /**
   * Remove opc group from the client
   * 
   * @param group OPCGroup
   */
  public void removeGroup(OPCGroup group) {
    groups.remove(new Integer(group.getClientHandle()));
  }
  
  /**
   * Get group by its clientHandle identification
   * 
   * @param clientHandle int
   * @return group OPCGroup
   */
  public OPCGroup getGroupByClientHandle(int clientHandle) {
    return groups.get(new Integer(clientHandle));
  }
  
  
  public void run() {
  // TODO Auto-generated method stub
  }

}
