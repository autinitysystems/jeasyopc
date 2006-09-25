package javafish.clients.opc.report;

/**
 * OPC Client Report
 */
public class OPCReport {
  protected int idReport;
  protected String report;

  public OPCReport(int idReport, String report) {
    this.idReport = idReport;
    this.report = report;
  }

  @Override
  public String toString() {
    return "(id" + idReport + ") " + report;
  }

  public int getIdReport() {
    return idReport;
  }

  public String getReport() {
    return report;
  }

}
