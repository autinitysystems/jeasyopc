package javafish.clients.opc;

import java.util.Properties;

import javafish.clients.opc.asynch.AsynchEvent;
import javafish.clients.opc.asynch.OpcAsynchGroupListener;
import javafish.clients.opc.component.OpcGroup;
import javafish.clients.opc.component.OpcItem;
import javafish.clients.opc.exception.CoInitializeException;
import javafish.clients.opc.exception.CoUninitializeException;
import javafish.clients.opc.exception.ComponentNotFoundException;
import javafish.clients.opc.exception.ConnectivityException;
import javafish.clients.opc.exception.GroupExistsException;
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
    group = new OpcGroup("group1", true, 2000, 0.0f);
    group2 = new OpcGroup("group2", true, 500, 0.0f);
    
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
      Thread.sleep(2000);
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

  public void testAsynch10Read() {
    fail("Not yet implemented");
  }

  public void testAsynch20Read() {
    fail("Not yet implemented");
  }

  public void testAsynch10Unadvise() {
    fail("Not yet implemented");
  }

  public void testAsynch20Unadvise() {
    fail("Not yet implemented");
  }

  public void testGetDownloadGroup() {
    fail("Not yet implemented");
  }

  public void testSetGroupUpdateTime() {
    fail("Not yet implemented");
  }

  public void testSetGroupActivity() {
    fail("Not yet implemented");
  }

  public void testSetItemActivity() {
    fail("Not yet implemented");
  }

}
