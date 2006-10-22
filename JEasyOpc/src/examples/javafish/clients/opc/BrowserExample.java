package javafish.clients.opc;

import java.util.Arrays;

import javafish.clients.opc.browser.JOpcBrowser;
import javafish.clients.opc.exception.CoInitializeException;
import javafish.clients.opc.exception.CoUninitializeException;
import javafish.clients.opc.exception.ConnectivityException;
import javafish.clients.opc.exception.UnableAddGroupException;
import javafish.clients.opc.exception.UnableAddItemException;
import javafish.clients.opc.exception.UnableBrowseBranchException;
import javafish.clients.opc.exception.UnableBrowseLeafException;
import javafish.clients.opc.exception.UnableIBrowseException;

public class BrowserExample {

  /**
   * @param args
   */
  public static void main(String[] args) {
    try {
      JOpcBrowser.coInitialize();
    }
    catch (CoInitializeException e1) {
      e1.printStackTrace();
    }
    
    JOpcBrowser jbrowser = new JOpcBrowser("localhost", "Matrikon.OPC.Simulation", "JOPCBrowser1");
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
      JOpcBrowser.coUninitialize();
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
    catch (CoUninitializeException e) {
      e.printStackTrace();
    }
  }

}
