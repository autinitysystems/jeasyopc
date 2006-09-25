package javafish.clients.opc.exception;

/**
 * OPC Servers not found on specific host 
 */
public class NotFoundServers extends Exception {
  private static final long serialVersionUID = -7780587122150100350L;
  
  public NotFoundServers(String message) {
   super(message); 
  }

}
