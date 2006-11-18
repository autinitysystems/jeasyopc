package javafish.clients.opc.exception;

/**
 * Asynchronous 2.0 read exception
 * Registration of Callback interface exception. 
 */
public class Asynch20ReadException extends OpcAsynchException {
  private static final long serialVersionUID = 5812258704825079908L;
  
  public Asynch20ReadException(String message) {
    super(message);
  }

}
