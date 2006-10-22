package javafish.clients.opc.report;

import java.util.EventListener;


/**
 * Report listener 
 * (report processing) 
 */
public interface OpcReportListener extends EventListener {
  
  /**
   * Get log event from opc-client
   * 
   * @param event LogEvent
   */
  public void getLogEvent(LogEvent event);

}
