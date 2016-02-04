package javafish.clients.opc.exception;

/**
 * IBrowser interface exception 
 */
public class UnableIBrowseException extends OpcBrowserException {
  private static final long serialVersionUID = 7146550762172755688L;
  
  public UnableIBrowseException(String message) {
    super(message);
  }

}
