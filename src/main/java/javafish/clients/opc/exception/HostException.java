package javafish.clients.opc.exception;

/**
 * Host not found exception 
 */
public class HostException extends OpcBrowserException {
  private static final long serialVersionUID = 251036655646283680L;
  
  public HostException(String message) {
    super(message);
  }

}
