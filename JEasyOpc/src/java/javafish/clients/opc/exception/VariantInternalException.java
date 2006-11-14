package javafish.clients.opc.exception;

/**
 * Variant internal native Runtime exception 
 */
public class VariantInternalException extends RuntimeException {
  private static final long serialVersionUID = -7791420233338610815L;
  
  public VariantInternalException(String message) {
        super(message);
  }

}
