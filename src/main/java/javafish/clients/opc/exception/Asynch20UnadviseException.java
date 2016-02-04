package javafish.clients.opc.exception;

/**
 * Unadvise asynchronous group exception (asynch 2.0) 
 */
public class Asynch20UnadviseException extends OpcAsynchException {
  private static final long serialVersionUID = -515905757159909611L;
  
  public Asynch20UnadviseException(String message) {
    super(message);
  }

}
