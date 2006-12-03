package javafish.clients.opc;

import javafish.clients.opc.exception.CoInitializeException;
import javafish.clients.opc.exception.CoUninitializeException;
import javafish.clients.opc.exception.ConnectivityException;

public class TryOpcConnectionExample {

  public static int iter = 0;

  public static void main(String[] args) throws InterruptedException {
    // JCustomOPC Clients test
    try {
      JOpc.coInitialize();
      JOpc jopc = new JOpc("localhost", "Matrikon.OPC.Simulation", "JCustomOPC");

      jopc.connect();
      while (true) {
        Thread.sleep(200);
        System.out.println("Client is connected: " + jopc.ping());
        iter++;
        if (iter == 5) {
          break;
        }
      }
      JOpc.coUninitialize();
    }
    catch (CoInitializeException e) {
      e.printStackTrace();
    }
    catch (ConnectivityException e) {
      e.printStackTrace();
    }
    catch (CoUninitializeException e) {
      e.printStackTrace();
    }
  }

}
