package javafish.clients.opc.component;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.LinkedHashMap;

import javafish.clients.opc.JOPC;
import javafish.clients.opc.exception.ItemExistsException;
import javafish.clients.opc.lang.Translate;

/**
 * OPC Group 
 */
public class OPCGroup implements Cloneable {
  /* ID of group (do not modify) */
  private int clientHandle;
  
  /* list of items */
  private LinkedHashMap<Integer, OPCItem> items;
  
  /* group name: must be unique */
  private String groupName;
  
  /* activity of group */
  private boolean active;
  
  /* update interval of group */
  private int updateRate;
  
  /* percent of dead band */
  private float percentDeadBand;
  
  /**
   * Create new instance of OPC Group
   * 
   * @param groupName String
   * @param active boolean
   * @param updateRate double
   * @param percentDeadBand float
   */
  public OPCGroup(String groupName, boolean active, int updateRate, float percentDeadBand) {
    items = new LinkedHashMap<Integer, OPCItem>();
    clientHandle = -1; // not assigned
    this.groupName = groupName;
    this.active = active;
    this.updateRate = updateRate;
    this.percentDeadBand = percentDeadBand;
  }
  
  /**
   * Generate clientHandle by its owner
   * 
   * @param opc JOPC
   */
  public void generateClientHandleByOwner(JOPC opc) {
    clientHandle = opc.getNewGroupClientHandle();
  }
  
  /**
   * Generate new clientHandle for its item
   * 
   * @return clientHandle int
   */
  public int getNewItemClientHandle() {
    return items.size();
  }
  
  /**
   * Test activity of group
   * 
   * @return is active, boolean
   */
  public boolean isActive() {
    return active;
  }

  /**
   * Set activity of group
   * 
   * @param active boolean
   */
  public void setActive(boolean active) {
    this.active = active;
  }

  /**
   * Get items as array list
   * 
   * @return items ArrayList
   */
  public ArrayList<OPCItem> getItems() {
    return new ArrayList<OPCItem>(items.values());
  }
  
  /**
   * Get items as array
   * 
   * @return items OPCItem[]
   */
  public OPCItem[] getItemsAsArray() {
    int i = 0;
    OPCItem[] aitems = new OPCItem[items.size()];
    for (Iterator iter = items.values().iterator(); iter.hasNext();) {
      aitems[i++] = (OPCItem)iter.next();
    }
    return aitems;
  }

  /**
   * Add item to group
   * <p>
   * <i>note:</i> throws ItemExistsException - runtime exception
   * 
   * @param item OPCItem
   */
  public void addItem(OPCItem item) {
    if (!items.containsKey(new Integer(item.getClientHandle()))) {
      item.generateClientHandleByOwner(this);
      items.put(new Integer(item.getClientHandle()), item);
    } else { // throw exception
      throw new ItemExistsException(Translate.getString("ITEM_EXISTS_EXCEPTION") + " " +
          item.getItemName());
    }
  }
  
  /**
   * Remove item from group
   * <p>
   * <i>note:</i> throws ItemExistsException - runtime exception
   * 
   * @param item OPCItem
   */
  public void removeItem(OPCItem item) {
    if (items.containsKey(new Integer(item.getClientHandle()))) {
      items.remove(new Integer(item.getClientHandle()));
    } else { // throw exception
      throw new ItemExistsException(Translate.getString("ITEM_NO_EXISTS_EXCEPTION") + " " +
          item.getItemName());
    }
  }

  /**
   * Get update rate of group
   * 
   * @return updateRatio [ms], int
   */
  public int getUpdateRate() {
    return updateRate;
  }

  /**
   * Set update rate of group
   * 
   * @param updateRate [ms], int
   */
  public void setUpdateRate(int updateRate) {
    this.updateRate = updateRate;
  }

  /**
   * Get clientHandle of group
   * (unique key)
   * 
   * @return key int
   */
  public int getClientHandle() {
    return clientHandle;
  }

  /**
   * Get group name
   * 
   * @return name String
   */
  public String getGroupName() {
    return groupName;
  }

  /**
   * Get percent dead band of group
   * 
   * @return band float
   */
  public float getPercentDeadBand() {
    return percentDeadBand;
  }
  
  /**
   * Get opc-item by its clientHandle
   * 
   * @param clientHandle int 
   * @return item OPCItem
   */
  public OPCItem getItemByClientHandle(int clientHandle) {
    return items.get(new Integer(clientHandle));
  }
  
  /**
   * Return clone of opc-group
   * 
   * @return group Object
   * @Override
   */
  public Object clone() {
    OPCGroup group = null;
    try {
      group = (OPCGroup) super.clone();
      // add attributes
      group.clientHandle = clientHandle;
      group.groupName = groupName;
      group.active = active;
      group.updateRate = updateRate;
      group.percentDeadBand = percentDeadBand;
      // clone items
      group.items = new LinkedHashMap<Integer, OPCItem>();
      for (Iterator iter = items.values().iterator(); iter.hasNext();) {
        OPCItem item = (OPCItem) iter.next();
        group.addItem((OPCItem)item.clone());
      }
    }
    catch (CloneNotSupportedException e) {
      System.err.println(e);
    }
    return group;
  }
  
  @Override
  public String toString() {
    StringBuffer sb = new StringBuffer();
    sb.append("(class = " + getClass().getName() + "; ");
    sb.append("clientHandle = " + clientHandle + "; ");
    sb.append("groupName = " + groupName + "; ");
    sb.append("active = " + active + "; ");
    sb.append("updateRate = " + updateRate + "; ");
    sb.append("percentDeadBand = " + percentDeadBand + "; ");
    sb.append("items => " + System.getProperty("line.separator"));
    // print items
    if (items.size() > 0) {
      for (Iterator iter = items.values().iterator(); iter.hasNext();) {
        sb.append(" => " + iter.next() + System.getProperty("line.separator"));
      }
    } else {
      sb.append(" => NO ITEMS" + System.getProperty("line.separator"));
    }
    
    return sb.toString();
  }

}
