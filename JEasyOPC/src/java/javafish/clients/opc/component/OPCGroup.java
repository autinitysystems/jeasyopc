package javafish.clients.opc.component;

import java.util.ArrayList;
import java.util.LinkedHashMap;

/**
 * OPC Group 
 */
public class OPCGroup {
  private static int generateHandle = 0;
  
  /* ID of group (do not modify) */
  private int clientHandle;
  
  /* list of items */
  private LinkedHashMap<Integer, OPCItem> items;
  
  /* group name: must be unique */
  private String groupName;
  
  /* activity of group */
  private boolean active;
  
  /* update interval of group */
  private double updateRate;
  
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
  public OPCGroup(String groupName, boolean active, double updateRate, float percentDeadBand) {
    items = new LinkedHashMap<Integer, OPCItem>();
    clientHandle = generateHandle();    
    this.groupName = groupName;
    this.active = active;
    this.updateRate = updateRate;
    this.percentDeadBand = percentDeadBand;
  }
  
  /**
   * Generate client handle identification.
   * Must be unique.
   * 
   * @return int
   */
  private static int generateHandle() {
    return generateHandle++;
  }

  public boolean isActive() {
    return active;
  }

  public void setActive(boolean active) {
    this.active = active;
  }

  public ArrayList<OPCItem> getItems() {
    return new ArrayList<OPCItem>(items.values());
  }
  
  public OPCItem[] getItemsAsArray() {
    OPCItem[] aitems = new OPCItem[items.size()];
    for (int i = 0; i < aitems.length; i++) {
      aitems[i] = items.get(i);
    }
    return aitems;
  }

  public void addItem(OPCItem item) {
    items.put(new Integer(item.getClientHandle()), item);
  }
  
  public void removeItem(OPCItem item) {
    items.remove(new Integer(item.getClientHandle()));
  }

  public double getUpdateRate() {
    return updateRate;
  }

  public void setUpdateRate(double updateRate) {
    this.updateRate = updateRate;
  }

  public int getClientHandle() {
    return clientHandle;
  }

  public String getGroupName() {
    return groupName;
  }

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

}
