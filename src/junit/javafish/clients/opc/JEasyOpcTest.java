package javafish.clients.opc;

import java.util.Properties;

import javafish.clients.opc.asynch.AsynchEvent;
import javafish.clients.opc.asynch.OpcAsynchGroupListener;
import javafish.clients.opc.component.OpcGroup;
import javafish.clients.opc.component.OpcItem;
import javafish.clients.opc.exception.CoInitializeException;
import javafish.clients.opc.exception.CoUninitializeException;
import javafish.clients.opc.property.PropertyLoader;
import junit.framework.TestCase;

public class JEasyOpcTest extends TestCase {
  
  private Properties serverProps;
  private JEasyOpc opc;
  private OpcGroup group;
  private OpcGroup group2;
  private OpcItem item1;
  private OpcItem item2;
  private OpcItem itemWrite;

  protected void setUp() {
    serverProps = PropertyLoader.loadProperties("javafish.clients.opc.OPCServerTest");
    
    opc = new JEasyOpc(
        serverProps.getProperty("host"),
        serverProps.getProperty("serverProgID"),
        serverProps.getProperty("clientHandle"));
    
    item1 = new OpcItem(serverProps.getProperty("itemTag1"), true, "");
    item2 = new OpcItem(serverProps.getProperty("itemTag1"), true, "");
    itemWrite = new OpcItem(serverProps.getProperty("itemTagWrite1"), true, "");
    group = new OpcGroup("group1", true, 100, 0.0f);
    group2 = new OpcGroup("group2", true, 2000, 0.0f);
    
    group.addItem(item1);
    group.addItem(item2);
    group2.addItem(itemWrite);
    
    try {
      JEasyOpc.coInitialize();
    }
    catch (CoInitializeException e) {
      fail(e.getMessage());
    }
    
    // add test-groups to opc-client
    opc.addGroup(group);
    opc.addGroup(group2);
  }
  
  @Override
  protected void tearDown() {
    try {
      JEasyOpc.coUninitialize();
    }
    catch (CoUninitializeException e) {
      fail(e.getMessage());
    }
  }

  public void testIsRunning() {
    assertEquals(false, opc.isRunning());
    
    opc.start();
    
    try {
      Thread.sleep(300);
    }
    catch (InterruptedException e) {
      fail(e.getMessage());
    }
    
    assertEquals(true, opc.isRunning());
    
    try {
      Thread.sleep(1000);
    }
    catch (InterruptedException e) {
      fail(e.getMessage());
    }
    
    opc.terminate();
    
    try {
      Thread.sleep(1000);
    }
    catch (InterruptedException e) {
      fail(e.getMessage());
    }
    
    assertEquals(false, opc.isRunning());
  }

  public void testTerminate() {
    opc.terminate();
    opc.start();
    
    try {
      Thread.sleep(3000);
    }
    catch (InterruptedException e) {
      fail(e.getMessage());
    }
    
    opc.terminate();

    try {
      Thread.sleep(2000);
    }
    catch (InterruptedException e) {
      fail(e.getMessage());
    }
    
    opc.terminate();
    try {
      opc.start();
      assertTrue(false);
    }
    catch (IllegalThreadStateException e) {
      assertTrue(true);
    }
  }
  
  /**
   * Asynch listener for JUnit tests 
   */
  class AsynchListenerTest implements OpcAsynchGroupListener {
    public int count = 0;
    private OpcGroup group;
    
    public void getAsynchEvent(AsynchEvent event) {
      group = event.getOPCGroup();
      assertEquals(group.getGroupName(), group.getGroupName());
      count++;
    }
    
    public void testUpdateTime(int expected) {
      assertEquals(expected, group.getUpdateRate());      
    }
  }

}
