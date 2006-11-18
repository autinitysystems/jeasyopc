package javafish.clients.opc.exception;

/**
 * OPCItem exists in OPCGroup. 
 */
public class ItemExistsException extends OpcExistsException {
  private static final long serialVersionUID = 6245523049244047229L;

  public ItemExistsException(String message) {
    super(message);
  }

}
