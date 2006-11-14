package javafish.clients.opc;

import javafish.clients.opc.component.OpcGroup;
import javafish.clients.opc.component.OpcItem;
import javafish.clients.opc.exception.CoInitializeException;
import javafish.clients.opc.exception.ConnectivityException;
import javafish.clients.opc.exception.CoUninitializeException;

public class CoInitializeComExample {
  
  public static void main(String[] args) throws InterruptedException {
    CoInitializeComExample test = new CoInitializeComExample();
    
    try {
      JOpc.coInitialize();
    }
    catch (CoInitializeException e1) {
      e1.printStackTrace();
    }
    
    JEasyOpc jopc = new JEasyOpc("localhost", "Matrikon.OPC.Simulation", "JOPC1");
    JEasyOpc jopc2 = new JEasyOpc("localhost", "Matrikon.OPC.Simulation", "JOPC1");
    
    OpcItem item1 = new OpcItem("Random.Real8", true, "");
    OpcItem item2 = new OpcItem("Random.Real8", true, "");
    
    OpcGroup group = new OpcGroup("group1", true, 2000, 0.0f);
    
    group.addItem(item1);
    group.addItem(item2);
    
    jopc.addGroup(group);
    
    try {
      jopc.connect();
      jopc2.connect();
      System.out.println("Connected....");
    }
    catch (ConnectivityException e) {
      e.printStackTrace();
    }
    
    synchronized(test) {
      test.wait(2000);
    }
    
    try {
      jopc.connect();
      System.out.println("Connected....");
    }
    catch (ConnectivityException e) {
      e.printStackTrace();
    }
    
    synchronized(test) {
      test.wait(2000);
    }
    
    try {
      JOpc.coUninitialize();
      System.out.println("Disconnected....");
    }
    catch (CoUninitializeException e) {
      e.printStackTrace();
    }
  }

}
