package javafish.clients.opc.property;

import java.io.InputStream;
import java.util.Properties;

/**
 * Properties loader
 * <p>
 * <i>NOTE:</i>Root of properties files has to be in a class path
 */
public class PropertyLoader {

  private static final String DEFAULT = "default";
  private static final String DEFAULT_LOGGER = "log4j";

  /**
   * Get property for class (propsName)
   *
   * @param propsName class package
   * @param propertyName key
   * @return property String
   */
  public static String getProperty(String propsName, String propertyName) {
    Properties props = loadProperties(propsName);
    return props.getProperty(propertyName);
  }

  /**
   * Get default application property
   *
   * @param propertyName String
   * @return property String
   */
  public static String getDefaultProperty(String propertyName) {
    return getDefaultProperties().getProperty(propertyName);
  }

  /**
   * Get default logger properties
   *
   * @return properties Properties
   */
  public static Properties getDefaultLoggerProperties() {
    return loadProperties(getDefaultProperty(DEFAULT_LOGGER));
  }

  /**
   * Return default application properties from default.properties
   *
   * @return properties Properties
   */
  public static Properties getDefaultProperties() {
    return loadProperties(DEFAULT);
  }

  /**
   * Get properties by class (className)
   *
   * @param className Class
   * @return properties Properties
   */
  public static Properties loadProperties(Class className) {
    return loadProperties(className.getName());
  }

  /**
   * Get properties for class (propsName)
   *
   * @param propsName class package
   * @return properties Properties
   */
  public static Properties loadProperties(final String propsName) {
    Properties props = null;
    InputStream in = null;
    try {
      ClassLoader cl = ClassLoader.getSystemClassLoader();
      String name = propsName.replace('.', '/').concat(".properties");

      in = cl.getResourceAsStream(name);
      if (in != null) {
        props = new Properties();
        props.load(in);
      }
    }
    catch (Exception e) {
      props = null;
    }
    finally {
      if (props == null) {
        System.err.print("Property file " + propsName + " doesn't exist. System terminated.");
        System.exit(0);
      }
    }

    return props;
  }

  // EXAMPLE
  public static void main(String[] args) {
    System.out.println(getProperty("test", "xprop"));
    System.out.println(getProperty("nested.test1", "yprop"));
  }

}

