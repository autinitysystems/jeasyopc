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
import javafish.clients.opc.report.OPCReport;
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
  
  // fixed constants
  public static final int WAITIME = 20; // ms 
  
  /** host server */
  protected String host;
  
  /** opc server name */
  protected String serverProgID;
  
  /** user name of opc server */
  protected String serverClientHandle;
  
  /** use log4j messaging */
  protected boolean useStandardReporting = true;
  
  /** log4j logger */
  protected final Logger logger = Logger.getLogger(getClass());
  
  /** properties file */
  protected Properties props = PropertyLoader.loadProperties(JCustomOPC.class);

  /** report guardian */
  protected OPCReportGuardian report;

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
    
    // create logging daemon
    report = new OPCReportGuardian();
    report.start();
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
   * Get native OPC Client Report (status)
   * 
   * @return OPCReport
   */
  private native OPCReport getReport();

  /**
   * Get OPC server status,
   * if connection between server and client still alive
   * 
   * @return server is OK, boolean
   */
  private native boolean getStatus();

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
   * Class for OPC Reporting
   */
  protected class OPCReportGuardian extends Thread {
    private boolean active = false;

    /**
     * Create Deamon thread
     */
    public OPCReportGuardian() {
      setDaemon(true);
    }

    /**
     * Terminate reporting thread
     */
    synchronized public void terminate() {
      active = false;
      notifyAll();
    }
    
    /**
     * Return level by id-message
     * <p>
     * Level:
     *  100 - 199 = error message
     *  200 - 299 = info message
     *  300 - 399 = debug message
     * 
     * @param id int
     * @return int level type
     */
    private int assignLevel(int id) {
      if (id >= 100 && id < 200) {
        return LogMessage.ERROR;
      } else if (id >= 200 && id < 400) {
        return LogMessage.INFO;
      } else if (id >= 400) {
        return LogMessage.DEBUG;
      }
      return LogMessage.DEBUG;
    }
    
    /**
     * Prepare log-message
     * (use translation property file)
     * 
     * @param report OPCReport (raw message from native code)
     * @return message LogMessage
     */
    private LogMessage prepareLogMessage(OPCReport report) {
      int id = report.getIdReport();
      // translate message
      String ids = String.valueOf(id);
      String info = Translate.getString("ID" + ids);
      // add adition message from native code
      info += " " + report.getReport();
      return new LogMessage(new Date(), assignLevel(id), id, info);
    }
    
    /**
     * Send log message to listeners
     * 
     * @param report OPCReport (raw report from native code)
     */
    private void sendLogMessage(OPCReport report) {
      Object[] list = reportListeners.getListenerList();
      for (int i = 0; i < list.length; i += 2) {
        Class listenerClass = (Class)(list[i]);
        if (listenerClass == OPCReportListener.class) {
          OPCReportListener listener = (OPCReportListener)(list[i + 1]);
          LogMessage message = prepareLogMessage(report);
          LogEvent event = new LogEvent(this, message.getIdReport(), message);
          listener.getLogEvent(event);
        }
      }
    }

    /**
     * Reporting Thread
     */
    synchronized public void run() {
      active = true;
      while (active) {
        OPCReport report = getReport();
        if (report != null) {
          // send log message to listeners
          sendLogMessage(report);
        }
        try {
          wait(WAITIME);
        }
        catch (InterruptedException e) {
          e.printStackTrace();
        }
      }
    }
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
