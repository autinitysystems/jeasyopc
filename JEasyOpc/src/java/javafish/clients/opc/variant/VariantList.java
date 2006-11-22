package javafish.clients.opc.variant;

import java.util.ArrayList;

/**
 * ArrayList of variants 
 */
public class VariantList extends ArrayList<Variant> {
  private static final long serialVersionUID = -3797571063094058671L;
  
  /** type of list */
  private int varType;
  
  /**
   * Create new instance of VariantList
   * 
   * @param varType Variant type of this list (Variant.xxx type)
   */
  public VariantList(int varType) {
    this.varType = Variant.VT_ARRAY + (varType & Variant.VT_TYPEMASK);
  }
  
  /**
   * Get variant type of list
   * 
   * @return var type, int
   */
  public int getVarType() {
    return varType;
  }
  
  /**
   * Get variant list as array of Variant
   * 
   * @return variant array Variant[]
   */
  public Variant[] getVariantListAsArray() {
    Variant[] arrayVarin = new Variant[size()];
    for (int i = 0; i < arrayVarin.length; i++) {
      arrayVarin[i] = (Variant)get(i);
    }
    return arrayVarin;
  }
}
