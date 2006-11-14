package javafish.clients.opc;

import javafish.clients.opc.component.OpcGroup;
import javafish.clients.opc.component.OpcItem;

public class GroupCloneExample {
  
  public static void main(String[] args) {
    OpcGroup group1 = new OpcGroup("group-1", true, 500, 0.0f);
    OpcItem item1 = new OpcItem("item-1", true, "path1");
    OpcItem item2 = new OpcItem("item-2", true, "path2"); 
    group1.addItem(item1);
    group1.addItem(item2);
    OpcGroup groupClone1 = (OpcGroup)group1.clone();
    
    System.out.println(groupClone1);
  }

}
