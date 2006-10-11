package javafish.clients.opc;

import java.util.Arrays;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;

import javax.swing.event.EventListenerList;

import javafish.clients.opc.asynch.AsynchEvent;
import javafish.clients.opc.asynch.OPCAsynchGroupListener;
import javafish.clients.opc.component.OPCGroup;
import javafish.clients.opc.component.OPCItem;
import javafish.clients.opc.exception.Asynch10ReadException;
import javafish.clients.opc.exception.Asynch10UnadviseException;
import javafish.clients.opc.exception.Asynch20ReadException;
import javafish.clients.opc.exception.Asynch20UnadviseException;
import javafish.clients.opc.exception.ComponentNotFoundException;
import javafish.clients.opc.exception.GroupExistsException;
import javafish.clients.opc.exception.SynchReadException;
import javafish.clients.opc.exception.SynchWriteException;
import javafish.clients.opc.exception.UnableAddGroupException;
import javafish.clients.opc.exception.UnableAddItemException;
import javafish.clients.opc.exception.UnableRemoveGroupException;
import javafish.clients.opc.exception.UnableRemoveItemException;
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
  
  /* asynchronous group event listeners */
  protected EventListenerList asynchGroupListeners;
  
  /* package counter */
  private int idpkg = 0;
  
  /**
   * Create new instance of OPC Client.
   * 
   * @param host String 
   * @param serverProgID String
   * @param serverClientHandle String
   */
  public JOPC(String host, String serverProgID, String serverClientHandle) {
    super(host, serverProgID, serverClientHandle);
    asynchGroupListeners = new EventListenerList();
    groups = new LinkedHashMap<Integer, OPCGroup>();
    thread = new Thread(this);
  }
  
  ///////////////////////////////////////////////////////////////////////
  // NATIVE CODE
  ////////////////
  
  private native void addNativeGroup(OPCGroup group);
  
  private native void updateNativeGroups();
  
  private native void registerGroupNative(OPCGroup group)
    throws ComponentNotFoundException, UnableAddGroupException; 
  
  private native void registerItemNative(OPCGroup group, OPCItem item)
    throws ComponentNotFoundException, UnableAddItemException;
  
  private native void registerGroupsNative()
    throws UnableAddGroupException, UnableAddItemException;
  
  private native void unregisterGroupNative(OPCGroup group)
    throws ComponentNotFoundException, UnableRemoveGroupException;
  
  private native void unregisterItemNative(OPCGroup group, OPCItem item)
    throws ComponentNotFoundException, UnableRemoveItemException;
  
  private native void unregisterGroupsNative()
    throws UnableRemoveGroupException;
  
  private native OPCItem synchReadItemNative(OPCGroup group, OPCItem item)
    throws ComponentNotFoundException, SynchReadException;

  private native void synchWriteItemNative(OPCGroup group, OPCItem item)
    throws ComponentNotFoundException, SynchWriteException;
  
  private native void asynch10ReadNative(OPCGroup group)
    throws ComponentNotFoundException, Asynch10ReadException;
  
  private native void asynch20ReadNative(OPCGroup group)
    throws ComponentNotFoundException, Asynch20ReadException;
  
  private native void asynch10UnadviseNative(OPCGroup group)
    throws ComponentNotFoundException, Asynch10UnadviseException;
  
  private native void asynch20UnadviseNative(OPCGroup group)
    throws ComponentNotFoundException, Asynch20UnadviseException;
  
  private native OPCGroup getDownloadGroupNative();
  
  ////////////////////////////////////////////////////////////////////////
  
  /**
   * Generate new clientHandle for group
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
   * @param group OPCGroup
   */
  public void addGroup(OPCGroup group) {
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
   * Get group by its clientHandle identification.
   * 
   * @param clientHandle int
   * @return group OPCGroup
   */
  public OPCGroup getGroupByClientHandle(int clientHandle) {
    return groups.get(new Integer(clientHandle));
  }
  
  /**
   * Get opc-groups as array.
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
   * Update native groups representation.
   */
  public void updateGroups() {
    updateNativeGroups();
  }
  
  /**
   * Add asynch-group listener
   * 
   * @param listener OPCReportListener
   */
  public void addAsynchGroupListener(OPCAsynchGroupListener listener) {
    List list = Arrays.asList(asynchGroupListeners.getListenerList());
    if (list.contains(listener) == false) {
      asynchGroupListeners.add(OPCAsynchGroupListener.class, listener);
    }
  }

  /**
   * Remove asynch-group listener
   * 
   * @param listener OPCReportListener
   */
  public void removeAsynchGroupListener(OPCAsynchGroupListener listener) {
    List list = Arrays.asList(asynchGroupListeners.getListenerList());
    if (list.contains(listener) == true) {
      asynchGroupListeners.remove(OPCAsynchGroupListener.class, listener);
    }
  }
  
  /**
   * Send opc-group in asynchronous mode (1.0, 2.0)
   * 
   * @param group OPCGroup
   */
  protected void sendOPCGroup(OPCGroup group) {
    Object[] list = asynchGroupListeners.getListenerList();
    for (int i = 0; i < list.length; i += 2) {
      Class listenerClass = (Class)(list[i]);
      if (listenerClass == OPCAsynchGroupListener.class) {
        OPCAsynchGroupListener listener = (OPCAsynchGroupListener)(list[i + 1]);
        AsynchEvent event = new AsynchEvent(this, idpkg++, group);
        listener.getAsynchEvent(event);
      }
    }
  }
  
  /**
   * Register group to opc-server.
   * 
   * @param group OPCGroup
   * 
   * @throws ComponentNotFoundException
   * @throws UnableAddGroupException
   */
  public void registerGroup(OPCGroup group)  
      throws ComponentNotFoundException, UnableAddGroupException {
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
   * @param group OPCGroup
   * @param item OPCItem
   * 
   * @throws ComponentNotFoundException
   * @throws UnableAddItemException
   */
  public void registerItem(OPCGroup group, OPCItem item) 
      throws ComponentNotFoundException, UnableAddItemException {
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
   * @param group OPCGroup
   * 
   * @throws ComponentNotFoundException
   * @throws UnableRemoveGroupException
   */
  public void unregisterGroup(OPCGroup group) 
      throws ComponentNotFoundException, UnableRemoveGroupException {
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
   * @param group OPCGroup
   * @param item OPCItem
   * 
   * @throws ComponentNotFoundException
   * @throws UnableRemoveItemException
   */
  public void unregisterItem(OPCGroup group, OPCItem item) 
      throws ComponentNotFoundException, UnableRemoveItemException {
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
   * @param group OPCGroup
   * @param item OPCItem
   * @return item OPCItem
   * 
   * @throws ComponentNotFoundException
   * @throws SynchReadException
   */
  public OPCItem synchReadItem(OPCGroup group, OPCItem item) 
      throws ComponentNotFoundException, SynchReadException {
    try {
      return synchReadItemNative(group, item);
    }
    catch (ComponentNotFoundException e) {
      throw new ComponentNotFoundException(Translate.getString("COMPONENT_NOT_FOUND_EXCEPTION") + " " +
          item.getItemName());
    }
    catch (SynchReadException e) {
      throw new SynchReadException(Translate.getString("SYNCH_READ_EXCEPTION"));
    }
  }
  
  /**
   * Synchronous writing of one item in specific group.
   * 
   * @param group OPCGroup
   * @param item OPCItem
   * 
   * @throws ComponentNotFoundException
   * @throws SynchWriteException
   */
  public void synchWriteItem(OPCGroup group, OPCItem item) 
      throws ComponentNotFoundException, SynchWriteException  {
    try {
      synchWriteItemNative(group, item);
    }
    catch (ComponentNotFoundException e) {
      throw new ComponentNotFoundException(Translate.getString("COMPONENT_NOT_FOUND_EXCEPTION") + " " +
          item.getItemName());
    }
    catch (SynchWriteException e) {
      throw new SynchWriteException(Translate.getString("SYNCH_WRITE_EXCEPTION"));
    }
  }
  
  /**
   * Asynchronous 1.0 reading (AdviseSink) - start 
   * 
   * @param group OPCGroup
   * 
   * @throws ComponentNotFoundException
   * @throws Asynch10ReadException
   */
  public void asynch10Read(OPCGroup group) throws ComponentNotFoundException, Asynch10ReadException {
    try {
      asynch10ReadNative(group);
    }
    catch (ComponentNotFoundException e) {
      throw new ComponentNotFoundException(Translate.getString("COMPONENT_NOT_FOUND_EXCEPTION") + " " +
          group.getGroupName());
    }
    catch (Asynch10ReadException e) {
      throw new Asynch10ReadException(Translate.getString("ASYNCH_10_READ_EXCEPTION") + " " +
          group.getGroupName());
    }
  }
  
  /**
   * Asynchronous 2.0 reading (Callback) - start 
   * 
   * @param group OPCGroup
   * @throws ComponentNotFoundException
   * @throws Asynch20ReadException
   */
  public void asynch20Read(OPCGroup group) throws ComponentNotFoundException, Asynch20ReadException {
    try {
      asynch20ReadNative(group);
    }
    catch (ComponentNotFoundException e) {
      throw new ComponentNotFoundException(Translate.getString("COMPONENT_NOT_FOUND_EXCEPTION") + " " +
          group.getGroupName());
    }
    catch (Asynch20ReadException e) {
      throw new Asynch20ReadException(Translate.getString("ASYNCH_20_READ_EXCEPTION") + " " +
          group.getGroupName());
    }
  }
  
  /**
   * Asynchronous 1.0 unadvise reading (AdviseSink) - terminate 
   * 
   * @param group OPCGroup
   * @throws ComponentNotFoundException
   * @throws Asynch10UnadviseException
   */
  public void asynch10Unadvise(OPCGroup group) throws ComponentNotFoundException, Asynch10UnadviseException {
    try {
      asynch10UnadviseNative(group);
    }
    catch (ComponentNotFoundException e) {
      throw new ComponentNotFoundException(Translate.getString("COMPONENT_NOT_FOUND_EXCEPTION") + " " +
          group.getGroupName());
    }
    catch (Asynch10UnadviseException e) {
      throw new Asynch10UnadviseException(Translate.getString("ASYNCH_20_UNADVISE_EXCEPTION") + " " +
          group.getGroupName());
    }
  }
  
  
  /**
   * Asynchronous 2.0 unadvise reading (Callback) - terminate 
   * 
   * @param group OPCGroup
   * 
   * @throws ComponentNotFoundException
   * @throws Asynch20UnadviseException
   */
  public void asynch20Unadvise(OPCGroup group) throws ComponentNotFoundException, Asynch20UnadviseException {
    try {
      asynch20UnadviseNative(group);
    }
    catch (ComponentNotFoundException e) {
      throw new ComponentNotFoundException(Translate.getString("COMPONENT_NOT_FOUND_EXCEPTION") + " " +
          group.getGroupName());
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
   * @return group OPCGroup
   */
  public OPCGroup getDownloadGroup() {
    return getDownloadGroupNative();
  }

  public void run() {
  // TODO Auto-generated method stub
  }

}
