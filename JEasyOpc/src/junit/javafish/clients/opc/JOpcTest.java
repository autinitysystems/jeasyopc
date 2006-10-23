package javafish.clients.opc;

import java.util.Properties;

import javafish.clients.opc.asynch.AsynchEvent;
import javafish.clients.opc.asynch.OpcAsynchGroupListener;
import javafish.clients.opc.component.OpcGroup;
import javafish.clients.opc.component.OpcItem;
import javafish.clients.opc.exception.Asynch10ReadException;
import javafish.clients.opc.exception.Asynch10UnadviseException;
import javafish.clients.opc.exception.Asynch20ReadException;
import javafish.clients.opc.exception.Asynch20UnadviseException;
import javafish.clients.opc.exception.CoInitializeException;
import javafish.clients.opc.exception.CoUninitializeException;
import javafish.clients.opc.exception.ComponentNotFoundException;
import javafish.clients.opc.exception.ConnectivityException;
import javafish.clients.opc.exception.GroupActivityException;
import javafish.clients.opc.exception.GroupExistsException;
import javafish.clients.opc.exception.GroupUpdateTimeException;
import javafish.clients.opc.exception.ItemActivityException;
import javafish.clients.opc.exception.SynchReadException;
import javafish.clients.opc.exception.SynchWriteException;
import javafish.clients.opc.exception.UnableAddGroupException;
import javafish.clients.opc.exception.UnableAddItemException;
import javafish.clients.opc.exception.UnableRemoveGroupException;
import javafish.clients.opc.exception.UnableRemoveItemException;
import javafish.clients.opc.property.PropertyLoader;
import junit.framework.TestCase;

public class JOpcTest extends TestCase {

  private Properties serverProps;
  private JOpc opc;
  private OpcGroup group;
  private OpcGroup group2;
  private OpcItem item1;
  private OpcItem item2;
  private OpcItem itemWrite;
  
  @Override
  protected void setUp() throws Exception {
    serverProps = PropertyLoader.loadProperties("javafish.clients.opc.OPCServerTest");
    
    opc = new JOpc(
        serverProps.getProperty("host"),
        serverProps.getProperty("serverProgID"),
        serverProps.getProperty("clientHandle"));
    
    item1 = new OpcItem(serverProps.getProperty("itemTag1"), true, "", 0);
    item2 = new OpcItem(serverProps.getProperty("itemTag1"), true, "", 0);
    itemWrite = new OpcItem(serverProps.getProperty("itemTagWrite1"), true, "", 0);
    group = new OpcGroup("group1", true, 100, 0.0f);
    group2 = new OpcGroup("group2", true, 2000, 0.0f);
    
    group.addItem(item1);
    group.addItem(item2);
    group.addItem(itemWrite);
    
    try {
      JOpc.coInitialize();
    }
    catch (CoInitializeException e1) {
      fail(e1.getMessage());
    }
    
    try {
      opc.connect();
    }
    catch (ConnectivityException e2) {
      fail(e2.getMessage());
    }
  }
  
  @Override
  protected void tearDown() throws Exception {
    try {
      JOpc.coUninitialize();
    }
    catch (CoUninitializeException e) {
      fail(e.getMessage());
    }
  }

  public void testAddGroup() {
    opc.addGroup(group);
    
    OpcGroup groupEqual = opc.getGroupByClientHandle(group.getClientHandle());
    assertEquals(group, groupEqual);
    
    opc.addGroup(null);
    assertTrue(true);
    
    try {
      opc.addGroup(group);
      fail("Group hasn't to added to the client.");
    }
    catch (GroupExistsException e) {
      assertTrue(true);
    }
  }

  public void testRemoveGroup() {
    try {
      opc.removeGroup(group);
      fail("Group doesn't remove from the client.");
    }
    catch (GroupExistsException e) {
      assertTrue(true);
    }
    
    opc.addGroup(group);
    opc.removeGroup(group);
    assertTrue(true);
  }

  public void testGetGroupByClientHandle() {
    opc.addGroup(group);
    OpcGroup groupEqual = opc.getGroupByClientHandle(group.getClientHandle());
    assertEquals(group, groupEqual);
    
    groupEqual = opc.getGroupByClientHandle(-1);
    assertNull(groupEqual);
  }

  public void testGetGroupsAsArray() {
    OpcGroup[] groups = opc.getGroupsAsArray();
    assertEquals(0, groups.length);
    
    opc.addGroup(group);
    groups = opc.getGroupsAsArray();
    assertEquals(1, groups.length);
    assertEquals(group, groups[0]);
  }

  public void testUpdateGroups() {
    opc.addGroup(group);
    opc.updateGroups();
    assertTrue(true);
  }

  public void testAddRemoveAsynchGroupListener() {
    OpcAsynchGroupListener asynchListener = new OpcAsynchGroupListener() {
      public void getAsynchEvent(AsynchEvent event) {
        String groupName = event.getOPCGroup().getGroupName();
        assertEquals(group.getGroupName(), groupName);
      }
    };
    opc.addAsynchGroupListener(asynchListener);
    opc.addAsynchGroupListener(asynchListener);
    opc.removeAsynchGroupListener(asynchListener);
    opc.removeAsynchGroupListener(asynchListener);
  }

  public void testRegisterGroup() {
    opc.addGroup(group);
    try {
      opc.registerGroup(group);
      opc.registerGroup(null);
    }
    catch (ComponentNotFoundException e) {
      fail(e.getMessage());
    }
    catch (UnableAddGroupException e) {
      fail(e.getMessage());
    }
    
    try {
      opc.registerGroup(group2);
      assertTrue(false);
    }
    catch (ComponentNotFoundException e1) {
      assertTrue(true);
    }
    catch (UnableAddGroupException e1) {
      fail(e1.getMessage());
    }
    
    opc.addGroup(group2);
    
    try {
      opc.registerGroup(group2);
    }
    catch (ComponentNotFoundException e1) {
      fail(e1.getMessage());
    }
    catch (UnableAddGroupException e1) {
      fail(e1.getMessage());
    }
  }

  public void testRegisterItem() {
    try {
      opc.registerItem(group, item1);
      assertTrue(false);
    }
    catch (ComponentNotFoundException e1) {
      assertTrue(true);
    }
    catch (UnableAddItemException e1) {
      fail(e1.getMessage());
    }
    
    opc.addGroup(group);
    
    try {
      opc.registerItem(group, item1);
      assertTrue(false);
    }
    catch (ComponentNotFoundException e1) {
      fail(e1.getMessage());
    }
    catch (UnableAddItemException e1) {
      assertTrue(true);
    }
    
    try {
      opc.registerGroup(group);
    }
    catch (ComponentNotFoundException e1) {
      fail(e1.getMessage());
    }
    catch (UnableAddGroupException e1) {
      fail(e1.getMessage());
    }
    
    try {
      opc.registerItem(group, item1);
    }
    catch (ComponentNotFoundException e1) {
      fail(e1.getMessage());
    }
    catch (UnableAddItemException e1) {
      fail(e1.getMessage());
    }
  }

  public void testRegisterGroups() {
    try {
      opc.registerGroups();
    }
    catch (UnableAddGroupException e) {
      fail(e.getMessage());
    }
    catch (UnableAddItemException e) {
      fail(e.getMessage());
    }
    
    opc.addGroup(group);
    
    try {
      opc.registerGroups();
    }
    catch (UnableAddGroupException e) {
      fail(e.getMessage());
    }
    catch (UnableAddItemException e) {
      fail(e.getMessage());
    }
  }

  public void testUnregisterGroup() {
    try {
      opc.unregisterGroup(group);
      assertTrue(false);
    }
    catch (ComponentNotFoundException e) {
      assertTrue(true);
    }
    catch (UnableRemoveGroupException e) {
      fail(e.getMessage());
    }
    
    opc.addGroup(group);
    
    try {
      opc.unregisterGroup(group);
      assertTrue(false);
    }
    catch (ComponentNotFoundException e) {
      fail(e.getMessage());
    }
    catch (UnableRemoveGroupException e) {
      assertTrue(true);
    }
    
    try {
      opc.registerGroup(group);
    }
    catch (ComponentNotFoundException e) {
      fail(e.getMessage());
    }
    catch (UnableAddGroupException e) {
      fail(e.getMessage());
    }
    
    try {
      opc.unregisterGroup(group);
    }
    catch (ComponentNotFoundException e) {
      fail(e.getMessage());
    }
    catch (UnableRemoveGroupException e) {
      fail(e.getMessage());
    }
  }

  public void testUnregisterItem() {
    try {
      opc.unregisterItem(group, item1);
      assertTrue(false);
    }
    catch (ComponentNotFoundException e) {
      assertTrue(true);
    }
    catch (UnableRemoveItemException e) {
      fail(e.getMessage());
    }
    
    opc.addGroup(group);
    
    try {
      opc.registerGroup(group);
    }
    catch (ComponentNotFoundException e) {
      fail(e.getMessage());
    }
    catch (UnableAddGroupException e) {
      fail(e.getMessage());
    }
    
    try {
      opc.unregisterItem(group, item1);
      assertTrue(false);
    }
    catch (ComponentNotFoundException e) {
      fail(e.getMessage());
    }
    catch (UnableRemoveItemException e) {
      assertTrue(true);
    }
    
    try {
      opc.registerItem(group, item1);
    }
    catch (ComponentNotFoundException e) {
      fail(e.getMessage());
    }
    catch (UnableAddItemException e) {
      fail(e.getMessage());
    }
    
    try {
      opc.unregisterItem(group, item1);
    }
    catch (ComponentNotFoundException e) {
      fail(e.getMessage());
    }
    catch (UnableRemoveItemException e) {
      fail(e.getMessage());
    }
  }

  public void testUnregisterGroups() {
    try {
      opc.unregisterGroups();
    }
    catch (UnableRemoveGroupException e) {
      fail(e.getMessage());
    }
    
    opc.addGroup(group);
    
    try {
      opc.registerGroups();
    }
    catch (UnableAddGroupException e) {
      fail(e.getMessage());
    }
    catch (UnableAddItemException e) {
      fail(e.getMessage());
    }
    
    try {
      opc.unregisterGroups();
    }
    catch (UnableRemoveGroupException e) {
      fail(e.getMessage());
    }
  }

  public void testSynchReadItem() {
    OpcItem item;
    try {
      item = opc.synchReadItem(null, null);
      assertTrue(false);
    }
    catch (ComponentNotFoundException e) {
      assertTrue(true);
    }
    catch (SynchReadException e) {
      fail(e.getMessage());
    }
    
    try {
      opc.synchReadItem(group, item1);
      assertTrue(false);
    }
    catch (ComponentNotFoundException e) {
      assertTrue(true);
    }
    catch (SynchReadException e) {
      fail(e.getMessage());
    }
    
    opc.addGroup(group);
    
    try {
      item = opc.synchReadItem(group, item1);
      assertTrue(false);
    }
    catch (ComponentNotFoundException e) {
      fail(e.getMessage());
    }
    catch (SynchReadException e) {
      assertTrue(true);
    }
    
    try {
      opc.registerGroups();
    }
    catch (UnableAddGroupException e) {
      fail(e.getMessage());
    }
    catch (UnableAddItemException e) {
      fail(e.getMessage());
    }
    
    try {
      Thread.sleep(2000);
    }
    catch (InterruptedException e1) {
      fail(e1.getMessage());
    }
    
    try {
      item = opc.synchReadItem(group, item1);
      assertEquals(item1.getItemName(), item.getItemName());
      assertTrue(item.isQuality());
    }
    catch (ComponentNotFoundException e) {
      fail(e.getMessage());
    }
    catch (SynchReadException e) {
      fail(e.getMessage());
    }
  }

  public void testSynchWriteItem() {
    OpcItem item;
    try {
      opc.synchWriteItem(null, null);
      assertTrue(false);
    }
    catch (ComponentNotFoundException e) {
      assertTrue(true);
    }
    catch (SynchWriteException e) {
      fail(e.getMessage());
    }
    
    try {
      opc.synchWriteItem(group, item1);
      assertTrue(false);
    }
    catch (ComponentNotFoundException e) {
      assertTrue(true);
    }
    catch (SynchWriteException e) {
      fail(e.getMessage());
    }
    
    opc.addGroup(group);
    
    try {
      opc.synchWriteItem(group, item1);
      assertTrue(false);
    }
    catch (ComponentNotFoundException e) {
      fail(e.getMessage());
    }
    catch (SynchWriteException e) {
      assertTrue(true);
    }
    
    try {
      opc.registerGroups();
    }
    catch (UnableAddGroupException e) {
      fail(e.getMessage());
    }
    catch (UnableAddItemException e) {
      fail(e.getMessage());
    }
    
    try {
      Thread.sleep(1000);
    }
    catch (InterruptedException e) {
      fail(e.getMessage());
    }
    
    itemWrite.setValue("10.0");
    
    try {
      opc.synchWriteItem(group, itemWrite);
      assertTrue(true);
    }
    catch (ComponentNotFoundException e) {
      fail(e.getMessage());
    }
    catch (SynchWriteException e) {
      fail(e.getMessage());
    }
    
    try {
      Thread.sleep(2000);
    }
    catch (InterruptedException e) {
      fail(e.getMessage());
    }
    
    try {
      item = opc.synchReadItem(group, itemWrite);
      assertTrue(item.isQuality());
      assertEquals(itemWrite.getValue(), item.getValue());
    }
    catch (ComponentNotFoundException e) {
      fail(e.getMessage());
    }
    catch (SynchReadException e) {
      fail(e.getMessage());
    }
  }
  
  public void testSynchReadGroup() {
    OpcGroup groupTest;
    try {
      opc.synchReadGroup(null);
      assertTrue(false);
    }
    catch (ComponentNotFoundException e) {
      assertTrue(true);
    }
    catch (SynchReadException e) {
      fail(e.getMessage());
    }
    
    try {
      opc.synchReadGroup(group);
      assertTrue(false);
    }
    catch (ComponentNotFoundException e) {
      assertTrue(true);
    }
    catch (SynchReadException e) {
      fail(e.getMessage());
    }
    
    opc.addGroup(group);
    
    try {
      opc.synchReadGroup(group);
      assertTrue(false);
    }
    catch (ComponentNotFoundException e) {
      fail(e.getMessage());
    }
    catch (SynchReadException e) {
      assertTrue(true);
    }
    
    try {
      opc.registerGroups();
    }
    catch (UnableAddGroupException e) {
      fail(e.getMessage());
    }
    catch (UnableAddItemException e) {
      fail(e.getMessage());
    }
    
    try {
      Thread.sleep(4000);
    }
    catch (InterruptedException e) {
      fail(e.getMessage());
    }
    
    try {
      groupTest = opc.synchReadGroup(group);
      assertEquals(groupTest.getGroupName(), group.getGroupName());
      OpcItem[] items = groupTest.getItemsAsArray();
      for (int i = 0; i < items.length; i++) {
        assertTrue(items[i].isQuality());
      }
    }
    catch (ComponentNotFoundException e) {
      fail(e.getMessage());
    }
    catch (SynchReadException e) {
      fail(e.getMessage());
    }
  }

  public void testAsynch10ReadAndUnadvise() {
    try {
      opc.asynch10Read(null);
      assertTrue(false);
    }
    catch (ComponentNotFoundException e) {
      assertTrue(true);
    }
    catch (Asynch10ReadException e) {
      fail(e.getMessage());
    }
    
    try {
      opc.asynch10Read(group);
      assertTrue(false);
    }
    catch (ComponentNotFoundException e) {
      assertTrue(true);
    }
    catch (Asynch10ReadException e) {
      fail(e.getMessage());
    }
    
    try {
      opc.asynch10Unadvise(null);
      assertTrue(false);
    }
    catch (ComponentNotFoundException e1) {
      assertTrue(true);
    }
    catch (Asynch10UnadviseException e1) {
      fail(e1.getMessage());
    }
    
    try {
      opc.asynch10Unadvise(group);
      assertTrue(false);
    }
    catch (ComponentNotFoundException e1) {
      assertTrue(true);
    }
    catch (Asynch10UnadviseException e1) {
      fail(e1.getMessage());
    }
    
    opc.addGroup(group);
    
    try {
      opc.asynch10Unadvise(group);
      assertTrue(false);
    }
    catch (ComponentNotFoundException e1) {
      fail(e1.getMessage());
    }
    catch (Asynch10UnadviseException e1) {
      assertTrue(true);
    }
    
    try {
      opc.asynch10Read(group);
      assertTrue(false);
    }
    catch (ComponentNotFoundException e) {
      fail(e.getMessage());
    }
    catch (Asynch10ReadException e) {
      assertTrue(true);
    }
    
    try {
      opc.registerGroups();
    }
    catch (UnableAddGroupException e) {
      fail(e.getMessage());
    }
    catch (UnableAddItemException e) {
      fail(e.getMessage());
    }
    
    AsynchListenerTest asynchTestListener = new AsynchListenerTest(); 
    opc.addAsynchGroupListener(asynchTestListener);
    
    try {
      Thread.sleep(2000);
    }
    catch (InterruptedException e) {
      fail(e.getMessage());
    }
    
    try {
      opc.asynch10Read(group);
    }
    catch (ComponentNotFoundException e) {
      fail(e.getMessage());
    }
    catch (Asynch10ReadException e) {
      fail(e.getMessage());
    }
    
    int count = 10;
    int cc = 0;
    while (cc++ < count) {
      try {
        Thread.sleep(100);
      }
      catch (InterruptedException e) {
        fail(e.getMessage());
      }
      opc.ping();
      OpcGroup downGroup = opc.getDownloadGroup();
      if (downGroup != null) {
        opc.sendOpcGroup(downGroup);
      }
    }
    if (asynchTestListener.count == 0) {
      assertTrue(false);
    }
    
    try {
      opc.asynch10Unadvise(group);
      assertTrue(true);
    }
    catch (ComponentNotFoundException e1) {
      fail(e1.getMessage());
    }
    catch (Asynch10UnadviseException e1) {
      fail(e1.getMessage());
    }
  }

  public void testAsynch20ReadAndUnadvise() {
    try {
      opc.asynch20Read(null);
      assertTrue(false);
    }
    catch (ComponentNotFoundException e) {
      assertTrue(true);
    }
    catch (Asynch20ReadException e) {
      fail(e.getMessage());
    }
    
    try {
      opc.asynch20Read(group);
      assertTrue(false);
    }
    catch (ComponentNotFoundException e) {
      assertTrue(true);
    }
    catch (Asynch20ReadException e) {
      fail(e.getMessage());
    }
    
    try {
      opc.asynch20Unadvise(null);
      assertTrue(false);
    }
    catch (ComponentNotFoundException e1) {
      assertTrue(true);
    }
    catch (Asynch20UnadviseException e1) {
      fail(e1.getMessage());
    }
    
    try {
      opc.asynch20Unadvise(group);
      assertTrue(false);
    }
    catch (ComponentNotFoundException e1) {
      assertTrue(true);
    }
    catch (Asynch20UnadviseException e1) {
      fail(e1.getMessage());
    }
    
    opc.addGroup(group);
    
    try {
      opc.asynch20Unadvise(group);
      assertTrue(false);
    }
    catch (ComponentNotFoundException e1) {
      fail(e1.getMessage());
    }
    catch (Asynch20UnadviseException e1) {
      assertTrue(true);
    }
    
    try {
      opc.asynch20Read(group);
      assertTrue(false);
    }
    catch (ComponentNotFoundException e) {
      fail(e.getMessage());
    }
    catch (Asynch20ReadException e) {
      assertTrue(true);
    }
    
    try {
      opc.registerGroups();
    }
    catch (UnableAddGroupException e) {
      fail(e.getMessage());
    }
    catch (UnableAddItemException e) {
      fail(e.getMessage());
    }
    
    AsynchListenerTest asynchTestListener = new AsynchListenerTest(); 
    opc.addAsynchGroupListener(asynchTestListener);
    
    try {
      Thread.sleep(2000);
    }
    catch (InterruptedException e) {
      fail(e.getMessage());
    }
    
    try {
      opc.asynch20Read(group);
    }
    catch (ComponentNotFoundException e) {
      fail(e.getMessage());
    }
    catch (Asynch20ReadException e) {
      fail(e.getMessage());
    }
    
    int count = 10;
    int cc = 0;
    while (cc++ < count) {
      try {
        Thread.sleep(100);
      }
      catch (InterruptedException e) {
        fail(e.getMessage());
      }
      opc.ping();
      OpcGroup downGroup = opc.getDownloadGroup();
      if (downGroup != null) {
        opc.sendOpcGroup(downGroup);
      }
    }
    if (asynchTestListener.count == 0) {
      assertTrue(false);
    }
    
    try {
      opc.asynch20Unadvise(group);
      assertTrue(true);
    }
    catch (ComponentNotFoundException e1) {
      fail(e1.getMessage());
    }
    catch (Asynch20UnadviseException e1) {
      fail(e1.getMessage());
    }
  }

  public void testSetGroupUpdateTime() {
    try {
      opc.setGroupUpdateTime(null, 100);
      assertTrue(false);
    }
    catch (ComponentNotFoundException e2) {
      assertTrue(true);
    }
    catch (GroupUpdateTimeException e2) {
      fail(e2.getMessage());
    }
    
    try {
      opc.setGroupUpdateTime(group, 100);
      assertTrue(false);
    }
    catch (ComponentNotFoundException e2) {
      assertTrue(true);
    }
    catch (GroupUpdateTimeException e2) {
      fail(e2.getMessage());
    }
    
    opc.addGroup(group);
    
    try {
      opc.setGroupUpdateTime(group, 100);
      assertTrue(false);
    }
    catch (ComponentNotFoundException e2) {
      fail(e2.getMessage());
    }
    catch (GroupUpdateTimeException e2) {
      assertTrue(true);
    }
    
    try {
      opc.registerGroups();
      AsynchListenerTest asynchTestListener = new AsynchListenerTest(); 
      opc.addAsynchGroupListener(asynchTestListener);
      try {
        Thread.sleep(2000);
      }
      catch (InterruptedException e1) {
        fail(e1.getMessage());
      }
      try {
        opc.asynch10Read(group);
        int count = 10;
        int cc = 0;
        while (cc++ < count) {
          try {
            Thread.sleep(100);
          }
          catch (InterruptedException e1) {
            fail(e1.getMessage());
          }
          opc.ping();
          OpcGroup downGroup = opc.getDownloadGroup();
          if (downGroup != null) {
            opc.sendOpcGroup(downGroup);
          }
        }
        
        try {
          opc.setGroupUpdateTime(group, 100);
          cc = 0;
          while (cc++ < count) {
            try {
              Thread.sleep(100);
            }
            catch (InterruptedException e1) {
              fail(e1.getMessage());
            }
            opc.ping();
            OpcGroup downGroup = opc.getDownloadGroup();
            if (downGroup != null) {
              opc.sendOpcGroup(downGroup);
            }
          }
          
          asynchTestListener.testUpdateTime(group.getUpdateRate());
          
          try {
            opc.asynch10Unadvise(group);
          }
          catch (Asynch10UnadviseException e) {
            fail(e.getMessage());
          }
        }
        catch (GroupUpdateTimeException e) {
          fail(e.getMessage());
        }
      }
      catch (ComponentNotFoundException e) {
        fail(e.getMessage());
      }
      catch (Asynch10ReadException e) {
        fail(e.getMessage());
      }
    }
    catch (UnableAddGroupException e) {
      fail(e.getMessage());
    }
    catch (UnableAddItemException e) {
      fail(e.getMessage());
    }
  }

  public void testSetGroupActivity() {
    try {
      opc.setGroupActivity(null, true);
      assertTrue(false);
    }
    catch (ComponentNotFoundException e) {
      assertTrue(true);
    }
    catch (GroupActivityException e) {
      fail(e.getMessage());
    }
    
    try {
      opc.setGroupActivity(group, true);
      assertTrue(false);
    }
    catch (ComponentNotFoundException e) {
      assertTrue(true);
    }
    catch (GroupActivityException e) {
      fail(e.getMessage());
    }
    
    opc.addGroup(group);
    
    try {
      opc.setGroupActivity(group, true);
      assertTrue(false);
    }
    catch (ComponentNotFoundException e) {
      fail(e.getMessage());
    }
    catch (GroupActivityException e) {
      assertTrue(true);
    }
    
    try {
      opc.registerGroups();
    }
    catch (UnableAddGroupException e) {
      fail(e.getMessage());
    }
    catch (UnableAddItemException e) {
      fail(e.getMessage());
    }
    
    try {
      opc.setGroupActivity(group, false);
    }
    catch (ComponentNotFoundException e) {
      fail(e.getMessage());
    }
    catch (GroupActivityException e) {
      fail(e.getMessage());
    }
    
    assertEquals(false, group.isActive());
    
    try {
      Thread.sleep(500);
    }
    catch (InterruptedException e1) {
      fail(e1.getMessage());
    }
    
    try {
      opc.setGroupActivity(group, true);
    }
    catch (ComponentNotFoundException e) {
      fail(e.getMessage());
    }
    catch (GroupActivityException e) {
      fail(e.getMessage());
    }
    
    assertEquals(true, group.isActive());
    
    try {
      opc.unregisterGroups();
    }
    catch (UnableRemoveGroupException e) {
      fail(e.getMessage());
    }
  }

  public void testSetItemActivity() {
    try {
      opc.setItemActivity(null, null, true);
      assertTrue(false);
    }
    catch (ComponentNotFoundException e) {
      assertTrue(true);
    }
    catch (ItemActivityException e) {
      fail(e.getMessage());
    }
    
    try {
      opc.setItemActivity(group, item1, true);
      assertTrue(false);
    }
    catch (ComponentNotFoundException e) {
      assertTrue(true);
    }
    catch (ItemActivityException e) {
      fail(e.getMessage());
    }
    
    opc.addGroup(group);
    
    try {
      opc.setItemActivity(group, item1, true);
      assertTrue(false);
    }
    catch (ComponentNotFoundException e) {
      fail(e.getMessage());
    }
    catch (ItemActivityException e) {
      assertTrue(true);
    }
    
    try {
      opc.registerGroups();
    }
    catch (UnableAddGroupException e) {
      fail(e.getMessage());
    }
    catch (UnableAddItemException e) {
      fail(e.getMessage());
    }
    
    try {
      opc.setItemActivity(group, item1, false);
      assertEquals(false, item1.isActive());
    }
    catch (ComponentNotFoundException e) {
      fail(e.getMessage());
    }
    catch (ItemActivityException e) {
      fail(e.getMessage());
    }
    
    try {
      Thread.sleep(500);
    }
    catch (InterruptedException e) {
      fail(e.getMessage());
    }
    
    try {
      opc.setItemActivity(group, item1, true);
      assertEquals(true, item1.isActive());
    }
    catch (ComponentNotFoundException e) {
      fail(e.getMessage());
    }
    catch (ItemActivityException e) {
      fail(e.getMessage());
    }
    
    try {
      opc.unregisterGroups();
    }
    catch (UnableRemoveGroupException e) {
      fail(e.getMessage());
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
