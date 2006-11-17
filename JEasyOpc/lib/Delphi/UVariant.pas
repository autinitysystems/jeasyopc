unit UVariant;

interface

uses SysUtils, JNI, Variants, Classes, ActiveX, UOPCExceptions;

// commit native variant to java representation
function variantCommit(PEnv: PJNIEnv; varin : Variant) : JObject;
// update native variant from java representation
function variantUpdate(PEnv: PJNIEnv; varin : JObject) : Variant;
// create java VariantList from Variant array
function createVariantList(PEnv: PJNIEnv; varArray : Variant) : JObject;
// create Variant array from java VariantList
function createVariantArray(PEnv: PJNIEnv; variantList : JObject) : Variant;

implementation

function variantCommit(PEnv: PJNIEnv; varin : Variant) : JObject;
var
  Cls: JClass;
  Mid: JMethodID;
  args: array[0..0] of JValue;
  msyntax : string;
  JVM: TJNIEnv;
begin
  JVM := TJNIEnv.Create(PEnv);

  case VarType(varin) of
   varEmpty: begin
     // not supported -> string
     msyntax := '(Ljava/lang/String;)V';
     args[0].l := JVM.StringToJString(PAnsiChar(VarToStr(varin)));
   end;
   varNull: begin
     // not supported -> string
     msyntax := '(Ljava/lang/String;)V';
     args[0].l := JVM.StringToJString(PAnsiChar(VarToStr(varin)));
   end;
   varSmallint: begin
     msyntax := '(S)V';
     args[0].s := varin;   end;
   varInteger: begin
     msyntax := '(I)V';
     args[0].i := varin;   end;
   varSingle: begin
     msyntax := '(F)V';
     args[0].f := varin;   end;
   varDouble: begin
    msyntax := '(D)V';
    args[0].d := varin;   end;
   varCurrency: begin
     // not supported -> string
     msyntax := '(Ljava/lang/String;)V';
     args[0].l := JVM.StringToJString(PAnsiChar(VarToStr(varin)));
   end;
   varDate: begin
     // not supported -> string
     msyntax := '(Ljava/lang/String;)V';
     args[0].l := JVM.StringToJString(PAnsiChar(VarToStr(varin)));
   end;
   varOleStr: begin
     msyntax := '(Ljava/lang/String;)V';
     args[0].l := JVM.StringToJString(PAnsiChar(VarToStr(varin)));
   end;
   varDispatch: begin
     // not supported -> string
     msyntax := '(Ljava/lang/String;)V';
     args[0].l := JVM.StringToJString(PAnsiChar(VarToStr(varin)));
   end;
   varError: begin
     // not supported -> string
     msyntax := '(Ljava/lang/String;)V';
     args[0].l := JVM.StringToJString(PAnsiChar(VarToStr(varin)));
   end;
   varBoolean: begin
     msyntax := '(Z)V';
     args[0].z := varin;   end;
   varVariant: begin
     msyntax := '(Ljavafish/clients/opc/variant/Variant;)V';
     args[0].l := variantCommit(PEnv, varin);
   end;
   varUnknown: begin
     // not supported -> string
     msyntax := '(Ljava/lang/String;)V';
     args[0].l := JVM.StringToJString(PAnsiChar(VarToStr(varin)));
   end;
   varShortInt: begin
     msyntax := '(I)V';
     args[0].i := varin;   end;
   varByte: begin
     msyntax := '(B)V';
     args[0].b := varin;   end;
   varWord: begin
     msyntax := '(S)V';
     args[0].s := varin;   end;
   varLongWord: begin
     msyntax := '(S)V';
     args[0].s := varin;   end;
   varInt64: begin
     // not supported -> string
     msyntax := '(Ljava/lang/String;)V';
     args[0].l := JVM.StringToJString(PAnsiChar(VarToStr(varin)));
   end;
   varStrArg: begin
     msyntax := '(Ljava/lang/String;)V';
     args[0].l := JVM.StringToJString(PAnsiChar(VarToStr(varin)));
   end;
   varString: begin
     msyntax := '(Ljava/lang/String;)V';
     args[0].l := JVM.StringToJString(PAnsiChar(VarToStr(varin)));
   end;
  end;

  // variant list
  if VarIsArray(varin)
  then begin
    msyntax := '(Ljavafish/clients/opc/variant/VariantList;)V';
    args[0].l := createVariantList(PEnv, varin);
  end;

  // Find the Variant class
  Cls := JVM.FindClass('javafish/clients/opc/variant/Variant');
  if Cls = nil
  then raise VariantInternalException.Create('Class not found.');

  // Get correct constructor
  Mid := JVM.GetMethodID(Cls, '<init>', PAnsiChar(msyntax));
  if Mid = nil
  then raise VariantInternalException.Create('Method not found.');

  // Create a new Variant instance
  Result := JVM.NewObjectA(Cls, Mid, @args);

  VarClear(varin);
  JVM.free;
end;

function variantUpdate(PEnv: PJNIEnv; varin : JObject) : Variant;
type
  types = (VINTEGER, VFLOAT, VDOUBLE, VSTRING, VEMPTY, VNULL, VBOOLEAN,
           VVARIANT, VBYTE, VSHORT, VARRAY);
var
  JVM        : TJNIEnv;
  Cls        : JClass;
  FID        : JFieldID;
  varinClass : JClass;
  GetMid     : JMethodID;
  methodID   : string;
  output     : string;
  vtype      : types;
  vtemp      : Variant;
begin
  JVM := TJNIEnv.Create(PEnv);

  // get variant_native
  varinClass := JVM.GetObjectClass(varin);
  FID := JVM.GetFieldID(varinClass, 'variant_native', 'I');

  // standard string format
  methodID := 'getString';
  output := '()Ljava/lang/String;';

  // prepare transformation
  case JVM.GetIntField(varin, FID) of
   VT_EMPTY: begin
     vtype := VEMPTY;
   end;
   VT_NULL: begin
     vtype := VNULL;
   end;
   VT_INT: begin
     methodID := 'getInteger';
     output := '()I';
     vtype := VINTEGER;
   end;
   VT_R4: begin
     methodID := 'getFloat';
     output := '()F';
     vtype := VFLOAT;
   end;
   VT_R8: begin
     methodID := 'getDouble';
     output := '()D';
     vtype := VDOUBLE;
   end;
   VT_CY: begin
     // not supported -> string
     methodID := 'getString';
     output := '()Ljava/lang/String;';
     vtype := VSTRING;
   end;
   VT_DATE: begin
     // not supported -> string
     methodID := 'getString';
     output := '()Ljava/lang/String;';
     vtype := VSTRING;
   end;
   VT_DISPATCH: begin
     // not supported -> string
     methodID := 'getString';
     output := '()Ljava/lang/String;';
     vtype := VSTRING;
   end;
   VT_ERROR: begin
     // not supported -> string
     methodID := 'getString';
     output := '()Ljava/lang/String;';
     vtype := VSTRING;
   end;
   VT_BOOL: begin
     methodID := 'getBoolean';
     output := '()Z';
     vtype := VBOOLEAN;   end;   VT_VARIANT: begin
     methodID := 'getVariant';
     output := '()Ljavafish/clients/opc/variant/Variant;';
     vtype := VVARIANT;   end;
   VT_UNKNOWN: begin
     // not supported -> string
     methodID := 'getString';
     output := '()Ljava/lang/String;';
     vtype := VSTRING;
   end;
   VT_I1: begin
     methodID := 'getByte';
     output := '()B';
     vtype := VBYTE;
   end;
   VT_I2: begin
     methodID := 'getWord';
     output := '()S';
     vtype := VSHORT;
   end;
   VT_I4: begin
     methodID := 'getInteger';
     output := '()I';
     vtype := VINTEGER;
   end;
   VT_I8: begin
     // not supported -> string
     methodID := 'getString';
     output := '()Ljava/lang/String;';
     vtype := VSTRING;
   end;
   VT_UI1: begin
     methodID := 'getByte';
     output := '()B';
     vtype := VBYTE;
   end;
   VT_LPSTR: begin
     methodID := 'getString';
     output := '()Ljava/lang/String;';
     vtype := VSTRING;
   end;
   VT_LPWSTR: begin
     methodID := 'getString';
     output := '()Ljava/lang/String;';
     vtype := VSTRING;
   end;
   VT_BSTR: begin
     methodID := 'getString';
     output := '()Ljava/lang/String;';
     vtype := VSTRING;
   end;
  end;

  // check array type
  if (JVM.GetIntField(varin, FID) and varArray) = varArray
  then begin
    methodID := 'getArray';
    output := '()Ljavafish/clients/opc/variant/VariantList;';
    vtype := VARRAY;
  end;

  // Get correct data method
  if (vtype <> VEMPTY) and (vtype <> VNULL)
  then begin
    GetMid := JVM.GetMethodID(varinClass, PAnsiChar(methodID), PAnsiChar(output));
    if GetMid = nil
    then raise VariantInternalException.Create('Method not found.');
  end;

  // call method and capture output
  case vtype of
    VINTEGER: Result := JVM.CallIntMethodA(varin, GetMid, nil);
    VDOUBLE:  Result := JVM.CallDoubleMethodA(varin, GetMid, nil);
    VSTRING:  Result := JVM.JStringToString(JVM.CallObjectMethodA(varin, GetMid, nil));
    VBOOLEAN: Result := JVM.CallBooleanMethodA(varin, GetMid, nil);
    VEMPTY:   Result := VT_EMPTY;
    VNULL:    Result := VT_NULL;
    VBYTE:    begin
      vtemp  := JVM.CallByteMethodA(varin, GetMid, nil);
      Result := VarAsType(vtemp, VT_UI1);
    end;
    VVARIANT: begin
      Result := variantUpdate(PEnv, JVM.CallObjectMethodA(varin, GetMid, nil));
    end;
    VSHORT: begin
      vtemp := JVM.CallShortMethodA(varin, GetMid, nil);
      Result := VarAsType(vtemp, VT_I2);
    end;
    VFLOAT: begin
      vtemp  := JVM.CallFloatMethodA(varin, GetMid, nil);
      Result := VarAsType(vtemp, VT_R4);
    end;
    VARRAY: begin
      Result := createVariantArray(PEnv, JVM.CallObjectMethodA(varin, GetMid, nil));
    end;
  end;

  JVM.free;
end;

// create java Variant list
function createVariantList(PEnv: PJNIEnv; varArray : Variant) : JObject;
var J,I : integer;
    jvarin : JObject;
    jlist  : JObject;
    JVM: TJNIEnv;
    Cls: JClass;
    Mid: JMethodID;
    AddMid : JMethodID;
    args: array[0..0] of JValue;
begin
  // create VariantList
  JVM := TJNIEnv.Create(PEnv);
  Cls := JVM.FindClass('Ljavafish/clients/opc/variant/VariantList;');
  if Cls = nil
  then raise VariantInternalException.Create('Class not found.');

  // Get correct constructor
  Mid := JVM.GetMethodID(Cls, '<init>', '(I)V');
  if Mid = nil
  then raise VariantInternalException.Create('Method not found.');

  // Get correct constructor
  AddMid := JVM.GetMethodID(Cls, 'add', '(Ljava/lang/Object;)Z');
  if AddMid = nil
  then raise VariantInternalException.Create('Method not found.');

  // Create a new Variant instance
  args[0].i := VarType(varArray) and varTypeMask;
  jlist := JVM.NewObjectA(Cls, Mid, @args);

  // add elements
  J := VarArrayDimCount(varArray);
  for I := VarArrayLowBound(varArray, J)
        to VarArrayHighBound(varArray, J) do
  begin
    // create Variant java instance
    jvarin := variantCommit(PEnv, varArray[I]);
    // add instance to the list
    args[0].l := jvarin;
    JVM.CallObjectMethodA(jlist, AddMid, @args);
  end;

  Result := jlist;

  JVM.free;
end;

// create Variant array from java VariantList
function createVariantArray(PEnv: PJNIEnv; variantList : JObject) : Variant;
var
  i            : integer;
  JVM          : TJNIEnv;
  Cls          : JClass;
  ArrayMid     : JMethodID;
  aitems       : JObjectArray;
  itemsCount   : integer;
  varin        : JObject;
  varinNative  : Variant;
  itemClass    : JClass;
  firstElement : boolean;
  varinArray   : Variant;
begin
  // create VariantList
  JVM := TJNIEnv.Create(PEnv);
  Cls := JVM.FindClass('Ljavafish/clients/opc/variant/VariantList;');
  if Cls = nil
  then raise VariantInternalException.Create('Class not found.');

  // get method of array of variant
  ArrayMid := JVM.GetMethodID(Cls, 'getVariantListAsArray',
    '()[Ljavafish/clients/opc/variant/Variant;');
  if ArrayMid = nil
  then raise VariantInternalException.Create('Method not found.');

  aitems := JArray(JVM.CallObjectMethodA(variantList, ArrayMid, nil));
  itemsCount := JVM.GetArrayLength(aitems);
  firstElement := true;

  for i:=0 to itemsCount-1 do
  begin
    // get item from list (Variant instance)
    varin := JVM.GetObjectArrayElement(aitems, i);
    // create variant from java instance
    varinNative := variantUpdate(PEnv, varin);
    // store to the Variant array
    if firstElement
    then begin
      varinArray := VarArrayCreate([0, itemsCount-1], VarType(varinNative));
      firstElement := false;
    end;
    VarArrayPut(varinArray, varinNative, i);
  end;
  JVM.free;
  
  // return variant array or empty
  if firstElement = false
  then Result := varinArray
  else Result := VT_EMPTY;
end;

end.
