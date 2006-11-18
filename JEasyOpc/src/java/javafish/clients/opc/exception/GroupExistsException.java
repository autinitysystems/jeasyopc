package javafish.clients.opc.exception;

/**
 * OPCGroup exists in OPC-server. 
 */
public class GroupExistsException extends OpcExistsException {
  private static final long serialVersionUID = 6669674238753654838L;

  public GroupExistsException(String message) {
    super(message);
  }

}
