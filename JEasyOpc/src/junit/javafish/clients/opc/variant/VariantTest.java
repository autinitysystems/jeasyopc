package javafish.clients.opc.variant;

import java.util.TreeSet;

import junit.framework.TestCase;

/**
 * JUnit test: Variant class tests 
 */
public class VariantTest extends TestCase {

  public void testCompareVariant() {
    Variant var1 = new Variant(2.0);
    Variant var2 = new Variant(2.0);
    assertEquals(var1, var2);
  }
  
  public void testCompareVariantArrays() {
    VariantList list1 = new VariantList(Variant.VT_R8);
    list1.add(new Variant(1.0));
    list1.add(new Variant(2.0));

    VariantList list2 = new VariantList(Variant.VT_R8);
    list2.add(new Variant(1.0));
    list2.add(new Variant(2.0));
    
    Variant var1 = new Variant(list1);
    Variant var2 = new Variant(list2);
    assertEquals(var1, var2);
  }
  
  public void testCompareTo() {
    Variant var1 = new Variant(2.0);
    Variant var2 = new Variant(-1.0);
    Variant var3 = new Variant(-3.0);
    
    // add variants to the list
    VariantList list = new VariantList(Variant.VT_R8);
    list.add(var1);
    list.add(var2);
    list.add(var3);
    
    // sort list
    TreeSet<Variant> set = new TreeSet<Variant>();
    set.addAll(list);
    Object[] array = set.toArray();
    
    // check order
    assertEquals(var3, array[0]);
    assertEquals(var2, array[1]);
    assertEquals(var1, array[2]);
  }
  
  public void testClone() {
    Variant var1 = new Variant(2.0f);
    Variant var2 = (Variant)var1.clone();
    assertEquals(var1, var2);
    
    VariantList list1 = new VariantList(Variant.VT_R8);
    list1.add(new Variant(1.0));
    list1.add(new Variant(2.0));

    VariantList list2 = new VariantList(Variant.VT_R8);
    list2.add(new Variant(1.0));
    list2.add(new Variant(2.0));
    
    var1 = new Variant(list1);
    var2 = new Variant(list2);
    assertEquals(var1, var2);
  }

  public void testVariant() {
    Variant var = new Variant();
    assertEquals("", var.getString());
    assertEquals(Variant.VT_EMPTY, var.getVariantType());
  }

  public void testVariantString() {
    Variant var = new Variant("Hello World");
    assertEquals("Hello World", var.getString());
    assertEquals(Variant.VT_BSTR, var.getVariantType());
  }

  public void testVariantDouble() {
    Variant var = new Variant(1.0);
    assertEquals(1.0, var.getDouble(), 0.0001);
    assertEquals(Variant.VT_R8, var.getVariantType());
  }

  public void testVariantFloat() {
    Variant var = new Variant(1.0f);
    assertEquals(1.0f, var.getFloat(), 0.0001);
    assertEquals(Variant.VT_R4, var.getVariantType());
  }

  public void testVariantInt() {
    Variant var = new Variant(1);
    assertEquals(1, var.getInteger());
    assertEquals(Variant.VT_INT, var.getVariantType());
  }

  public void testVariantBoolean() {
    Variant var = new Variant(true);
    assertEquals(true, var.getBoolean());
    assertEquals(Variant.VT_BOOL, var.getVariantType());
  }

  public void testVariantVariant() {
    Variant var = new Variant(new Variant(2.0));
    assertEquals(2.0, var.getDouble(), 0.0001);
    assertEquals(Variant.VT_R8, var.getVariantType());
  }

  public void testVariantByte() {
    Variant var = new Variant((byte)1);
    assertEquals((byte)1, var.getByte());
    assertEquals(Variant.VT_UI1, var.getVariantType());
  }

  public void testVariantShort() {
    Variant var = new Variant((short)1);
    assertEquals((short)1, var.getWord());
    assertEquals(Variant.VT_I2, var.getVariantType());
  }

  public void testVariantVariantList() {
    VariantList list = new VariantList(Variant.VT_R4);
    list.add(new Variant(1.0f));
    list.add(new Variant(2.0f));
    
    Variant var = new Variant(list);
    assertEquals(list, var.getArray());
    assertEquals(Variant.VT_ARRAY + Variant.VT_R4, var.getVariantType());
  }

  public void testGetVariantType() {
    Variant var = new Variant(1);
    assertEquals(Variant.VT_INT, var.getVariantType());
  }

  public void testGetDouble() {
    Variant var = new Variant(1.0);
    assertEquals(1.0, var.getDouble(), 0.0001);
    var = new Variant(1);
    assertEquals(1.0, var.getDouble(), 0.0001);
    var = new Variant(true);
    assertEquals(1.0, var.getDouble(), 0.0001);
    var = new Variant(false);
    assertEquals(0.0, var.getDouble(), 0.0001);
    var = new Variant(1.0f);
    assertEquals(1.0f, var.getDouble(), 0.0001);
  }

  public void testGetFloat() {
    Variant var = new Variant(1);
    assertEquals(1.0, var.getFloat(), 0.0001);
    var = new Variant(true);
    assertEquals(1.0, var.getFloat(), 0.0001);
    var = new Variant(false);
    assertEquals(0.0, var.getFloat(), 0.0001);
    var = new Variant(1.0f);
    assertEquals(1.0f, var.getFloat(), 0.0001);
  }

  public void testGetInteger() {
    Variant var = new Variant(1);
    assertEquals(1, var.getInteger(), 0.0001);
    var = new Variant(true);
    assertEquals(1, var.getInteger());
    var = new Variant(false);
    assertEquals(0, var.getInteger());
  }
  
  public void testIsEmpty() {
    Variant var = new Variant();
    assertEquals(true, var.isEmpty());
    
    var = new Variant(1.0);
    assertEquals(false, var.isEmpty());
  }

}
