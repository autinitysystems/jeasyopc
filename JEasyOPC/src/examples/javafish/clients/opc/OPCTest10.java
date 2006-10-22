package javafish.clients.opc;

import javafish.clients.opc.component.OPCGroup;
import javafish.clients.opc.component.OPCItem;
import javafish.clients.opc.exception.CoInitializeException;
import javafish.clients.opc.exception.CoUninitializeException;
import javafish.clients.opc.exception.ComponentNotFoundException;
import javafish.clients.opc.exception.ConnectivityException;
import javafish.clients.opc.exception.SynchReadException;
import javafish.clients.opc.exception.UnableAddGroupException;
import javafish.clients.opc.exception.UnableAddItemException;

public class OPCTest10 {
  public static void main(String[] args) throws InterruptedException {
    OPCTest10 test = new OPCTest10();
    
    try {
      JOPC.coInitialize();
    }
    catch (CoInitializeException e1) {
      e1.printStackTrace();
    }
    
    JOPC jopc = new JOPC("localhost", "Matrikon.OPC.Simulation", "JOPC1");
    
    OPCItem item1 = new OPCItem("Random.Real8", true, "", 0);
    OPCItem item2 = new OPCItem("Random.Real8", true, "", 0);
    OPCItem item3 = new OPCItem("Random.Real8", true, "", 0);
    
    OPCGroup group = new OPCGroup("group1", true, 10, 0.0f);
    
    group.addItem(item1);
    group.addItem(item2);
    group.addItem(item3);
    
    jopc.addGroup(group);
    
    try {
      jopc.connect();
      System.out.println("JOPC client is connected...");
    }
    catch (ConnectivityException e2) {
      e2.printStackTrace();
    }
    
    try {
      jopc.registerGroups();
      System.out.println("OPCGroup are registered...");
    }
    catch (UnableAddGroupException e2) {
      e2.printStackTrace();
    }
    catch (UnableAddItemException e2) {
      e2.printStackTrace();
    }
    
    synchronized(test) {
      test.wait(2000);
    }
    
    // Synchronous reading of group
    int cycles = 100;
    int acycle = 0;
    while (acycle++ < cycles) {
      synchronized(test) {
        test.wait(50);
      }
      
      try {
        OPCGroup responseGroup = jopc.synchReadGroup(group);
        System.out.println(responseGroup);
      }
      catch (ComponentNotFoundException e1) {
        e1.printStackTrace();
      }
      catch (SynchReadException e1) {
        e1.printStackTrace();
      }
    }
    
    try {
      JOPC.coUninitialize();
    }
    catch (CoUninitializeException e) {
      e.printStackTrace();
    }
  }
}
