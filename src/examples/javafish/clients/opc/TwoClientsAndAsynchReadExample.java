package javafish.clients.opc;

import javafish.clients.opc.component.OpcGroup;
import javafish.clients.opc.component.OpcItem;
import javafish.clients.opc.exception.Asynch10ReadException;
import javafish.clients.opc.exception.Asynch10UnadviseException;
import javafish.clients.opc.exception.Asynch20ReadException;
import javafish.clients.opc.exception.Asynch20UnadviseException;
import javafish.clients.opc.exception.CoInitializeException;
import javafish.clients.opc.exception.ComponentNotFoundException;
import javafish.clients.opc.exception.ConnectivityException;
import javafish.clients.opc.exception.CoUninitializeException;
import javafish.clients.opc.exception.UnableAddGroupException;
import javafish.clients.opc.exception.UnableAddItemException;

public class TwoClientsAndAsynchReadExample {

  /**
   * @param args
   * @throws InterruptedException 
   */
  public static void main(String[] args) throws InterruptedException {
    TwoClientsAndAsynchReadExample test = new TwoClientsAndAsynchReadExample();
    
    try {
      JOpc.coInitialize();
    }
    catch (CoInitializeException e1) {
      e1.printStackTrace();
    }
    
    JOpc jopc = new JOpc("localhost", "Matrikon.OPC.Simulation", "JOPC1");
    JEasyOpc jopc2 = new JEasyOpc("localhost", "Matrikon.OPC.Simulation", "JOPC2");
    
    OpcItem item1 = new OpcItem("Random.Real8", true, "");
    OpcItem item2 = new OpcItem("Random.Real8", true, "");
    OpcGroup group = new OpcGroup("group1", true, 1000, 0.0f);

    OpcItem item3 = new OpcItem("Random.Real8", true, "");
    OpcItem item4 = new OpcItem("Random.Real8", true, "");
    OpcGroup group2 = new OpcGroup("group2", true, 2500, 0.0f);
    
    group.addItem(item1);
    group.addItem(item2);
    
    group2.addItem(item3);
    group2.addItem(item4);
    
    jopc.addGroup(group);
    jopc2.addGroup(group2);
    
    try {
      jopc.connect();
      jopc2.connect();
      System.out.println("OPC client is connected...");
      
      jopc.registerGroups();
      jopc2.registerGroups();
      System.out.println("OPC groups are registered...");
      
      jopc.asynch10Read(group);
      jopc2.asynch20Read(group2);
      System.out.println("OPC asynchronous reading is applied...");
      
      OpcGroup downGroup;
      OpcGroup downGroup2;
      
      long start = System.currentTimeMillis();
      while ((System.currentTimeMillis() - start) < 30000) {
        jopc.ping();
        jopc2.ping();
        
        downGroup = jopc.getDownloadGroup();
        if (downGroup != null) {
          System.out.println(downGroup);
        }
        
        downGroup2 = jopc2.getDownloadGroup();
        if (downGroup2 != null) {
          System.out.println(downGroup2);
        }
        
        synchronized(test) {
          test.wait(50);       
        }
      }
      
      jopc.asynch10Unadvise(group);
      jopc2.asynch20Unadvise(group2);
      System.out.println("OPC asynchronous reading is unadvise...");
      
      JOpc.coUninitialize();
      System.out.println("Program terminated...");
      
    }
    catch (ConnectivityException e) {
      e.printStackTrace();
    }
    catch (UnableAddGroupException e) {
      e.printStackTrace();
    }
    catch (UnableAddItemException e) {
      e.printStackTrace();
    }
    catch (ComponentNotFoundException e) {
      e.printStackTrace();
    }
    catch (Asynch10ReadException e) {
      e.printStackTrace();
    }
    catch (Asynch10UnadviseException e) {
      e.printStackTrace();
    }
    catch (Asynch20ReadException e) {
      e.printStackTrace();
    }
    catch (Asynch20UnadviseException e) {
      e.printStackTrace();
    }
    catch (CoUninitializeException e) {
      e.printStackTrace();
    }
  }

}
