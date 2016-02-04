package javafish.clients.opc.exception;

/**
 * Unable to add item to group on opc server 
 */
public class UnableAddItemException extends OpcSignException {
  private static final long serialVersionUID = -5061250751997808959L;
  
  public UnableAddItemException(String message) {
    super(message);
  }

}
