package javafish.clients.opc.asynch;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.Locale;

/**
 * Class OPC Item
 */
public class OPCItem {
  protected String name;
  protected GregorianCalendar timeStamp;
  protected String value;
  protected boolean quality;

  public OPCItem(String name, GregorianCalendar timeStamp, String value, boolean quality) {
    this.name = name;
    this.timeStamp = timeStamp;
    this.value = value;
    this.quality = quality;
  }

  @Override
  public String toString() {
    SimpleDateFormat sdf = new SimpleDateFormat("dd.MM.yyyy [HH:mm:ss]", Locale.getDefault());
    return name + " -> " + sdf.format(timeStamp.getTime()) + ": " + value + " quality: " + quality;
  }

  public String getName() {
    return name;
  }

  public boolean isQuality() {
    return quality;
  }

  public Date getTimeStamp() {
    return timeStamp.getTime();
  }

  public String getValue() {
    return value;
  }

}
