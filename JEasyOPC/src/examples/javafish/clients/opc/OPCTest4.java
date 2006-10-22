package javafish.clients.opc;

import javafish.clients.opc.component.OPCGroup;
import javafish.clients.opc.component.OPCItem;

public class OPCTest4 {
  
  public static void main(String[] args) {
    OPCGroup group1 = new OPCGroup("group-1", true, 500, 0.0f);
    OPCItem item1 = new OPCItem("item-1", true, "./path1", 0);
    OPCItem item2 = new OPCItem("item-2", true, "./path2", 0); 
    group1.addItem(item1);
    group1.addItem(item2);
    OPCGroup groupClone1 = (OPCGroup)group1.clone();
    
    System.out.println(groupClone1);
  }

}
