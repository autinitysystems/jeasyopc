package javafish.clients.opc.report;

import java.util.Date;


/**
 * Log message
 */
public class LogMessage {
  
  public static final int DEBUG    = 0;
  public static final int INFO     = 1;
  public static final int WARNING  = 2;
  public static final int ERROR    = 3;
  public static final int FATAL    = 4;
  
  protected String report;
  protected Date timeStamp;
  protected int level;

  public LogMessage(Date timeStamp, int level, String report) {
    this.timeStamp = timeStamp;
    this.level = level;
    this.report = report;
  }

  public int getLevel() {
    return level;
  }

  public Date getTimeStamp() {
    return timeStamp;
  }
  
  public String getReport() {
    return report;
  }

}
