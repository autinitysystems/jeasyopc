package javafish.clients.opc.component;

import java.util.Date;

/**
 * OPC Item class
 *
 */
public class OPCItem {
  private static int generateHandle = 0;
  
  // ATTRIBUTES
  
  /* client handle ID (do not modify) */
  private int clientHandle;

  /* tag item */
  private String itemName;
  
  /* item activation */
  private boolean active;
  
  /* access path of item (package) */
  private String accessPath;
  
  /* time stamp of item */
  private Date timeStamp;
  
  /* value */
  private String itemValue;
  
  /* quality of item */
  private boolean itemQuality;
  
  /* opc data type of item */
  private int dataType;

  public boolean isActive() {
    return active;
  }
  
  /**
   * Create new instance of OPCItem
   * 
   * @param itemName String
   * @param active boolean
   * @param accessPath String
   * @param dataType int
   */
  public OPCItem(String itemName, boolean active, String accessPath, int dataType) {
    clientHandle = generateHandle();
    this.itemName = itemName;
    this.active = active;
    this.accessPath = accessPath;
    this.dataType = dataType;
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
  
  // GET and SET methods

  public void setActive(boolean active) {
    this.active = active;
  }

  public boolean isQuality() {
    return itemQuality;
  }

  public void setQuality(boolean itemQuality) {
    this.itemQuality = itemQuality;
  }

  public String getValue() {
    return itemValue;
  }

  public void setValue(String itemValue) {
    this.itemValue = itemValue;
  }

  public Date getTimeStamp() {
    return timeStamp;
  }

  public void setTimeStamp(Date timeStamp) {
    this.timeStamp = timeStamp;
  }

  public String getAccessPath() {
    return accessPath;
  }

  public int getClientHandle() {
    return clientHandle;
  }

  public int getDataType() {
    return dataType;
  }

  public String getItemName() {
    return itemName;
  }
  
}
