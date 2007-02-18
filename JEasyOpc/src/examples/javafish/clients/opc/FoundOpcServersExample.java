package javafish.clients.opc;

import java.util.Arrays;

import javafish.clients.opc.browser.JOpcBrowser;
import javafish.clients.opc.exception.HostException;
import javafish.clients.opc.exception.NotFoundServersException;

public class FoundOpcServersExample {

  /**
   * @param args
   */
  public static void main(String[] args) {
    // init COM components
    JOpcBrowser.coInitialize();
    
    try {
      String[] servers = JOpcBrowser.getOpcServers("localhost");
      if (servers != null) {
        System.out.println(Arrays.asList(servers));
      } else {
        System.out.println("Array Servers is null.");
      }
    }
    catch (HostException e) {
      e.printStackTrace();
    }
    catch (NotFoundServersException e) {
      e.printStackTrace();
    }
    
    // uninitialize COM components
    JOpcBrowser.coUninitialize();
  }

}
