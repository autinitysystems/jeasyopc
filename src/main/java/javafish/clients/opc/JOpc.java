package javafish.clients.opc;

import java.util.Iterator;
import java.util.LinkedHashMap;

import javafish.clients.opc.asynch.AsynchEvent;
import javafish.clients.opc.asynch.OpcAsynchGroupListener;
import javafish.clients.opc.component.OpcGroup;
import javafish.clients.opc.component.OpcItem;
import javafish.clients.opc.exception.Asynch10ReadException;
import javafish.clients.opc.exception.Asynch10UnadviseException;
import javafish.clients.opc.exception.Asynch20ReadException;
import javafish.clients.opc.exception.Asynch20UnadviseException;
import javafish.clients.opc.exception.ComponentNotFoundException;
import javafish.clients.opc.exception.GroupActivityException;
import javafish.clients.opc.exception.GroupExistsException;
import javafish.clients.opc.exception.GroupUpdateTimeException;
import javafish.clients.opc.exception.ItemActivityException;
import javafish.clients.opc.exception.SynchReadException;
import javafish.clients.opc.exception.SynchWriteException;
import javafish.clients.opc.exception.UnableAddGroupException;
import javafish.clients.opc.exception.UnableAddItemException;
import javafish.clients.opc.exception.UnableRemoveGroupException;
import javafish.clients.opc.exception.UnableRemoveItemException;
import javafish.clients.opc.lang.Translate;

/**
 * <b>Java OPC class</b>
 * <p>
 * <i>implements OPCDA standard (2.0, 3.0)</i>
 * <p>
 * OPC is open connectivity in industrial automation and the enterprise systems
 * that support the industry. Interoperability is assured through the creation and
 * maintenance of non-proprietary open standards specifications.
 * <p>
 * The first OPC standard specification resulted from the collaboration of
 * a number of leading worldwide automation suppliers working in cooperation
 * with Microsoft. Originally based on Microsoft's OLE COM and DCOM technologies,
 * the specification defined a standard set of objects, interfaces and methods
 * for use in process control and manufacturing automation applications to facilitate
 * interoperability.
 * <p>
 * The COM/DCOM technologies provided the framework for software products to be developed.
 * There are now hundreds of OPC Data Access servers and clients.
 * 
 * @author arnal2@seznam.cz
 */
public class JOpc extends JCustomOpc implements Runnable {
  
  /* thread instance */
  protected Thread thread;
  
  /* opc groups storage */
  protected LinkedHashMap<Integer, OpcGroup> groups;
  
  /* package counter */
  protected int idpkg = 0;
  
  /**
   * Create new instance of OPC Client.
   * 
   * @param host - host computer
   * @param serverProgID - OPC Server name
   * @param serverClientHandle - user name for OPC Client
   */
  public JOpc(String host, String serverProgID, String serverClientHandle) {
    super(host, serverProgID, serverClientHandle);
    groups = new LinkedHashMap<Integer, OpcGroup>();
    thread = new Thread(this);
  }
  
  ///////////////////////////////////////////////////////////////////////
  // NATIVE CODE
  ////////////////
  
  synchronized private native void addNativeGroup(OpcGroup group);
  
  synchronized private native void updateNativeGroups();
  
  synchronized private native void registerGroupNative(OpcGroup group)
    throws ComponentNotFoundException, UnableAddGroupException; 
  
  synchronized private native void registerItemNative(OpcGroup group, OpcItem item)
    throws ComponentNotFoundException, UnableAddItemException;
  
  private native void registerGroupsNative()
    throws UnableAddGroupException, UnableAddItemException;
  
  synchronized private native void unregisterGroupNative(OpcGroup group)
    throws ComponentNotFoundException, UnableRemoveGroupException;
  
  synchronized private native void unregisterItemNative(OpcGroup group, OpcItem item)
    throws ComponentNotFoundException, UnableRemoveItemException;
  
  private native void unregisterGroupsNative()
    throws UnableRemoveGroupException;
  
  private native OpcItem synchReadItemNative(OpcGroup group, OpcItem item)
    throws ComponentNotFoundException, SynchReadException;

  private native void synchWriteItemNative(OpcGroup group, OpcItem item)
    throws ComponentNotFoundException, SynchWriteException;
  
  private native OpcGroup synchReadGroupNative(OpcGroup group)
    throws ComponentNotFoundException, SynchReadException;
  
  private native void asynch10ReadNative(OpcGroup group)
    throws ComponentNotFoundException, Asynch10ReadException;
  
  private native void asynch20ReadNative(OpcGroup group)
    throws ComponentNotFoundException, Asynch20ReadException;
  
  private native void asynch10UnadviseNative(OpcGroup group)
    throws ComponentNotFoundException, Asynch10UnadviseException;
  
  private native void asynch20UnadviseNative(OpcGroup group)
    throws ComponentNotFoundException, Asynch20UnadviseException;
  
  private native OpcGroup getDownloadGroupNative();
  
  synchronized private native void setGroupUpdateTimeNative(OpcGroup group, int updateTime)
    throws ComponentNotFoundException, GroupUpdateTimeException;
  
  synchronized private native void setGroupActivityNative(OpcGroup group, boolean active)
    throws ComponentNotFoundException, GroupActivityException;
  
  synchronized private native void setItemActivityNative(OpcGroup group, OpcItem item, boolean active)
    throws ComponentNotFoundException, ItemActivityException;
  
  ////////////////////////////////////////////////////////////////////////
  
  /**
   * Generate new clientHandle for group
   * <p>
   * (Generation of unique group ID)
   * 
   * @return int clientHandle
   */
  public int getNewGroupClientHandle() {
    return groups.size();
  }
  
  /**
   * Add opc group to the client.
   * <p>
   * <i>NOTE:</i> GroupExistsException - runtime exception
   * 
   * @param group OpcGroup
   */
  public void addGroup(OpcGroup group) {
    if (group == null) return;
    
    if (!groups.containsKey(new Integer(group.getClientHandle()))) {
      group.generateClientHandleByOwner(this); // set clientHandle
      addNativeGroup(group);
      groups.put(new Integer(group.getClientHandle()), group);    
    } else { // throw exception
      throw new GroupExistsException(Translate.getString("GROUP_EXISTS_EXCEPTION") + " " +
          group.getGroupName());
    }
  }
  
  /**
   * Remove opc group from the client.
   * <p>
   * <i>NOTE:</i> GroupExistsException - runtime exception
   * 
   * @param group OpcGroup
   */
  public void removeGroup(OpcGroup group) {
    if (groups.containsKey(new Integer(group.getClientHandle()))) {
      groups.remove(new Integer(group.getClientHandle()));
      updateGroups();
    } else { // throw exception
      throw new GroupExistsException(Translate.getString("GROUP_NO_EXISTS_EXCEPTION") + " " +
          group.getGroupName());
    }
  }
  
  /**
   * Get group by its clientHandle identification.
   * 
   * @param clientHandle int
   * @return group OpcGroup
   */
  public OpcGroup getGroupByClientHandle(int clientHandle) {
    return groups.get(new Integer(clientHandle));
  }
  
  /**
   * Get opc-groups as array.
   * 
   * @return groups OpcGroup[]
   */
  public OpcGroup[] getGroupsAsArray() {
    int i = 0;
    OpcGroup[] agroups = new OpcGroup[groups.size()];
    for (Iterator iter = groups.values().iterator(); iter.hasNext();) {
      agroups[i++] = (OpcGroup)iter.next();
    }
    return agroups;
  }
  
  /**
   * Update native groups representation.
   */
  public void updateGroups() {
    updateNativeGroups();
  }
  
  /**
   * Send opc-group in asynchronous mode (1.0, 2.0)
   * 
   * @param group OpcGroup
   */
  protected void sendOpcGroup(OpcGroup group) {
    Object[] list = group.getAsynchListeners().getListenerList();
    for (int i = 0; i < list.length; i += 2) {
      Class listenerClass = (Class)(list[i]);
      if (listenerClass == OpcAsynchGroupListener.class) {
        OpcAsynchGroupListener listener = (OpcAsynchGroupListener)(list[i + 1]);
        AsynchEvent event = new AsynchEvent(this, idpkg++, group);
        listener.getAsynchEvent(event);
      }
    }
  }
  
  /**
   * Register group to opc-server.
   * 
   * @param group OpcGroup
   * 
   * @throws ComponentNotFoundException
   * @throws UnableAddGroupException
   */
  public void registerGroup(OpcGroup group)  
      throws ComponentNotFoundException, UnableAddGroupException {
    if (group == null) return;
    try {
      registerGroupNative(group);
    }
    catch (ComponentNotFoundException e) {
      throw new ComponentNotFoundException(Translate.getString("COMPONENT_NOT_FOUND_EXCEPTION") + " " +
          group.getGroupName());
    }
    catch (UnableAddGroupException e) {
      throw new UnableAddGroupException(Translate.getString("UNABLE_ADD_GROUP_EXCEPTION") + " " +
          group.getGroupName());
    }    
  }
  
  /**
   * Register item (in group) to opc-server.
   * 
   * @param group OpcGroup
   * @param item OpcItem
   * 
   * @throws ComponentNotFoundException
   * @throws UnableAddItemException
   */
  public void registerItem(OpcGroup group, OpcItem item) 
      throws ComponentNotFoundException, UnableAddItemException {
    if (group == null) return;
    if (item == null) return;
    try {
      registerItemNative(group, item);
    }
    catch (ComponentNotFoundException e) {
      throw new ComponentNotFoundException(Translate.getString("COMPONENT_NOT_FOUND_EXCEPTION") + " " +
          item.getItemName());
    }
    catch (UnableAddItemException e) {
      throw new UnableAddItemException(Translate.getString("UNABLE_ADD_ITEM_EXCEPTION") + " " +
          item.getItemName());
    }
  }
  
  /**
   * Register all groups (with items) to opc-server.
   * <p>
   * <i>NOTE:</i> It's faster than separate methods registerGroup and registerItem,
   * but you don't know, which item or group causes the registration exception.
   *  
   * @throws UnableAddGroupException
   * @throws UnableAddItemException
   */
  public void registerGroups() 
      throws UnableAddGroupException, UnableAddItemException {
    try {
      registerGroupsNative();
    }
    catch (UnableAddGroupException e) {
      throw new UnableAddGroupException(Translate.getString("UNABLE_ADD_GROUP_EXCEPTION_UNKNOWN"));
    }
    catch (UnableAddItemException e) {
      throw new UnableAddItemException(Translate.getString("UNABLE_ADD_ITEM_EXCEPTION_UNKNOWN"));
    }
  }
  
  /**
   * Unregister group from opc-server. 
   * 
   * @param group OpcGroup
   * 
   * @throws ComponentNotFoundException
   * @throws UnableRemoveGroupException
   */
  public void unregisterGroup(OpcGroup group) 
      throws ComponentNotFoundException, UnableRemoveGroupException {
    if (group == null) return;
    try {
      unregisterGroupNative(group);
    }
    catch (ComponentNotFoundException e) {
      throw new ComponentNotFoundException(Translate.getString("COMPONENT_NOT_FOUND_EXCEPTION") + " " +
          group.getGroupName());
    }
    catch (UnableRemoveGroupException e) {
      throw new UnableRemoveGroupException(Translate.getString("UNABLE_REMOVE_GROUP_EXCEPTION") + " " +
          group.getGroupName());
    }
  }

  /**
   * Unregister item (in group) from opc-server.
   * 
   * @param group OpcGroup
   * @param item OpcItem
   * 
   * @throws ComponentNotFoundException
   * @throws UnableRemoveItemException
   */
  public void unregisterItem(OpcGroup group, OpcItem item) 
      throws ComponentNotFoundException, UnableRemoveItemException {
    if (group == null) return;
    if (item == null) return;
    try {
      unregisterItemNative(group, item);
    }
    catch (ComponentNotFoundException e) {
      throw new ComponentNotFoundException(Translate.getString("COMPONENT_NOT_FOUND_EXCEPTION") + " " +
          item.getItemName());
    }
    catch (UnableRemoveItemException e) {
      throw new UnableRemoveItemException(Translate.getString("UNABLE_REMOVE_ITEM_EXCEPTION") + " " +
          item.getItemName());
    }
  }
  
  /**
   * Unregister all groups from opc-server (with items).
   * <p>
   * <i>NOTE:</i> It's faster than separate methods unregisterGroup and unregisterItem,
   * but you don't know, which group causes the unregistration exception.
   * 
   * @throws UnableRemoveGroupException
   */
  public void unregisterGroups() throws UnableRemoveGroupException {
    try {
      unregisterGroupsNative();
    }
    catch (UnableRemoveGroupException e) {
      throw new UnableRemoveGroupException(Translate.getString("UNABLE_REMOVE_GROUP_EXCEPTION_UNKNOWN"));
    }
  }
  
  /**
   * Synchronous reading of one item in specific group. 
   * 
   * @param group OpcGroup
   * @param item OpcItem
   * @return item OpcItem
   * 
   * @throws ComponentNotFoundException
   * @throws SynchReadException
   */
  public OpcItem synchReadItem(OpcGroup group, OpcItem item) 
      throws ComponentNotFoundException, SynchReadException {
    try {
      if (group == null || item == null) {
        throw new ComponentNotFoundException("NullPointerException");
      }
      return synchReadItemNative(group, item);
    }
    catch (ComponentNotFoundException e) {
      throw new ComponentNotFoundException(Translate.getString("COMPONENT_NOT_FOUND_EXCEPTION") + " " +
          ((item == null) ? "null" : item.getItemName()));
    }
    catch (SynchReadException e) {
      throw new SynchReadException(Translate.getString("SYNCH_READ_EXCEPTION"));
    }
  }
  
  /**
   * Synchronous writing of one item in specific group.
   * 
   * @param group OpcGroup
   * @param item OpcItem
   * 
   * @throws ComponentNotFoundException
   * @throws SynchWriteException
   */
  public void synchWriteItem(OpcGroup group, OpcItem item) 
      throws ComponentNotFoundException, SynchWriteException  {
    try {
      if (group == null || item == null) {
        throw new ComponentNotFoundException("NullPointerException");
      }
      synchWriteItemNative(group, item);
    }
    catch (ComponentNotFoundException e) {
      throw new ComponentNotFoundException(Translate.getString("COMPONENT_NOT_FOUND_EXCEPTION") + " " +
          (item == null ? "null" : item.getItemName()));
    }
    catch (SynchWriteException e) {
      throw new SynchWriteException(Translate.getString("SYNCH_WRITE_EXCEPTION"));
    }
  }
  
  /**
   * Synchronous reading of group
   * 
   * @param group OpcGroup
   * @return group with response (clone) OPCGroup
   * 
   * @throws ComponentNotFoundException
   * @throws SynchReadException
   */
  public OpcGroup synchReadGroup(OpcGroup group) 
      throws ComponentNotFoundException, SynchReadException {
    try {
      if (group == null) {
        throw new ComponentNotFoundException("NullPointerException");
      }
      return synchReadGroupNative(group);
    }
    catch (ComponentNotFoundException e) {
      throw new ComponentNotFoundException(Translate.getString("COMPONENT_NOT_FOUND_EXCEPTION") + " " +
          (group == null ? "null" : group.getGroupName()));
    }
    catch (SynchReadException e) {
      throw new SynchReadException(Translate.getString("SYNCH_READ_EXCEPTION"));
    }
  }
  
  /**
   * Asynchronous 1.0 reading (AdviseSink) - start 
   * 
   * @param group OpcGroup
   * 
   * @throws ComponentNotFoundException
   * @throws Asynch10ReadException
   */
  public void asynch10Read(OpcGroup group) throws ComponentNotFoundException, Asynch10ReadException {
    try {
      if (group == null) {
        throw new ComponentNotFoundException("NullPointerException");
      }
      asynch10ReadNative(group);
    }
    catch (ComponentNotFoundException e) {
      throw new ComponentNotFoundException(Translate.getString("COMPONENT_NOT_FOUND_EXCEPTION") + " " +
          (group == null ? "null" : group.getGroupName()));
    }
    catch (Asynch10ReadException e) {
      throw new Asynch10ReadException(Translate.getString("ASYNCH_10_READ_EXCEPTION") + " " +
          group.getGroupName());
    }
  }
  
  /**
   * Asynchronous 2.0 reading (Callback) - start 
   * 
   * @param group OpcGroup
   * 
   * @throws ComponentNotFoundException
   * @throws Asynch20ReadException
   */
  public void asynch20Read(OpcGroup group) throws ComponentNotFoundException, Asynch20ReadException {
    try {
      if (group == null) {
        throw new ComponentNotFoundException("NullPointerException");
      }
      asynch20ReadNative(group);
    }
    catch (ComponentNotFoundException e) {
      throw new ComponentNotFoundException(Translate.getString("COMPONENT_NOT_FOUND_EXCEPTION") + " " +
          (group == null ? "null" : group.getGroupName()));
    }
    catch (Asynch20ReadException e) {
      throw new Asynch20ReadException(Translate.getString("ASYNCH_20_READ_EXCEPTION") + " " +
          group.getGroupName());
    }
  }
  
  /**
   * Asynchronous 1.0 unadvise reading (AdviseSink) - terminate 
   * 
   * @param group OpcGroup
   * 
   * @throws ComponentNotFoundException
   * @throws Asynch10UnadviseException
   */
  public void asynch10Unadvise(OpcGroup group) throws ComponentNotFoundException, Asynch10UnadviseException {
    try {
      if (group == null) {
        throw new ComponentNotFoundException("NullPointerException");
      }
      asynch10UnadviseNative(group);
    }
    catch (ComponentNotFoundException e) {
      throw new ComponentNotFoundException(Translate.getString("COMPONENT_NOT_FOUND_EXCEPTION") + " " +
          (group == null ? "null" : group.getGroupName()));
    }
    catch (Asynch10UnadviseException e) {
      throw new Asynch10UnadviseException(Translate.getString("ASYNCH_10_UNADVISE_EXCEPTION") + " " +
          group.getGroupName());
    }
  }
  
  
  /**
   * Asynchronous 2.0 unadvise reading (Callback) - terminate 
   * 
   * @param group OpcGroup
   * 
   * @throws ComponentNotFoundException
   * @throws Asynch20UnadviseException
   */
  public void asynch20Unadvise(OpcGroup group) throws ComponentNotFoundException, Asynch20UnadviseException {
    try {
      if (group == null) {
        throw new ComponentNotFoundException("NullPointerException");
      }
      asynch20UnadviseNative(group);
    }
    catch (ComponentNotFoundException e) {
      throw new ComponentNotFoundException(Translate.getString("COMPONENT_NOT_FOUND_EXCEPTION") + " " +
          (group == null ? "null" : group.getGroupName()));
    }
    catch (Asynch20UnadviseException e) {
      throw new Asynch20UnadviseException(Translate.getString("ASYNCH_20_UNADVISE_EXCEPTION") + " " +
          group.getGroupName());
    }
  }
  
  /**
   * Get downloaded group (clone) from opc-server
   * <p>
   * <i>NOTE:</i> Asynchronous mode, OPC-Queue of downloaded groups,
   * OPCGroup can be NULL. 
   * 
   * @return group OpcGroup
   */
  public OpcGroup getDownloadGroup() {
    return getDownloadGroupNative();
  }
  
  /**
   * Set new updateTime of group (refresh rate)
   * 
   * @param group OpcGroup
   * @param updateTime int
   * 
   * @throws ComponentNotFoundException
   * @throws GroupUpdateTimeException
   */
  public void setGroupUpdateTime(OpcGroup group, int updateTime) throws ComponentNotFoundException, GroupUpdateTimeException {
    try {
      if (group == null) {
        throw new ComponentNotFoundException("NullPointerException");
      }
      setGroupUpdateTimeNative(group, updateTime);
    }
    catch (ComponentNotFoundException e) {
      throw new ComponentNotFoundException(Translate.getString("COMPONENT_NOT_FOUND_EXCEPTION") + " " +
          (group == null ? "null" : group.getGroupName()));
    }
    catch (GroupUpdateTimeException e) {
      throw new GroupUpdateTimeException(Translate.getString("GROUP_UPDATETIME_EXCEPTION") + " " +
          group.getGroupName());
    }
  }
  
  /**
   * Set new activity of group (change active state)
   * 
   * @param group OpcGroup
   * @param active boolean
   *
   * @throws ComponentNotFoundException
   * @throws GroupActivityException
   */
  public void setGroupActivity(OpcGroup group, boolean active) throws ComponentNotFoundException, GroupActivityException {
    try {
      if (group == null) {
        throw new ComponentNotFoundException("NullPointerException");
      }
      setGroupActivityNative(group, active);
    }
    catch (ComponentNotFoundException e) {
      throw new ComponentNotFoundException(Translate.getString("COMPONENT_NOT_FOUND_EXCEPTION") + " " +
          (group == null ? "null" : group.getGroupName()));
    }
    catch (GroupActivityException e) {
      throw new GroupActivityException(Translate.getString("GROUP_ACTIVITY_EXCEPTION") + " " +
          group.getGroupName());
    }
  }
  
  /**
   * Set new activity of item (change active state)
   * 
   * @param group OpcGroup
   * @param item OpcItem
   * @param active boolean
   * 
   * @throws ComponentNotFoundException
   * @throws ItemActivityException
   */
  public void setItemActivity(OpcGroup group, OpcItem item, boolean active)
      throws ComponentNotFoundException, ItemActivityException {
    try {
      if (group == null || item == null) {
        throw new ComponentNotFoundException("NullPointerException");
      }
      setItemActivityNative(group, item, active);
    }
    catch (ComponentNotFoundException e) {
      throw new ComponentNotFoundException(Translate.getString("COMPONENT_NOT_FOUND_EXCEPTION") + " " +
          (item == null ? "null" : item.getItemName()));
    }
    catch (ItemActivityException e) {
      throw new ItemActivityException(Translate.getString("ITEM_ACTIVITY_EXCEPTION") + " " +
          item.getItemName());
    }
  }
  
  /**
   * Run OPC-Client thread
   */
  public void start() {
    thread.start();
  }

  public void run() {
    // not implemented
    // you can override this method (see JEasyOpc example)
  }

}
