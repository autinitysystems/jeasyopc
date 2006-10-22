package javafish.clients.opc.exception;

/**
 * Synchronous reading exception
 */
public class SynchReadException extends Exception {
  private static final long serialVersionUID = 3984589399856109670L;
  
  public SynchReadException(String message) {
    super(message);
  }

}
