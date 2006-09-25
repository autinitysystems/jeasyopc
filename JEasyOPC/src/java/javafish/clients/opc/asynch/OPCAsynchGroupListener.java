package javafish.clients.opc.asynch;

import java.util.EventListener;


/**
 * Asynchronous OPC Group Listener 
 */
public interface OPCAsynchGroupListener extends EventListener {
  
  /**
   * Get asynchronous event
   * 
   * @param AsynchEvent event
   */
  public void getAsynchEvent(AsynchEvent event);

}
