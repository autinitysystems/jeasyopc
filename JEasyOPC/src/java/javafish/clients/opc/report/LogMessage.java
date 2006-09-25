package javafish.clients.opc.report;

import java.util.Date;


/**
 * Log message
 */
public class LogMessage extends OPCReport {
  
  public static final int DEBUG    = 0;
  public static final int INFO     = 1;
  public static final int WARNING  = 2;
  public static final int ERROR    = 3;
  public static final int FATAL    = 4;
  
  protected Date timeStamp;
  protected int level;

  public LogMessage(Date timeStamp, int level, int idReport, String report) {
    super(idReport,report);
    this.timeStamp = timeStamp;
    this.level = level;
  }

  public int getLevel() {
    return level;
  }

  public Date getTimeStamp() {
    return timeStamp;
  }

}
