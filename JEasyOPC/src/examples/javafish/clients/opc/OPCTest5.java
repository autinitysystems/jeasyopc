package javafish.clients.opc;

import javafish.clients.opc.component.OPCGroup;
import javafish.clients.opc.component.OPCItem;
import javafish.clients.opc.exception.ComponentNotFoundException;
import javafish.clients.opc.exception.ConnectivityException;
import javafish.clients.opc.exception.SynchReadException;
import javafish.clients.opc.exception.SynchWriteException;
import javafish.clients.opc.exception.UnableAddGroupException;
import javafish.clients.opc.exception.UnableAddItemException;
import javafish.clients.opc.exception.UnableRemoveGroupException;
import javafish.clients.opc.exception.UnableRemoveItemException;

public class OPCTest5 {

  /**
   * @param args
   * @throws InterruptedException 
   */
  public static void main(String[] args) throws InterruptedException {
    JOPC jopc = new JOPC("localhost", "Matrikon.OPC.Simulation", "JOPC1");
    
    OPCItem item1 = new OPCItem("Random.Real8", true, "", 0);
    OPCItem item2 = new OPCItem("Bucket Brigade.Real4", true, "", 0);
    OPCGroup group = new OPCGroup("group1", true, 500, 0.0f);
    
    group.addItem(item1);
    group.addItem(item2);
    
    try {
      jopc.connect();
      System.out.println("OPC is connected...");
      jopc.addGroup(group);
      
      jopc.registerGroup(group);
      System.out.println("Group was registred...");
      jopc.registerItem(group, item1);
      System.out.println("Item was registred...");
      jopc.registerItem(group, item2);
      System.out.println("Item was registred...");
      
      // synchronous reading
      OPCItem itemRead = null;
      for (int i = 0; i < 2; i++) {
        Thread.sleep(2000);
        
        itemRead = jopc.synchReadItem(group, item1);
        System.out.println(itemRead);
      }
      
      // synchronous writing
      item2.setValue("101");
      jopc.synchWriteItem(group, item2);
      
      Thread.sleep(2000);
      
      itemRead = jopc.synchReadItem(group, item2);
      System.out.println("WRITE ITEM IS: " + itemRead);
      
      jopc.unregisterItem(group, item1);
      
      System.out.println("Item was unregistred...");
      jopc.unregisterGroup(group);
      
      System.out.println("Group was unregistred...");
      
      jopc.disconnect();
      System.out.println("OPC is disconnected...");
    }
    catch (ConnectivityException e) {
      e.printStackTrace();
    }
    catch (ComponentNotFoundException e) {
      e.printStackTrace();
    }
    catch (UnableAddGroupException e) {
      e.printStackTrace();
    }
    catch (UnableAddItemException e) {
      e.printStackTrace();
    }
    catch (UnableRemoveGroupException e) {
      e.printStackTrace();
    }
    catch (UnableRemoveItemException e) {
      e.printStackTrace();
    }
    catch (SynchReadException e) {
      e.printStackTrace();
    }
    catch (SynchWriteException e) {
      e.printStackTrace();
    }
  }

}
