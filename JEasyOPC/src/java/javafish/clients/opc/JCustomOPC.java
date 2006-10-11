package javafish.clients.opc;

import java.util.Arrays;
import java.util.Date;
import java.util.List;
import java.util.Properties;

import javafish.clients.opc.exception.ConnectivityException;
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
    newInstance(getClass().getName(), host, serverProgID, serverClientHandle);
    
    // create standard reporting listener
    useStandardReporting = Boolean.valueOf(props.getProperty("standardReport", "true"));
    if (useStandardReporting) {
      addOPCReportListener(this);
    }
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
   * Disconnect server
   */
  private native void disconnectServer();

  /**
   * Get OPC server status,
   * if connection between server and client still alive
   * 
   * @return server is OK, boolean
   */
  private native boolean getStatus();
  
  /**
   * Return Description of OPC Server
   * 
   * @return String
   */
  public String getFullOPCServerName() {
    return host + "//" + serverProgID + " (" + serverClientHandle + ")";
  }

  /**
   * Return ID of OPC Client
   * 
   * @return id int
   */
  public int getIDClient() {
    return id;
  }

  /**
   * Disconnect OPC Server
   */
  synchronized public void disconnect() {
    disconnectServer();
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
  public void connect() throws ConnectivityException {
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
