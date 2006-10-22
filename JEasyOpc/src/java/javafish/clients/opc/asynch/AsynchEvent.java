package javafish.clients.opc.asynch;

import java.awt.AWTEvent;

import javafish.clients.opc.component.OpcGroup;


/**
 * OPC Asynchronous event 
 */
public class AsynchEvent extends AWTEvent {
  private static final long serialVersionUID = -3603520013179390255L;
  
  private OpcGroup group;
  
  //private OPCGroup group;
  public AsynchEvent(Object source, int id, OpcGroup group) {
    super(source, id);
    this.group = group;
  }
  
  /**
   * Return downloaded OPCGroup
   * 
   * @return group OPCGroup
   */
  public OpcGroup getOPCGroup() {
    return group;
  }

}
