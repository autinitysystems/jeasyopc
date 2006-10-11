package javafish.clients.opc;


public class OPCTest2 {
  
  public static int iter = 0;
  
  public static void main(String[] args) throws InterruptedException {
    // JCustomOPC Clients test
    /*
    JCustomOPC jopc = new JCustomOPC("localhost", "Matrikon.OPC.Simulation", "JCustomOPC");
    try {
      jopc.connect();
      while (true) {
        Thread.sleep(3000);
        System.out.println("Client is connected: " + jopc.ping());
        iter++;
        if (iter == 5) {
          jopc.disconnect();
          break;
        }
      }
    }
    catch (ConnectivityException e) {
      e.printStackTrace();
    }
    */
  }

}
