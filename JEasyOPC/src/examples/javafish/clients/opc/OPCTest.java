package javafish.clients.opc;

import java.util.Arrays;

import javafish.clients.opc.browser.JOPCBrowser;
import javafish.clients.opc.exception.HostException;
import javafish.clients.opc.exception.NotFoundServers;

public class OPCTest {

  /**
   * @param args
   */
  public static void main(String[] args) {
    try {
      String[] servers = JOPCBrowser.getOPCServers("localhost");
      if (servers != null) {
        System.out.println(Arrays.asList(servers));
      } else {
        System.out.println("Array Servers is null.");
      }
    }
    catch (HostException e) {
      e.printStackTrace();
    }
    catch (NotFoundServers e) {
      e.printStackTrace();
    }
  }

}
