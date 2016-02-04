package javafish.clients.opc.exception;

/**
 * Opc existance exception
 */
public class OpcExistsException extends OpcRuntimeException {
  private static final long serialVersionUID = 124209534323144682L;
  
  public OpcExistsException(String message) {
    super(message);
  }

}
