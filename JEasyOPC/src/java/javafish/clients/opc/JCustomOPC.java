package javafish.clients.opc;

import java.util.Arrays;
import java.util.Date;
import java.util.List;
import java.util.Properties;

import javafish.clients.opc.browser.JOPCBrowser;
import javafish.clients.opc.exception.CoInitializeException;
import javafish.clients.opc.exception.ConnectivityException;
import javafish.clients.opc.exception.CoUninitializeException;
import javafish.clients.opc.lang.Translate;
import javafish.clients.opc.property.PropertyLoader;
import javafish.clients.opc.report.LogEvent;
import javafish.clients.opc.report.LogMessage;
import javafish.clients.opc.report.OPCReportListener;

import javax.swing.event.EventListenerList;

import org.apache.log4j.Logger;
import org.apache.log4j.PropertyConfigurator;

/**
 * JCustomOPC Client
 * abstract class
 * 
 * @author arnal2@seznam.cz
 * @version 2.00/2006
 */
abstract public class JCustomOPC implements OPCReportListener {
  
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
  
  /** log4j logger */
  protected final Logger logger = Logger.getLogger(getClass());
  
  /** properties file */
  protected Properties props = PropertyLoader.loadProperties(JCustomOPC.class);

  /** report event listeners */
  protected EventListenerList reportListeners = new EventListenerList();
  
  /** important: specify OPC object in dll-library (not modify) */
  private int id;

  static {
    // load native library OPC Client
    System.loadLibrary("lib/JCustomOPC");
  }

  /**
   * Create new custom OPC client
   * 
   * @param host - host computer
   * @param serverProgID - OPC Server name
   * @param serverClientHandle - user name for OPC Client
   */
  public JCustomOPC(String host, String serverProgID, String serverClientHandle) {
    this.host = host;
    this.serverProgID = serverProgID;
    this.serverClientHandle = serverClientHandle;
    
    // init logger
    PropertyConfigurator.configure(PropertyLoader.getDefaultLoggerProperties());
    
    // create native child of CustomOPC client
    newInstance(getParentClass().getName(), host, serverProgID, serverClientHandle);
    
    // create standard reporting listener
    useStandardReporting = Boolean.valueOf(props.getProperty("standardReport", "true"));
    if (useStandardReporting) {
      addOPCReportListener(this);
    }
  }
  
  /**
   * Get parent class for native representation structures
   * 
   * @return parent Class
   */
  protected Class getParentClass() {
    if (this instanceof JOPC) {
      return JOPC.class;
    }
    if (this instanceof JOPCBrowser) {
      return JOPCBrowser.class;
    }
    if (this instanceof JCustomOPC) {
      return JCustomOPC.class;
    }
    return JCustomOPC.class; // parent of all
  }

  /**
   * Create new instance of native OPC Client (Delphi code)
   * 
   * @param className String 
   * @param host String
   * @param serverProgID String
   * @param serverClientHandle String
   */
  private native void newInstance(String className, String host,
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
  public String getFullOPCServerName() {
    return host + "//" + serverProgID + " (" + serverClientHandle + ")";
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

  /**
   * Usage of standard reporting
   * 
   * @return is used standard reporting (log4j), boolean
   */
  public boolean isUseStandardReporting() {
    return useStandardReporting;
  }

  /**
   * Add opc-report listener
   * 
   * @param listener OPCReportListener
   */
  public void addOPCReportListener(OPCReportListener listener) {
    List list = Arrays.asList(reportListeners.getListenerList());
    if (list.contains(listener) == false) {
      reportListeners.add(OPCReportListener.class, listener);
    }
  }

  /**
   * Remove opc-report listener
   * 
   * @param listener OPCReportListener
   */
  public void removeOPCReportListener(OPCReportListener listener) {
    List list = Arrays.asList(reportListeners.getListenerList());
    if (list.contains(listener) == true) {
      reportListeners.remove(OPCReportListener.class, listener);
    }
  }
  
  /**
   * Send log message to listeners
   * 
   * @param LogMessage message
   */
  protected void sendLogMessage(LogMessage message) {
    Object[] list = reportListeners.getListenerList();
    for (int i = 0; i < list.length; i += 2) {
      Class listenerClass = (Class)(list[i]);
      if (listenerClass == OPCReportListener.class) {
        OPCReportListener listener = (OPCReportListener)(list[i + 1]);
        LogEvent event = new LogEvent(this, logPkg++, message);
        listener.getLogEvent(event);
      }
    }
  }
  
  /**
   * Debug opc-log
   * 
   * @param message String
   */
  public void debug(String message) {
    LogMessage log = new LogMessage(new Date(), LogMessage.DEBUG, message);
    sendLogMessage(log);
  }
  
  /**
   * Info opc-log
   * 
   * @param message String
   */
  public void info(String message) {
    LogMessage log = new LogMessage(new Date(), LogMessage.INFO, message);
    sendLogMessage(log);
  }
  
  /**
   * Warning opc-log
   * 
   * @param message String
   */
  public void warn(String message) {
    LogMessage log = new LogMessage(new Date(), LogMessage.WARNING, message);
    sendLogMessage(log);
  }
  
  /**
   * Error opc-log
   * 
   * @param message String
   */
  public void error(String message) {
    LogMessage log = new LogMessage(new Date(), LogMessage.ERROR, message);
    sendLogMessage(log);
  }
  
  /**
   * Error opc-log
   * 
   * @param e Exception
   */
  public void error(Exception e) {
    StringBuffer sb = new StringBuffer(e.getMessage() +
        System.getProperty("line.separator"));
    StackTraceElement[] elements = e.getStackTrace();
    for (int i = 0; i < elements.length; i++) {
      sb.append(elements[i]);
      sb.append(System.getProperty("line.separator"));
    }
    LogMessage log = new LogMessage(new Date(), LogMessage.ERROR, sb.toString());
    sendLogMessage(log);
  }
  
  /**
   * Fatal opc-log
   * 
   * @param message String
   */
  public void fatal(String message) {
    LogMessage log = new LogMessage(new Date(), LogMessage.FATAL, message);
    sendLogMessage(log);
  }

  public void getLogEvent(LogEvent event) {
    // standard logging listener (log4j)
    switch (event.getMessage().getLevel()) {
      case LogMessage.DEBUG:
        logger.debug(event.getMessage().getReport());
        break;
      case LogMessage.INFO:
        logger.info(event.getMessage().getReport());
        break;
      case LogMessage.WARNING:
        logger.warn(event.getMessage().getReport());
        break;
      case LogMessage.ERROR:
        logger.error(event.getMessage().getReport());
        break;
      case LogMessage.FATAL:
        logger.fatal(event.getMessage().getReport());
        break;
    }
  }
  
}
