package javafish.clients.opc.exception;

/**
 * Unable to add group to opc server 
 */
public class UnableAddGroupException extends OpcSignException {
  private static final long serialVersionUID = -8404432823798210406L;
  
  public UnableAddGroupException(String message) {
    super(message);
  }
}
