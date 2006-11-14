package javafish.clients.opc.exception;

/**
 * Variant typecast exception
 */
public class VariantTypeException extends RuntimeException {
  private static final long serialVersionUID = 6360867811432199426L;
  
  public VariantTypeException(String message) {
    super(message);
  }
}
