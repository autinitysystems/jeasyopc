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
  protected LinkedHashMap<String, OPCGroup> groups;

  public JOPC(String host, String serverProgID, String serverClientHandle) {
    super(host, serverProgID, serverClientHandle);
    groups = new LinkedHashMap<String, OPCGroup>();
    thread = new Thread(this);
  }
  
  public void addGroup(OPCGroup group) {
    //groups.put(, value)    
  }
  
  public void removeGroup(OPCGroup group) {
    
  }
  
  
  public void run() {
  // TODO Auto-generated method stub
  }

}
