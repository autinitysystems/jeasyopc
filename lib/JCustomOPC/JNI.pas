{******************************************************************}
{                                                                  }
{       Borland Delphi Runtime Library                             }
{       Java Native Interface Unit                                 }
{                                                                  }
{ Portions created by Sun are                                      }
{ Copyright (C) 1996-1999 Sun Microsystems, Inc.,                  }
{ 901 San Antonio Road, Palo Alto, California, 94303, U.S.A.       }
{ All Rights Reserved.                                             }
{                                                                  }
{ The original file is: jni.h, released 22 Apr 1999.               }
{ The original Pascal code is: jni.pas, released 01 Sep 2000.      }
{                                                                  }
{ Portions created by Matthew Mead are                             }
{ Copyright (C) 2001 MMG and Associates                            }
{                                                                  }
{ Obtained through:                                                }
{ Joint Endeavour of Delphi Innovators (Project JEDI)              }
{                                                                  }
{ You may retrieve the latest version of this file at the Project  }
{ JEDI home page, located at http://delphi-jedi.org                }
{                                                                  }
{ The contents of this file are used with permission, subject to   }
{ the Mozilla Public License Version 1.1 (the "License"); you may  }
{ not use this file except in compliance with the License. You may }
{ obtain a copy of the License at                                  }
{ http://www.mozilla.org/NPL/NPL-1_1Final.html                     }
{                                                                  }
{ Software distributed under the License is distributed on an      }
{ "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or   }
{ implied. See the License for the specific language governing     }
{ rights and limitations under the License.                        }
{                                                                  }
{ History:                                                         }
{   03 Dec 2000 - Fixed parameters for DestroyJavaVM, GetEnv,      }
{                 AttachCurrentThread, and DetachCurrentThread     }
{   02 Jan 2001 - Fix in TJNIEnv.ArgsToJValues. Cast AnsiString    }
{                 to JString.                                      }
{                                                                  }
{******************************************************************}

unit JNI;

interface

uses
  {$IFDEF WIN32}
  Windows,
  {$ENDIF}
  {$IFDEF LINUX}
  Types, Libc,
  {$ENDIF}
  SysUtils;

{ Note:
  It is possible to include the defintions from JNI_MD.INC directly
  in this file. However, the idea behind separating platform-specific
  definitions is to keep this file as generic as possible. Some time
  ago, this would not have been important, since Delphi *was* a
  Windows-only tool. Now, with Kylix approaching, it will be important
  to keep the platform-specific types separate.
}

// JNI_MD.INC contains the machine-dependent typedefs for JByte, JInt and JLong

{$INCLUDE JNI_MD.INC}

{$IFDEF LINUX}
type
  va_list = PChar;
{$ENDIF}

const
  JNI_VERSION_1_1 = JInt($00010001);
  {$EXTERNALSYM JNI_VERSION_1_1}
  JNI_VERSION_1_2 = JInt($00010002);
  {$EXTERNALSYM JNI_VERSION_1_2}

  // JBoolean constants
  JNI_TRUE  = True;
  {$EXTERNALSYM JNI_TRUE}
  JNI_FALSE = False;
  {$EXTERNALSYM JNI_FALSE}

  // possible return values for JNI functions.
  JNI_OK        =  0;  // success
  {$EXTERNALSYM JNI_OK}
  JNI_ERR       = -1;  // unknown error
  {$EXTERNALSYM JNI_ERR}
  JNI_EDETACHED = -2;  // thread detached from the VM
  {$EXTERNALSYM JNI_EDETACHED}
  JNI_EVERSION  = -3;  // JNI version error
  {$EXTERNALSYM JNI_EVERSION}
  JNI_ENOMEM    = -4;  // not enough memory
  {$EXTERNALSYM JNI_ENOMEM}
  JNI_EEXIST    = -5;  // VM already created
  {$EXTERNALSYM JNI_EEXIST}
  JNI_EINVAL    = -6;  // invalid arguments
  {$EXTERNALSYM JNI_EINVAL}

  JNI_ENOJAVA   = -101; // local error for not finding the DLL

  // used in ReleaseScalarArrayElements
  JNI_COMMIT = 1;
  {$EXTERNALSYM JNI_COMMIT}
  JNI_ABORT  = 2;
  {$EXTERNALSYM JNI_ABORT}

type
  // JNI Types
  JBoolean = Boolean;
  JChar    = WideChar;
  JShort   = Smallint;
  JFloat   = Single;
  JDouble  = Double;
  JSize    = JInt;

  _JObject = record
  end;

  JObject       = ^_JObject;
  JClass        = JObject;
  JThrowable    = JObject;
  JString       = JObject;
  JArray        = JObject;
  JBooleanArray = JArray;
  JByteArray    = JArray;
  JCharArray    = JArray;
  JShortArray   = JArray;
  JIntArray     = JArray;
  JLongArray    = JArray;
  JFloatArray   = JArray;
  JDoubleArray  = JArray;
  JObjectArray  = JArray;

  JWeak = JObject;
  JRef  = JObject;

  JValue = packed record
  case Integer of
    0: (z: JBoolean);
    1: (b: JByte   );
    2: (c: JChar   );
    3: (s: JShort  );
    4: (i: JInt    );
    5: (j: JLong   );
    6: (f: JFloat  );
    7: (d: JDouble );
    8: (l: JObject );
  end;

  JFieldID = ^_JFieldID;
  _JFieldID = record
  end;

  JMethodID = ^_JMethodID;
  _JMethodID = record
  end;

  PPointer       = ^Pointer;
  PJByte         = ^JByte;
  PJBoolean      = ^JBoolean;
  PJChar         = ^JChar;
  PJShort        = ^JShort;
  PJInt          = ^JInt;
  PJLong         = ^JLong;
  PJFloat        = ^JFloat;
  PJDouble       = ^JDouble;
  PJString       = ^JString;
  PJSize         = ^JSize;
  PJClass        = ^JClass;
  PJObject       = ^JObject;
  PJThrowable    = ^JThrowable;
  PJArray        = ^JArray;
  PJByteArray    = ^JByteArray;
  PJBooleanArray = ^JBooleanArray;
  PJCharArray    = ^JCharArray;
  PJShortArray   = ^JShortArray;
  PJIntArray     = ^JIntArray;
  PJLongArray    = ^JLongArray;
  PJFloatArray   = ^JFloatArray;
  PJDoubleArray  = ^JDoubleArray;
  PJObjectArray  = ^JObjectArray;
  PJFieldID      = ^JFieldID;
  PJMethodID     = ^JMethodID;
  PJValue        = ^JValue;
  PJWeak         = ^JWeak;
  PJRef          = ^JRef;

  // used in RegisterNatives to describe native method name, signature,
  // and function pointer.
  PJNINativeMethod = ^JNINativeMethod;
  JNINativeMethod = packed record
    name: PAnsiChar;
    signature: PAnsiChar;
    fnPtr: Pointer;
  end;
  {$EXTERNALSYM JNINativeMethod}

  // JNI Native Method Interface.
  JNIEnv              = ^JNINativeInterface_;
  {$EXTERNALSYM JNIEnv}
  PJNIEnv             = ^JNIEnv;
  PPJNIEnv            = ^PJNIEnv;
  PJNINativeInterface = ^JNINativeInterface_;

  // JNI Invocation Interface.
  JavaVM              = ^JNIInvokeInterface_;
  {$EXTERNALSYM JavaVM}
  PJNIInvokeInterface = ^JNIInvokeInterface_;
  PJavaVM             = ^JavaVM;

  JNINativeInterface_ = packed record
    reserved0: Pointer;
    reserved1: Pointer;
    reserved2: Pointer;
    reserved3: Pointer;

    GetVersion: function(Env: PJNIEnv): JInt; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    DefineClass: function(Env: PJNIEnv; const Name: PAnsiChar; Loader: JObject; const Buf: PJByte; Len: JSize): JClass; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    FindClass: function(Env: PJNIEnv; const Name: PAnsiChar): JClass; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    // Reflection Support
    FromReflectedMethod: function(Env: PJNIEnv; Method: JObject): JMethodID; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    FromReflectedField: function(Env: PJNIEnv; Field: JObject): JFieldID; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    ToReflectedMethod: function(Env: PJNIEnv; AClass: JClass; MethodID: JMethodID; IsStatic: JBoolean): JObject; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    GetSuperclass: function(Env: PJNIEnv; Sub: JClass): JClass; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    IsAssignableFrom: function(Env: PJNIEnv; Sub: JClass; Sup: JClass): JBoolean; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    // Reflection Support
    ToReflectedField: function(Env: PJNIEnv; AClass: JClass; FieldID: JFieldID; IsStatic: JBoolean): JObject; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    Throw: function(Env: PJNIEnv; Obj: JThrowable): JInt; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    ThrowNew: function(Env: PJNIEnv; AClass: JClass; const Msg: PAnsiChar): JInt; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    ExceptionOccurred: function(Env: PJNIEnv): JThrowable; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    ExceptionDescribe: procedure(Env: PJNIEnv); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    ExceptionClear: procedure(Env: PJNIEnv); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    FatalError: procedure(Env: PJNIEnv; const Msg: PAnsiChar); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    // Local Reference Management
    PushLocalFrame: function(Env: PJNIEnv; Capacity: JInt): JInt; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    PopLocalFrame: function(Env: PJNIEnv; Result: JObject): JObject; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    NewGlobalRef: function(Env: PJNIEnv; LObj: JObject): JObject; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    DeleteGlobalRef: procedure(Env: PJNIEnv; GRef: JObject); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    DeleteLocalRef: procedure(Env: PJNIEnv; Obj: JObject); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    IsSameObject: function(Env: PJNIEnv; Obj1: JObject; Obj2: JObject): JBoolean; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    // Local Reference Management
    NewLocalRef: function(Env: PJNIEnv; Ref: JObject): JObject; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    EnsureLocalCapacity: function(Env: PJNIEnv; Capacity: JInt): JObject; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    AllocObject: function(Env: PJNIEnv; AClass: JClass): JObject; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    NewObject: function(Env: PJNIEnv; AClass: JClass; MethodID: JMethodID): JObject; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    NewObjectV: function(Env: PJNIEnv; AClass: JClass; MethodID: JMethodID; Args: va_list): JObject; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    NewObjectA: function(Env: PJNIEnv; AClass: JClass; MethodID: JMethodID; Args: PJValue): JObject; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    GetObjectClass: function(Env: PJNIEnv; Obj: JObject): JClass; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    IsInstanceOf: function(Env: PJNIEnv; Obj: JObject; AClass: JClass): JBoolean; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    GetMethodID: function(Env: PJNIEnv; AClass: JClass; const Name: PAnsiChar; const Sig: PAnsiChar): JMethodID; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    CallObjectMethod: function(Env: PJNIEnv; Obj: JObject; MethodID: JMethodID): JObject; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    CallObjectMethodV: function(Env: PJNIEnv; Obj: JObject; MethodID: JMethodID; Args: va_list): JObject; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    CallObjectMethodA: function(Env: PJNIEnv; Obj: JObject; MethodID: JMethodID; Args: PJValue): JObject; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    CallBooleanMethod: function(Env: PJNIEnv; Obj: JObject; MethodID: JMethodID): JBoolean; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    CallBooleanMethodV: function(Env: PJNIEnv; Obj: JObject; MethodID: JMethodID; Args: va_list): JBoolean; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    CallBooleanMethodA: function(Env: PJNIEnv; Obj: JObject; MethodID: JMethodID; Args: PJValue): JBoolean; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    CallByteMethod: function(Env: PJNIEnv; Obj: JObject; MethodID: JMethodID): JByte; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    CallByteMethodV: function(Env: PJNIEnv; Obj: JObject; MethodID: JMethodID; Args: va_list): JByte; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    CallByteMethodA: function(Env: PJNIEnv; Obj: JObject; MethodID: JMethodID; Args: PJValue): JByte; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    CallCharMethod: function(Env: PJNIEnv; Obj: JObject; MethodID: JMethodID): JChar; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    CallCharMethodV: function(Env: PJNIEnv; Obj: JObject; MethodID: JMethodID; Args: va_list): JChar; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    CallCharMethodA: function(Env: PJNIEnv; Obj: JObject; MethodID: JMethodID; Args: PJValue): JChar; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    CallShortMethod: function(Env: PJNIEnv; Obj: JObject; MethodID: JMethodID): JShort; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    CallShortMethodV: function(Env: PJNIEnv; Obj: JObject; MethodID: JMethodID; Args: va_list): JShort; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    CallShortMethodA: function(Env: PJNIEnv; Obj: JObject; MethodID: JMethodID; Args: PJValue): JShort; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    CallIntMethod: function(Env: PJNIEnv; Obj: JObject; MethodID: JMethodID): JInt; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    CallIntMethodV: function(Env: PJNIEnv; Obj: JObject; MethodID: JMethodID; Args: va_list): JInt; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    CallIntMethodA: function(Env: PJNIEnv; Obj: JObject; MethodID: JMethodID; Args: PJValue): JInt; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    CallLongMethod: function(Env: PJNIEnv; Obj: JObject; MethodID: JMethodID): JLong; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    CallLongMethodV: function(Env: PJNIEnv; Obj: JObject; MethodID: JMethodID; Args: va_list): JLong; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    CallLongMethodA: function(Env: PJNIEnv; Obj: JObject; MethodID: JMethodID; Args: PJValue): JLong; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    CallFloatMethod: function(Env: PJNIEnv; Obj: JObject; MethodID: JMethodID): JFloat; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    CallFloatMethodV: function(Env: PJNIEnv; Obj: JObject; MethodID: JMethodID; Args: va_list): JFloat; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    CallFloatMethodA: function(Env: PJNIEnv; Obj: JObject; MethodID: JMethodID; Args: PJValue): JFloat; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    CallDoubleMethod: function(Env: PJNIEnv; Obj: JObject; MethodID: JMethodID): JDouble; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    CallDoubleMethodV: function(Env: PJNIEnv; Obj: JObject; MethodID: JMethodID; Args: va_list): JDouble; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    CallDoubleMethodA: function(Env: PJNIEnv; Obj: JObject; MethodID: JMethodID; Args: PJValue): JDouble; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    CallVoidMethod: procedure(Env: PJNIEnv; Obj: JObject; MethodID: JMethodID); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    CallVoidMethodV: procedure(Env: PJNIEnv; Obj: JObject; MethodID: JMethodID; Args: va_list); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    CallVoidMethodA: procedure(Env: PJNIEnv; Obj: JObject; MethodID: JMethodID; Args: PJValue); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    CallNonvirtualObjectMethod: function(Env: PJNIEnv; Obj: JObject; AClass: JClass; MethodID: JMethodID): JObject; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    CallNonvirtualObjectMethodV: function(Env: PJNIEnv; Obj: JObject; AClass: JClass; MethodID: JMethodID; Args: va_list): JObject; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    CallNonvirtualObjectMethodA: function(Env: PJNIEnv; Obj: JObject; AClass: JClass; MethodID: JMethodID; Args: PJValue): JObject; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    CallNonvirtualBooleanMethod: function(Env: PJNIEnv; Obj: JObject; AClass: JClass; MethodID: JMethodID): JBoolean; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    CallNonvirtualBooleanMethodV: function(Env: PJNIEnv; Obj: JObject; AClass: JClass; MethodID: JMethodID; Args: va_list): JBoolean; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    CallNonvirtualBooleanMethodA: function(Env: PJNIEnv; Obj: JObject; AClass: JClass; MethodID: JMethodID; Args: PJValue): JBoolean; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    CallNonvirtualByteMethod: function(Env: PJNIEnv; Obj: JObject; AClass: JClass; MethodID: JMethodID): JByte; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    CallNonvirtualByteMethodV: function(Env: PJNIEnv; Obj: JObject; AClass: JClass; MethodID: JMethodID; Args: va_list): JByte; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    CallNonvirtualByteMethodA: function(Env: PJNIEnv; Obj: JObject; AClass: JClass; MethodID: JMethodID; Args: PJValue): JByte; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    CallNonvirtualCharMethod: function(Env: PJNIEnv; Obj: JObject; AClass: JClass; MethodID: JMethodID): JChar; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    CallNonvirtualCharMethodV: function(Env: PJNIEnv; Obj: JObject; AClass: JClass; MethodID: JMethodID; Args: va_list): JChar; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    CallNonvirtualCharMethodA: function(Env: PJNIEnv; Obj: JObject; AClass: JClass; MethodID: JMethodID; Args: PJValue): JChar; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    CallNonvirtualShortMethod: function(Env: PJNIEnv; Obj: JObject; AClass: JClass; MethodID: JMethodID): JShort; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    CallNonvirtualShortMethodV: function(Env: PJNIEnv; Obj: JObject; AClass: JClass; MethodID: JMethodID; Args: va_list): JShort; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    CallNonvirtualShortMethodA: function(Env: PJNIEnv; Obj: JObject; AClass: JClass; MethodID: JMethodID; Args: PJValue): JShort; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    CallNonvirtualIntMethod: function(Env: PJNIEnv; Obj: JObject; AClass: JClass; MethodID: JMethodID): JInt; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    CallNonvirtualIntMethodV: function(Env: PJNIEnv; Obj: JObject; AClass: JClass; MethodID: JMethodID; Args: va_list): JInt; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    CallNonvirtualIntMethodA: function(Env: PJNIEnv; Obj: JObject; AClass: JClass; MethodID: JMethodID; Args: PJValue): JInt; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    CallNonvirtualLongMethod: function(Env: PJNIEnv; Obj: JObject; AClass: JClass; MethodID: JMethodID): JLong; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    CallNonvirtualLongMethodV: function(Env: PJNIEnv; Obj: JObject; AClass: JClass; MethodID: JMethodID; Args: va_list): JLong; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    CallNonvirtualLongMethodA: function(Env: PJNIEnv; Obj: JObject; AClass: JClass; MethodID: JMethodID; Args: PJValue): JLong; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    CallNonvirtualFloatMethod: function(Env: PJNIEnv; Obj: JObject; AClass: JClass; MethodID: JMethodID): JFloat; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    CallNonvirtualFloatMethodV: function(Env: PJNIEnv; Obj: JObject; AClass: JClass; MethodID: JMethodID; Args: va_list): JFloat; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    CallNonvirtualFloatMethodA: function(Env: PJNIEnv; Obj: JObject; AClass: JClass; MethodID: JMethodID; Args: PJValue): JFloat; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    CallNonvirtualDoubleMethod: function(Env: PJNIEnv; Obj: JObject; AClass: JClass; MethodID: JMethodID): JDouble; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    CallNonvirtualDoubleMethodV: function(Env: PJNIEnv; Obj: JObject; AClass: JClass; MethodID: JMethodID; Args: va_list): JDouble; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    CallNonvirtualDoubleMethodA: function(Env: PJNIEnv; Obj: JObject; AClass: JClass; MethodID: JMethodID; Args: PJValue): JDouble; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    CallNonvirtualVoidMethod: procedure(Env: PJNIEnv; Obj: JObject; AClass: JClass; MethodID: JMethodID); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    CallNonvirtualVoidMethodV: procedure(Env: PJNIEnv; Obj: JObject; AClass: JClass; MethodID: JMethodID; Args: va_list); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    CallNonvirtualVoidMethodA: procedure(Env: PJNIEnv; Obj: JObject; AClass: JClass; MethodID: JMethodID; Args: PJValue); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    GetFieldID: function(Env: PJNIEnv; AClass: JClass; const Name: PAnsiChar; const Sig: PAnsiChar): JFieldID; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    GetObjectField: function(Env: PJNIEnv; Obj: JObject; FieldID: JFieldID): JObject; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    GetBooleanField: function(Env: PJNIEnv; Obj: JObject; FieldID: JFieldID): JBoolean; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    GetByteField: function(Env: PJNIEnv; Obj: JObject; FieldID: JFieldID): JByte; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    GetCharField: function(Env: PJNIEnv; Obj: JObject; FieldID: JFieldID): JChar; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    GetShortField: function(Env: PJNIEnv; Obj: JObject; FieldID: JFieldID): JShort; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    GetIntField: function(Env: PJNIEnv; Obj: JObject; FieldID: JFieldID): JInt; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    GetLongField: function(Env: PJNIEnv; Obj: JObject; FieldID: JFieldID): JLong; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    GetFloatField: function(Env: PJNIEnv; Obj: JObject; FieldID: JFieldID): JFloat; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    GetDoubleField: function(Env: PJNIEnv; Obj: JObject; FieldID: JFieldID): JDouble; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    SetObjectField: procedure(Env: PJNIEnv; Obj: JObject; FieldID: JFieldID; Val: JObject); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    SetBooleanField: procedure(Env: PJNIEnv; Obj: JObject; FieldID: JFieldID; Val: JBoolean); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    SetByteField: procedure(Env: PJNIEnv; Obj: JObject; FieldID: JFieldID; Val: JByte); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    SetCharField: procedure(Env: PJNIEnv; Obj: JObject; FieldID: JFieldID; Val: JChar); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    SetShortField: procedure(Env: PJNIEnv; Obj: JObject; FieldID: JFieldID; Val: JShort); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    SetIntField: procedure(Env: PJNIEnv; Obj: JObject; FieldID: JFieldID; Val: JInt); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    SetLongField: procedure(Env: PJNIEnv; Obj: JObject; FieldID: JFieldID; Val: JLong); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    SetFloatField: procedure(Env: PJNIEnv; Obj: JObject; FieldID: JFieldID; Val: JFloat); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    SetDoubleField: procedure(Env: PJNIEnv; Obj: JObject; FieldID: JFieldID; Val: JDouble); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    GetStaticMethodID: function(Env: PJNIEnv; AClass: JClass; const Name: PAnsiChar; const Sig: PAnsiChar): JMethodID; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    CallStaticObjectMethod: function(Env: PJNIEnv; AClass: JClass; MethodID: JMethodID): JObject; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    CallStaticObjectMethodV: function(Env: PJNIEnv; AClass: JClass; MethodID: JMethodID; Args: va_list): JObject; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    CallStaticObjectMethodA: function(Env: PJNIEnv; AClass: JClass; MethodID: JMethodID; Args: PJValue): JObject; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    CallStaticBooleanMethod: function(Env: PJNIEnv; AClass: JClass; MethodID: JMethodID): JBoolean; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    CallStaticBooleanMethodV: function(Env: PJNIEnv; AClass: JClass; MethodID: JMethodID; Args: va_list): JBoolean; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    CallStaticBooleanMethodA: function(Env: PJNIEnv; AClass: JClass; MethodID: JMethodID; Args: PJValue): JBoolean; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    CallStaticByteMethod: function(Env: PJNIEnv; AClass: JClass; MethodID: JMethodID): JByte; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    CallStaticByteMethodV: function(Env: PJNIEnv; AClass: JClass; MethodID: JMethodID; Args: va_list): JByte; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    CallStaticByteMethodA: function(Env: PJNIEnv; AClass: JClass; MethodID: JMethodID; Args: PJValue): JByte; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    CallStaticCharMethod: function(Env: PJNIEnv; AClass: JClass; MethodID: JMethodID): JChar; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    CallStaticCharMethodV: function(Env: PJNIEnv; AClass: JClass; MethodID: JMethodID; Args: va_list): JChar; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    CallStaticCharMethodA: function(Env: PJNIEnv; AClass: JClass; MethodID: JMethodID; Args: PJValue): JChar; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    CallStaticShortMethod: function(Env: PJNIEnv; AClass: JClass; MethodID: JMethodID): JShort; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    CallStaticShortMethodV: function(Env: PJNIEnv; AClass: JClass; MethodID: JMethodID; Args: va_list): JShort; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    CallStaticShortMethodA: function(Env: PJNIEnv; AClass: JClass; MethodID: JMethodID; Args: PJValue): JShort; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    CallStaticIntMethod: function(Env: PJNIEnv; AClass: JClass; MethodID: JMethodID): JInt; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    CallStaticIntMethodV: function(Env: PJNIEnv; AClass: JClass; MethodID: JMethodID; Args: va_list): JInt; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    CallStaticIntMethodA: function(Env: PJNIEnv; AClass: JClass; MethodID: JMethodID; Args: PJValue): JInt; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    CallStaticLongMethod: function(Env: PJNIEnv; AClass: JClass; MethodID: JMethodID): JLong; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    CallStaticLongMethodV: function(Env: PJNIEnv; AClass: JClass; MethodID: JMethodID; Args: va_list): JLong; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    CallStaticLongMethodA: function(Env: PJNIEnv; AClass: JClass; MethodID: JMethodID; Args: PJValue): JLong; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    CallStaticFloatMethod: function(Env: PJNIEnv; AClass: JClass; MethodID: JMethodID): JFloat; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    CallStaticFloatMethodV: function(Env: PJNIEnv; AClass: JClass; MethodID: JMethodID; Args: va_list): JFloat; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    CallStaticFloatMethodA: function(Env: PJNIEnv; AClass: JClass; MethodID: JMethodID; Args: PJValue): JFloat; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    CallStaticDoubleMethod: function(Env: PJNIEnv; AClass: JClass; MethodID: JMethodID): JDouble; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    CallStaticDoubleMethodV: function(Env: PJNIEnv; AClass: JClass; MethodID: JMethodID; Args: va_list): JDouble; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    CallStaticDoubleMethodA: function(Env: PJNIEnv; AClass: JClass; MethodID: JMethodID; Args: PJValue): JDouble; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    CallStaticVoidMethod: procedure(Env: PJNIEnv; AClass: JClass; MethodID: JMethodID); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    CallStaticVoidMethodV: procedure(Env: PJNIEnv; AClass: JClass; MethodID: JMethodID; Args: va_list); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    CallStaticVoidMethodA: procedure(Env: PJNIEnv; AClass: JClass; MethodID: JMethodID; Args: PJValue); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    GetStaticFieldID: function(Env: PJNIEnv; AClass: JClass; const Name: PAnsiChar; const Sig: PAnsiChar): JFieldID; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    GetStaticObjectField: function(Env: PJNIEnv; AClass: JClass; FieldID: JFieldID): JObject; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    GetStaticBooleanField: function(Env: PJNIEnv; AClass: JClass; FieldID: JFieldID): JBoolean; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    GetStaticByteField: function(Env: PJNIEnv; AClass: JClass; FieldID: JFieldID): JByte; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    GetStaticCharField: function(Env: PJNIEnv; AClass: JClass; FieldID: JFieldID): JChar; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    GetStaticShortField: function(Env: PJNIEnv; AClass: JClass; FieldID: JFieldID): JShort; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    GetStaticIntField: function(Env: PJNIEnv; AClass: JClass; FieldID: JFieldID): JInt; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    GetStaticLongField: function(Env: PJNIEnv; AClass: JClass; FieldID: JFieldID): JLong; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    GetStaticFloatField: function(Env: PJNIEnv; AClass: JClass; FieldID: JFieldID): JFloat; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    GetStaticDoubleField: function(Env: PJNIEnv; AClass: JClass; FieldID: JFieldID): JDouble; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    SetStaticObjectField: procedure(Env: PJNIEnv; AClass: JClass; FieldID: JFieldID; Val: JObject); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    SetStaticBooleanField: procedure(Env: PJNIEnv; AClass: JClass; FieldID: JFieldID; Val: JBoolean); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    SetStaticByteField: procedure(Env: PJNIEnv; AClass: JClass; FieldID: JFieldID; Val: JByte); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    SetStaticCharField: procedure(Env: PJNIEnv; AClass: JClass; FieldID: JFieldID; Val: JChar); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    SetStaticShortField: procedure(Env: PJNIEnv; AClass: JClass; FieldID: JFieldID; Val: JShort); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    SetStaticIntField: procedure(Env: PJNIEnv; AClass: JClass; FieldID: JFieldID; Val: JInt); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    SetStaticLongField: procedure(Env: PJNIEnv; AClass: JClass; FieldID: JFieldID; Val: JLong); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    SetStaticFloatField: procedure(Env: PJNIEnv; AClass: JClass; FieldID: JFieldID; Val: JFloat); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    SetStaticDoubleField: procedure(Env: PJNIEnv; AClass: JClass; FieldID: JFieldID; Val: JDouble); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    NewString: function(Env: PJNIEnv; const Unicode: PJChar; Len: JSize): JString; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    GetStringLength: function(Env: PJNIEnv; Str: JString): JSize; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    GetStringChars: function(Env: PJNIEnv; Str: JString; var IsCopy: JBoolean): PJChar; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    ReleaseStringChars: procedure(Env: PJNIEnv; Str: JString; const Chars: PJChar); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    NewStringUTF: function(Env: PJNIEnv; const UTF: PAnsiChar): JString; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    GetStringUTFLength: function(Env: PJNIEnv; Str: JString): JSize; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    GetStringUTFChars: function(Env: PJNIEnv; Str: JString; var IsCopy: JBoolean): PAnsiChar; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    ReleaseStringUTFChars: procedure(Env: PJNIEnv; Str: JString; const Chars: PAnsiChar); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    GetArrayLength: function(Env: PJNIEnv; AArray: JArray): JSize; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    NewObjectArray: function(Env: PJNIEnv; Len: JSize; AClass: JClass; Init: JObject): JObjectArray; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    GetObjectArrayElement: function(Env: PJNIEnv; AArray: JObjectArray; Index: JSize): JObject; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    SetObjectArrayElement: procedure(Env: PJNIEnv; AArray: JObjectArray; Index: JSize; Val: JObject); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    NewBooleanArray: function(Env: PJNIEnv; Len: JSize): JBooleanArray; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    NewByteArray: function(Env: PJNIEnv; Len: JSize): JByteArray; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    NewCharArray: function(Env: PJNIEnv; Len: JSize): JCharArray; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    NewShortArray: function(Env: PJNIEnv; Len: JSize): JShortArray; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    NewIntArray: function(Env: PJNIEnv; Len: JSize): JIntArray; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    NewLongArray: function(Env: PJNIEnv; Len: JSize): JLongArray; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    NewFloatArray: function(Env: PJNIEnv; Len: JSize): JFloatArray; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    NewDoubleArray: function(Env: PJNIEnv; Len: JSize): JDoubleArray; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    GetBooleanArrayElements: function(Env: PJNIEnv; AArray: JBooleanArray; var IsCopy: JBoolean): PJBoolean; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    GetByteArrayElements: function(Env: PJNIEnv; AArray: JByteArray; var IsCopy: JBoolean): PJByte; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    GetCharArrayElements: function(Env: PJNIEnv; AArray: JCharArray; var IsCopy: JBoolean): PJChar; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    GetShortArrayElements: function(Env: PJNIEnv; AArray: JShortArray; var IsCopy: JBoolean): PJShort; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    GetIntArrayElements: function(Env: PJNIEnv; AArray: JIntArray; var IsCopy: JBoolean): PJInt; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    GetLongArrayElements: function(Env: PJNIEnv; AArray: JLongArray; var IsCopy: JBoolean): PJLong; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    GetFloatArrayElements: function(Env: PJNIEnv; AArray: JFloatArray; var IsCopy: JBoolean): PJFloat; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    GetDoubleArrayElements: function(Env: PJNIEnv; AArray: JDoubleArray; var IsCopy: JBoolean): PJDouble; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    ReleaseBooleanArrayElements: procedure(Env: PJNIEnv; AArray: JBooleanArray; Elems: PJBoolean; Mode: JInt); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    ReleaseByteArrayElements: procedure(Env: PJNIEnv; AArray: JByteArray; Elems: PJByte; Mode: JInt); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    ReleaseCharArrayElements: procedure(Env: PJNIEnv; AArray: JCharArray; Elems: PJChar; Mode: JInt); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    ReleaseShortArrayElements: procedure(Env: PJNIEnv; AArray: JShortArray; Elems: PJShort; Mode: JInt); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    ReleaseIntArrayElements: procedure(Env: PJNIEnv; AArray: JIntArray; Elems: PJInt; Mode: JInt); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    ReleaseLongArrayElements: procedure(Env: PJNIEnv; AArray: JLongArray; Elems: PJLong; Mode: JInt); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    ReleaseFloatArrayElements: procedure(Env: PJNIEnv; AArray: JFloatArray; Elems: PJFloat; Mode: JInt); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    ReleaseDoubleArrayElements: procedure(Env: PJNIEnv; AArray: JDoubleArray; Elems: PJDouble; Mode: JInt); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    GetBooleanArrayRegion: procedure(Env: PJNIEnv; AArray: JBooleanArray; Start: JSize; Len: JSize; Buf: PJBoolean); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    GetByteArrayRegion: procedure(Env: PJNIEnv; AArray: JByteArray; Start: JSize; Len: JSize; Buf: PJByte); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    GetCharArrayRegion: procedure(Env: PJNIEnv; AArray: JCharArray; Start: JSize; Len: JSize; Buf: PJChar); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    GetShortArrayRegion: procedure(Env: PJNIEnv; AArray: JShortArray; Start: JSize; Len: JSize; Buf: PJShort); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    GetIntArrayRegion: procedure(Env: PJNIEnv; AArray: JIntArray; Start: JSize; Len: JSize; Buf: PJInt); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    GetLongArrayRegion: procedure(Env: PJNIEnv; AArray: JLongArray; Start: JSize; Len: JSize; Buf: PJLong); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    GetFloatArrayRegion: procedure(Env: PJNIEnv; AArray: JFloatArray; Start: JSize; Len: JSize; Buf: PJFloat); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    GetDoubleArrayRegion: procedure(Env: PJNIEnv; AArray: JDoubleArray; Start: JSize; Len: JSize; Buf: PJDouble); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    SetBooleanArrayRegion: procedure(Env: PJNIEnv; AArray: JBooleanArray; Start: JSize; Len: JSize; Buf: PJBoolean); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    SetByteArrayRegion: procedure(Env: PJNIEnv; AArray: JByteArray; Start: JSize; Len: JSize; Buf: PJByte); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    SetCharArrayRegion: procedure(Env: PJNIEnv; AArray: JCharArray; Start: JSize; Len: JSize; Buf: PJChar); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    SetShortArrayRegion: procedure(Env: PJNIEnv; AArray: JShortArray; Start: JSize; Len: JSize; Buf: PJShort); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    SetIntArrayRegion: procedure(Env: PJNIEnv; AArray: JIntArray; Start: JSize; Len: JSize; Buf: PJInt); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    SetLongArrayRegion: procedure(Env: PJNIEnv; AArray: JLongArray; Start: JSize; Len: JSize; Buf: PJLong); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    SetFloatArrayRegion: procedure(Env: PJNIEnv; AArray: JFloatArray; Start: JSize; Len: JSize; Buf: PJFloat); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    SetDoubleArrayRegion: procedure(Env: PJNIEnv; AArray: JDoubleArray; Start: JSize; Len: JSize; Buf: PJDouble); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    RegisterNatives: function(Env: PJNIEnv; AClass: JClass; const Methods: PJNINativeMethod; NMethods: JInt): JInt; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    UnregisterNatives: function(Env: PJNIEnv; AClass: JClass): JInt; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    MonitorEnter: function(Env: PJNIEnv; Obj: JObject): JInt; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    MonitorExit: function(Env: PJNIEnv; Obj: JObject): JInt; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    GetJavaVM: function(Env: PJNIEnv; var VM: JavaVM): JInt; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    // String Operations
    GetStringRegion: procedure(Env: PJNIEnv; Str: JString; Start: JSize; Len: JSize; Buf: PJChar); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    GetStringUTFRegion: procedure(Env: PJNIEnv; Str: JString; Start: JSize; Len: JSize; Buf: PAnsiChar); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    // Array Operations
    GetPrimitiveArrayCritical: function(Env: PJNIEnv; AArray: JArray; var IsCopy: JBoolean): Pointer; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    ReleasePrimitiveArrayCritical: procedure(Env: PJNIEnv; AArray: JArray; CArray: Pointer; Mode: JInt); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    // String Operations
    GetStringCritical: function(Env: PJNIEnv; Str: JString; var IsCopy: JBoolean): PJChar; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    ReleaseStringCritical: procedure(Env: PJNIEnv; Str: JString; CString: PJChar); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    // Weak Global References
    NewWeakGlobalRef: function(Env: PJNIEnv; Obj: JObject): JWeak; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    DeleteWeakGlobalRef: procedure(Env: PJNIEnv; Ref: JWeak); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    // Exceptions
    ExceptionCheck: function(Env: PJNIEnv): JBoolean; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
  end;
  {$EXTERNALSYM JNINativeInterface_}

  // Invocation API

  PJavaVMOption = ^JavaVMOption;
  JavaVMOption = packed record
    optionString: PAnsiChar;
    extraInfo: Pointer;
  end;
  {$EXTERNALSYM JavaVMOption}

  PJavaVMInitArgs = ^JavaVMInitArgs;
  JavaVMInitArgs = packed record
    version: JInt;
    nOptions: JInt;
    options: PJavaVMOption;
    ignoreUnrecognized: JBoolean;
  end;
  {$EXTERNALSYM JavaVMInitArgs}

  PJavaVMAttachArgs = ^JavaVMAttachArgs;
  JavaVMAttachArgs = packed record
    version: JInt;
    name: PAnsiChar;
    group: JObject;
  end;
  {$EXTERNALSYM JavaVMAttachArgs}

  {$IFDEF WIN32}
  TIOFile = Pointer; // (rom) for Kylix compatibility
  {$ENDIF}

  // These structures will be VM-specific.
  PJDK1_1InitArgs = ^JDK1_1InitArgs;
  JDK1_1InitArgs = packed record
    version: JInt;
    properties: ^PAnsiChar;
    checkSource: JInt;
    nativeStackSize: JInt;
    javaStackSize: JInt;
    minHeapSize: JInt;
    maxHeapSize: JInt;
    verifyMode: JInt;
    classpath: PAnsiChar;

    vfprintf: function(FP: TIOFile; const Format: PAnsiChar; Args: va_list): JInt; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    exit: procedure(Code: JInt); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    abort: procedure; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    enableClassGC: JInt;
    enableVerboseGC: JInt;
    disableAsyncGC: JInt;
    verbose: JInt;
    debugging: JBoolean;
    debugPort: JInt;
  end;
  {$EXTERNALSYM JDK1_1InitArgs}

  JDK1_1AttachArgs = packed record
    __padding: Pointer;
  end;
  {$EXTERNALSYM JDK1_1AttachArgs}

  // End VM-specific.

  JNIInvokeInterface_ = packed record
    reserved0: Pointer;
    reserved1: Pointer;
    reserved2: Pointer;

    DestroyJavaVM: function(PVM: PJavaVM): JInt; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    AttachCurrentThread: function(PVM: PJavaVM; PEnv: PPJNIEnv; Args: Pointer): JInt; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
    DetachCurrentThread: function(PVM: PJavaVM): JInt; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

    GetEnv: function(PVM: PJavaVM; PEnv: PPointer; Version: JInt): JInt; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
  end;
  {$EXTERNALSYM JNIInvokeInterface_}

  // Defined by native libraries.
  TJNI_OnLoad = function(PVM: PJavaVM; Reserved: Pointer): JInt; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
  TJNI_OnUnload = procedure(PVM: PJavaVM; Reserved: Pointer); {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

{$IFDEF DYNAMIC_LINKING}
function JNI_GetDefaultJavaVMInitArgs(Args: PJDK1_1InitArgs; const JVMDLLFile: string): JInt;
{$EXTERNALSYM JNI_GetDefaultJavaVMInitArgs}
function JNI_CreateJavaVM(PJVM: PJavaVM; PEnv: PPointer; Args: Pointer; const JVMDLLFile: string): JInt;
{$EXTERNALSYM JNI_CreateJavaVM}
function JNI_GetCreatedJavaVMs(PJVM: PJavaVM; JSize1: JSize; var JSize2: JSize; const JVMDLLFile: string): JInt;
{$EXTERNALSYM JNI_GetCreatedJavaVMs}
{$ELSE}
function JNI_GetDefaultJavaVMInitArgs(Args: Pointer): JInt; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
{$EXTERNALSYM JNI_GetDefaultJavaVMInitArgs}
function JNI_CreateJavaVM(PJVM: PJavaVM; PEnv: PPointer; Args: Pointer): JInt; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
{$EXTERNALSYM JNI_CreateJavaVM}
function JNI_GetCreatedJavaVMs(PJVM: PJavaVM; JSize1: JSize; var JSize2: JSize): JInt; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
{$EXTERNALSYM JNI_GetCreatedJavaVMs}
{$ENDIF}

// Wrapper stuff
type
  TJValueArray = array of JValue;

  EJVMError = class(Exception);
  EJNIError = class(Exception);
  EJNIUnsupportedMethodError = class(EJNIError);

  TJNI_GetDefaultJavaVMInitArgs = function(Args: Pointer): JInt; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
  TJNI_CreateJavaVM = function(PJVM: PJavaVM; PEnv: PPointer; Args: Pointer): JInt; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}
  TJNI_GetCreatedJavaVMs = function(PJVM: PJavaVM; JSize1: JSize; var JSize2: JSize): JInt; {$IFDEF WIN32} stdcall; {$ENDIF} {$IFDEF LINUX} cdecl; {$ENDIF}

  TJavaVM = class(TObject)
  private
    FJavaVM: PJavaVM;
    FEnv: PJNIEnv;
    FJavaVMInitArgs: JavaVMInitArgs;
    FJDK1_1InitArgs: JDK1_1InitArgs;
    FJVMDLLFile: string;

    FVersion: JInt;
    {$IFDEF WIN32}
    FDLLHandle: THandle;
    {$ENDIF}
    {$IFDEF LINUX}
    FDLLHandle: Pointer;
    {$ENDIF}
    FIsInitialized: Boolean;

    // DLL functions
    FJNI_GetDefaultJavaVMInitArgs: TJNI_GetDefaultJavaVMInitArgs;
    FJNI_CreateJavaVM:             TJNI_CreateJavaVM;
    FJNI_GetCreatedJavaVMs:        TJNI_GetCreatedJavaVMs;

    procedure SetVersion(const Value: JInt);
  public
    property JavaVM: PJavaVM read FJavaVM;
    property Env: PJNIEnv read FEnv;
    property JDK1_1InitArgs: JDK1_1InitArgs read FJDK1_1InitArgs;
    property JDK1_2InitArgs: JavaVMInitArgs read FJavaVMInitArgs;
    property Version: JInt read FVersion write SetVersion;

    // Constructors
    constructor Create; overload;
    constructor Create(JDKVersion: Integer); overload;
    constructor Create(JDKVersion: Integer; const JVMDLLFilename: string); overload;

    destructor Destroy; override;
    function LoadVM(const Options: JDK1_1InitArgs): JInt; overload;
    function LoadVM(const Options: JavaVMInitArgs): JInt; overload;
    function GetDefaultJavaVMInitArgs(Args: PJDK1_1InitArgs): JInt;
    function GetCreatedJavaVMs(PJVM: PJavaVM; JSize1: JSize; var JSize2: JSize): JInt;
  end;

  TJNIEnv = class(TObject)
  private
    FEnv: PJNIEnv;
    FMajorVersion: JInt;
    FMinorVersion: JInt;
    FVersion: JInt;
    FConvertedArgs: TJValueArray;
    function GetMajorVersion: JInt;
    function GetMinorVersion: JInt;
    procedure VersionCheck(const FuncName: string; RequiredVersion: JInt);
  public
    // Properties
    property Env: PJNIEnv read FEnv;
    property MajorVersion: JInt read FMajorVersion;
    property MinorVersion: JInt read FMinorVersion;
    property Version: JInt read FVersion;

    // Constructors
    constructor Create(AEnv: PJNIEnv);

    // Support methods
    function ArgsToJValues(const Args: array of const): PJValue;
    function JStringToString(JStr: JString): string;
    function StringToJString(const AString: PAnsiChar): JString;
    function UnicodeJStringToString(JStr: JString): string;
    function StringToUnicodeJString(const AString: PAnsiChar): JString;

    // JNIEnv methods
    function GetVersion: JInt;
    function DefineClass(const Name: PAnsiChar; Loader: JObject; const Buf: PJByte; Len: JSize): JClass;
    function FindClass(const Name: PAnsiChar): JClass;

    // Reflection Support
    function FromReflectedMethod(Method: JObject): JMethodID;
    function FromReflectedField(Field: JObject): JFieldID;
    function ToReflectedMethod(AClass: JClass; MethodID: JMethodID; IsStatic: JBoolean): JObject;

    function GetSuperclass(Sub: JClass): JClass;
    function IsAssignableFrom(Sub: JClass; Sup: JClass): JBoolean;

    // Reflection Support
    function ToReflectedField(AClass: JClass; FieldID: JFieldID; IsStatic: JBoolean): JObject;

    function Throw(Obj: JThrowable): JInt;
    function ThrowNew(AClass: JClass; const Msg: PAnsiChar): JInt;
    function ExceptionOccurred: JThrowable;
    procedure ExceptionDescribe;
    procedure ExceptionClear;
    procedure FatalError(const Msg: PAnsiChar);

    // Local Reference Management
    function PushLocalFrame(Capacity: JInt): JInt;
    function PopLocalFrame(AResult: JObject): JObject;

    function NewGlobalRef(LObj: JObject): JObject;
    procedure DeleteGlobalRef(GRef: JObject);
    procedure DeleteLocalRef(Obj: JObject);
    function IsSameObject(Obj1: JObject; Obj2: JObject): JBoolean;

    // Local Reference Management
    function NewLocalRef(Ref: JObject): JObject;
    function EnsureLocalCapacity(Capacity: JInt): JObject;

    function AllocObject(AClass: JClass): JObject;
    function NewObject(AClass: JClass; MethodID: JMethodID; const Args: array of const): JObject;
    function NewObjectV(AClass: JClass; MethodID: JMethodID; Args: va_list): JObject;
    function NewObjectA(AClass: JClass; MethodID: JMethodID; Args: PJValue): JObject;

    function GetObjectClass(Obj: JObject): JClass;
    function IsInstanceOf(Obj: JObject; AClass: JClass): JBoolean;

    function GetMethodID(AClass: JClass; const Name: PAnsiChar; const Sig: PAnsiChar): JMethodID;

    function CallObjectMethod(Obj: JObject; MethodID: JMethodID; const Args: array of const): JObject;
    function CallObjectMethodV(Obj: JObject; MethodID: JMethodID; Args: va_list): JObject;
    function CallObjectMethodA(Obj: JObject; MethodID: JMethodID; Args: PJValue): JObject;

    function CallBooleanMethod(Obj: JObject; MethodID: JMethodID; const Args: array of const): JBoolean;
    function CallBooleanMethodV(Obj: JObject; MethodID: JMethodID; Args: va_list): JBoolean;
    function CallBooleanMethodA(Obj: JObject; MethodID: JMethodID; Args: PJValue): JBoolean;

    function CallByteMethod(Obj: JObject; MethodID: JMethodID; const Args: array of const): JByte;
    function CallByteMethodV(Obj: JObject; MethodID: JMethodID; Args: va_list): JByte;
    function CallByteMethodA(Obj: JObject; MethodID: JMethodID; Args: PJValue): JByte;

    function CallCharMethod(Obj: JObject; MethodID: JMethodID; const Args: array of const): JChar;
    function CallCharMethodV(Obj: JObject; MethodID: JMethodID; Args: va_list): JChar;
    function CallCharMethodA(Obj: JObject; MethodID: JMethodID; Args: PJValue): JChar;

    function CallShortMethod(Obj: JObject; MethodID: JMethodID; const Args: array of const): JShort;
    function CallShortMethodV(Obj: JObject; MethodID: JMethodID; Args: va_list): JShort;
    function CallShortMethodA(Obj: JObject; MethodID: JMethodID; Args: PJValue): JShort;

    function CallIntMethod(Obj: JObject; MethodID: JMethodID; const Args: array of const): JInt;
    function CallIntMethodV(Obj: JObject; MethodID: JMethodID; Args: va_list): JInt;
    function CallIntMethodA(Obj: JObject; MethodID: JMethodID; Args: PJValue): JInt;

    function CallLongMethod(Obj: JObject; MethodID: JMethodID; const Args: array of const): JLong;
    function CallLongMethodV(Obj: JObject; MethodID: JMethodID; Args: va_list): JLong;
    function CallLongMethodA(Obj: JObject; MethodID: JMethodID; Args: PJValue): JLong;

    function CallFloatMethod(Obj: JObject; MethodID: JMethodID; const Args: array of const): JFloat;
    function CallFloatMethodV(Obj: JObject; MethodID: JMethodID; Args: va_list): JFloat;
    function CallFloatMethodA(Obj: JObject; MethodID: JMethodID; Args: PJValue): JFloat;

    function CallDoubleMethod(Obj: JObject; MethodID: JMethodID; const Args: array of const): JDouble;
    function CallDoubleMethodV(Obj: JObject; MethodID: JMethodID; Args: va_list): JDouble;
    function CallDoubleMethodA(Obj: JObject; MethodID: JMethodID; Args: PJValue): JDouble;

    procedure CallVoidMethod(Obj: JObject; MethodID: JMethodID; const Args: array of const);
    procedure CallVoidMethodV(Obj: JObject; MethodID: JMethodID; Args: va_list);
    procedure CallVoidMethodA(Obj: JObject; MethodID: JMethodID; Args: PJValue);

    function CallNonvirtualObjectMethod(Obj: JObject; AClass: JClass; MethodID: JMethodID; const Args: array of const): JObject;
    function CallNonvirtualObjectMethodV(Obj: JObject; AClass: JClass; MethodID: JMethodID; Args: va_list): JObject;
    function CallNonvirtualObjectMethodA(Obj: JObject; AClass: JClass; MethodID: JMethodID; Args: PJValue): JObject;

    function CallNonvirtualBooleanMethod(Obj: JObject; AClass: JClass; MethodID: JMethodID; const Args: array of const): JBoolean;
    function CallNonvirtualBooleanMethodV(Obj: JObject; AClass: JClass; MethodID: JMethodID; Args: va_list): JBoolean;
    function CallNonvirtualBooleanMethodA(Obj: JObject; AClass: JClass; MethodID: JMethodID; Args: PJValue): JBoolean;

    function CallNonvirtualByteMethod(Obj: JObject; AClass: JClass; MethodID: JMethodID; const Args: array of const): JByte;
    function CallNonvirtualByteMethodV(Obj: JObject; AClass: JClass; MethodID: JMethodID; Args: va_list): JByte;
    function CallNonvirtualByteMethodA(Obj: JObject; AClass: JClass; MethodID: JMethodID; Args: PJValue): JByte;

    function CallNonvirtualCharMethod(Obj: JObject; AClass: JClass; MethodID: JMethodID; const Args: array of const): JChar;
    function CallNonvirtualCharMethodV(Obj: JObject; AClass: JClass; MethodID: JMethodID; Args: va_list): JChar;
    function CallNonvirtualCharMethodA(Obj: JObject; AClass: JClass; MethodID: JMethodID; Args: PJValue): JChar;

    function CallNonvirtualShortMethod(Obj: JObject; AClass: JClass; MethodID: JMethodID; const Args: array of const): JShort;
    function CallNonvirtualShortMethodV(Obj: JObject; AClass: JClass; MethodID: JMethodID; Args: va_list): JShort;
    function CallNonvirtualShortMethodA(Obj: JObject; AClass: JClass; MethodID: JMethodID; Args: PJValue): JShort;

    function CallNonvirtualIntMethod(Obj: JObject; AClass: JClass; MethodID: JMethodID; const Args: array of const): JInt;
    function CallNonvirtualIntMethodV(Obj: JObject; AClass: JClass; MethodID: JMethodID; Args: va_list): JInt;
    function CallNonvirtualIntMethodA(Obj: JObject; AClass: JClass; MethodID: JMethodID; Args: PJValue): JInt;

    function CallNonvirtualLongMethod(Obj: JObject; AClass: JClass; MethodID: JMethodID; const Args: array of const): JLong;
    function CallNonvirtualLongMethodV(Obj: JObject; AClass: JClass; MethodID: JMethodID; Args: va_list): JLong;
    function CallNonvirtualLongMethodA(Obj: JObject; AClass: JClass; MethodID: JMethodID; Args: PJValue): JLong;

    function CallNonvirtualFloatMethod(Obj: JObject; AClass: JClass; MethodID: JMethodID; const Args: array of const): JFloat;
    function CallNonvirtualFloatMethodV(Obj: JObject; AClass: JClass; MethodID: JMethodID; Args: va_list): JFloat;
    function CallNonvirtualFloatMethodA(Obj: JObject; AClass: JClass; MethodID: JMethodID; Args: PJValue): JFloat;

    function CallNonvirtualDoubleMethod(Obj: JObject; AClass: JClass; MethodID: JMethodID; const Args: array of const): JDouble;
    function CallNonvirtualDoubleMethodV(Obj: JObject; AClass: JClass; MethodID: JMethodID; Args: va_list): JDouble;
    function CallNonvirtualDoubleMethodA(Obj: JObject; AClass: JClass; MethodID: JMethodID; Args: PJValue): JDouble;

    procedure CallNonvirtualVoidMethod(Obj: JObject; AClass: JClass; MethodID: JMethodID; const Args: array of const);
    procedure CallNonvirtualVoidMethodV(Obj: JObject; AClass: JClass; MethodID: JMethodID; Args: va_list);
    procedure CallNonvirtualVoidMethodA(Obj: JObject; AClass: JClass; MethodID: JMethodID; Args: PJValue);

    function GetFieldID(AClass: JClass; const Name: PAnsiChar; const Sig: PAnsiChar): JFieldID;

    function GetObjectField(Obj: JObject; FieldID: JFieldID): JObject;
    function GetBooleanField(Obj: JObject; FieldID: JFieldID): JBoolean;
    function GetByteField(Obj: JObject; FieldID: JFieldID): JByte;
    function GetCharField(Obj: JObject; FieldID: JFieldID): JChar;
    function GetShortField(Obj: JObject; FieldID: JFieldID): JShort;
    function GetIntField(Obj: JObject; FieldID: JFieldID): JInt;
    function GetLongField(Obj: JObject; FieldID: JFieldID): JLong;
    function GetFloatField(Obj: JObject; FieldID: JFieldID): JFloat;
    function GetDoubleField(Obj: JObject; FieldID: JFieldID): JDouble;

    procedure SetObjectField(Obj: JObject; FieldID: JFieldID; Val: JObject);
    procedure SetBooleanField(Obj: JObject; FieldID: JFieldID; Val: JBoolean);
    procedure SetByteField(Obj: JObject; FieldID: JFieldID; Val: JByte);
    procedure SetCharField(Obj: JObject; FieldID: JFieldID; Val: JChar);
    procedure SetShortField(Obj: JObject; FieldID: JFieldID; Val: JShort);
    procedure SetIntField(Obj: JObject; FieldID: JFieldID; Val: JInt);
    procedure SetLongField(Obj: JObject; FieldID: JFieldID; Val: JLong);
    procedure SetFloatField(Obj: JObject; FieldID: JFieldID; Val: JFloat);
    procedure SetDoubleField(Obj: JObject; FieldID: JFieldID; Val: JDouble);

    function GetStaticMethodID(AClass: JClass; const Name: PAnsiChar; const Sig: PAnsiChar): JMethodID;

    function CallStaticObjectMethod(AClass: JClass; MethodID: JMethodID; const Args: array of const): JObject;
    function CallStaticObjectMethodV(AClass: JClass; MethodID: JMethodID; Args: va_list): JObject;
    function CallStaticObjectMethodA(AClass: JClass; MethodID: JMethodID; Args: PJValue): JObject;

    function CallStaticBooleanMethod(AClass: JClass; MethodID: JMethodID; const Args: array of const): JBoolean;
    function CallStaticBooleanMethodV(AClass: JClass; MethodID: JMethodID; Args: va_list): JBoolean;
    function CallStaticBooleanMethodA(AClass: JClass; MethodID: JMethodID; Args: PJValue): JBoolean;

    function CallStaticByteMethod(AClass: JClass; MethodID: JMethodID; const Args: array of const): JByte;
    function CallStaticByteMethodV(AClass: JClass; MethodID: JMethodID; Args: va_list): JByte;
    function CallStaticByteMethodA(AClass: JClass; MethodID: JMethodID; Args: PJValue): JByte;

    function CallStaticCharMethod(AClass: JClass; MethodID: JMethodID; const Args: array of const): JChar;
    function CallStaticCharMethodV(AClass: JClass; MethodID: JMethodID; Args: va_list): JChar;
    function CallStaticCharMethodA(AClass: JClass; MethodID: JMethodID; Args: PJValue): JChar;

    function CallStaticShortMethod(AClass: JClass; MethodID: JMethodID; const Args: array of const): JShort;
    function CallStaticShortMethodV(AClass: JClass; MethodID: JMethodID; Args: va_list): JShort;
    function CallStaticShortMethodA(AClass: JClass; MethodID: JMethodID; Args: PJValue): JShort;

    function CallStaticIntMethod(AClass: JClass; MethodID: JMethodID; const Args: array of const): JInt;
    function CallStaticIntMethodV(AClass: JClass; MethodID: JMethodID; Args: va_list): JInt;
    function CallStaticIntMethodA(AClass: JClass; MethodID: JMethodID; Args: PJValue): JInt;

    function CallStaticLongMethod(AClass: JClass; MethodID: JMethodID; const Args: array of const): JLong;
    function CallStaticLongMethodV(AClass: JClass; MethodID: JMethodID; Args: va_list): JLong;
    function CallStaticLongMethodA(AClass: JClass; MethodID: JMethodID; Args: PJValue): JLong;

    function CallStaticFloatMethod(AClass: JClass; MethodID: JMethodID; const Args: array of const): JFloat;
    function CallStaticFloatMethodV(AClass: JClass; MethodID: JMethodID; Args: va_list): JFloat;
    function CallStaticFloatMethodA(AClass: JClass; MethodID: JMethodID; Args: PJValue): JFloat;

    function CallStaticDoubleMethod(AClass: JClass; MethodID: JMethodID; const Args: array of const): JDouble;
    function CallStaticDoubleMethodV(AClass: JClass; MethodID: JMethodID; Args: va_list): JDouble;
    function CallStaticDoubleMethodA(AClass: JClass; MethodID: JMethodID; Args: PJValue): JDouble;

    procedure CallStaticVoidMethod(AClass: JClass; MethodID: JMethodID; const Args: array of const);
    procedure CallStaticVoidMethodV(AClass: JClass; MethodID: JMethodID; Args: va_list);
    procedure CallStaticVoidMethodA(AClass: JClass; MethodID: JMethodID; Args: PJValue);

    function GetStaticFieldID(AClass: JClass; const Name: PAnsiChar; const Sig: PAnsiChar): JFieldID;
    function GetStaticObjectField(AClass: JClass; FieldID: JFieldID): JObject;
    function GetStaticBooleanField(AClass: JClass; FieldID: JFieldID): JBoolean;
    function GetStaticByteField(AClass: JClass; FieldID: JFieldID): JByte;
    function GetStaticCharField(AClass: JClass; FieldID: JFieldID): JChar;
    function GetStaticShortField(AClass: JClass; FieldID: JFieldID): JShort;
    function GetStaticIntField(AClass: JClass; FieldID: JFieldID): JInt;
    function GetStaticLongField(AClass: JClass; FieldID: JFieldID): JLong;
    function GetStaticFloatField(AClass: JClass; FieldID: JFieldID): JFloat;
    function GetStaticDoubleField(AClass: JClass; FieldID: JFieldID): JDouble;

    procedure SetStaticObjectField(AClass: JClass; FieldID: JFieldID; Val: JObject);
    procedure SetStaticBooleanField(AClass: JClass; FieldID: JFieldID; Val: JBoolean);
    procedure SetStaticByteField(AClass: JClass; FieldID: JFieldID; Val: JByte);
    procedure SetStaticCharField(AClass: JClass; FieldID: JFieldID; Val: JChar);
    procedure SetStaticShortField(AClass: JClass; FieldID: JFieldID; Val: JShort);
    procedure SetStaticIntField(AClass: JClass; FieldID: JFieldID; Val: JInt);
    procedure SetStaticLongField(AClass: JClass; FieldID: JFieldID; Val: JLong);
    procedure SetStaticFloatField(AClass: JClass; FieldID: JFieldID; Val: JFloat);
    procedure SetStaticDoubleField(AClass: JClass; FieldID: JFieldID; Val: JDouble);

    function NewString(const Unicode: PJChar; Len: JSize): JString;
    function GetStringLength(Str: JString): JSize;
    function GetStringChars(Str: JString; var IsCopy: JBoolean): PJChar;
    procedure ReleaseStringChars(Str: JString; const Chars: PJChar);

    function NewStringUTF(const UTF: PAnsiChar): JString;
    function GetStringUTFLength(Str: JString): JSize;
    function GetStringUTFChars(Str: JString; var IsCopy: JBoolean): PAnsiChar;
    procedure ReleaseStringUTFChars(Str: JString; const Chars: PAnsiChar);

    function GetArrayLength(AArray: JArray): JSize;

    function NewObjectArray(Len: JSize; AClass: JClass; Init: JObject): JObjectArray;
    function GetObjectArrayElement(AArray: JObjectArray; Index: JSize): JObject;
    procedure SetObjectArrayElement(AArray: JObjectArray; Index: JSize; Val: JObject);

    function NewBooleanArray(Len: JSize): JBooleanArray;
    function NewByteArray(Len: JSize): JByteArray;
    function NewCharArray(Len: JSize): JCharArray;
    function NewShortArray(Len: JSize): JShortArray;
    function NewIntArray(Len: JSize): JIntArray;
    function NewLongArray(Len: JSize): JLongArray;
    function NewFloatArray(Len: JSize): JFloatArray;
    function NewDoubleArray(Len: JSize): JDoubleArray;

    function GetBooleanArrayElements(AArray: JBooleanArray; var IsCopy: JBoolean): PJBoolean;
    function GetByteArrayElements(AArray: JByteArray; var IsCopy: JBoolean): PJByte;
    function GetCharArrayElements(AArray: JCharArray; var IsCopy: JBoolean): PJChar;
    function GetShortArrayElements(AArray: JShortArray; var IsCopy: JBoolean): PJShort;
    function GetIntArrayElements(AArray: JIntArray; var IsCopy: JBoolean): PJInt;
    function GetLongArrayElements(AArray: JLongArray; var IsCopy: JBoolean): PJLong;
    function GetFloatArrayElements(AArray: JFloatArray; var IsCopy: JBoolean): PJFloat;
    function GetDoubleArrayElements(AArray: JDoubleArray; var IsCopy: JBoolean): PJDouble;

    procedure ReleaseBooleanArrayElements(AArray: JBooleanArray; Elems: PJBoolean; Mode: JInt);
    procedure ReleaseByteArrayElements(AArray: JByteArray; Elems: PJByte; Mode: JInt);
    procedure ReleaseCharArrayElements(AArray: JCharArray; Elems: PJChar; Mode: JInt);
    procedure ReleaseShortArrayElements(AArray: JShortArray; Elems: PJShort; Mode: JInt);
    procedure ReleaseIntArrayElements(AArray: JIntArray; Elems: PJInt; Mode: JInt);
    procedure ReleaseLongArrayElements(AArray: JLongArray; Elems: PJLong; Mode: JInt);
    procedure ReleaseFloatArrayElements(AArray: JFloatArray; Elems: PJFloat; Mode: JInt);
    procedure ReleaseDoubleArrayElements(AArray: JDoubleArray; Elems: PJDouble; Mode: JInt);

    procedure GetBooleanArrayRegion(AArray: JBooleanArray; Start: JSize; Len: JSize; Buf: PJBoolean);
    procedure GetByteArrayRegion(AArray: JByteArray; Start: JSize; Len: JSize; Buf: PJByte);
    procedure GetCharArrayRegion(AArray: JCharArray; Start: JSize; Len: JSize; Buf: PJChar);
    procedure GetShortArrayRegion(AArray: JShortArray; Start: JSize; Len: JSize; Buf: PJShort);
    procedure GetIntArrayRegion(AArray: JIntArray; Start: JSize; Len: JSize; Buf: PJInt);
    procedure GetLongArrayRegion(AArray: JLongArray; Start: JSize; Len: JSize; Buf: PJLong);
    procedure GetFloatArrayRegion(AArray: JFloatArray; Start: JSize; Len: JSize; Buf: PJFloat);
    procedure GetDoubleArrayRegion(AArray: JDoubleArray; Start: JSize; Len: JSize; Buf: PJDouble);

    procedure SetBooleanArrayRegion(AArray: JBooleanArray; Start: JSize; Len: JSize; Buf: PJBoolean);
    procedure SetByteArrayRegion(AArray: JByteArray; Start: JSize; Len: JSize; Buf: PJByte);
    procedure SetCharArrayRegion(AArray: JCharArray; Start: JSize; Len: JSize; Buf: PJChar);
    procedure SetShortArrayRegion(AArray: JShortArray; Start: JSize; Len: JSize; Buf: PJShort);
    procedure SetIntArrayRegion(AArray: JIntArray; Start: JSize; Len: JSize; Buf: PJInt);
    procedure SetLongArrayRegion(AArray: JLongArray; Start: JSize; Len: JSize; Buf: PJLong);
    procedure SetFloatArrayRegion(AArray: JFloatArray; Start: JSize; Len: JSize; Buf: PJFloat);
    procedure SetDoubleArrayRegion(AArray: JDoubleArray; Start: JSize; Len: JSize; Buf: PJDouble);

    function RegisterNatives(AClass: JClass; const Methods: PJNINativeMethod; NMethods: JInt): JInt;
    function UnregisterNatives(AClass: JClass): JInt;

    function MonitorEnter(Obj: JObject): JInt;
    function MonitorExit(Obj: JObject): JInt;

    function GetJavaVM(var VM: JavaVM): JInt;

    // String Operations
    procedure GetStringRegion(Str: JString; Start: JSize; Len: JSize; Buf: PJChar);
    procedure GetStringUTFRegion(Str: JString; Start: JSize; Len: JSize; Buf: PAnsiChar);

    // Array Operations
    function GetPrimitiveArrayCritical(AArray: JArray; var IsCopy: JBoolean): Pointer;
    procedure ReleasePrimitiveArrayCritical(AArray: JArray; CArray: Pointer; Mode: JInt);

    // String Operations
    function GetStringCritical(Str: JString; var IsCopy: JBoolean): PJChar;
    procedure ReleaseStringCritical(Str: JString; CString: PJChar);

    // Weak Global References
    function NewWeakGlobalRef(Obj: JObject): JWeak;
    procedure DeleteWeakGlobalRef(Ref: JWeak);

    // Exceptions
    function ExceptionCheck: JBoolean;
  end;

{$IFDEF DYNAMIC_LINKING}
function LoadJVM(const Filename: string): Boolean;
function UnloadJVM: Boolean;
function JVMIsLoaded: Boolean;
{$ENDIF}

implementation

{$IFNDEF DYNAMIC_LINKING}
const
  {$IFDEF WIN32}
    {$IFDEF JDK1_1}
    JvmModuleName = 'javai.dll';
    {$ELSE}
    JvmModuleName = 'jvm.dll';
    {$ENDIF}
  {$ENDIF}
  {$IFDEF LINUX}
  JvmModuleName = 'libjvm.so';
  {$ENDIF}

function JNI_CreateJavaVM; external JvmModuleName name 'JNI_CreateJavaVM';
function JNI_GetDefaultJavaVMInitArgs; external JvmModuleName name 'JNI_GetDefaultJavaVMInitArgs';
function JNI_GetCreatedJavaVMs; external JvmModuleName name 'JNI_GetCreatedJavaVMs';

{$ELSE}

var
  {$IFDEF WIN32}
  JVMHandle: THandle;
  {$ENDIF}
  {$IFDEF LINUX}
  JVMHandle: Pointer;
  {$ENDIF}
  CreateJavaVM: TJNI_CreateJavaVM;
  GetCreatedJavaVMs: TJNI_GetCreatedJavaVMs;
  GetDefaultJavaVMInitArgs: TJNI_GetDefaultJavaVMInitArgs;

{$IFDEF WIN32}

function JVMIsLoaded: Boolean;
begin
  Result := JVMHandle <> 0;
end;

function UnloadJVM: Boolean;
begin
  Result := True;
  if JVMIsLoaded then
    Result := FreeLibrary(JVMHandle);
  JVMHandle := 0;
  CreateJavaVM := nil;
  GetCreatedJavaVMs := nil;
  GetDefaultJavaVMInitArgs := nil;
end;

function LoadJVM(const Filename: string): Boolean;
begin
  Result := JVMIsLoaded;
  if not Result then
  begin
    JVMHandle := LoadLibrary(PChar(Filename));
    if JVMIsLoaded then
    begin
      @CreateJavaVM := GetProcAddress(JVMHandle, 'JNI_CreateJavaVM');
      @GetCreatedJavaVMs := GetProcAddress(JVMHandle, 'JNI_GetCreatedJavaVMs');
      @GetDefaultJavaVMInitArgs := GetProcAddress(JVMHandle, 'JNI_GetDefaultJavaVMInitArgs');
      Result := Assigned(CreateJavaVM) and Assigned(GetCreatedJavaVMs) and Assigned(GetDefaultJavaVMInitArgs);
      if not Result then
      begin
        UnloadJVM;
        raise EJVMError.CreateFmt('"%s" is not a valid JVM library', [Filename]);
      end;
    end;
  end;
end;

{$ENDIF} // WIN32

{$IFDEF LINUX}

function JVMIsLoaded: Boolean;
begin
  Result := JVMHandle <> nil;
end;

function UnloadJVM: Boolean;
begin
  Result := True;
  if JVMIsLoaded then
    dlclose(JVMHandle);
  JVMHandle := nil;
  CreateJavaVM := nil;
  GetCreatedJavaVMs := nil;
  GetDefaultJavaVMInitArgs := nil;
end;

function LoadJVM(const Filename: string): Boolean;
begin
  Result := JVMIsLoaded;
  if not Result then
  begin
    JVMHandle := dlopen(PChar(Filename), RTLD_NOW);
    if JVMIsLoaded then
    begin
      @CreateJavaVM := dlsym(JVMHandle, 'JNI_CreateJavaVM');
      @GetCreatedJavaVMs := dlsym(JVMHandle, 'JNI_GetCreatedJavaVMs');
      @GetDefaultJavaVMInitArgs := dlsym(JVMHandle, 'JNI_GetDefaultJavaVMInitArgs');
      Result := Assigned(CreateJavaVM) and Assigned(GetCreatedJavaVMs) and Assigned(GetDefaultJavaVMInitArgs);
      if not Result then
      begin
        UnloadJVM;
        raise EJVMError.CreateFmt('"%s" is not a valid JVM library', [Filename]);
      end;
    end;
  end;
end;

{$ENDIF} // LINUX

function JNI_CreateJavaVM(PJVM: PJavaVM; PEnv: PPointer; Args: Pointer; const JVMDLLFile: string): JInt;
begin
  if not JVMIsLoaded then
    LoadJVM(JVMDLLFile);

  if JVMIsLoaded then
    Result := CreateJavaVM(PJVM, PEnv, Args)
  else
    Result := JNI_ENOJAVA;
end;

function JNI_GetCreatedJavaVMs(PJVM: PJavaVM; JSize1: JSize; var JSize2: JSize; const JVMDLLFile: string): JInt;
begin
  if not JVMIsLoaded then
    LoadJVM(JVMDLLFile);

  if JVMIsLoaded then
    Result := GetCreatedJavaVMs(PJVM, JSize1, JSize2)
  else
    Result := JNI_ENOJAVA;
end;

function JNI_GetDefaultJavaVMInitArgs(Args: PJDK1_1InitArgs; const JVMDLLFile: string): JInt;
begin
  if not JVMIsLoaded then
    LoadJVM(JVMDLLFile);

  if JVMIsLoaded then
    Result := GetDefaultJavaVMInitArgs(Args)
  else
    Result := JNI_ENOJAVA;
end;

{$ENDIF} // DYNAMIC_LINKING defined

function TJNIEnv.ArgsToJValues(const Args: array of const): PJValue;
var
  I: Integer;
begin
  if Length(Args) <> Length(FConvertedArgs) then
    SetLength(FConvertedArgs, Length(Args));
  for I := 0 to High(Args) do
    case Args[I].VType of
      vtInteger:
        FConvertedArgs[I].i := Args[I].VInteger;
      vtBoolean:
        FConvertedArgs[I].z := Args[I].VBoolean;
      vtWideChar:
        FConvertedArgs[I].c := Args[I].VWideChar;
      vtInt64:
        FConvertedArgs[I].j := Args[I].VInt64^;
      vtPointer, vtObject:
        FConvertedArgs[I].l := JObject(Args[I].VObject);
      vtAnsiString:
        FConvertedArgs[I].l := StringToJString(Args[I].VAnsiString);
      vtExtended:
        FConvertedArgs[I].d := Args[I].VExtended^; // Extended to Double (we lose Floats here)
    else
      raise EJNIError.Create('Unsupported variant argument');
    end;
  Result := PJValue(FConvertedArgs);
end;

constructor TJNIEnv.Create(AEnv: PJNIEnv);
begin
  inherited Create;
  FConvertedArgs := nil;
  FEnv := AEnv;
  FMajorVersion := GetMajorVersion;
  FMinorVersion := GetMinorVersion;
  FVersion      := GetVersion;
end;

function TJNIEnv.StringToJString(const AString: PAnsiChar): JString;
begin
  Result := Env^.NewStringUTF(Env, PChar(AString));
end;

function TJNIEnv.StringToUnicodeJString(const AString: PAnsiChar): JString;
begin
  Result := Env^.NewString(Env, PJChar(AString), Length(AString));
end;

function TJNIEnv.JStringToString(JStr: JString): string;
var
  IsCopy: JBoolean;
  Chars: PChar;
begin
  if JStr = nil then
  begin
    Result := '';
    Exit;
  end;

  Chars := Env^.GetStringUTFChars(Env, JStr, IsCopy);
  if Chars = nil then
    Result := ''
  else
  begin
    Result := string(Chars);
    Env^.ReleaseStringUTFChars(Env, JStr, Chars);
  end;
end;

function TJNIEnv.UnicodeJStringToString(JStr: JString): string;
var
  IsCopy: JBoolean;
  Chars: PJChar;
begin
  if JStr = nil then
  begin
    Result := '';
    Exit;
  end;

  Chars := Env^.GetStringChars(Env, JStr, IsCopy);
  if Chars = nil then
    Result := ''
  else
  begin
    Result := string(Chars);
    Env^.ReleaseStringChars(Env, JStr, Chars);
  end;
end;

function TJNIEnv.GetMajorVersion: JInt;
begin
  Result := GetVersion shr 16;
end;

function TJNIEnv.GetMinorVersion: JInt;
begin
  Result := GetVersion mod 65536;
end;

function TJNIEnv.GetVersion: JInt;
begin
  Result := Env^.GetVersion(Env);
end;

procedure TJNIEnv.VersionCheck(const FuncName: string; RequiredVersion: JInt);
begin
  if Version < RequiredVersion then
    raise EJNIUnsupportedMethodError.CreateFmt('Method "%s" not supported in JDK %d.%d', [FuncName, MajorVersion, MinorVersion]);
end;

procedure TJNIEnv.CallVoidMethod(Obj: JObject; MethodID: JMethodID; const Args: array of const);
begin
  Env^.CallVoidMethodA(Env, Obj, MethodID, ArgsToJValues(Args));
end;

function TJNIEnv.AllocObject(AClass: JClass): JObject;
begin
  Result := Env^.AllocObject(Env, AClass);
end;

function TJNIEnv.CallBooleanMethod(Obj: JObject; MethodID: JMethodID; const Args: array of const): JBoolean;
begin
  Result := Env^.CallBooleanMethodA(Env, Obj, MethodID, ArgsToJValues(Args));
end;

function TJNIEnv.CallBooleanMethodA(Obj: JObject; MethodID: JMethodID; Args: PJValue): JBoolean;
begin
  Result := Env^.CallBooleanMethodA(Env, Obj, MethodID, Args);
end;

function TJNIEnv.CallBooleanMethodV(Obj: JObject; MethodID: JMethodID; Args: va_list): JBoolean;
begin
  Result := Env^.CallBooleanMethodV(Env, Obj, MethodID, Args);
end;

function TJNIEnv.CallByteMethod(Obj: JObject; MethodID: JMethodID; const Args: array of const): JByte;
begin
  Result := Env^.CallByteMethodA(Env, Obj, MethodID, ArgsToJValues(Args));
end;

function TJNIEnv.CallByteMethodA(Obj: JObject; MethodID: JMethodID; Args: PJValue): JByte;
begin
  Result := Env^.CallByteMethodA(Env, Obj, MethodID, Args);
end;

function TJNIEnv.CallByteMethodV(Obj: JObject; MethodID: JMethodID; Args: va_list): JByte;
begin
  Result := Env^.CallByteMethodV(Env, Obj, MethodID, Args);
end;

function TJNIEnv.CallCharMethod(Obj: JObject; MethodID: JMethodID; const Args: array of const): JChar;
begin
  Result := Env^.CallCharMethodA(Env, Obj, MethodID, ArgsToJValues(Args));
end;

function TJNIEnv.CallCharMethodA(Obj: JObject; MethodID: JMethodID; Args: PJValue): JChar;
begin
  Result := Env^.CallCharMethodA(Env, Obj, MethodID, Args);
end;

function TJNIEnv.CallCharMethodV(Obj: JObject; MethodID: JMethodID; Args: va_list): JChar;
begin
  Result := Env^.CallCharMethodV(Env, Obj, MethodID, Args);
end;

function TJNIEnv.CallDoubleMethod(Obj: JObject; MethodID: JMethodID; const Args: array of const): JDouble;
begin
  Result := Env^.CallDoubleMethodA(Env, Obj, MethodID, ArgsToJValues(Args));
end;

function TJNIEnv.CallDoubleMethodA(Obj: JObject; MethodID: JMethodID; Args: PJValue): JDouble;
begin
  Result := Env^.CallDoubleMethodA(Env, Obj, MethodID, Args);
end;

function TJNIEnv.CallDoubleMethodV(Obj: JObject; MethodID: JMethodID; Args: va_list): JDouble;
begin
  Result := Env^.CallDoubleMethodV(Env, Obj, MethodID, Args);
end;

function TJNIEnv.CallFloatMethod(Obj: JObject; MethodID: JMethodID; const Args: array of const): JFloat;
begin
  Result := Env^.CallFloatMethodA(Env, Obj, MethodID, ArgsToJValues(Args));
end;

function TJNIEnv.CallFloatMethodA(Obj: JObject; MethodID: JMethodID; Args: PJValue): JFloat;
begin
  Result := Env^.CallFloatMethodA(Env, Obj, MethodID, Args);
end;

function TJNIEnv.CallFloatMethodV(Obj: JObject; MethodID: JMethodID; Args: va_list): JFloat;
begin
  Result := Env^.CallFloatMethodV(Env, Obj, MethodID, Args);
end;

function TJNIEnv.CallIntMethod(Obj: JObject; MethodID: JMethodID; const Args: array of const): JInt;
begin
  Result := Env^.CallIntMethodA(Env, Obj, MethodID, ArgsToJValues(Args));
end;

function TJNIEnv.CallIntMethodA(Obj: JObject; MethodID: JMethodID; Args: PJValue): JInt;
begin
  Result := Env^.CallIntMethodA(Env, Obj, MethodID, Args);
end;

function TJNIEnv.CallIntMethodV(Obj: JObject; MethodID: JMethodID; Args: va_list): JInt;
begin
  Result := Env^.CallIntMethodV(Env, Obj, MethodID, Args);
end;

function TJNIEnv.CallLongMethod(Obj: JObject; MethodID: JMethodID; const Args: array of const): JLong;
begin
    Result := Env^.CallLongMethodA(Env, Obj, MethodID, ArgsToJValues(Args));
end;

function TJNIEnv.CallLongMethodA(Obj: JObject; MethodID: JMethodID; Args: PJValue): JLong;
begin
  Result := Env^.CallLongMethodA(Env, Obj, MethodID, Args);
end;

function TJNIEnv.CallLongMethodV(Obj: JObject; MethodID: JMethodID; Args: va_list): JLong;
begin
  Result := Env^.CallLongMethodV(Env, Obj, MethodID, Args);
end;

function TJNIEnv.CallNonvirtualBooleanMethod(Obj: JObject; AClass: JClass; MethodID: JMethodID; const Args: array of const): JBoolean;
begin
  Result := Env^.CallNonvirtualBooleanMethodA(Env, Obj, AClass, MethodID, ArgsToJValues(Args));
end;

function TJNIEnv.CallNonvirtualBooleanMethodA(Obj: JObject; AClass: JClass; MethodID: JMethodID; Args: PJValue): JBoolean;
begin
  Result := Env^.CallNonvirtualBooleanMethodA(Env, Obj, AClass, MethodID, Args);
end;

function TJNIEnv.CallNonvirtualBooleanMethodV(Obj: JObject; AClass: JClass; MethodID: JMethodID; Args: va_list): JBoolean;
begin
  Result := Env^.CallNonvirtualBooleanMethodV(Env, Obj, AClass, MethodID, Args);
end;

function TJNIEnv.CallNonvirtualByteMethod(Obj: JObject; AClass: JClass; MethodID: JMethodID; const Args: array of const): JByte;
begin
  Result := Env^.CallNonvirtualByteMethodA(Env, Obj, AClass, MethodID, ArgsToJValues(Args));
end;

function TJNIEnv.CallNonvirtualByteMethodA(Obj: JObject; AClass: JClass; MethodID: JMethodID; Args: PJValue): JByte;
begin
  Result := Env^.CallNonvirtualByteMethodA(Env, Obj, AClass, MethodID, Args);
end;

function TJNIEnv.CallNonvirtualByteMethodV(Obj: JObject; AClass: JClass; MethodID: JMethodID; Args: va_list): JByte;
begin
  Result := Env^.CallNonvirtualByteMethodV(Env, Obj, AClass, MethodID, Args);
end;

function TJNIEnv.CallNonvirtualCharMethod(Obj: JObject; AClass: JClass; MethodID: JMethodID; const Args: array of const): JChar;
begin
  Result := Env^.CallNonvirtualCharMethodA(Env, Obj, AClass, MethodID, ArgsToJValues(Args));
end;

function TJNIEnv.CallNonvirtualCharMethodA(Obj: JObject; AClass: JClass; MethodID: JMethodID; Args: PJValue): JChar;
begin
  Result := Env^.CallNonvirtualCharMethodA(Env, Obj, AClass, MethodID, Args);
end;

function TJNIEnv.CallNonvirtualCharMethodV(Obj: JObject; AClass: JClass; MethodID: JMethodID; Args: va_list): JChar;
begin
  Result := Env^.CallNonvirtualCharMethodV(Env, Obj, AClass, MethodID, Args);
end;

function TJNIEnv.CallNonvirtualDoubleMethod(Obj: JObject; AClass: JClass; MethodID: JMethodID; const Args: array of const): JDouble;
begin
  Result := Env^.CallNonvirtualDoubleMethodA(Env, Obj, AClass, MethodID, ArgsToJValues(Args));
end;

function TJNIEnv.CallNonvirtualDoubleMethodA(Obj: JObject; AClass: JClass; MethodID: JMethodID; Args: PJValue): JDouble;
begin
  Result := Env^.CallNonvirtualDoubleMethodA(Env, Obj, AClass, MethodID, Args);
end;

function TJNIEnv.CallNonvirtualDoubleMethodV(Obj: JObject; AClass: JClass; MethodID: JMethodID; Args: va_list): JDouble;
begin
  Result := Env^.CallNonvirtualDoubleMethodV(Env, Obj, AClass, MethodID, Args);
end;

function TJNIEnv.CallNonvirtualFloatMethod(Obj: JObject; AClass: JClass; MethodID: JMethodID; const Args: array of const): JFloat;
begin
  Result := Env^.CallNonvirtualFloatMethodA(Env, Obj, AClass, MethodID, ArgsToJValues(Args));
end;

function TJNIEnv.CallNonvirtualFloatMethodA(Obj: JObject; AClass: JClass; MethodID: JMethodID; Args: PJValue): JFloat;
begin
  Result := Env^.CallNonvirtualFloatMethodA(Env, Obj, AClass, MethodID, Args);
end;

function TJNIEnv.CallNonvirtualFloatMethodV(Obj: JObject; AClass: JClass; MethodID: JMethodID; Args: va_list): JFloat;
begin
  Result := Env^.CallNonvirtualFloatMethodV(Env, Obj, AClass, MethodID, Args);
end;

function TJNIEnv.CallNonvirtualIntMethod(Obj: JObject; AClass: JClass; MethodID: JMethodID; const Args: array of const): JInt;
begin
  Result := Env^.CallNonvirtualIntMethodA(Env, Obj, AClass, MethodID, ArgsToJValues(Args));
end;

function TJNIEnv.CallNonvirtualIntMethodA(Obj: JObject; AClass: JClass; MethodID: JMethodID; Args: PJValue): JInt;
begin
  Result := Env^.CallNonvirtualIntMethodA(Env, Obj, AClass, MethodID, Args);
end;

function TJNIEnv.CallNonvirtualIntMethodV(Obj: JObject; AClass: JClass; MethodID: JMethodID; Args: va_list): JInt;
begin
  Result := Env^.CallNonvirtualIntMethodV(Env, Obj, AClass, MethodID, Args);
end;

function TJNIEnv.CallNonvirtualLongMethod(Obj: JObject; AClass: JClass; MethodID: JMethodID; const Args: array of const): JLong;
begin
  Result := Env^.CallNonvirtualLongMethodA(Env, Obj, AClass, MethodID, ArgsToJValues(Args));
end;

function TJNIEnv.CallNonvirtualLongMethodA(Obj: JObject; AClass: JClass; MethodID: JMethodID; Args: PJValue): JLong;
begin
  Result := Env^.CallNonvirtualLongMethodA(Env, Obj, AClass, MethodID, Args);
end;

function TJNIEnv.CallNonvirtualLongMethodV(Obj: JObject; AClass: JClass; MethodID: JMethodID; Args: va_list): JLong;
begin
  Result := Env^.CallNonvirtualLongMethodV(Env, Obj, AClass, MethodID, Args);
end;

function TJNIEnv.CallNonvirtualObjectMethod(Obj: JObject; AClass: JClass; MethodID: JMethodID; const Args: array of const): JObject;
begin
  Result := Env^.CallNonvirtualObjectMethodA(Env, Obj, AClass, MethodID, ArgsToJValues(Args));
end;

function TJNIEnv.CallNonvirtualObjectMethodA(Obj: JObject; AClass: JClass; MethodID: JMethodID; Args: PJValue): JObject;
begin
  Result := Env^.CallNonvirtualObjectMethodA(Env, Obj, AClass, MethodID, Args);
end;

function TJNIEnv.CallNonvirtualObjectMethodV(Obj: JObject; AClass: JClass; MethodID: JMethodID; Args: va_list): JObject;
begin
  Result := Env^.CallNonvirtualObjectMethodV(Env, Obj, AClass, MethodID, Args);
end;

function TJNIEnv.CallNonvirtualShortMethod(Obj: JObject; AClass: JClass; MethodID: JMethodID; const Args: array of const): JShort;
begin
  Result := Env^.CallNonvirtualShortMethodA(Env, Obj, AClass, MethodID, ArgsToJValues(Args));
end;

function TJNIEnv.CallNonvirtualShortMethodA(Obj: JObject; AClass: JClass; MethodID: JMethodID; Args: PJValue): JShort;
begin
  Result := Env^.CallNonvirtualShortMethodA(Env, Obj, AClass, MethodID, Args);
end;

function TJNIEnv.CallNonvirtualShortMethodV(Obj: JObject; AClass: JClass; MethodID: JMethodID; Args: va_list): JShort;
begin
  Result := Env^.CallNonvirtualShortMethodV(Env, Obj, AClass, MethodID, Args);
end;

procedure TJNIEnv.CallNonvirtualVoidMethod(Obj: JObject; AClass: JClass; MethodID: JMethodID; const Args: array of const);
begin
  Env^.CallNonvirtualVoidMethodA(Env, Obj, AClass, MethodID, ArgsToJValues(Args));
end;

procedure TJNIEnv.CallNonvirtualVoidMethodA(Obj: JObject; AClass: JClass; MethodID: JMethodID; Args: PJValue);
begin
  Env^.CallNonvirtualDoubleMethodA(Env, Obj, AClass, MethodID, Args);
end;

procedure TJNIEnv.CallNonvirtualVoidMethodV(Obj: JObject; AClass: JClass; MethodID: JMethodID; Args: va_list);
begin
  Env^.CallNonvirtualVoidMethodV(Env, Obj, AClass, MethodID, Args);
end;

function TJNIEnv.CallObjectMethod(Obj: JObject; MethodID: JMethodID; const Args: array of const): JObject;
begin
  Result := Env^.CallObjectMethodA(Env, Obj, MethodID, ArgsToJValues(Args));
end;

function TJNIEnv.CallObjectMethodA(Obj: JObject; MethodID: JMethodID; Args: PJValue): JObject;
begin
  Result := Env^.CallObjectMethodA(Env, Obj, MethodID, Args);
end;

function TJNIEnv.CallObjectMethodV(Obj: JObject; MethodID: JMethodID; Args: va_list): JObject;
begin
  Result := Env^.CallObjectMethodV(Env, Obj, MethodID, Args);
end;

function TJNIEnv.CallShortMethod(Obj: JObject; MethodID: JMethodID; const Args: array of const): JShort;
begin
  Result := Env^.CallShortMethodA(Env, Obj, MethodID, ArgsToJValues(Args));
end;

function TJNIEnv.CallShortMethodA(Obj: JObject; MethodID: JMethodID; Args: PJValue): JShort;
begin
  Result := Env^.CallShortMethodA(Env, Obj, MethodID, Args);
end;

function TJNIEnv.CallShortMethodV(Obj: JObject; MethodID: JMethodID; Args: va_list): JShort;
begin
  Result := Env^.CallShortMethodV(Env, Obj, MethodID, Args);
end;

function TJNIEnv.CallStaticBooleanMethod(AClass: JClass; MethodID: JMethodID; const Args: array of const): JBoolean;
begin
  Result := Env^.CallStaticBooleanMethodA(Env, AClass, MethodID, ArgsToJValues(Args));
end;

function TJNIEnv.CallStaticBooleanMethodA(AClass: JClass; MethodID: JMethodID; Args: PJValue): JBoolean;
begin
  Result := Env^.CallStaticBooleanMethodA(Env, AClass, MethodID, Args);
end;

function TJNIEnv.CallStaticBooleanMethodV(AClass: JClass; MethodID: JMethodID; Args: va_list): JBoolean;
begin
  Result := Env^.CallStaticBooleanMethodV(Env, AClass, MethodID, Args);
end;

function TJNIEnv.CallStaticByteMethod(AClass: JClass; MethodID: JMethodID; const Args: array of const): JByte;
begin
  Result := Env^.CallStaticByteMethodA(Env, AClass, MethodID, ArgsToJValues(Args));
end;

function TJNIEnv.CallStaticByteMethodA(AClass: JClass; MethodID: JMethodID; Args: PJValue): JByte;
begin
  Result := Env^.CallStaticByteMethodA(Env, AClass, MethodID, Args);
end;

function TJNIEnv.CallStaticByteMethodV(AClass: JClass; MethodID: JMethodID; Args: va_list): JByte;
begin
  Result := Env^.CallStaticByteMethodV(Env, AClass, MethodID, Args);
end;

function TJNIEnv.CallStaticCharMethod(AClass: JClass; MethodID: JMethodID; const Args: array of const): JChar;
begin
  Result := Env^.CallStaticCharMethodA(Env, AClass, MethodID, ArgsToJValues(Args));
end;

function TJNIEnv.CallStaticCharMethodA(AClass: JClass; MethodID: JMethodID; Args: PJValue): JChar;
begin
  Result := Env^.CallStaticCharMethodA(Env, AClass, MethodID, Args);
end;

function TJNIEnv.CallStaticCharMethodV(AClass: JClass; MethodID: JMethodID; Args: va_list): JChar;
begin
  Result := Env^.CallStaticCharMethodV(Env, AClass, MethodID, Args);
end;

function TJNIEnv.CallStaticDoubleMethod(AClass: JClass; MethodID: JMethodID; const Args: array of const): JDouble;
begin
  Result := Env^.CallStaticDoubleMethodA(Env, AClass, MethodID, ArgsToJValues(Args));
end;

function TJNIEnv.CallStaticDoubleMethodA(AClass: JClass; MethodID: JMethodID; Args: PJValue): JDouble;
begin
  Result := Env^.CallStaticDoubleMethodA(Env, AClass, MethodID, Args);
end;

function TJNIEnv.CallStaticDoubleMethodV(AClass: JClass; MethodID: JMethodID; Args: va_list): JDouble;
begin
  Result := Env^.CallStaticDoubleMethodV(Env, AClass, MethodID, Args);
end;

function TJNIEnv.CallStaticFloatMethod(AClass: JClass; MethodID: JMethodID; const Args: array of const): JFloat;
begin
  Result := Env^.CallStaticFloatMethodA(Env, AClass, MethodID, ArgsToJValues(Args));
end;

function TJNIEnv.CallStaticFloatMethodA(AClass: JClass; MethodID: JMethodID; Args: PJValue): JFloat;
begin
  Result := Env^.CallStaticFloatMethodA(Env, AClass, MethodID, Args);
end;

function TJNIEnv.CallStaticFloatMethodV(AClass: JClass; MethodID: JMethodID; Args: va_list): JFloat;
begin
  Result := Env^.CallStaticFloatMethodV(Env, AClass, MethodID, Args);
end;

function TJNIEnv.CallStaticIntMethod(AClass: JClass; MethodID: JMethodID; const Args: array of const): JInt;
begin
  Result := Env^.CallStaticIntMethodA(Env, AClass, MethodID, ArgsToJValues(Args));
end;

function TJNIEnv.CallStaticIntMethodA(AClass: JClass; MethodID: JMethodID; Args: PJValue): JInt;
begin
  Result := Env^.CallStaticIntMethodA(Env, AClass, MethodID, Args);
end;

function TJNIEnv.CallStaticIntMethodV(AClass: JClass; MethodID: JMethodID; Args: va_list): JInt;
begin
  Result := Env^.CallStaticIntMethodV(Env, AClass, MethodID, Args);
end;

function TJNIEnv.CallStaticLongMethod(AClass: JClass; MethodID: JMethodID; const Args: array of const): JLong;
begin
  Result := Env^.CallStaticLongMethodA(Env, AClass, MethodID, ArgsToJValues(Args));
end;

function TJNIEnv.CallStaticLongMethodA(AClass: JClass; MethodID: JMethodID; Args: PJValue): JLong;
begin
  Result := Env^.CallStaticLongMethodA(Env, AClass, MethodID, Args);
end;

function TJNIEnv.CallStaticLongMethodV(AClass: JClass; MethodID: JMethodID; Args: va_list): JLong;
begin
  Result := Env^.CallStaticLongMethodV(Env, AClass, MethodID, Args);
end;

function TJNIEnv.CallStaticObjectMethod(AClass: JClass; MethodID: JMethodID; const Args: array of const): JObject;
begin
  Result := Env^.CallStaticObjectMethodA(Env, AClass, MethodID, ArgsToJValues(Args));
end;

function TJNIEnv.CallStaticObjectMethodA(AClass: JClass; MethodID: JMethodID; Args: PJValue): JObject;
begin
  Result := Env^.CallStaticObjectMethodA(Env, AClass, MethodID, Args);
end;

function TJNIEnv.CallStaticObjectMethodV(AClass: JClass; MethodID: JMethodID; Args: va_list): JObject;
begin
  Result := Env^.CallStaticObjectMethodV(Env, AClass, MethodID, Args);
end;

function TJNIEnv.CallStaticShortMethod(AClass: JClass; MethodID: JMethodID; const Args: array of const): JShort;
begin
  Result := Env^.CallStaticShortMethodA(Env, AClass, MethodID, ArgsToJValues(Args));
end;

function TJNIEnv.CallStaticShortMethodA(AClass: JClass; MethodID: JMethodID; Args: PJValue): JShort;
begin
  Result := Env^.CallStaticShortMethodA(Env, AClass, MethodID, Args);
end;

function TJNIEnv.CallStaticShortMethodV(AClass: JClass; MethodID: JMethodID; Args: va_list): JShort;
begin
  Result := Env^.CallStaticShortMethodV(Env, AClass, MethodID, Args);
end;

procedure TJNIEnv.CallStaticVoidMethod(AClass: JClass; MethodID: JMethodID; const Args: array of const);
begin
  Env^.CallStaticVoidMethodA(Env, AClass, MethodID, ArgsToJValues(Args));
end;

procedure TJNIEnv.CallStaticVoidMethodA(AClass: JClass; MethodID: JMethodID; Args: PJValue);
begin
  Env^.CallStaticVoidMethodA(Env, AClass, MethodID, Args);
end;

procedure TJNIEnv.CallStaticVoidMethodV(AClass: JClass; MethodID: JMethodID; Args: va_list);
begin
  Env^.CallStaticVoidMethodV(Env, AClass, MethodID, Args);
end;

procedure TJNIEnv.CallVoidMethodA(Obj: JObject; MethodID: JMethodID; Args: PJValue);
begin
  Env^.CallVoidMethodA(Env, Obj, MethodID, Args);
end;

procedure TJNIEnv.CallVoidMethodV(Obj: JObject; MethodID: JMethodID; Args: va_list);
begin
  Env^.CallVoidMethodV(Env, Obj, MethodID, Args);
end;

function TJNIEnv.DefineClass(const Name: PAnsiChar; Loader: JObject; const Buf: PJByte; Len: JSize): JClass;
begin
  Result := Env^.DefineClass(Env, Name, Loader, Buf, Len);
end;

procedure TJNIEnv.DeleteGlobalRef(GRef: JObject);
begin
  Env^.DeleteGlobalRef(Env, GRef);
end;

procedure TJNIEnv.DeleteLocalRef(Obj: JObject);
begin
  Env^.DeleteLocalRef(Env, Obj);
end;

procedure TJNIEnv.ExceptionClear;
begin
  Env^.ExceptionClear(Env);
end;

procedure TJNIEnv.ExceptionDescribe;
begin
  Env^.ExceptionDescribe(Env);
end;

function TJNIEnv.ExceptionOccurred: JThrowable;
begin
  Result := Env^.ExceptionOccurred(Env);
end;

procedure TJNIEnv.FatalError(const Msg: PAnsiChar);
begin
  Env^.FatalError(Env, Msg);
end;

function TJNIEnv.FindClass(const Name: PAnsiChar): JClass;
begin
  Result := Env^.FindClass(Env, Name);
end;

function TJNIEnv.GetArrayLength(AArray: JArray): JSize;
begin
  Result := Env^.GetArrayLength(Env, AArray);
end;

function TJNIEnv.GetBooleanArrayElements(AArray: JBooleanArray; var IsCopy: JBoolean): PJBoolean;
begin
  Result := Env^.GetBooleanArrayElements(Env, AArray, IsCopy);
end;

procedure TJNIEnv.GetBooleanArrayRegion(AArray: JBooleanArray; Start, Len: JSize; Buf: PJBoolean);
begin
  Env^.GetBooleanArrayRegion(Env, AArray, Start, Len, Buf);
end;

function TJNIEnv.GetBooleanField(Obj: JObject; FieldID: JFieldID): JBoolean;
begin
  Result := Env^.GetBooleanField(Env, Obj, FieldID);
end;

function TJNIEnv.GetByteArrayElements(AArray: JByteArray; var IsCopy: JBoolean): PJByte;
begin
  Result := Env^.GetByteArrayElements(Env, AArray, IsCopy);
end;

procedure TJNIEnv.GetByteArrayRegion(AArray: JByteArray; Start, Len: JSize; Buf: PJByte);
begin
  Env^.GetByteArrayRegion(Env, AArray, Start, Len, Buf);
end;

function TJNIEnv.GetByteField(Obj: JObject; FieldID: JFieldID): JByte;
begin
  Result := Env^.GetByteField(Env, Obj, FieldID);
end;

function TJNIEnv.GetCharArrayElements(AArray: JCharArray; var IsCopy: JBoolean): PJChar;
begin
  Result := Env^.GetCharArrayElements(Env, AArray, IsCopy);
end;

procedure TJNIEnv.GetCharArrayRegion(AArray: JCharArray; Start, Len: JSize; Buf: PJChar);
begin
  Env^.GetCharArrayRegion(Env, AArray, Start, Len, Buf);
end;

function TJNIEnv.GetCharField(Obj: JObject; FieldID: JFieldID): JChar;
begin
  Result := Env^.GetCharField(Env, Obj, FieldID);
end;

function TJNIEnv.GetDoubleArrayElements(AArray: JDoubleArray; var IsCopy: JBoolean): PJDouble;
begin
  Result := Env^.GetDoubleArrayElements(Env, AArray, IsCopy);
end;

procedure TJNIEnv.GetDoubleArrayRegion(AArray: JDoubleArray; Start, Len: JSize; Buf: PJDouble);
begin
  Env^.GetDoubleArrayRegion(Env, AArray, Start, Len, Buf);
end;

function TJNIEnv.GetDoubleField(Obj: JObject; FieldID: JFieldID): JDouble;
begin
  Result := Env^.GetDoubleField(Env, Obj, FieldID);
end;

function TJNIEnv.GetFieldID(AClass: JClass; const Name, Sig: PAnsiChar): JFieldID;
begin
  Result := Env^.GetFieldID(Env, AClass, Name, Sig);
end;

function TJNIEnv.GetFloatArrayElements(AArray: JFloatArray; var IsCopy: JBoolean): PJFloat;
begin
  Result := Env^.GetFloatArrayElements(Env, AArray, IsCopy);
end;

procedure TJNIEnv.GetFloatArrayRegion(AArray: JFloatArray; Start, Len: JSize; Buf: PJFloat);
begin
  Env^.GetFloatArrayRegion(Env, AArray, Start, Len, Buf);
end;

function TJNIEnv.GetFloatField(Obj: JObject; FieldID: JFieldID): JFloat;
begin
  Result := Env^.GetFloatField(Env, Obj, FieldID);
end;

function TJNIEnv.GetIntArrayElements(AArray: JIntArray; var IsCopy: JBoolean): PJInt;
begin
  Result := Env^.GetIntArrayElements(Env, AArray, IsCopy);
end;

procedure TJNIEnv.GetIntArrayRegion(AArray: JIntArray; Start, Len: JSize; Buf: PJInt);
begin
  Env^.GetIntArrayRegion(Env, AArray, Start, Len, Buf);
end;

function TJNIEnv.GetIntField(Obj: JObject; FieldID: JFieldID): JInt;
begin
  Result := Env^.GetIntField(Env, Obj, FieldID);
end;

function TJNIEnv.GetJavaVM(var VM: JavaVM): JInt;
begin
  Result := Env^.GetJavaVM(Env, VM);
end;

function TJNIEnv.GetLongArrayElements(AArray: JLongArray; var IsCopy: JBoolean): PJLong;
begin
  Result := Env^.GetLongArrayElements(Env, AArray, IsCopy);
end;

procedure TJNIEnv.GetLongArrayRegion(AArray: JLongArray; Start, Len: JSize; Buf: PJLong);
begin
  Env^.GetLongArrayRegion(Env, AArray, Start, Len, Buf);
end;

function TJNIEnv.GetLongField(Obj: JObject; FieldID: JFieldID): JLong;
begin
  Result := Env^.GetLongField(Env, Obj, FieldID);
end;

function TJNIEnv.GetMethodID(AClass: JClass; const Name, Sig: PAnsiChar): JMethodID;
begin
  Result := Env^.GetMethodID(Env, AClass, Name, Sig);
end;

function TJNIEnv.GetObjectArrayElement(AArray: JObjectArray; Index: JSize): JObject;
begin
  Result := Env^.GetObjectArrayElement(Env, AArray, Index);
end;

function TJNIEnv.GetObjectClass(Obj: JObject): JClass;
begin
  Result := Env^.GetObjectClass(Env, Obj);
end;

function TJNIEnv.GetObjectField(Obj: JObject; FieldID: JFieldID): JObject;
begin
  Result := Env^.GetObjectField(Env, Obj, FieldID);
end;

function TJNIEnv.GetShortArrayElements(AArray: JShortArray; var IsCopy: JBoolean): PJShort;
begin
  Result := Env^.GetShortArrayElements(Env, AArray, IsCopy);
end;

procedure TJNIEnv.GetShortArrayRegion(AArray: JShortArray; Start, Len: JSize; Buf: PJShort);
begin
  Env^.GetShortArrayRegion(Env, AArray, Start, Len, Buf);
end;

function TJNIEnv.GetShortField(Obj: JObject; FieldID: JFieldID): JShort;
begin
  Result := Env^.GetShortField(Env, Obj, FieldID);
end;

function TJNIEnv.GetStaticBooleanField(AClass: JClass; FieldID: JFieldID): JBoolean;
begin
  Result := Env^.GetStaticBooleanField(Env, AClass, FieldID);
end;

function TJNIEnv.GetStaticByteField(AClass: JClass; FieldID: JFieldID): JByte;
begin
  Result := Env^.GetStaticByteField(Env, AClass, FieldID);
end;

function TJNIEnv.GetStaticCharField(AClass: JClass; FieldID: JFieldID): JChar;
begin
  Result := Env^.GetStaticCharField(Env, AClass, FieldID);
end;

function TJNIEnv.GetStaticDoubleField(AClass: JClass; FieldID: JFieldID): JDouble;
begin
  Result := Env^.GetStaticDoubleField(Env, AClass, FieldID);
end;

function TJNIEnv.GetStaticFieldID(AClass: JClass; const Name, Sig: PAnsiChar): JFieldID;
begin
  Result := Env^.GetStaticFieldID(Env, AClass, Name, Sig);
end;

function TJNIEnv.GetStaticFloatField(AClass: JClass; FieldID: JFieldID): JFloat;
begin
  Result := Env^.GetStaticFloatField(Env, AClass, FieldID);
end;

function TJNIEnv.GetStaticIntField(AClass: JClass; FieldID: JFieldID): JInt;
begin
  Result := Env^.GetStaticIntField(Env, AClass, FieldID);
end;

function TJNIEnv.GetStaticLongField(AClass: JClass; FieldID: JFieldID): JLong;
begin
  Result := Env^.GetStaticLongField(Env, AClass, FieldID);
end;

function TJNIEnv.GetStaticMethodID(AClass: JClass; const Name, Sig: PAnsiChar): JMethodID;
begin
  Result := Env^.GetStaticMethodID(Env, AClass, Name, Sig);
end;

function TJNIEnv.GetStaticObjectField(AClass: JClass; FieldID: JFieldID): JObject;
begin
  Result := Env^.GetStaticObjectField(Env, AClass, FieldID);
end;

function TJNIEnv.GetStaticShortField(AClass: JClass; FieldID: JFieldID): JShort;
begin
  Result := Env^.GetStaticShortField(Env, AClass, FieldID);
end;

function TJNIEnv.GetStringChars(Str: JString; var IsCopy: JBoolean): PJChar;
begin
  Result := Env^.GetStringChars(Env, Str, IsCopy);
end;

function TJNIEnv.GetStringLength(Str: JString): JSize;
begin
   Result := Env^.GetStringLength(Env, Str);
end;

function TJNIEnv.GetStringUTFChars(Str: JString; var IsCopy: JBoolean): PAnsiChar;
begin
  Result := Env^.GetStringUTFChars(Env, Str, IsCopy);
end;

function TJNIEnv.GetStringUTFLength(Str: JString): JSize;
begin
  Result := Env^.GetStringUTFLength(Env, Str);
end;

function TJNIEnv.GetSuperclass(Sub: JClass): JClass;
begin
  Result := Env^.GetSuperclass(Env, Sub);
end;

function TJNIEnv.IsAssignableFrom(Sub, Sup: JClass): JBoolean;
begin
  Result := Env^.IsAssignableFrom(Env, Sub, Sup);
end;

function TJNIEnv.IsInstanceOf(Obj: JObject; AClass: JClass): JBoolean;
begin
  Result := Env^.IsInstanceOf(Env, Obj, AClass);
end;

function TJNIEnv.IsSameObject(Obj1, Obj2: JObject): JBoolean;
begin
  Result := Env^.IsSameObject(Env, Obj1, Obj2);
end;

function TJNIEnv.MonitorEnter(Obj: JObject): JInt;
begin
  Result := Env^.MonitorEnter(Env, Obj);
end;

function TJNIEnv.MonitorExit(Obj: JObject): JInt;
begin
  Result := Env^.MonitorExit(Env, Obj);
end;

function TJNIEnv.NewBooleanArray(Len: JSize): JBooleanArray;
begin
  Result := Env^.NewBooleanArray(Env, Len);
end;

function TJNIEnv.NewByteArray(Len: JSize): JByteArray;
begin
  Result := Env^.NewByteArray(Env, Len);
end;

function TJNIEnv.NewCharArray(Len: JSize): JCharArray;
begin
  Result := Env^.NewCharArray(Env, Len);
end;

function TJNIEnv.NewDoubleArray(Len: JSize): JDoubleArray;
begin
  Result := Env^.NewDoubleArray(Env, Len);
end;

function TJNIEnv.NewFloatArray(Len: JSize): JFloatArray;
begin
  Result := Env^.NewFloatArray(Env, Len);
end;

function TJNIEnv.NewGlobalRef(LObj: JObject): JObject;
begin
  Result := Env^.NewGlobalRef(Env, LObj);
end;

function TJNIEnv.NewIntArray(Len: JSize): JIntArray;
begin
  Result := Env^.NewIntArray(Env, Len);
end;

function TJNIEnv.NewLongArray(Len: JSize): JLongArray;
begin
  Result := Env^.NewLongArray(Env, Len);
end;

function TJNIEnv.NewObject(AClass: JClass; MethodID: JMethodID; const Args: array of const): JObject;
begin
  Result := nil;
end;

function TJNIEnv.NewObjectA(AClass: JClass; MethodID: JMethodID; Args: PJValue): JObject;
begin
  Result := Env^.NewObjectA(Env, AClass, MethodID, Args);
end;

function TJNIEnv.NewObjectV(AClass: JClass; MethodID: JMethodID; Args: va_list): JObject;
begin
  Result := Env^.NewObjectV(Env, AClass, MethodID, Args);
end;

function TJNIEnv.NewObjectArray(Len: JSize; AClass: JClass; Init: JObject): JObjectArray;
begin
  Result := Env^.NewObjectArray(Env, Len, AClass, Init);
end;

function TJNIEnv.NewShortArray(Len: JSize): JShortArray;
begin
  Result := Env^.NewShortArray(Env, Len);
end;

function TJNIEnv.NewString(const Unicode: PJChar; Len: JSize): JString;
begin
  Result := Env^.NewString(Env, Unicode, Len);
end;

function TJNIEnv.NewStringUTF(const UTF: PAnsiChar): JString;
begin
  Result := Env^.NewStringUTF(Env, UTF);
end;

function TJNIEnv.RegisterNatives(AClass: JClass; const Methods: PJNINativeMethod; NMethods: JInt): JInt;
begin
  Result := Env^.RegisterNatives(Env, AClass, Methods, NMethods);
end;

function TJNIEnv.UnregisterNatives(AClass: JClass): JInt;
begin
  Result := Env^.UnregisterNatives(Env, AClass);
end;

procedure TJNIEnv.ReleaseBooleanArrayElements(AArray: JBooleanArray; Elems: PJBoolean; Mode: JInt);
begin
  Env^.ReleaseBooleanArrayElements(Env, AArray, Elems, Mode);
end;

procedure TJNIEnv.ReleaseByteArrayElements(AArray: JByteArray; Elems: PJByte; Mode: JInt);
begin
  Env^.ReleaseByteArrayElements(Env, AArray, Elems, Mode);
end;

procedure TJNIEnv.ReleaseCharArrayElements(AArray: JCharArray; Elems: PJChar; Mode: JInt);
begin
  Env^.ReleaseCharArrayElements(Env, AArray, Elems, Mode);
end;

procedure TJNIEnv.ReleaseDoubleArrayElements(AArray: JDoubleArray; Elems: PJDouble; Mode: JInt);
begin
  Env^.ReleaseDoubleArrayElements(Env, AArray, Elems, Mode);
end;

procedure TJNIEnv.ReleaseFloatArrayElements(AArray: JFloatArray; Elems: PJFloat; Mode: JInt);
begin
  Env^.ReleaseFloatArrayElements(Env, AArray, Elems, Mode);
end;

procedure TJNIEnv.ReleaseIntArrayElements(AArray: JIntArray; Elems: PJInt; Mode: JInt);
begin
  Env^.ReleaseIntArrayElements(Env, AArray, Elems, Mode);
end;

procedure TJNIEnv.ReleaseLongArrayElements(AArray: JLongArray; Elems: PJLong; Mode: JInt);
begin
  Env^.ReleaseLongArrayElements(Env, AArray, Elems, Mode);
end;

procedure TJNIEnv.ReleaseShortArrayElements(AArray: JShortArray; Elems: PJShort; Mode: JInt);
begin
  Env^.ReleaseShortArrayElements(Env, AArray, Elems, Mode);
end;

procedure TJNIEnv.ReleaseStringChars(Str: JString; const Chars: PJChar);
begin
  Env^.ReleaseStringChars(Env, Str, Chars);
end;

procedure TJNIEnv.ReleaseStringUTFChars(Str: JString; const Chars: PAnsiChar);
begin
  Env^.ReleaseStringUTFChars(Env, Str, Chars);
end;

procedure TJNIEnv.SetBooleanArrayRegion(AArray: JBooleanArray; Start, Len: JSize; Buf: PJBoolean);
begin
  Env^.SetBooleanArrayRegion(Env, AArray, Start, Len, Buf);
end;

procedure TJNIEnv.SetBooleanField(Obj: JObject; FieldID: JFieldID; Val: JBoolean);
begin
  Env^.SetBooleanField(Env, Obj, FieldID, Val);
end;

procedure TJNIEnv.SetByteArrayRegion(AArray: JByteArray; Start, Len: JSize; Buf: PJByte);
begin
  Env^.SetByteArrayRegion(Env, AArray, Start, Len, Buf);
end;

procedure TJNIEnv.SetByteField(Obj: JObject; FieldID: JFieldID; Val: JByte);
begin
  Env^.SetByteField(Env, Obj, FieldID, Val);
end;

procedure TJNIEnv.SetCharArrayRegion(AArray: JCharArray; Start, Len: JSize; Buf: PJChar);
begin
  Env^.SetCharArrayRegion(Env, AArray, Start, Len, Buf);
end;

procedure TJNIEnv.SetCharField(Obj: JObject; FieldID: JFieldID; Val: JChar);
begin
  Env^.SetCharField(Env, Obj, FieldID, Val);
end;

procedure TJNIEnv.SetDoubleArrayRegion(AArray: JDoubleArray; Start, Len: JSize; Buf: PJDouble);
begin
  Env^.SetDoubleArrayRegion(Env, AArray, Start, Len, Buf);
end;

procedure TJNIEnv.SetDoubleField(Obj: JObject; FieldID: JFieldID; Val: JDouble);
begin
  Env^.SetDoubleField(Env, Obj, FieldID, Val);
end;

procedure TJNIEnv.SetFloatArrayRegion(AArray: JFloatArray; Start, Len: JSize; Buf: PJFloat);
begin
  Env^.SetFloatArrayRegion(Env, AArray, Start, Len, Buf);
end;

procedure TJNIEnv.SetFloatField(Obj: JObject; FieldID: JFieldID; Val: JFloat);
begin
  Env^.SetFloatField(Env, Obj, FieldID, Val);
end;

procedure TJNIEnv.SetIntArrayRegion(AArray: JIntArray; Start, Len: JSize; Buf: PJInt);
begin
  Env^.SetIntArrayRegion(Env, AArray, Start, Len, Buf);
end;

procedure TJNIEnv.SetIntField(Obj: JObject; FieldID: JFieldID; Val: JInt);
begin
  Env^.SetIntField(Env, Obj, FieldID, Val);
end;

procedure TJNIEnv.SetLongArrayRegion(AArray: JLongArray; Start, Len: JSize; Buf: PJLong);
begin
  Env^.SetLongArrayRegion(Env, AArray, Start, Len, Buf);
end;

procedure TJNIEnv.SetLongField(Obj: JObject; FieldID: JFieldID; Val: JLong);
begin
  Env^.SetLongField(Env, Obj, FieldID, Val);
end;

procedure TJNIEnv.SetObjectArrayElement(AArray: JObjectArray; Index: JSize; Val: JObject);
begin
  Env^.SetObjectArrayElement(Env, AArray, Index, Val);
end;

procedure TJNIEnv.SetObjectField(Obj: JObject; FieldID: JFieldID; Val: JObject);
begin
  Env^.SetObjectField(Env, Obj, FieldID, Val);
end;

procedure TJNIEnv.SetShortArrayRegion(AArray: JShortArray; Start, Len: JSize; Buf: PJShort);
begin
  Env^.SetShortArrayRegion(Env, AArray, Start, Len, Buf);
end;

procedure TJNIEnv.SetShortField(Obj: JObject; FieldID: JFieldID; Val: JShort);
begin
  Env^.SetShortField(Env, Obj, FieldID, Val);
end;

procedure TJNIEnv.SetStaticBooleanField(AClass: JClass; FieldID: JFieldID; Val: JBoolean);
begin
  Env^.SetStaticBooleanField(Env, AClass, FieldID, Val);
end;

procedure TJNIEnv.SetStaticByteField(AClass: JClass; FieldID: JFieldID; Val: JByte);
begin
  Env^.SetStaticByteField(Env, AClass, FieldID, Val);
end;

procedure TJNIEnv.SetStaticCharField(AClass: JClass; FieldID: JFieldID; Val: JChar);
begin
  Env^.SetStaticCharField(Env, AClass, FieldID, Val);
end;

procedure TJNIEnv.SetStaticDoubleField(AClass: JClass; FieldID: JFieldID; Val: JDouble);
begin
  Env^.SetStaticDoubleField(Env, AClass, FieldID, Val);
end;

procedure TJNIEnv.SetStaticFloatField(AClass: JClass; FieldID: JFieldID; Val: JFloat);
begin
  Env^.SetStaticFloatField(Env, AClass, FieldID, Val);
end;

procedure TJNIEnv.SetStaticIntField(AClass: JClass; FieldID: JFieldID; Val: JInt);
begin
  Env^.SetStaticIntField(Env, AClass, FieldID, Val);
end;

procedure TJNIEnv.SetStaticLongField(AClass: JClass; FieldID: JFieldID; Val: JLong);
begin
  Env^.SetStaticLongField(Env, AClass, FieldID, Val);
end;

procedure TJNIEnv.SetStaticObjectField(AClass: JClass; FieldID: JFieldID; Val: JObject);
begin
  Env^.SetStaticObjectField(Env, AClass, FieldID, Val);
end;

procedure TJNIEnv.SetStaticShortField(AClass: JClass; FieldID: JFieldID; Val: JShort);
begin
  Env^.SetStaticShortField(Env, AClass, FieldID, Val);
end;

function TJNIEnv.Throw(Obj: JThrowable): JInt;
begin
  Result := Env^.Throw(Env, Obj);
end;

function TJNIEnv.ThrowNew(AClass: JClass; const Msg: PAnsiChar): JInt;
begin
  Result := Env^.ThrowNew(Env, AClass, Msg);
end;

procedure TJNIEnv.DeleteWeakGlobalRef(Ref: JWeak);
begin
  VersionCheck('DeleteWeakGlobalRef', JNI_VERSION_1_2);
  Env^.DeleteWeakGlobalRef(Env, Ref);
end;

function TJNIEnv.EnsureLocalCapacity(Capacity: JInt): JObject;
begin
  Result := Env^.EnsureLocalCapacity(Env, Capacity);
end;

function TJNIEnv.ExceptionCheck: JBoolean;
begin
  VersionCheck('ExceptionCheck', JNI_VERSION_1_2);
  Result := Env^.ExceptionCheck(Env)
end;

function TJNIEnv.FromReflectedField(field: JObject): JFieldID;
begin
  VersionCheck('FromReflectedField', JNI_VERSION_1_2);
  Result := Env^.FromReflectedField(Env, Field);
end;

function TJNIEnv.FromReflectedMethod(method: JObject): JMethodID;
begin
  VersionCheck('FromReflectedMethod', JNI_VERSION_1_2);
  Result := Env^.FromReflectedMethod(Env, Method);
end;

function TJNIEnv.GetPrimitiveArrayCritical(AArray: JArray; var IsCopy: JBoolean): Pointer;
begin
  VersionCheck('GetPrimitiveArrayCritical', JNI_VERSION_1_2);
  Result := Env^.GetPrimitiveArrayCritical(Env, AArray, IsCopy);
end;

function TJNIEnv.GetStringCritical(Str: JString; var IsCopy: JBoolean): PJChar;
begin
  VersionCheck('GetStringCritical', JNI_VERSION_1_2);
  Result := Env^.GetStringCritical(Env, Str, IsCopy);
end;

procedure TJNIEnv.GetStringRegion(Str: JString; Start, Len: JSize; Buf: PJChar);
begin
  VersionCheck('GetStringRegion', JNI_VERSION_1_2);
  Env^.GetStringRegion(Env, Str, Start, Len, Buf);
end;

procedure TJNIEnv.GetStringUTFRegion(Str: JString; Start, Len: JSize; Buf: PAnsiChar);
begin
  VersionCheck('GetStringUTFRegion', JNI_VERSION_1_2);
  Env^.GetStringUTFRegion(Env, Str, Start, Len, Buf);
end;

function TJNIEnv.NewLocalRef(Ref: JObject): JObject;
begin
  VersionCheck('NewLocalRef', JNI_VERSION_1_2);
  Result := Env^.NewLocalRef(Env, Ref);
end;

function TJNIEnv.NewWeakGlobalRef(Obj: JObject): JWeak;
begin
  VersionCheck('NewWeakGlobalRef', JNI_VERSION_1_2);
  Result := Env^.NewWeakGlobalRef(Env, Obj);
end;

function TJNIEnv.PopLocalFrame(AResult: JObject): JObject;
begin
  VersionCheck('PopLocalFrame', JNI_VERSION_1_2);
  Result := Env^.PopLocalFrame(Env, AResult);
end;

function TJNIEnv.PushLocalFrame(Capacity: JInt): JInt;
begin
  VersionCheck('PushLocalFrame', JNI_VERSION_1_2);
  Result := Env^.PushLocalFrame(Env, Capacity);
end;

procedure TJNIEnv.ReleasePrimitiveArrayCritical(AArray: JArray; CArray: Pointer; Mode: JInt);
begin
  VersionCheck('ReleasePrimitiveArrayCritical', JNI_VERSION_1_2);
  Env^.ReleasePrimitiveArrayCritical(Env, AArray, CArray, Mode);
end;

procedure TJNIEnv.ReleaseStringCritical(Str: JString; CString: PJChar);
begin
  VersionCheck('ReleaseStringCritical', JNI_VERSION_1_2);
  Env^.ReleaseStringCritical(Env, Str, CString);
end;

function TJNIEnv.ToReflectedField(AClass: JClass; FieldID: JFieldID; IsStatic: JBoolean): JObject;
begin
  VersionCheck('ToReflectedField', JNI_VERSION_1_2);
  Result := Env^.ToReflectedField(Env, AClass, FieldID, IsStatic);
end;

function TJNIEnv.ToReflectedMethod(AClass: JClass; MethodID: JMethodID; IsStatic: JBoolean): JObject;
begin
  VersionCheck('ToReflectedMethod', JNI_VERSION_1_2);
  Result := Env^.ToReflectedMethod(Env, AClass, MethodID, IsStatic);
end;

{ TJavaVM }
constructor TJavaVM.Create;
begin
  {$IFDEF DYNAMIC_LINKING}
    // We need to know which DLL to load if we're linking at runtime
    raise Exception.Create('No JDK version specified');
  {$ELSE}
    FJNI_GetDefaultJavaVMInitArgs := JNI_GetDefaultJavaVMInitArgs;
    FJNI_CreateJavaVM := JNI_CreateJavaVM;
    FJNI_GetCreatedJavaVMs := JNI_GetCreatedJavaVMs;
    FIsInitialized := True;
  {$ENDIF}
end;

{$IFDEF WIN32}

constructor TJavaVM.Create(JDKVersion: Integer);
begin
  if JDKVersion = JNI_VERSION_1_1 then
    Create(JDKVersion, 'javai.dll')
  else
  if JDKVersion = JNI_VERSION_1_2 then
    Create(JDKVersion, 'jvm.dll')
  else
    raise Exception.Create('Unknown JDK Version');
end;

constructor TJavaVM.Create(JDKVersion: Integer; const JVMDLLFilename: string);
begin
  FIsInitialized := False;
  FJVMDLLFile := JVMDLLFilename;
  Version := JDKVersion;

  FJavaVM := nil;
  FEnv := nil;
  FDLLHandle := LoadLibrary(PChar(FJVMDLLFile));
  if FDLLHandle = 0 then
    raise Exception.CreateFmt('LoadLibrary failed trying to load %s', [FJVMDLLFile]);

  @FJNI_CreateJavaVM := GetProcAddress(FDLLHandle, 'JNI_CreateJavaVM');
  if not Assigned(FJNI_CreateJavaVM) then
  begin
    FreeLibrary(FDLLHandle);
    raise Exception.CreateFmt('GetProcAddress failed to locate JNI_CreateJavaVM in library %s', [FJVMDLLFile]);
  end;

  @FJNI_GetDefaultJavaVMInitArgs := GetProcAddress(FDLLHandle, 'JNI_GetDefaultJavaVMInitArgs');
  if not Assigned(FJNI_GetDefaultJavaVMInitArgs) then
  begin
    FreeLibrary(FDLLHandle);
    raise Exception.CreateFmt('GetProcAddress failed to locate JNI_GetDefaultJavaVMInitArgs in library %s', [FJVMDLLFile]);
  end;

  @FJNI_GetCreatedJavaVMs := GetProcAddress(FDLLHandle, 'JNI_GetCreatedJavaVMs');
  if not Assigned(FJNI_GetCreatedJavaVMs) then
  begin
    FreeLibrary(FDLLHandle);
    raise Exception.CreateFmt('GetProcAddress failed to locate JNI_GetCreatedJavaVMs in library %s', [FJVMDLLFile]);
  end;
  FIsInitialized := True;
end;

destructor TJavaVM.Destroy;
begin
  if FDLLHandle <> 0 then
    FreeLibrary(FDLLHandle);
  inherited Destroy;
end;

{$ENDIF} // Win32

{$IFDEF LINUX}

constructor TJavaVM.Create(JDKVersion: Integer);
begin
  if JDKVersion = JNI_VERSION_1_1 then
    Create(JDKVersion, 'libjava.so')
  else
  if JDKVersion = JNI_VERSION_1_2 then
    Create(JDKVersion, 'libjvm.so')
  else
    raise Exception.Create('Unknown JDK Version');
end;

constructor TJavaVM.Create(JDKVersion: Integer; const JVMDLLFilename: string);
begin
  FIsInitialized := False;
  FJVMDLLFile := JVMDLLFilename;
  Version := JDKVersion;

  FJavaVM := nil;
  FEnv := nil;
  FDLLHandle := dlopen(PChar(FJVMDLLFile), RTLD_NOW);
  if FDLLHandle = nil then
    raise Exception.CreateFmt('dlopen failed trying to load %s', [FJVMDLLFile]);

  @FJNI_CreateJavaVM := dlsym(FDLLHandle, 'JNI_CreateJavaVM');
  if not Assigned(FJNI_CreateJavaVM) then
  begin
    dlclose(FDLLHandle);
    raise Exception.CreateFmt('dlsym failed to locate JNI_CreateJavaVM in library %s', [FJVMDLLFile]);
  end;

  @FJNI_GetDefaultJavaVMInitArgs := dlsym(FDLLHandle, 'JNI_GetDefaultJavaVMInitArgs');
  if not Assigned(FJNI_GetDefaultJavaVMInitArgs) then
  begin
    dlclose(FDLLHandle);
    raise Exception.CreateFmt('dlsym failed to locate JNI_GetDefaultJavaVMInitArgs in library %s', [FJVMDLLFile]);
  end;
  @FJNI_GetCreatedJavaVMs := dlsym(FDLLHandle, 'JNI_GetCreatedJavaVMs');
  if not Assigned(FJNI_GetCreatedJavaVMs) then
  begin
    dlclose(FDLLHandle);
    raise Exception.CreateFmt('dlsym failed to locate JNI_GetCreatedJavaVMs in library %s', [FJVMDLLFile]);
  end;
  FIsInitialized := True;
end;

destructor TJavaVM.Destroy;
begin
  if FDLLHandle <> nil then
    dlclose(FDLLHandle);
  inherited Destroy;
end;

{$ENDIF} // LINUX

function TJavaVM.GetCreatedJavaVMs(PJVM: PJavaVM; JSize1: JSize; var JSize2: JSize): JInt;
begin
  if not FIsInitialized then
    raise Exception.Create('JavaVM has not been initialized');
  Result := FJNI_GetCreatedJavaVMs(PJVM, JSize1, JSize2);
end;

function TJavaVM.GetDefaultJavaVMInitArgs(Args: PJDK1_1InitArgs): JInt;
begin
  if not FIsInitialized then
    raise Exception.Create('JavaVM has not been initialized');
  Result := FJNI_GetDefaultJavaVMInitArgs(Args)
end;

function TJavaVM.LoadVM(const Options: JDK1_1InitArgs): JInt;
begin
  FJDK1_1InitArgs := Options;
  Result := FJNI_CreateJavaVM(@FJavaVM, @FEnv, @FJDK1_1InitArgs)
end;

function TJavaVM.LoadVM(const Options: JavaVMInitArgs): JInt;
begin
  FJavaVMInitArgs := Options;
  Result := FJNI_CreateJavaVM(@FJavaVM, @FEnv, @FJavaVMInitArgs);
end;

procedure TJavaVM.SetVersion(const Value: JInt);
begin
  FVersion := Value;
end;

{$IFDEF DYNAMIC_LINKING}
initialization

finalization
    UnloadJVM;
{$ENDIF}

end.
