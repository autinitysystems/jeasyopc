package javafish.clients.opc.v1;

import java.util.Arrays;
import java.util.Date;
import java.util.List;
import java.util.Properties;

import javafish.clients.opc.asynch.OPCAsynchGroupListener;
import javafish.clients.opc.lang.Translate;
import javafish.clients.opc.property.PropertyLoader;
import javafish.clients.opc.report.LogEvent;
import javafish.clients.opc.report.LogMessage;
import javafish.clients.opc.report.OPCReport;
import javafish.clients.opc.report.OPCReportListener;

import javax.swing.event.EventListenerList;
import javax.swing.tree.DefaultMutableTreeNode;

import org.apache.log4j.Logger;
import org.apache.log4j.PropertyConfigurator;

/**
 * JCustomOPC Client (Native class)
 * 
 * @author A.Fischer (arnal2@seznam.cz)
 * @version 2.00/2006
 */
public class JCustomOPC extends Thread implements OPCReportListener {
  protected final int WAITIME = 3000; // ms
  protected String host;
  protected String serverProgID;
  protected String serverClientHandle;
  protected boolean running = false;
  protected boolean paused = false;
  
  /** use log4j messaging */
  protected boolean useStandardReporting = true;
  
  /** log4j logger */
  protected final Logger logger = Logger.getLogger(getClass());
  
  /* properties file */
  protected Properties props = PropertyLoader.loadProperties(getClass());

  /* report guardian */
  protected OPCReportGuardian report;

  /* report event listeners */
  protected EventListenerList reportListeners = new EventListenerList();
  
  /* asynchronous group event listeners */
  protected EventListenerList asynchGroupListeners = new EventListenerList();
  
  /* package counter */
  private int idpkg = 0;

  /**
   * int id - Important: specify OPC Thread in dll-library
   */
  private int id;

  static {
    // load native library OPC Client
    System.loadLibrary("lib/JCustomOPC");
  }

  /**
   * CONSTRUCTOR: Create Custom OPC Client
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
    // create native CustomOPC client
    createCustomOPC(host, serverProgID, serverClientHandle);
    // create standard reporting listener
    useStandardReporting = Boolean.valueOf(props.getProperty("standardReport", "true"));
    if (useStandardReporting) {
      addOPCReportListener(this);
    }
    // create reporting deamon
    report = new OPCReportGuardian();
    report.start();
  }

  /**
   * Return Description of OPC Server
   * 
   * @return String
   */
  public String getFullOPCServerName() {
    return new String(host + "//" + serverProgID + " (" + serverClientHandle + ")");
  }

  /**
   * Create Native OPC Client (Delphi code)
   * 
   * @param host
   * @param serverProgID
   * @param serverClientHandle
   */
  private native void createCustomOPC(String host, String serverProgID, String serverClientHandle);

  /**
   * Start native OPC Client
   */
  public native void startCustomOPC();

  /**
   * Terminate native OPC Client
   */
  private native void terminateCustomOPC();

  /**
   * Set activity of Groups to false
   */
  private native void pauseClient();

  /**
   * Set activity of Groups to true
   */
  private native void playClient();

  /**
   * Add OPC Group to native OPC Client
   * 
   * @param name
   * @param sleepTime
   */
  private native void addCustomGroup(String name, int sleepTime);

  /**
   * Add OPC item (tag) to native OPC Client
   * 
   * @param groupName
   * @param itemName
   */
  private native void addCustomItem(String groupName, String itemName);

  /**
   * Get downloaded OPCGroup from OPC Server
   * 
   * @return OPCGroup
   */
  //private native OPCGroup getDownloadGroup();

  /**
   * Get native OPC Client Report (status)
   * 
   * @return OPCReport
   */
  private native OPCReport getReport();

  /**
   * Get OPC-Servers from host computer
   * 
   * @param host
   * @return String[]
   */
  public static native String[] getOPCServers(String host);

  /**
   * Browser: Get branch of tree OPC
   * 
   * @param host
   * @param serverName
   * @param branch
   * @return
   */
  private native String[] getOPCBranch(String host, String serverName, String branch);

  /**
   * BROWSER: Get items of a OPC-tree leaf
   * 
   * @param host
   * @param serverName
   * @param leaf
   * @param showValues - show actual values
   * @return String[]
   */
  private native String[] getOPCItems(String host, String serverName, String leaf, boolean showValues);
  
  /**
   * Ping OPC server,
   * if connection between server and client
   * still alive (ASYNCHRONOUS MODE)
   * 
   * @return server is OK, boolean
   */
  public native boolean ping();

  /**
   * Return ID-thread of OPC Client
   * 
   * @return id int
   */
  public int getIDClient() {
    return id;
  }

  /**
   * Terminate OPC Client
   */
  synchronized public void terminate() {
    running = false;
    terminateCustomOPC();
    notifyAll();
  }

  /**
   * Pause OPC Client
   */
  public void pause() {
    pauseClient();
    paused = true;
  }

  /**
   * Continue after pause
   */
  public void play() {
    playClient();
    paused = false;
  }

  /**
   * Is OPC Client temporary paused?
   * 
   * @return boolean
   */
  public boolean isPaused() {
    return paused;
  }

  /**
   * Add Group to OPC Server
   * 
   * @param name
   * @param sleepTime
   */
  public void addGroup(String name, int sleepTime) {
    addCustomGroup(name, sleepTime);
  }

  /**
   * Add Item to OPC Group
   * 
   * @param groupName
   * @param itemName
   */
  public void addItem(String groupName, String itemName) {
    addCustomItem(groupName, itemName);
  }

  /**
   * Browser: Get branch of tree OPC
   * 
   * @param branch
   * @return String[]
   */
  public String[] getOPCBranch(String branch) {
    return getOPCBranch(host, serverProgID, branch);
  }

  /**
   * BROWSER: Get items of a OPC-tree leaf
   * 
   * @param leaf
   * @param showValues - show actual values
   * @return String[]
   */
  public String[] getOPCItems(String leaf, boolean showValues) {
    return getOPCItems(host, serverProgID, leaf, showValues);
  }

  /**
   * Return OPC Server Tree Structure
   * 
   * @param node DefaultMutableTreeNode
   */
  public void downloadTreeServerStructure(DefaultMutableTreeNode node) {
    downloadTreeServerStructure("", node);
  }

  /**
   * Browse OPC Server Tree Structure
   * 
   * @param branch
   * @param node
   */
  protected void downloadTreeServerStructure(String branch, DefaultMutableTreeNode node) {
    String[] list = getOPCBranch(branch);
    if ((list != null) && (list.length > 0)) {
      for (int i = 0; i < list.length; i++) {
        DefaultMutableTreeNode child = new DefaultMutableTreeNode(list[i]);
        String path = branch.equals("") ? list[i] : branch + "." + list[i];
        downloadTreeServerStructure(path, child);
        node.add(child);
      }
    }
  }

  /**
   * Thread: handle downloaded group
   */
  synchronized public void run() {
    running = true;
    startCustomOPC();

    while (running) {
      /*
      OPCGroup group = getDownloadGroup();
      if (group != null) {
        sendOPCGroup(group);
      }
      */
      System.out.println("OPC State in THREAD: " + ping());
      
      try {
        wait(WAITIME);
      }
      catch (InterruptedException e) {
        e.printStackTrace();
      }
      logger.debug("Cycle in loop...");
    }
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
   * Add asynch-group listener
   * 
   * @param listener OPCReportListener
   */
  public void addAsynchGroupListener(OPCAsynchGroupListener listener) {
    List list = Arrays.asList(asynchGroupListeners.getListenerList());
    if (list.contains(listener) == false) {
      asynchGroupListeners.add(OPCAsynchGroupListener.class, listener);
    }
  }

  /**
   * Remove asynch-group listener
   * 
   * @param listener OPCReportListener
   */
  public void removeAsynchGroupListener(OPCAsynchGroupListener listener) {
    List list = Arrays.asList(asynchGroupListeners.getListenerList());
    if (list.contains(listener) == true) {
      asynchGroupListeners.remove(OPCAsynchGroupListener.class, listener);
    }
  }
  
  /**
   * Send opc-group in asynchronous mode
   * 
   * @param group OPCGroup
   */
  /*
  private void sendOPCGroup(OPCGroup group) {
    Object[] list = asynchGroupListeners.getListenerList();
    for (int i = 0; i < list.length; i += 2) {
      Class listenerClass = (Class)(list[i]);
      if (listenerClass == OPCAsynchGroupListener.class) {
        OPCAsynchGroupListener listener = (OPCAsynchGroupListener)(list[i + 1]);
        AsynchEvent event = new AsynchEvent(this, idpkg++, group);
        listener.getAsynchEvent(event);
      }
    }
  }
  */

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
     *  200 - 299 = warning message
     *  300 - 399 = info message
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
    // standard logging listener
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
