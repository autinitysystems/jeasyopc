package javafish.clients.opc;

import javafish.clients.opc.component.OPCGroup;
import javafish.clients.opc.component.OPCItem;
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

public class OPCTest7 {

  /**
   * @param args
   * @throws InterruptedException 
   */
  public static void main(String[] args) throws InterruptedException {
    OPCTest7 test = new OPCTest7();
    
    try {
      JOPC.coInitialize();
    }
    catch (CoInitializeException e1) {
      e1.printStackTrace();
    }
    
    JOPC jopc = new JOPC("localhost", "Matrikon.OPC.Simulation", "JOPC1");
    JEasyOPC jopc2 = new JEasyOPC("localhost", "Matrikon.OPC.Simulation", "JOPC2");
    
    OPCItem item1 = new OPCItem("Random.Real8", true, "", 0);
    OPCItem item2 = new OPCItem("Random.Real8", true, "", 0);
    OPCGroup group = new OPCGroup("group1", true, 1000, 0.0f);

    OPCItem item3 = new OPCItem("Random.Real8", true, "", 0);
    OPCItem item4 = new OPCItem("Random.Real8", true, "", 0);
    OPCGroup group2 = new OPCGroup("group2", true, 2500, 0.0f);
    
    group.addItem(item1);
    group.addItem(item2);
    
    group2.addItem(item3);
    group2.addItem(item4);
    
    jopc.addGroup(group);
    jopc2.addGroup(group2);
    
    try {
      jopc.connect();
      jopc2.connect();
      jopc.debug("OPC client is connected...");
      
      jopc.registerGroups();
      jopc2.registerGroups();
      jopc.debug("OPC groups are registered...");
      
      jopc.asynch10Read(group);
      jopc2.asynch20Read(group2);
      jopc.debug("OPC asynchronous reading is applied...");
      
      OPCGroup downGroup;
      OPCGroup downGroup2;
      
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
      jopc.debug("OPC asynchronous reading is unadvise...");
      
      JOPC.coUninitialize();
      jopc.debug("Program terminated...");
      
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
