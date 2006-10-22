package javafish.clients.opc;

import javafish.clients.opc.component.OPCGroup;
import javafish.clients.opc.component.OPCItem;
import javafish.clients.opc.exception.CoInitializeException;
import javafish.clients.opc.exception.ConnectivityException;
import javafish.clients.opc.exception.CoUninitializeException;

public class OPCTest9 {
  
  public static void main(String[] args) throws InterruptedException {
    OPCTest9 test = new OPCTest9();
    
    try {
      JOPC.coInitialize();
    }
    catch (CoInitializeException e1) {
      e1.printStackTrace();
    }
    
    JEasyOPC jopc = new JEasyOPC("localhost", "Matrikon.OPC.Simulation", "JOPC1");
    JEasyOPC jopc2 = new JEasyOPC("localhost", "Matrikon.OPC.Simulation", "JOPC1");
    
    OPCItem item1 = new OPCItem("Random.Real8", true, "", 0);
    OPCItem item2 = new OPCItem("Random.Real8", true, "", 0);
    
    OPCGroup group = new OPCGroup("group1", true, 2000, 0.0f);
    
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
      JOPC.coUninitialize();
      System.out.println("Disconnected....");
    }
    catch (CoUninitializeException e) {
      e.printStackTrace();
    }
  }

}
