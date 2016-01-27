package javafish.clients.opc;

import javafish.clients.opc.component.OpcGroup;
import javafish.clients.opc.component.OpcItem;
import javafish.clients.opc.exception.CoInitializeException;
import javafish.clients.opc.exception.CoUninitializeException;
import javafish.clients.opc.exception.ComponentNotFoundException;
import javafish.clients.opc.exception.ConnectivityException;
import javafish.clients.opc.exception.SynchReadException;
import javafish.clients.opc.exception.UnableAddGroupException;
import javafish.clients.opc.exception.UnableAddItemException;
import javafish.clients.opc.variant.Variant;

public class EmptyValueExample {
  
  public static void main(String[] args) throws InterruptedException {
    EmptyValueExample test = new EmptyValueExample();
    
    try {
      JOpc.coInitialize();
    }
    catch (CoInitializeException e1) {
      e1.printStackTrace();
    }
    
    JOpc jopc = new JOpc("localhost", "Matrikon.OPC.Simulation", "JOPC1");
    
    OpcItem item1 = new OpcItem("Random.ArrayOfReal8", true, "");
    /*
    // try all types, you can see appropriate Variant type and output
    item1 = new OpcItem("Random.ArrayOfString", true, "");
    item1 = new OpcItem("Random.Boolean", true, "");
    item1 = new OpcItem("Random.Int1", true, "");
    item1 = new OpcItem("Random.Int2", true, "");
    item1 = new OpcItem("Random.Int4", true, "");
    item1 = new OpcItem("Random.Money", true, "");
    item1 = new OpcItem("Random.Qualities", true, "");
    item1 = new OpcItem("Random.Real4", true, "");
    item1 = new OpcItem("Random.Real8", true, "");
    item1 = new OpcItem("Random.String", true, "");
    item1 = new OpcItem("Random.Time", true, "");
    item1 = new OpcItem("Random.UInt1", true, "");
    item1 = new OpcItem("Random.UInt2", true, "");
    item1 = new OpcItem("Random.UInt4", true, "");
    */
    
    OpcGroup group = new OpcGroup("group1", true, 10, 0.0f);
    
    group.addItem(item1);
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
    
    // not waiting for registration
    
    try {
      OpcItem responseItem = jopc.synchReadItem(group, item1);
      System.out.println(responseItem);
      System.out.println(!responseItem.isQuality()? "Quality: BAD!!!" : "Quality: GOOD");
      // processing
      if (!responseItem.isQuality()) {
        System.out.println("This next processing is WRONG!!! You haven't quality!!!");
      }
      System.out.println("Processing: Data type: " + Variant.getVariantName(responseItem.getDataType()) + 
          " Value: " + responseItem.getValue());
      
      synchronized(test) {
        test.wait(2000);
      }
      
      // read again
      responseItem = jopc.synchReadItem(group, item1);
      System.out.println(responseItem);
      System.out.println(!responseItem.isQuality()? "Quality: BAD!!!" : "Quality: GOOD");
      // processing
      if (!responseItem.isQuality()) {
        System.out.println("This next processing is WRONG!!! You haven't quality!!!");
      }
      System.out.println("Processing: Data type: " + Variant.getVariantName(responseItem.getDataType()) + 
          " Value: " + responseItem.getValue());
    }
    catch (ComponentNotFoundException e1) {
      e1.printStackTrace();
    }
    catch (SynchReadException e1) {
      e1.printStackTrace();
    }
    
    try {
      JOpc.coUninitialize();
    }
    catch (CoUninitializeException e) {
      e.printStackTrace();
    }
  }

}
