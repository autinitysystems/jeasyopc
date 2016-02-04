package javafish.clients.opc.component;

import java.io.Serializable;
import java.util.GregorianCalendar;

import javafish.clients.opc.variant.Variant;

/**
 * OPC Item class
 */
public class OpcItem implements Cloneable, Serializable {
  private static final long serialVersionUID = -4300978347532315219L;
  
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
  private Variant itemValue;
  
  /* quality of item */
  private boolean itemQuality;
  
  /**
   * Create new instance of OPCItem
   * 
   * @param itemName String - specific Tag name of item
   * @param active boolean - begin activity of item
   * @param accessPath String - accessPath is the "how" for the server to get the
   * data specified by the itemName (ItemID, the what). The client uses this function
   * to identify the possible access paths for the specified ItemID (similary with namespaces).
   * Not all Opc Serves support these access paths.
   */
  public OpcItem(String itemName, boolean active, String accessPath) {
    clientHandle = -1; // not assigned
    timeStamp = new GregorianCalendar();
    itemValue = new Variant();
    this.itemName = itemName;
    this.active = active;
    this.accessPath = accessPath;
  }
  
  /**
   * Generate clientHandle by its owner.
   * <p>
   * It is internal method for generation of unique item ID.
   * 
   * @param group OpcGroup
   */
  public void generateClientHandleByOwner(OpcGroup group) {
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
   * Get activity of OpcItem
   * 
   * @return is active, boolean
   */
  public boolean isActive() {
    return active;
  }

  /**
   * Get quality of downloaded item.
   * <p>
   * The quality is very important flag. This flag has to be
   * checked, because you have to handle only correct values.
   * The item can have some values, but the quality has to be true. 
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
   * Get value (Variant)
   * 
   * @return value Variant
   */
  public Variant getValue() {
    return itemValue;
  }

  /**
   * Set value (Variant)
   * 
   * @param itemValue Variant
   */
  public void setValue(Variant itemValue) {
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
    return (itemValue != null)? itemValue.getVariantType() : Variant.VT_EMPTY;
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
    OpcItem item = null;
    try {
      item = (OpcItem) super.clone();
      // add attributes
      item.clientHandle = clientHandle;
      item.itemName = itemName;
      item.active = active;
      item.accessPath = accessPath;
      item.timeStamp = (timeStamp == null) ? null : (GregorianCalendar)timeStamp.clone();
      item.itemValue = (Variant)itemValue.clone();
      item.itemQuality = itemQuality;
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
    
    return sb.toString();
  }
  
}
