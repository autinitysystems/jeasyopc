package javafish.clients.opc.exception;

/**
 * Synchronous write exception 
 */
public class SynchWriteException extends Exception {
  private static final long serialVersionUID = -537188612957706596L;
  
  public SynchWriteException(String message) {
    super(message);
  }

}
