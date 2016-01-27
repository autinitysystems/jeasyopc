unit JUtils;

interface

uses JNI;

function getInt(varib : string; PEnv: PJNIEnv; Obj: JObject) : JInt;
procedure setInt(varib : string; val : JInt; PEnv: PJNIEnv; Obj: JObject);
function throwException(PEnv: PJNIEnv; className, messageStr : PAnsiChar) : jint;

implementation

function getInt(varib : string; PEnv: PJNIEnv; Obj: JObject) : JInt;
var
  Cls : JClass;
  Env : TJNIEnv;
  FID : JFieldID;
begin
  // Create an instance of the Java environment
  Env := TJNIEnv.Create(PEnv);
  // Get the class associated with this object
  Cls := Env.GetObjectClass(Obj);
  // varib is a non-static integer field
  FID := Env.GetFieldID(Cls, PChar(varib), 'I');
  // Get the value of the integer
  Result := Env.GetIntField(Obj, FID);
  Env.Free;
end;


procedure setInt(varib : string; val : JInt; PEnv: PJNIEnv; Obj: JObject);
var
  Cls : JClass;
  Env : TJNIEnv;
  FID : JFieldID;
begin
  // Create an instance of the Java environment
  Env := TJNIEnv.Create(PEnv);
  // Get the class associated with this object
  Cls := Env.GetObjectClass(Obj);
  // varib is a non-static integer field
  FID := Env.GetFieldID(Cls, PChar(varib), 'I');
  // Get the value of the integer
  Env.SetIntField(Obj, FID, val);
  Env.Free;
end;

function throwException(PEnv: PJNIEnv; className, messageStr : PAnsiChar) : jint;
var
  Cls    : JClass;
  JVM    : TJNIEnv;
begin
  JVM := TJNIEnv.Create(PEnv);
  Cls := JVM.FindClass(className);
  Result := JVM.throwNew(Cls, messageStr);
  JVM.free;
end;

end.
