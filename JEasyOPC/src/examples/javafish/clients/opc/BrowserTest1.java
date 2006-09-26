package javafish.clients.opc;

import java.util.Arrays;

import javafish.clients.opc.browser.JOPCBrowser;
import javafish.clients.opc.exception.ConnectivityException;
import javafish.clients.opc.exception.UnableBrowseBranchException;
import javafish.clients.opc.exception.UnableIBrowseException;

public class BrowserTest1 {

  /**
   * @param args
   */
  public static void main(String[] args) {
    // JCustomOPC Clients test
    JOPCBrowser jbrowser = new JOPCBrowser("localhost", "Matrikon.OPC.Simulation", "JOPCBrowser1");
    try {
      jbrowser.connect();
      String[] branches = jbrowser.getOPCBranch("23");
      System.out.println(Arrays.asList(branches));
      jbrowser.disconnect();
    }
    catch (ConnectivityException e) {
      e.printStackTrace();
    }
    catch (UnableBrowseBranchException e) {
      e.printStackTrace();
    }
    catch (UnableIBrowseException e) {
      e.printStackTrace();
    }
  }

}
