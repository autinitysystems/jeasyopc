package javafish.clients.opc.asynch;

import java.awt.AWTEvent;


/**
 * OPC Asynchronous event 
 */
public class AsynchEvent extends AWTEvent {
  private static final long serialVersionUID = -3603520013179390255L;
  
  private OPCGroup group;
  
  public AsynchEvent(Object source, int id, OPCGroup group) {
    super(source, id);
    this.group = group;
  }
  
  /**
   * Return downloaded OPCGroup
   * 
   * @return group OPCGroup
   */
  public OPCGroup getOPCGroup() {
    return group;
  }

}
