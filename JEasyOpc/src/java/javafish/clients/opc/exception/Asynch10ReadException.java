package javafish.clients.opc.exception;

/**
 * Asynchronous 1.0 read exception
 * Registration of AdviseSink interface exception. 
 */
public class Asynch10ReadException extends OpcAsynchException {
  private static final long serialVersionUID = 2257350932203579765L;
   
  public Asynch10ReadException(String message) {
    super(message);
  }

}
