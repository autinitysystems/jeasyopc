package javafish.clients.opc.component;

import java.util.ArrayList;

/**
 * OPC Group 
 */
public class OPCGroup {
  private static int generateHandle = 0;
  
  /* ID of group (do not modify) */
  private int clientHandle;
  
  /* list of items */
  private ArrayList<OPCItem> items;
  
  /* group name: must be unique */
  private String groupName;
  
  /* activity of group */
  private boolean active;
  
  /* update interval of group */
  private double updateRate;
  
  /* percent of dead band */
  private float percentDeadBand;
  
  public OPCGroup() {
    items = new ArrayList<OPCItem>();
    clientHandle = generateHandle();    
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
    return items;
  }

  public void setItems(ArrayList<OPCItem> items) {
    this.items = items;
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
  
  

}
