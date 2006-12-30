package javafish.clients.opc;

import java.util.Properties;

import javafish.clients.opc.browser.JOpcBrowser;
import javafish.clients.opc.exception.CoInitializeException;
import javafish.clients.opc.exception.CoUninitializeException;
import javafish.clients.opc.exception.ConnectivityException;
import javafish.clients.opc.lang.Translate;
import javafish.clients.opc.property.PropertyLoader;

import javax.swing.event.EventListenerList;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * JCustomOpc Client<br>
 * <i>abstract class</i>
 * <p>
 * OPC is open connectivity in industrial automation and the enterprise systems
 * that support the industry. Interoperability is assured through the creation and
 * maintenance of non-proprietary open standards specifications.
 * <p>
 * The first OPC standard specification resulted from the collaboration of
 * a number of leading worldwide automation suppliers working in cooperation
 * with Microsoft. Originally based on Microsoft's OLE COM and DCOM technologies,
 * the specification defined a standard set of objects, interfaces and methods
 * for use in process control and manufacturing automation applications to facilitate
 * interoperability.
 * <p>
 * The COM/DCOM technologies provided the framework for software products to be developed.
 * There are now hundreds of OPC Data Access servers and clients.
 * 
 * @author arnal2@seznam.cz
 * @version 2.3.1/2006
 */
abstract public class JCustomOpc {
  
  /** host server */
  protected String host;
  
  /** opc server name */
  protected String serverProgID;
  
  /** user name of opc server */
  protected String serverClientHandle;
  
  /** use log4j messaging */
  protected boolean useStandardReporting = true;
  
  /** counter of messages */
  protected int logPkg = 0;
  
  /** common logger */
  protected Log log = LogFactory.getLog(getClass());
  
  /** properties file */
  protected static Properties props;

  /** report event listeners */
  protected EventListenerList reportListeners = new EventListenerList();
  
  /** important: specify OPC object in dll-library (not modify) */
  private int id;

  static {
    // load class properties
    props = PropertyLoader.loadProperties(JCustomOpc.class);
    // load native library OPC Client
    System.loadLibrary(props.getProperty("library.path"));
  }

  /**
   * Create new custom OPC client
   * 
   * @param host - host computer
   * @param serverProgID - OPC Server name
   * @param serverClientHandle - user name for OPC Client
   */
  public JCustomOpc(String host, String serverProgID, String serverClientHandle) {
    this.host = host;
    this.serverProgID = serverProgID;
    this.serverClientHandle = serverClientHandle;
    
    // create native child of CustomOpc client
    newInstance(getParentClass().getName(), host, serverProgID, serverClientHandle);
  }
  
  /**
   * Get parent class for native representation structures
   * 
   * @return parent Class
   */
  protected Class getParentClass() {
    if (this instanceof JOpc) {
      return JOpc.class;
    }
    if (this instanceof JOpcBrowser) {
      return JOpcBrowser.class;
    }
    if (this instanceof JCustomOpc) {
      return JCustomOpc.class;
    }
    return JCustomOpc.class; // parent of all
  }

  /**
   * Create new instance of native OPC Client (Delphi code)
   * 
   * @param className String 
   * @param host String
   * @param serverProgID String
   * @param serverClientHandle String
   */
  synchronized private native void newInstance(String className, String host,
      String serverProgID, String serverClientHandle);
  
  /**
   * Connect to server
   * 
   * @throws ConnectivityException 
   */
  private native void connectServer() throws ConnectivityException;
  
  /**
   * COM objects initialize (must be call first in program!)
   * 
   * @throws CoInitializeException
   */
  private static native void coInitializeNative() throws CoInitializeException;
  
  /**
   * COM objects uninitialize (can be call on program exit)
   * 
   * @throws CoUninitializeException
   */
  private static native void coUninitializeNative() throws CoUninitializeException;

  /**
   * Get OPC server status,
   * if connection between server and client still alive
   * 
   * @return server is OK, boolean
   */
  private native boolean getStatus();
  
  /**
   * COM objects uninitialize (can be call on program exit)
   * 
   * @throws CoUninitializeException 
   */
  synchronized static public void coUninitialize() throws CoUninitializeException {
    try {
      coUninitializeNative();
    }
    catch (CoUninitializeException e) {
      throw new CoUninitializeException(Translate.getString("COUNINITIALIZE_EXCECPTION"));
    }
  }
  
  /**
   * COM objects initialize (must be call first in program!)
   * 
   * @throws CoInitializeException
   */
  synchronized static public void coInitialize() throws CoInitializeException {
    try {
      coInitializeNative();
    }
    catch (CoInitializeException e) {
      throw new CoInitializeException(Translate.getString("COINITIALIZE_EXCECPTION"));
    }
  }
  
  /**
   * Return Description of OPC Server
   * 
   * @return String
   */
  public String getFullOpcServerName() {
    return host + "//" + serverProgID + " (" + serverClientHandle + ")" + " [" + id + "]";
  }

  /**
   * Check connection between server and client
   * 
   * @return server is connected, boolean
   */
  public boolean ping() {
    return getStatus();
  }
  
  /**
   * Connect to OPC Server
   * 
   * @throws ConnectivityException
   */
  synchronized public void connect() throws ConnectivityException {
    try {
      connectServer();
    }
    catch (ConnectivityException e) {
      throw new ConnectivityException(Translate.getString("CONNECTIVITY_EXCEPTION") + " " +
          getHost() + "->" + getServerProgID());
    }
  }
  
  /**
   * Get host server
   * 
   * @return host String
   */
  public String getHost() {
    return host;
  }

  /**
   * Get user client name
   * 
   * @return name String
   */
  public String getServerClientHandle() {
    return serverClientHandle;
  }

  /**
   * Get OPC Server prog id
   * 
   * @return id name String
   */
  public String getServerProgID() {
    return serverProgID;
  }
  
}
