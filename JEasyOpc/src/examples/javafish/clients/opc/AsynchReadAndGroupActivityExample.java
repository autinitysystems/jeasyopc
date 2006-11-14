package javafish.clients.opc;

import javafish.clients.opc.component.OpcGroup;
import javafish.clients.opc.component.OpcItem;
import javafish.clients.opc.exception.Asynch10ReadException;
import javafish.clients.opc.exception.Asynch10UnadviseException;
import javafish.clients.opc.exception.CoInitializeException;
import javafish.clients.opc.exception.ComponentNotFoundException;
import javafish.clients.opc.exception.ConnectivityException;
import javafish.clients.opc.exception.CoUninitializeException;
import javafish.clients.opc.exception.GroupActivityException;
import javafish.clients.opc.exception.GroupUpdateTimeException;
import javafish.clients.opc.exception.UnableAddGroupException;
import javafish.clients.opc.exception.UnableAddItemException;

public class AsynchReadAndGroupActivityExample {

  /**
   * @param args
   * @throws InterruptedException 
   */
  public static void main(String[] args) throws InterruptedException {
    AsynchReadAndGroupActivityExample test = new AsynchReadAndGroupActivityExample();
    
    try {
      JOpc.coInitialize();
    }
    catch (CoInitializeException e1) {
      e1.printStackTrace();
    }
    
    JOpc jopc = new JOpc("localhost", "Matrikon.OPC.Simulation", "JOPC1");
    
    OpcItem item1 = new OpcItem("Random.Real8", true, "");
    OpcItem item2 = new OpcItem("Random.Real8", true, "");
    OpcGroup group = new OpcGroup("group1", true, 2000, 0.0f);
    
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
      
      OpcGroup downGroup;
      
      long start = System.currentTimeMillis();
      while ((System.currentTimeMillis() - start) < 10000) {
        jopc.ping();
        downGroup = jopc.getDownloadGroup();
        if (downGroup != null) {
          System.out.println(downGroup);
        }
        
        if ((System.currentTimeMillis() - start) >= 6000) {
          jopc.setGroupActivity(group, false);
        }
        
        synchronized(test) {
          test.wait(50);       
        }
      }
      
      // change activity
      jopc.setGroupActivity(group, true);
      
      // change updateTime
      jopc.setGroupUpdateTime(group, 100);
      
      start = System.currentTimeMillis();
      while ((System.currentTimeMillis() - start) < 10000) {
        jopc.ping();
        downGroup = jopc.getDownloadGroup();
        if (downGroup != null) {
          System.out.println(downGroup);
        }
        
        synchronized(test) {
          test.wait(50);       
        }
      }
      
      jopc.asynch10Unadvise(group);
      System.out.println("OPC asynchronous reading is unadvise...");
      
      JOpc.coUninitialize();
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
    catch (GroupUpdateTimeException e) {
      e.printStackTrace();
    }
    catch (GroupActivityException e) {
      e.printStackTrace();
    }
    catch (CoUninitializeException e) {
      e.printStackTrace();
    }
  }

}
