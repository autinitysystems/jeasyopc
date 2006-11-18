package javafish.clients.opc.exception;

/**
 * COM objects uninitialization
 * <p>
 * <i>NOTE:</i> Can be call on program exit 
 */
public class CoUninitializeException extends OpcRuntimeException {
  private static final long serialVersionUID = -6676745171410580681L;
  
  public CoUninitializeException(String message) {
    super(message);
  }
}
