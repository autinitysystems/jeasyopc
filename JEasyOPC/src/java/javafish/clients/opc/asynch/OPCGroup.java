package javafish.clients.opc.asynch;

/**
 * Class OPC Group
 */
public class OPCGroup {
  protected String name;
  protected int itemCount;
  protected OPCItem[] items;

  public OPCGroup(String name, int itemCount, OPCItem[] items) {
    this.name = name;
    this.itemCount = itemCount;
    this.items = items;
  }

  @Override
  public String toString() {
    String text = "";
    for (int i = 0; i < itemCount; i++) {
      text = text + name + "." + items[i] + "\r\n";
    }
    return text;
  }

  public int getItemCount() {
    return itemCount;
  }

  public OPCItem[] getItems() {
    return items;
  }

  public String getName() {
    return name;
  }
  
}
