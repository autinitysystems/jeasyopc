package javafish.clients.opc.asynch;

import java.awt.AWTEvent;

import javafish.clients.opc.component.OpcGroup;

/**
 * OPC Asynchronous event 
 * This class and its subclasses supercede the original
 * java.awt.AWTEvent class.
 * The event is used for a instance of OpcGroup transmission. 
 */
public class AsynchEvent extends AWTEvent {
  private static final long serialVersionUID = -3603520013179390255L;
  
  /** downloaded group */
  private OpcGroup group;
  
  /**
   * Create asynchronous event for OpcGroup transmission.
   * 
   * @param source - JCustomOpc client or subclasses
   * @param id - id of transport package
   * @param group - downloaded OpcGroup
   */
  public AsynchEvent(Object source, int id, OpcGroup group) {
    super(source, id);
    this.group = group;
  }
  
  /**
   * Return downloaded OpcGroup
   * 
   * @return group OPCGroup
   */
  public OpcGroup getOPCGroup() {
    return group;
  }

}
