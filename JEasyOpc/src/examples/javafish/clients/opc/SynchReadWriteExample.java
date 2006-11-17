package javafish.clients.opc;

import javafish.clients.opc.component.OpcGroup;
import javafish.clients.opc.component.OpcItem;
import javafish.clients.opc.exception.CoInitializeException;
import javafish.clients.opc.exception.CoUninitializeException;
import javafish.clients.opc.exception.ComponentNotFoundException;
import javafish.clients.opc.exception.ConnectivityException;
import javafish.clients.opc.exception.SynchReadException;
import javafish.clients.opc.exception.SynchWriteException;
import javafish.clients.opc.exception.UnableAddGroupException;
import javafish.clients.opc.exception.UnableAddItemException;
import javafish.clients.opc.exception.UnableRemoveGroupException;
import javafish.clients.opc.exception.UnableRemoveItemException;
import javafish.clients.opc.variant.Variant;
import javafish.clients.opc.variant.VariantList;

public class SynchReadWriteExample {

  /**
   * @param args
   * @throws InterruptedException 
   */
  public static void main(String[] args) throws InterruptedException {
    JOpc jopc = new JOpc("localhost", "Matrikon.OPC.Simulation", "JOPC1");
    
    try {
      JOpc.coInitialize();
    }
    catch (CoInitializeException e1) {
      e1.printStackTrace();
    }
    
    OpcItem item1 = new OpcItem("Random.Real8", true, "");
    //OpcItem item2 = new OpcItem("Bucket Brigade.Real4", true, "");
    OpcItem item2 = new OpcItem("Bucket Brigade.ArrayOfReal8", true, "");
    OpcGroup group = new OpcGroup("group1", true, 500, 0.0f);
    
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
      OpcItem itemRead = null;
      for (int i = 0; i < 2; i++) {
        Thread.sleep(2000);
        
        itemRead = jopc.synchReadItem(group, item1);
        System.out.println(itemRead);
      }
      
      // synchronous writing (example with array writing ;-)
      // prepare array
      VariantList list = new VariantList(Variant.VT_R8);
      list.add(new Variant(1.0));
      list.add(new Variant(2.0));
      list.add(new Variant(3.0));
      Variant varin = new Variant(list);
      System.out.println("Original Variant type: " +
          Variant.getVariantName(varin.getVariantType()) + ", " + varin);
      item2.setValue(varin);
      
      // write to opc-server
      jopc.synchWriteItem(group, item2);
      
      Thread.sleep(2000);
      
      // read item from opc-server
      itemRead = jopc.synchReadItem(group, item2);
      // show item and its variant type
      System.out.println("WRITE ITEM IS: " + itemRead);
      System.out.println("VALUE TYPE: " + Variant.getVariantName(itemRead.getDataType()));
      
      jopc.unregisterItem(group, item1);
      
      System.out.println("Item was unregistred...");
      jopc.unregisterGroup(group);
      
      System.out.println("Group was unregistred...");
      
      JOpc.coUninitialize();
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
    catch (CoUninitializeException e) {
      e.printStackTrace();
    }
  }

}
