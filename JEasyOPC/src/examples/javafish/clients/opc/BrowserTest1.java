package javafish.clients.opc;

import java.util.Arrays;

import javafish.clients.opc.browser.JOPCBrowser;
import javafish.clients.opc.exception.ConnectivityException;
import javafish.clients.opc.exception.UnableAddGroupException;
import javafish.clients.opc.exception.UnableAddItemException;
import javafish.clients.opc.exception.UnableBrowseBranchException;
import javafish.clients.opc.exception.UnableBrowseLeafException;
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
      String[] branches = jbrowser.getOPCBranch("");
      System.out.println(Arrays.asList(branches));
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
    
    try {
      String[] items = jbrowser.getOPCItems("Simulation Items.Random", true);
      if (items != null) {
        for (int i = 0; i < items.length; i++) {
          System.out.println(items[i]);
        }
      }
      // disconnect server
      jbrowser.disconnect();
    }
    catch (UnableBrowseLeafException e) {
      e.printStackTrace();
    }
    catch (UnableIBrowseException e) {
      e.printStackTrace();
    }
    catch (UnableAddGroupException e) {
      e.printStackTrace();
    }
    catch (UnableAddItemException e) {
      e.printStackTrace();
    }
  }

}
