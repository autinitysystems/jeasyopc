package javafish.clients.opc.component;

import java.util.GregorianCalendar;

/**
 * OPC Item class
 */
public class OPCItem implements Cloneable {
  
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
  private GregorianCalendar timeStamp;
  
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
    clientHandle = -1; // not assigned
    this.itemName = itemName;
    this.active = active;
    this.accessPath = accessPath;
    this.dataType = dataType;
  }
  
  /**
   * Generate clientHandle by its owner
   * 
   * @param group OPCGroup
   */
  public void generateClientHandleByOwner(OPCGroup group) {
    clientHandle = group.getNewItemClientHandle();
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
   * Get quality of downloaded item
   * 
   * @return quality is OK, boolean
   */
  public boolean isQuality() {
    return itemQuality;
  }

  /**
   * Set quality of downloaded item
   * 
   * @param itemQuality boolean
   */
  public void setQuality(boolean itemQuality) {
    this.itemQuality = itemQuality;
  }

  /**
   * Get value (String)
   * 
   * @return value String
   */
  public String getValue() {
    return itemValue;
  }

  /**
   * Set value (String)
   * 
   * @param itemValue String
   */
  public void setValue(String itemValue) {
    this.itemValue = itemValue;
  }

  /**
   * Get time stamp of downloaded item
   * 
   * @return timeStamp GregorianCalendar
   */
  public GregorianCalendar getTimeStamp() {
    return timeStamp;
  }

  /**
   * Set time stamp of downloaded item
   * 
   * @param timeStamp GregorianCalendar
   */
  public void setTimeStamp(GregorianCalendar timeStamp) {
    this.timeStamp = timeStamp;
  }

  /**
   * Get access path of item
   * 
   * @return accessPath String
   */
  public String getAccessPath() {
    return accessPath;
  }

  /**
   * Get client handle of item
   * (unique key)
   * 
   * @return key int
   */
  public int getClientHandle() {
    return clientHandle;
  }

  /**
   * Get item type
   * 
   * @return type int
   */
  public int getDataType() {
    return dataType;
  }

  /**
   * Get item name
   * 
   * @return String
   */
  public String getItemName() {
    return itemName;
  }
  
  /**
   * Return clone of opc-item
   * 
   * @return item Object
   */
  public Object clone() {
    OPCItem item = null;
    try {
      item = (OPCItem) super.clone();
      // add attributes
      item.clientHandle = clientHandle;
      item.itemName = itemName;
      item.active = active;
      item.accessPath = accessPath;
      item.timeStamp = (timeStamp == null) ? null : (GregorianCalendar)timeStamp.clone();
      item.itemValue = itemValue;
      item.itemQuality = itemQuality;
      item.dataType = dataType;
    }
    catch (CloneNotSupportedException e) {
      System.err.println(e);
    }
    return item;
  }
  
  @Override
  public String toString() {
    StringBuffer sb = new StringBuffer();
    sb.append("(class = " + getClass().getName() + "; ");
    sb.append("clientHandle = " + clientHandle + "; ");
    sb.append("itemName = " + itemName + "; ");
    sb.append("active = " + active + "; ");
    sb.append("accessPath = " + accessPath + "; ");
    sb.append("timeStamp = " + (timeStamp == null ? "" : timeStamp.getTime()) + "; ");
    sb.append("itemValue = " + itemValue + "; ");
    sb.append("itemQuality = " + itemQuality + "; ");
    sb.append("dataType = " + dataType + ")");
    
    return sb.toString();
  }
  
}
