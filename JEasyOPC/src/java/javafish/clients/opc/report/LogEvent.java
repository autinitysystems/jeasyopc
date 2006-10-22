package javafish.clients.opc.report;

import java.awt.AWTEvent;


/**
 * Log event 
 */
public class LogEvent extends AWTEvent {
  private static final long serialVersionUID = -6076385742587004859L;
  
  protected LogMessage message;

  public LogEvent(Object source, int id, LogMessage message) {
    super(source, id);
    this.message = message;
  }

  public LogMessage getMessage() {
    return message;
  }
  
}
