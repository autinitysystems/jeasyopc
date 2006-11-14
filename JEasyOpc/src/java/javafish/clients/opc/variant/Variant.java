package javafish.clients.opc.variant;

import java.util.Date;

import javafish.clients.opc.exception.VariantTypeException;
import javafish.clients.opc.lang.Translate;

/**
 * <p>The <em>Variant</em> types as defined by Microsoft's COM. I
 * found this information in <a
 * href="http://www.marin.clara.net/COM/variant_type_definitions.htm">
 * http://www.marin.clara.net/COM/variant_type_definitions.htm</a>.</p>
 *
 * <p>In the variant types descriptions the following shortcuts are
 * used: <strong> [V]</strong> - may appear in a VARIANT,
 * <strong>[T]</strong> - may appear in a TYPEDESC,
 * <strong>[P]</strong> - may appear in an OLE property set,
 * <strong>[S]</strong> - may appear in a Safe Array.</p>
 * 
 * Implementation of <em>Variant</em> types => java data types
 */
public class Variant extends VariantTypes implements Cloneable {
  
  /** Variant Value */
  protected Object value = null;
  
  /** Native type of Variant (primary type) */
  protected int variant_native = VT_EMPTY;
  
  /**
   * Create new instance of Variant
   */
  public Variant() {}
  
  /**
   * Create new instance of Variant
   * 
   * @param value String
   */
  public Variant(String value) {
    setString(value);
  }
  
  /**
   * Create new instance of Variant
   * 
   * @param value Double
   */
  public Variant(double value) {
    setDouble(value);
  }

  /**
   * Create new instance of Variant
   * 
   * @param value float
   */
  public Variant(float value) {
    setFloat(value);
  }

  /**
   * Create new instance of Variant
   * 
   * @param value int
   */
  public Variant(int value) {
    setInteger(value);
  }

  /**
   * Create new instance of Variant
   * 
   * @param value Date
   */
  public Variant(Date value) {
    setDate(value);
  }

  /**
   * Create new instance of Variant
   * 
   * @param value boolean
   */
  public Variant(boolean value) {
    setBoolean(value);
  }
  
  /**
   * Create new instance of Variant
   * 
   * @param value Variant
   */
  public Variant(Variant value) {
    setVariant(value);
  }
  
  /**
   * Create new instance of byte
   * 
   * @param value byte
   */
  public Variant(byte value) {
    setByte(value);
  }
  
  /**
   * Create new instance of short
   * 
   * @param value short
   */
  public Variant(short value) {
    setWord(value);
  }

  /**
   * Create new instance of Variant
   * 
   * @param value VariantList
   */
  public Variant(VariantList value) {
    setArray(value);
  }

  /**
   * Get type of variant
   * 
   * @return type int
   */
  public int getVariantType() {
    return variant_native;
  }
  
  /**
   * Set value (String)
   * 
   * @param value String
   */
  public void setString(String value) {
    this.value = value;
    variant_native = VT_BSTR;
  }
  
  /**
   * Get value (String)
   * 
   * @return value String
   */
  public String getString() {
    switch (variant_native) {
      case VT_BSTR :
      case VT_LPSTR :
      case VT_LPWSTR :  
      case VT_CY :
        return (String)value;
      case VT_INT:
        return String.valueOf(((Integer)value).intValue());
      case VT_BOOL:
        return String.valueOf(((Boolean)value).booleanValue());
      case VT_R4:
        return String.valueOf(((Float)value).floatValue());
      case VT_R8:
        return String.valueOf(((Double)value).doubleValue());
      case VT_DATE:
        return ((Date)value).toString();
      case VT_ERROR:
        return "ERROR";
      case VT_NULL:
      case VT_EMPTY:
        return "";
      default :
        throw new VariantTypeException(Translate.getString("VARIANT_TYPE_EXCEPTION"));
    }
  }
  
  /**
   * Set value (double)
   * 
   * @param value double
   */
  public void setDouble(double value) {
    this.value = new Double(value);
    variant_native = VT_R8;
  }
  
  /**
   * Get value (double)
   * 
   * @return value double
   */
  public double getDouble() {
    switch (variant_native) {
      case VT_R8 :
        return ((Double)value).doubleValue();
      default :
        throw new VariantTypeException(Translate.getString("VARIANT_TYPE_EXCEPTION"));
    }
  }
  

  /**
   * Set value (float)
   * 
   * @param value float
   */
  public void setFloat(float value) {
    this.value = new Float(value);
    variant_native = VT_R4;
  }
  
  /**
   * Get value (float)
   * 
   * @return value float
   */
  public float getFloat() {
    switch (variant_native) {
      case VT_R4 :
        return ((Float)value).floatValue();
      default :
        throw new VariantTypeException(Translate.getString("VARIANT_TYPE_EXCEPTION"));
    }
  }
  
  /**
   * Set value (int)
   * 
   * @param value int
   */
  public void setInteger(int value) {
    this.value = new Integer(value);
    variant_native = VT_INT;
  }
  
  /**
   * Get value (int)
   * 
   * @return value int
   */
  public int getInteger() {
    switch (variant_native) {
      case VT_INT :
        return ((Integer)value).intValue();
      default :
        throw new VariantTypeException(Translate.getString("VARIANT_TYPE_EXCEPTION"));
    }
  }
  
  /**
   * Set value (boolean)
   * 
   * @param value boolean
   */
  public void setBoolean(boolean value) {
    this.value = new Boolean(value);
    variant_native = VT_BOOL;
  }
  
  /**
   * Get value (boolean)
   * 
   * @return value boolean
   */
  public boolean getBoolean() {
    switch (variant_native) {
      case VT_INT :
        return ((Boolean)value).booleanValue();
      default :
        throw new VariantTypeException(Translate.getString("VARIANT_TYPE_EXCEPTION"));
    }
  }
  
  /**
   * Set value (byte)
   * 
   * @param value byte
   */
  public void setByte(byte value) {
    this.value = new Byte(value);
    variant_native = VT_I1;
  }
  
  /**
   * Get value (byte)
   * 
   * @return value byte
   */
  public byte getByte() {
    switch (variant_native) {
      case VT_I1 :
        return ((Byte)value).byteValue();
      default :
        throw new VariantTypeException(Translate.getString("VARIANT_TYPE_EXCEPTION"));
    }
  }
  
  /**
   * Set value (short)
   * 
   * @param value short
   */
  public void setWord(short value) {
    this.value = new Short(value);
    variant_native = VT_I2;
  }
  
  /**
   * Get value (short)
   * 
   * @return value short
   */
  public short getWord() {
    switch (variant_native) {
      case VT_I2 :
        return ((Short)value).shortValue();
      default :
        throw new VariantTypeException(Translate.getString("VARIANT_TYPE_EXCEPTION"));
    }
  }
  
  /**
   * Set value (Date)
   * 
   * @param value Date
   */
  public void setDate(Date value) {
    this.value = value;
    variant_native = VT_DATE;
  }
  
  /**
   * Get value (Date)
   * 
   * @return value Date
   */
  public Date getDate() {
    switch (variant_native) {
      case VT_DATE :
        return (Date)value;
      default :
        throw new VariantTypeException(Translate.getString("VARIANT_TYPE_EXCEPTION"));
    }
  }
  
  /**
   * Set null value
   */
  public void setEmpty() {
    this.value = null;
    variant_native = VT_EMPTY;
  }
  
  /**
   * Check empty of variant instance
   * 
   * @return is empty, boolean
   */
  public boolean isEmpty() {
    switch (variant_native) {
      case VT_EMPTY :
      case VT_NULL :
        return true;
      default :
        return false;
    }
  }
  
  /**
   * Set value (Variant)
   * 
   * @param value Variant
   */
  public void setVariant(Variant value) {
    this.value = value;
    variant_native = VT_VARIANT;
  }
  
  /**
   * Get value (Variant)
   * 
   * @return value (Variant)
   */
  public Variant getVariant() {
    switch (variant_native) {
      case VT_VARIANT :
        return (Variant)value;
      default :
        throw new VariantTypeException(Translate.getString("VARIANT_TYPE_EXCEPTION"));
    }
  }
  
  /**
   * Set array (VT_ARRAY)
   * 
   * @param values VariantList
   */
  public void setArray(VariantList values) {
    this.value = values;
    variant_native = values.getVarType();
  }
  
  /**
   * Get array (VT_ARRAY)
   * 
   * @return elements VariantList
   */
  public VariantList getArray() {
    switch (variant_native & VT_ARRAY) {
      case VT_ARRAY :
        return (VariantList)value;
      default :
        throw new VariantTypeException(Translate.getString("VARIANT_TYPE_EXCEPTION"));
    }
  }
  
  @Override
  public String toString() {
    return (value != null) ? value.toString() : "";
  }
  
  /**
   * Return clone of Variant
   * 
   * @return item Object
   */
  public Object clone() {
    Variant var = null;
    try {
      var = (Variant) super.clone();
      // add attributes
      var.value = value;
      var.variant_native = variant_native;
    }
    catch (CloneNotSupportedException e) {
      System.err.println(e);
    }
    return var;
  }
  
  // compare not yet
  
  // equal not yet
  
  // hashcode not yet
  
  public static void main(String[] args) {
    Variant var = new Variant();
    VariantList vars = new VariantList(Variant.VT_R8);
    var.setArray(vars);
    System.out.println("TYPE: " + Variant.getVariantName(vars.getVarType()));
    System.out.println(var);
    
    Variant varin = new Variant(2.5);
    Variant varin2 = (Variant)varin.clone();
    varin.setString("Ahoj");
    System.out.println(varin);
    System.out.println(varin2);
  }
  
}
