package javafish.clients.opc;

import javafish.clients.opc.component.OpcGroup;
import javafish.clients.opc.exception.ConnectivityException;
import javafish.clients.opc.exception.UnableRemoveGroupException;
import javafish.clients.opc.lang.Translate;

/**
 * Easy implementation of JCustomOPC client
 * <p>
 * <i>NOTE:</i> Usage of Asynch 2.0 mode (Callback interface)
 */
public class JEasyOpc extends JOpc {
  
  /** refresh for global asynch loop */
  private final int WAITIME = 20; // ms
  
  /** timeout for connectivity checker */
  private final int CONNTIME = 2000; // ms
  
  /** opc-client running thread */
  private boolean running = false;
  
  /** check connectivity */
  private boolean connected = false;

  /**
   * Create new JEasyOpc client
   * 
   * @param host - host computer
   * @param serverProgID - OPC Server name
   * @param serverClientHandle - user name for OPC Client
   */
  public JEasyOpc(String host, String serverProgID, String serverClientHandle) {
    super(host, serverProgID, serverClientHandle);
  }
  
  /**
   * Asynch thread of client is active
   * 
   * @return is running, boolean
   */
  synchronized public boolean isRunning() {
    return running;
  }
  
  /**
   * Stop OPC Client thread
   */
  synchronized public void terminate() {
    running = false;
    notifyAll();
  }
  
  @Override
  synchronized public void run() {
    running = true;
    
    // global loop
    while (running) {
      try {
        // connect to OPC-Server
        connect();
        log.info(Translate.getString("JEASYOPC_CONNECTED"));
        
        // register groups on server
        registerGroups();
        log.info(Translate.getString("JEASYOPC_GRP_REG"));
        
        // run asynchronous mode 2.0
        for (int i = 0; i < groups.size(); i++) {
          asynch20Read(getGroupByClientHandle(i));
        }
        log.info(Translate.getString("JEASYOPC_ASYNCH20_START"));
        
        // life cycle
        while (running) { 
          // check connectivity
          connected = ping();
          
          if (!connected) {
            throw new ConnectivityException(Translate.getString("CONNECTIVITY_EXCEPTION") + " " +
                getHost() + "->" + getServerProgID());
          }
          
          // check and clone downloaded group
          OpcGroup group = getDownloadGroup();
          
          if (group != null) { // send to listeners
            sendOpcGroup(group);
          }
          
          try { // sleep time
            wait(WAITIME);
          }
          catch (InterruptedException e) {
            log.error(e);
          }
        } // life cycle
        
      }
      catch (ConnectivityException e) {
        log.error(e);
        try {
          wait(CONNTIME); // try reconnect
        }
        catch (InterruptedException e1) {
          log.error(e1);
        }
      }
      catch (Exception e) {
        log.error(e);
        try {
          wait(CONNTIME); // try reconnect
        }
        catch (InterruptedException e1) {
          log.error(e1);
        }
      };
    }
    
    try { // remove groups
      unregisterGroups();
      log.info(Translate.getString("JEASYOPC_GRP_UNREG"));
    }
    catch (UnableRemoveGroupException e) {
      log.error(e);
    }
    
    connected = false;
    running = false;
    log.info(Translate.getString("JEASYOPC_DISCONNECTED"));
  }

}