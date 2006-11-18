package javafish.clients.opc.browser;

import java.util.Arrays;
import java.util.Properties;

import javafish.clients.opc.exception.CoInitializeException;
import javafish.clients.opc.exception.CoUninitializeException;
import javafish.clients.opc.exception.ConnectivityException;
import javafish.clients.opc.exception.HostException;
import javafish.clients.opc.exception.NotFoundServersException;
import javafish.clients.opc.exception.UnableAddGroupException;
import javafish.clients.opc.exception.UnableAddItemException;
import javafish.clients.opc.exception.UnableBrowseBranchException;
import javafish.clients.opc.exception.UnableBrowseLeafException;
import javafish.clients.opc.exception.UnableIBrowseException;
import javafish.clients.opc.property.PropertyLoader;
import junit.framework.TestCase;

public class JOpcBrowserTest extends TestCase {

  private Properties serverProps;
  private String host;

  @Override
  protected void setUp() throws Exception {
    serverProps = PropertyLoader.loadProperties("javafish.clients.opc.OPCServerTest");
    host = serverProps.getProperty("host");
  }

  public void testGetOPCServers() {
    try {
      JOpcBrowser.coInitialize();
    }
    catch (CoInitializeException e1) {
      fail(e1.getMessage());
    }
    
    try {
      String[] servers = JOpcBrowser.getOpcServers(host);
      if (servers == null || servers.length == 0) {
        fail("OPC Server has to exist on test-host: " + host);
      }
    }
    catch (HostException e) {
      fail(e.getMessage());
    }
    catch (NotFoundServersException e) {
      fail(e.getMessage());
    }
    
    try {
      JOpcBrowser.getOpcServers("noname");
    }
    catch (HostException e) {
      assertTrue(true);
    }
    catch (NotFoundServersException e) {
      fail(e.getMessage());
    }
    
    // disconnect server
    try {
      JOpcBrowser.coUninitialize();
    }
    catch (CoUninitializeException e) {
      fail(e.getMessage());
    }
    
    // NotFoundServersException not tested!
    // Must exist computer without OPC-Servers.
  }

  public void testGetOPCBranch() {
    try {
      JOpcBrowser.coInitialize();
    }
    catch (CoInitializeException e1) {
      fail(e1.getMessage());
    }

    JOpcBrowser jbrowser = new JOpcBrowser(
        serverProps.getProperty("host"),
        serverProps.getProperty("serverProgID"),
        serverProps.getProperty("clientHandle") + "-Browser");
    try {
      jbrowser.connect();
      String[] branches = jbrowser.getOpcBranch("");
      if (branches == null || branches.length == 0) {
        fail("Branches don't download from OPC-Server: " +
            serverProps.getProperty("serverProgID"));
      }
    }
    catch (ConnectivityException e) {
      fail(e.getMessage());
    }
    catch (UnableBrowseBranchException e) {
      fail(e.getMessage());
    }
    catch (UnableIBrowseException e) {
      fail(e.getMessage());
    }

    // disconnect server
    try {
      JOpcBrowser.coUninitialize();
    }
    catch (CoUninitializeException e) {
      fail(e.getMessage());
    }
  }

  public void testGetOPCItems() {
    try {
      JOpcBrowser.coInitialize();
    }
    catch (CoInitializeException e1) {
      fail(e1.getMessage());
    }

    JOpcBrowser jbrowser = new JOpcBrowser(
        serverProps.getProperty("host"),
        serverProps.getProperty("serverProgID"),
        serverProps.getProperty("clientHandle") + "-Browser");
    try {
      jbrowser.connect();
      
      String[] items =
        jbrowser.getOpcItems(serverProps.getProperty("itemLeafTestName"), true);
      
      System.out.println(Arrays.asList(items));
      
      if (items == null || items.length == 0) {
        fail("Items don't download from OPC-Server: " +
            serverProps.getProperty("serverProgID"));
      }
    }
    catch (ConnectivityException e) {
      fail(e.getMessage());
    }
    catch (UnableIBrowseException e) {
      fail(e.getMessage());
    }
    catch (UnableBrowseLeafException e) {
      fail(e.getMessage());
    }
    catch (UnableAddGroupException e) {
      fail(e.getMessage());
    }
    catch (UnableAddItemException e) {
      fail(e.getMessage());
    }

    // disconnect server
    try {
      JOpcBrowser.coUninitialize();
    }
    catch (CoUninitializeException e) {
      fail(e.getMessage());
    }
  }

}
