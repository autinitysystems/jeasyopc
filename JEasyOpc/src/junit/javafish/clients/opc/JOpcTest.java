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
import javafish.clients.opc.exception.UnableAddGroupException;
import javafish.clients.opc.property.PropertyLoader;
import junit.framework.TestCase;

public class JOpcTest extends TestCase {

  private Properties serverProps;
  private JOpc opc;
  private OpcGroup group;
  private OpcGroup group2;
  
  @Override
  protected void setUp() throws Exception {
    serverProps = PropertyLoader.loadProperties("javafish.clients.opc.OPCServerTest");
    
    opc = new JOpc(
        serverProps.getProperty("host"),
        serverProps.getProperty("serverProgID"),
        serverProps.getProperty("clientHandle"));
    
    OpcItem item1 = new OpcItem("Random.Real8", true, "", 0);
    OpcItem item2 = new OpcItem("Random.Real8", true, "", 0);
    group = new OpcGroup("group1", true, 2000, 0.0f);
    group2 = new OpcGroup("group2", true, 500, 0.0f);
    
    group.addItem(item1);
    group.addItem(item2);
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
    
    try {
      JOpc.coUninitialize();
    }
    catch (CoUninitializeException e) {
      fail(e.getMessage());
    }
  }

  public void testRegisterItem() {
    fail("Not yet implemented");
  }

  public void testRegisterGroups() {
    fail("Not yet implemented");
  }

  public void testUnregisterGroup() {
    fail("Not yet implemented");
  }

  public void testUnregisterItem() {
    fail("Not yet implemented");
  }

  public void testUnregisterGroups() {
    fail("Not yet implemented");
  }

  public void testSynchReadItem() {
    fail("Not yet implemented");
  }

  public void testSynchWriteItem() {
    fail("Not yet implemented");
  }
  
  public void testSynchReadGroup() {
    fail("Not yet implemented");
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
