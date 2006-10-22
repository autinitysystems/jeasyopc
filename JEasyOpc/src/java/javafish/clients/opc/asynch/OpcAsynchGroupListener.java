package javafish.clients.opc.asynch;

import java.util.EventListener;


/**
 * Asynchronous OPC Group Listener 
 */
public interface OpcAsynchGroupListener extends EventListener {
  
  /**
   * Get asynchronous event
   * 
   * @param event AsynchEvent
   */
  public void getAsynchEvent(AsynchEvent event);

}
