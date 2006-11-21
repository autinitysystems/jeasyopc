package javafish.clients.opc;

import java.util.Properties;

import javafish.clients.opc.exception.CoInitializeException;
import javafish.clients.opc.exception.CoUninitializeException;
import javafish.clients.opc.exception.ConnectivityException;
import javafish.clients.opc.property.PropertyLoader;
import javafish.clients.opc.report.OpcReportListener;
import junit.framework.TestCase;

/**
 * JUnit: JCustomOPC test 
 */
public class JCustomOpcTest extends TestCase {

  private Properties serverProps;
  private JCustomOPCImpl opc1;
  
  @Override
  protected void setUp() throws Exception {
    serverProps = PropertyLoader.loadProperties("javafish.clients.opc.OPCServerTest");
    
    opc1 = new JCustomOPCImpl(
        serverProps.getProperty("host"),
        serverProps.getProperty("serverProgID"),
        serverProps.getProperty("clientHandle") + "1");
  }
  
  public void testCoInitialize() {
    try {
      JOpc.coInitialize();
    }
    catch (CoInitializeException e) {
      fail("CoInitialization isn't activated.");
    }
  }
  
  public void testCoUninitialize() {
    try {
      JOpc.coUninitialize();
    }
    catch (CoUninitializeException e) {
      fail("CoUninitialization doesn't work correctly.");
    }
  }
  
  public void testConnect() {
    try {
      JOpc.coInitialize();
    }
    catch (CoInitializeException e) {
      fail(e.getMessage());
    }
    
    try {
      opc1.connect();
    }
    catch (ConnectivityException e) {
      fail(e.getMessage());
    }
    
    try {
      JOpc.coUninitialize();
    }
    catch (CoUninitializeException e) {
      fail(e.getMessage());
    }
  }

  public void testPing() {
    boolean connActive;
    
    try {
      JOpc.coInitialize();
    }
    catch (CoInitializeException e) {
      fail(e.getMessage());
    }
    
    connActive = opc1.ping();
    assertEquals(false, connActive);
    
    try {
      opc1.connect();
      connActive = opc1.ping();
      assertEquals(true, connActive);
    }
    catch (ConnectivityException e) {
      fail(e.getMessage());
    }
    
    try {
      JOpc.coUninitialize();
    }
    catch (CoUninitializeException e) {
      fail(e.getMessage());
    }
    
    connActive = opc1.ping();
    assertEquals(false, connActive);
  }

  public void testGetHost() {
    assertEquals(serverProps.getProperty("host"), opc1.getHost());
  }

  public void testGetServerClientHandle() {
    assertEquals(serverProps.getProperty("clientHandle")+"1", opc1.getServerClientHandle());
  }

  public void testGetServerProgID() {
    assertEquals(serverProps.getProperty("serverProgID"), opc1.getServerProgID());
  }

  /**
   * Implementation of JCustomOPC for JUnit tests 
   */
  class JCustomOPCImpl extends JCustomOpc {

    public JCustomOPCImpl(String host, String serverProgID, String serverClientHandle) {
      super(host, serverProgID, serverClientHandle);
    }
  }
  
  /**
   * Implementation of OPCReportListener for JUnit send message test
   */
  abstract class OPCReportListenerTester implements OpcReportListener {
    public boolean messageWasSend = false;
  }  

}


