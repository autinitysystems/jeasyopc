package javafish.clients.opc.exception;

/**
 * COM object initialization 
 * <p>
 * <i>NOTE:</i> Must be call first in program! 
 */
public class CoInitializeException extends OpcRuntimeException {
  private static final long serialVersionUID = 729819761016093315L;
  
  public CoInitializeException(String message) {
    super(message);
  }

}
