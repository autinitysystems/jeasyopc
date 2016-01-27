package javafish.clients.opc.exception;

/**
 * BASE EXCEPTION: Opc Runtime exception 
 */
public class OpcRuntimeException extends RuntimeException {
  private static final long serialVersionUID = -1248359052753826184L;
  
  public OpcRuntimeException(String message) {
    super(message);
  }

}
