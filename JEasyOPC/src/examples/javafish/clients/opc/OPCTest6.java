package javafish.clients.opc;

import javafish.clients.opc.component.OPCGroup;
import javafish.clients.opc.component.OPCItem;
import javafish.clients.opc.exception.Asynch10ReadException;
import javafish.clients.opc.exception.Asynch10UnadviseException;
import javafish.clients.opc.exception.ComponentNotFoundException;
import javafish.clients.opc.exception.ConnectivityException;
import javafish.clients.opc.exception.UnableAddGroupException;
import javafish.clients.opc.exception.UnableAddItemException;

public class OPCTest6 {

  /**
   * @param args
   * @throws InterruptedException 
   */
  public static void main(String[] args) throws InterruptedException {
    OPCTest6 test = new OPCTest6();
    
    JOPC jopc = new JOPC("localhost", "Matrikon.OPC.Simulation", "JOPC1");
    
    OPCItem item1 = new OPCItem("Random.Real8", true, "", 0);
    OPCItem item2 = new OPCItem("Random.Real8", true, "", 0);
    OPCGroup group = new OPCGroup("group1", true, 2000, 0.0f);
    
    group.addItem(item1);
    group.addItem(item2);
    
    jopc.addGroup(group);
    
    try {
      jopc.connect();
      System.out.println("OPC client is connected...");
      
      jopc.registerGroups();
      System.out.println("OPC groups are registered...");
      
      jopc.asynch10Read(group);
      System.out.println("OPC asynchronous reading is applied...");
      
      OPCGroup downGroup;
      
      long start = System.currentTimeMillis();
      while ((System.currentTimeMillis() - start) < 10000) {
        jopc.ping();
        downGroup = jopc.getDownloadGroup();
        if (downGroup != null) {
          System.out.println(downGroup);
        } else {
          //System.out.println("Nothing...");
        }
        
        synchronized(test) {
          test.wait(50);       
        }
      }
      
      jopc.asynch10Unadvise(group);
      System.out.println("OPC asynchronous reading is unadvise...");
      
      jopc.disconnect();
      System.out.println("Program terminated...");
      
      System.out.println("");
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
  }

}
