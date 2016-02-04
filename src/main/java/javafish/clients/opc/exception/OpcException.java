package javafish.clients.opc.exception;

/**
 * BASE EXCEPTION: Opc exception 
 */
public class OpcException extends Exception {
  private static final long serialVersionUID = -2775704894721183911L;
  
  public OpcException(String message) {
    super(message);
  }

}
