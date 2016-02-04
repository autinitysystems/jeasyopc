package javafish.clients.opc.variant;

import java.io.Serializable;
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
public class Variant extends VariantTypes implements Cloneable, Comparable, Serializable {
  private static final long serialVersionUID = 205031141436955384L;

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
  private void setString(String value) {
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
  private void setDouble(double value) {
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
      case VT_R4 :
        return ((Float)value).floatValue();
      case VT_INT :
        return ((Integer)value).intValue();
      case VT_BOOL :
        return ((Boolean)value).booleanValue() ? 1 : 0;
      case VT_I1 :
        return ((Byte)value).byteValue();
      case VT_UI1 :
        return ((Byte)value).byteValue();
      default :
        throw new VariantTypeException(Translate.getString("VARIANT_TYPE_EXCEPTION"));
    }
  }

  /**
   * Set value (float)
   * 
   * @param value float
   */
  private void setFloat(float value) {
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
      case VT_INT :
        return ((Integer)value).intValue();
      case VT_BOOL :
        return ((Boolean)value).booleanValue() ? 1 : 0;
      case VT_I1 :
        return ((Byte)value).byteValue();
      case VT_UI1 :
        return ((Byte)value).byteValue();
      default :
        throw new VariantTypeException(Translate.getString("VARIANT_TYPE_EXCEPTION"));
    }
  }
  
  /**
   * Set value (int)
   * 
   * @param value int
   */
  private void setInteger(int value) {
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
      case VT_BOOL :
        return ((Boolean)value).booleanValue() ? 1 : 0;
      case VT_I1 :
        return ((Byte)value).byteValue();
      case VT_UI1 :
        return ((Byte)value).byteValue();
      default :
        throw new VariantTypeException(Translate.getString("VARIANT_TYPE_EXCEPTION"));
    }
  }
  
  /**
   * Set value (boolean)
   * 
   * @param value boolean
   */
  private void setBoolean(boolean value) {
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
      case VT_BOOL :
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
  private void setByte(byte value) {
    this.value = new Byte(value);
    variant_native = VT_UI1;
  }
  
  /**
   * Get value (byte)
   * 
   * @return value byte
   */
  public byte getByte() {
    switch (variant_native) {
      case VT_UI1 :
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
  private void setWord(short value) {
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
   * Set array (VT_ARRAY)
   * 
   * @param values VariantList
   */
  private void setArray(VariantList values) {
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
  
  /**
   * Set value (Variant)
   * 
   * @param value Variant
   */
  private void setVariant(Variant value) {
    variant_native = value.getVariantType();
    // set data
    switch (variant_native) {
      case VT_ARRAY:
        setArray(value.getArray());
        return;
      case VT_BOOL:
        setBoolean(value.getBoolean());
        return;
      case VT_LPSTR:
      case VT_LPWSTR:
      case VT_BSTR:
        setString(value.getString());
        break;
      case VT_I1:
        setByte(value.getByte());
        return;
      case VT_I2:
        setWord(value.getWord());
        return;
      case VT_INT:
        setInteger(value.getInteger());
        return;
      case VT_R4:
        setFloat(value.getFloat());
        return;
      case VT_R8:
        setDouble(value.getDouble());
        return;
      case VT_CY:
      case VT_DECIMAL:
      case VT_I4:
      case VT_I8:
      case VT_UI1:
      case VT_UI2:
      case VT_UI4:
      case VT_UI8:
      case VT_UINT:
      case VT_BLOB:
      case VT_BLOB_OBJECT:
      case VT_NULL:
      case VT_EMPTY:
        // not supported
        value = null;
        variant_native = VT_EMPTY;
        return;
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
  
  @SuppressWarnings("unchecked")
  public int compareTo(Object o) {
    if ((value instanceof Comparable) &&
       (((Variant)o).value instanceof Comparable)) {
      return ((Comparable)value).compareTo(((Variant)o).value);
    } else {
      throw new VariantTypeException(Translate.getString("VARIANT_TYPE_COMPARE_EXCEPTION"));
    }
  }
  
  @Override
  public boolean equals(Object obj) {
    if (obj == this)
      return true;
    if (obj instanceof Variant == false)
      return false;
    
    boolean sameValue = (value.equals(((Variant)obj).value));
    boolean sameType  = (variant_native == ((Variant)obj).variant_native);
    
    return (sameValue && sameType);
  }
  
  @Override
  public int hashCode() {
    int result = 17;
    result = 37 * result + value.hashCode();
    result = 37 * result + variant_native;
    return result;
  }
  
}
