package javafish.clients.opc;

import javafish.clients.opc.component.OpcGroup;
import javafish.clients.opc.component.OpcItem;
import javafish.clients.opc.exception.CoInitializeException;
import javafish.clients.opc.exception.CoUninitializeException;
import javafish.clients.opc.exception.ConnectivityException;

public class TryOpcConnection2Example {

  /**
   * @param args
   */
  public static void main(String[] args) {
    try {
      JOpc.coInitialize();
    }
    catch (CoInitializeException e1) {
      e1.printStackTrace();
    }
    
    JOpc jopc = new JOpc("localhost", "Matrikon.OPC.Simulation", "JOPC1");
    
    OpcItem item1 = new OpcItem("Random.Real8", true, "");
    OpcGroup group = new OpcGroup("group1", false, 500, 0.0f);
    
    group.addItem(item1);
    
    jopc.addGroup(group);
    
    try {
      jopc.connect();
      // jopc.registerGroups();
      System.out.println("Connected...");
    }
    catch (ConnectivityException e) {
      e.printStackTrace();
    }
    
    try {
      JOpc.coUninitialize();
    }
    catch (CoUninitializeException e) {
      e.printStackTrace();
    }
    System.out.println("Test terminated...");
  }

}
