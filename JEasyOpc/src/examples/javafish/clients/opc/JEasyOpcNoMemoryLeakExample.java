package javafish.clients.opc;

import javafish.clients.opc.asynch.AsynchEvent;
import javafish.clients.opc.asynch.OpcAsynchGroupListener;
import javafish.clients.opc.component.OpcGroup;
import javafish.clients.opc.component.OpcItem;
import javafish.clients.opc.exception.CoInitializeException;
import javafish.clients.opc.exception.CoUninitializeException;
import javafish.clients.opc.exception.ComponentNotFoundException;
import javafish.clients.opc.exception.GroupActivityException;
import javafish.clients.opc.exception.GroupUpdateTimeException;
import javafish.clients.opc.exception.ItemActivityException;

public class JEasyOpcNoMemoryLeakExample implements OpcAsynchGroupListener {

  public static void main(String[] args) throws InterruptedException {
    JEasyOpcNoMemoryLeakExample test = new JEasyOpcNoMemoryLeakExample();

    try {
      JOpc.coInitialize();
    }
    catch (CoInitializeException e1) {
      e1.printStackTrace();
    }

    JEasyOpc jopc = new JEasyOpc("localhost", "Matrikon.OPC.Simulation",
        "JOPC1");

    OpcItem item1 = new OpcItem("Random.Real8", true, "");
    OpcItem item2 = new OpcItem("Random.Real8", true, "");
    OpcItem item3 = new OpcItem("Random.Real8", true, "");
    OpcItem item4 = new OpcItem("Random.Real8", true, "");
    OpcItem item5 = new OpcItem("Random.Real8", true, "");
    OpcItem item6 = new OpcItem("Random.Real8", true, "");
    OpcItem item7 = new OpcItem("Random.Real8", true, "");
    OpcItem item8 = new OpcItem("Random.Real8", true, "");

    OpcGroup group = new OpcGroup("group1", true, 2000, 0.0f);

    group.addItem(item1);
    group.addItem(item2);
    group.addItem(item3);
    group.addItem(item4);
    group.addItem(item5);
    group.addItem(item6);
    group.addItem(item7);
    group.addItem(item8);

    for (int i = 0; i < 200; i++) {
      group.addItem(new OpcItem("Random.Real8", true, ""));
    }

    jopc.addGroup(group);

    group.addAsynchListener(test);

    jopc.start();

    synchronized (test) {
      test.wait(3000);
    }

    System.out.println("JOPC active: " + jopc.ping());

    synchronized (test) {
      test.wait(8000);
    }

    try {
      jopc.setGroupActivity(group, false);
    }
    catch (GroupActivityException e) {
      e.printStackTrace();
    }
    catch (ComponentNotFoundException e) {
      e.printStackTrace();
    }

    synchronized (test) {
      test.wait(4000);
    }

    try {
      jopc.setGroupActivity(group, true);
    }
    catch (GroupActivityException e) {
      e.printStackTrace();
    }
    catch (ComponentNotFoundException e) {
      e.printStackTrace();
    }

    synchronized (test) {
      test.wait(4000);
    }

    try {
      jopc.setGroupUpdateTime(group, 300);
    }
    catch (GroupUpdateTimeException e) {
      e.printStackTrace();
    }
    catch (ComponentNotFoundException e) {
      e.printStackTrace();
    }

    try {
      jopc.setItemActivity(group, item8, false);
    }
    catch (ComponentNotFoundException e1) {
      e1.printStackTrace();
    }
    catch (ItemActivityException e1) {
      e1.printStackTrace();
    }

    synchronized (test) {
      test.wait(15 * 60000);
    }

    jopc.terminate();

    synchronized (test) {
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
    System.out.println(((JCustomOpc)event.getSource()).getFullOpcServerName()
        + "=>");
    System.out.println("Package: " + event.getID());
    System.out.println("Group name: " + event.getOPCGroup().getGroupName());
    System.out.println("Items count: " + event.getOPCGroup().getItemCount());
  }

}
