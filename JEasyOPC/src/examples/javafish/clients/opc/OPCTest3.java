package javafish.clients.opc;

import javafish.clients.opc.component.OPCGroup;
import javafish.clients.opc.component.OPCItem;

public class OPCTest3 {

  /**
   * @param args
   */
  public static void main(String[] args) {
    JOPC jopc = new JOPC("localhost", "Matrikon.OPC.Simulation", "JOPC1");
    OPCItem item1 = new OPCItem("Saw1", true, "", 0);
    OPCItem item2 = new OPCItem("Saw2", true, "", 0);
    OPCGroup group = new OPCGroup("group1", true, 500.0, 0.0f);
    OPCGroup group2 = new OPCGroup("group2", true, 1000.0, 0.0f);
    group.addItem(item1);
    group.addItem(item2);
    group2.addItem(item1);
    
    jopc.addGroup(group);
    //jopc.addGroup(group2);
    
    System.out.println("Test terminated...");
  }

}
