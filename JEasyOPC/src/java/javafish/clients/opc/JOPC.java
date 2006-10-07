package javafish.clients.opc;

import java.util.Iterator;
import java.util.LinkedHashMap;

import javafish.clients.opc.component.OPCGroup;
import javafish.clients.opc.component.OPCItem;
import javafish.clients.opc.exception.GroupExistsException;
import javafish.clients.opc.lang.Translate;

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
   * Add opc group to native source
   * 
   * @param OPCGroup group
   */
  private native void addNativeGroup(OPCGroup group);
  
  /**
   * Update native groups from JAVA code
   */
  private native void updateNativeGroups();
  
  private native void synchReadItemNative(OPCGroup group, OPCItem item);
  
  /**
   * Add opc group to the client
   * <p>
   * <i>note:</i> GroupExistsException - runtime exception
   * 
   * @param group OPCGroup
   */
  public void addGroup(OPCGroup group) {
    if (!groups.containsKey(new Integer(group.getClientHandle()))) {
      addNativeGroup(group);
      groups.put(new Integer(group.getClientHandle()), group);    
    } else { // throw exception
      throw new GroupExistsException(Translate.getString("GROUP_EXISTS_EXCEPTION") + " " +
          group.getGroupName());
    }
  }
  
  /**
   * Remove opc group from the client
   * <p>
   * <i>note:</i> GroupExistsException - runtime exception
   * 
   * @param group OPCGroup
   */
  public void removeGroup(OPCGroup group) {
    if (groups.containsKey(new Integer(group.getClientHandle()))) {
      groups.remove(new Integer(group.getClientHandle()));
      updateGroups();
    } else { // throw exception
      throw new GroupExistsException(Translate.getString("GROUP_NO_EXISTS_EXCEPTION") + " " +
          group.getGroupName());
    }
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
  
  /**
   * Get opc-groups as array
   * 
   * @return groups OPCGroup[]
   */
  public OPCGroup[] getGroupsAsArray() {
    int i = 0;
    OPCGroup[] agroups = new OPCGroup[groups.size()];
    for (Iterator iter = groups.values().iterator(); iter.hasNext();) {
      agroups[i++] = (OPCGroup)iter.next();
    }
    return agroups;
  }
  
  /**
   * Update native groups representation
   */
  public void updateGroups() {
    updateNativeGroups();
  }
  
  
  
  public void run() {
  // TODO Auto-generated method stub
  }

}
