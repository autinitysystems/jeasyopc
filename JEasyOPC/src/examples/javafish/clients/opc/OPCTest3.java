package javafish.clients.opc;

import javafish.clients.opc.component.OPCGroup;
import javafish.clients.opc.component.OPCItem;
import javafish.clients.opc.exception.ConnectivityException;

public class OPCTest3 {

  /**
   * @param args
   */
  public static void main(String[] args) {
    JOPC jopc = new JOPC("localhost", "Matrikon.OPC.Simulation", "JOPC1");
    
    OPCItem item1 = new OPCItem("Random.Real8", true, "", 0);
    OPCGroup group = new OPCGroup("group1", false, 500, 0.0f);
    
    group.addItem(item1);
    
    jopc.addGroup(group);
    
    try {
      jopc.connect();
      // jopc.registerGroups();
    }
    catch (ConnectivityException e) {
      e.printStackTrace();
    }

    System.out.println("Test terminated...");
  }

}
