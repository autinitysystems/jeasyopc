package javafish.clients.opc;

import javafish.clients.opc.asynch.AsynchEvent;
import javafish.clients.opc.asynch.OPCAsynchGroupListener;
import javafish.clients.opc.component.OPCGroup;
import javafish.clients.opc.component.OPCItem;
import javafish.clients.opc.exception.CoInitializeException;
import javafish.clients.opc.exception.CoUninitializeException;
import javafish.clients.opc.exception.GroupActivityException;
import javafish.clients.opc.exception.GroupUpdateTimeException;

public class OPCTest8 implements OPCAsynchGroupListener {
  
  public static void main(String[] args) throws InterruptedException {
    OPCTest8 test = new OPCTest8();
    
    try {
      JOPC.coInitialize();
    }
    catch (CoInitializeException e1) {
      e1.printStackTrace();
    }
    
    JEasyOPC jopc = new JEasyOPC("localhost", "Matrikon.OPC.Simulation", "JOPC1");
    
    OPCItem item1 = new OPCItem("Random.Real8", true, "", 0);
    OPCItem item2 = new OPCItem("Random.Real8", true, "", 0);
    OPCItem item3 = new OPCItem("Random.Real8", true, "", 0);
    OPCItem item4 = new OPCItem("Random.Real8", true, "", 0);
    OPCItem item5 = new OPCItem("Random.Real8", true, "", 0);
    OPCItem item6 = new OPCItem("Random.Real8", true, "", 0);
    OPCItem item7 = new OPCItem("Random.Real8", true, "", 0);
    OPCItem item8 = new OPCItem("Random.Real8", true, "", 0);
    
    OPCGroup group = new OPCGroup("group1", true, 2000, 0.0f);
    
    group.addItem(item1);
    group.addItem(item2);
    group.addItem(item3);
    group.addItem(item4);
    group.addItem(item5);
    group.addItem(item6);
    group.addItem(item7);
    group.addItem(item8);
    
    jopc.addGroup(group);
    
    jopc.addAsynchGroupListener(test);
    
    jopc.start();
    
    synchronized(test) {
      test.wait(3000);
    }
    
    System.out.println("JOPC active: " + jopc.ping());
    
    synchronized(test) {
      test.wait(8000);
    }
    
    try {
      jopc.setGroupActivity(group, false);
    }
    catch (GroupActivityException e) {
      e.printStackTrace();
    }
    
    synchronized(test) {
      test.wait(4000);
    }
    
    try {
      jopc.setGroupActivity(group, true);
    }
    catch (GroupActivityException e) {
      e.printStackTrace();
    }

    synchronized(test) {
      test.wait(4000);
    }
    
    try {
      jopc.setGroupUpdateTime(group, 100);
    }
    catch (GroupUpdateTimeException e) {
      // TODO Auto-generated catch block
      e.printStackTrace();
    }
    
    synchronized(test) {
      test.wait(8000);
    }
    
    jopc.terminate();

    synchronized(test) {
      test.wait(2000);
    }
    
    try {
      JOPC.coUninitialize();
    }
    catch (CoUninitializeException e) {
      e.printStackTrace();
    }
  }

  public void getAsynchEvent(AsynchEvent event) {
    System.out.println(((JCustomOPC)event.getSource()).getFullOPCServerName() + "=>");
    System.out.println("Package: " + event.getID());
    System.out.println(event.getOPCGroup());
  }

}
