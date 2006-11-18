package javafish.clients.opc.exception;

/**
 * Component (group/item) not found exception 
 */
public class ComponentNotFoundException extends OpcExistsException {
  private static final long serialVersionUID = -492184153249917069L;
  
  public ComponentNotFoundException(String message) {
    super(message);
  }

}
