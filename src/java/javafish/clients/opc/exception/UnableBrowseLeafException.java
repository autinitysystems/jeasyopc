package javafish.clients.opc.exception;

/**
 * Unable browse leaf of opc tree (item) exception 
 */
public class UnableBrowseLeafException extends OpcBrowserException {
  private static final long serialVersionUID = -9169573921246772294L;
  
  public UnableBrowseLeafException(String message) {
    super(message);
  }

}
