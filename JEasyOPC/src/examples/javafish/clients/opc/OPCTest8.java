package javafish.clients.opc;

import javafish.clients.opc.asynch.AsynchEvent;
import javafish.clients.opc.asynch.OPCAsynchGroupListener;
import javafish.clients.opc.component.OPCGroup;
import javafish.clients.opc.component.OPCItem;

public class OPCTest8 implements OPCAsynchGroupListener {
  
  public static void main(String[] args) throws InterruptedException {
    OPCTest8 test = new OPCTest8();
    
    JEasyOPC jopc = new JEasyOPC("localhost", "Matrikon.OPC.Simulation", "JOPC1");
    
    OPCItem item1 = new OPCItem("Random.Real8", true, "", 0);
    OPCItem item2 = new OPCItem("Random.Real8", true, "", 0);
    OPCGroup group = new OPCGroup("group1", true, 2000, 0.0f);
    
    group.addItem(item1);
    group.addItem(item2);
    
    jopc.addGroup(group);
    
    jopc.addAsynchGroupListener(test);
    
    jopc.start();
    
    synchronized(test) {
      test.wait(30000);
    }
    
    jopc.terminate();
  }

  public void getAsynchEvent(AsynchEvent event) {
    System.out.println(event.getOPCGroup());
  }

}
