package javafish.clients.opc;

import javafish.clients.opc.asynch.AsynchEvent;
import javafish.clients.opc.component.OpcGroup;
import javafish.clients.opc.component.OpcItem;
import javafish.clients.opc.exception.CoInitializeException;
import javafish.clients.opc.exception.CoUninitializeException;
import javafish.clients.opc.exception.ComponentNotFoundException;
import javafish.clients.opc.exception.GroupActivityException;
import javafish.clients.opc.exception.GroupUpdateTimeException;
import javafish.clients.opc.exception.ItemActivityException;

public class TwoJEasyOpcExample {

  public static void main(String[] args) throws InterruptedException {
    JEasyOpcExample test = new JEasyOpcExample();
    
    try {
      JOpc.coInitialize();
    }
    catch (CoInitializeException e1) {
      e1.printStackTrace();
    }
    
    JEasyOpc jopc1 = new JEasyOpc("localhost", "Matrikon.OPC.Simulation", "JOPC1");
    JEasyOpc jopc2 = new JEasyOpc("localhost", "Matrikon.OPC.Simulation", "JOPC2");
    
    OpcItem item1 = new OpcItem("Random.Real8", true, "");
    OpcItem item2 = new OpcItem("Random.Real8", true, "");
    OpcItem item3 = new OpcItem("Random.Real8", true, "");
    OpcItem item4 = new OpcItem("Random.Real8", true, "");
    
    OpcItem item5 = new OpcItem("Random.Real8", true, "");
    OpcItem item6 = new OpcItem("Random.Real8", true, "");
    OpcItem item7 = new OpcItem("Random.Real8", true, "");
    OpcItem item8 = new OpcItem("Random.Real8", true, "");
    
    OpcGroup group1 = new OpcGroup("group1", true, 2000, 0.0f);
    OpcGroup group2 = new OpcGroup("group2", true, 2000, 0.0f);
    
    group1.addItem(item1);
    group1.addItem(item2);
    group1.addItem(item3);
    group1.addItem(item4);
    
    group2.addItem(item5);
    group2.addItem(item6);
    group2.addItem(item7);
    group2.addItem(item8);
    
    group1.addAsynchListener(test);
    group2.addAsynchListener(test);
    
    jopc1.addGroup(group1);
    jopc2.addGroup(group2);
    
    jopc1.start();
    jopc2.start();
    
    synchronized(test) {
      test.wait(3000);
    }
    
    System.out.println("JOPC1 active: " + jopc1.ping());
    
    synchronized(test) {
      test.wait(8000);
    }
    
    try {
      jopc1.setGroupActivity(group1, false);
    }
    catch (GroupActivityException e) {
      e.printStackTrace();
    }
    catch (ComponentNotFoundException e) {
      e.printStackTrace();
    }
    
    synchronized(test) {
      test.wait(4000);
    }
    
    try {
      jopc1.setGroupActivity(group1, true);
    }
    catch (GroupActivityException e) {
      e.printStackTrace();
    }
    catch (ComponentNotFoundException e) {
      e.printStackTrace();
    }

    synchronized(test) {
      test.wait(4000);
    }
    
    try {
      jopc1.setGroupUpdateTime(group1, 100);
    }
    catch (GroupUpdateTimeException e) {
      e.printStackTrace();
    }
    catch (ComponentNotFoundException e) {
      e.printStackTrace();
    }
    
    try {
      jopc2.setItemActivity(group2, item8, false);
    }
    catch (ComponentNotFoundException e1) {
      e1.printStackTrace();
    }
    catch (ItemActivityException e1) {
      e1.printStackTrace();
    }
    
    synchronized(test) {
      test.wait(8000);
    }
    
    jopc1.terminate();
    jopc2.terminate();

    synchronized(test) {
      test.wait(2000);
    }
    
    try {
      JOpc.coUninitialize();
    }
    catch (CoUninitializeException e) {
      e.printStackTrace();
    }
  }

  public void getAsynchEvent(AsynchEvent event) {
    System.out.println(((JCustomOpc)event.getSource()).getFullOpcServerName() + "=>");
    System.out.println("Client: " + ((JCustomOpc)event.getSource()).getServerClientHandle());
    System.out.println("Package: " + event.getID());
    System.out.println(event.getOPCGroup());
  }  
  
}
