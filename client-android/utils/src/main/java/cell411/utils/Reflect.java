package cell411.utils;

import android.os.PowerManager;

import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.lang.reflect.Modifier;

@SuppressWarnings("unused")
public class Reflect {
  private static final String TAG = currentSimpleClassName();

  public static void announce(boolean b) {
    XLog.i(currentSimpleClassName(1), announceStr(1, b));
  }
  public static void announce(Object obj) {
    XLog.i(currentSimpleClassName(1), announceStr(obj));
  }
  public static String announceStr(Object obj) {
    String announceStr = announceStr(1,null );
    return announceStr+"  "+obj;
  }
  public static void announce(XLog.Tag tag, String str, Object ... args) {
    String announceStr = announceStr(1,null);
    String message = Util.format("%s: "+str,announceStr,args);
    XLog.i(tag,message);
  }
  public static String announceStr(int i, Boolean b) {
    StackTraceElement pos = Reflect.currentStackPos(i + 1);
    String prefix;
    if (b == null)
      prefix = "X ";
    else if (b)
      prefix = "I ";
    else
      prefix = "O ";

    return prefix + pos;
  }


  public static String announceStr(Boolean b) {
    return announceStr(1, b);
  }



  public static String currentSimpleClassName() {
    return currentSimpleClassName(1);
  }

  public static String currentMethodName() {
    return currentMethodName(1);
  }
  private static String currentClassName(int i) {
    return currentStackPos(i + 1).getClassName();
  }



  public static String currentSimpleClassName(int i) {
    String fullClassName = currentClassName(i + 1);
    int pos = fullClassName.lastIndexOf('.') + 1;
    return fullClassName.substring(pos);
  }

  public static String currentMethodName(int i) {
    String res = currentStackPos(i + 1).getMethodName();
    if (res.equals("<init>")) {
      return currentSimpleClassName(i + 1);
    } else {
      return res;
    }
  }

  public static StackTraceElement currentStackPos(int i) {
    Exception ex = new Exception();
    StackTraceElement[] trace = ex.getStackTrace();
    if (trace.length < 3 + i) {
      throw new RuntimeException("trace.length<" + (3 + i) + "!");
    }
    return trace[1 + i];
  }

  public static StackTraceElement currentStackPos() {
    return currentStackPos(1);
  }


  public static Method findStaticMethod(Class<?> clazz, String name) {
    for (Method method : clazz.getDeclaredMethods()) {
      if (!method.getName()
        .equals(name)) {
        continue;
      }
      if (method.getTypeParameters().length != 0) {
        continue;
      }
      int modifiers = method.getModifiers();
      if ((modifiers & Modifier.STATIC) == 0) {
        continue;
      }
      return method;
    }
    return null;
  }

  public static String getTag() {
    return currentSimpleClassName(1);
  }

  public static void stackTrace(PrintString ps, StackTraceElement[] trace) {
    stackTrace(ps, "", trace);
  }

  public static void stackTrace(PrintString ps, String firstLine, StackTraceElement[] trace) {
    if (firstLine != null && !firstLine.isEmpty()) {
      ps.pl(firstLine);
    }
    for (StackTraceElement traceElement : trace) {
      ps.p("\tat ")
        .pl(traceElement);
    }
  }

  // for static fields
  public static int getInt(Class<PowerManager> type, String name) {
    return getInt(type, null, name);
  }

  public static int getInt(Class<PowerManager> type, Object obj, String name) {
    try {
      Field field = type.getField(name);
      return field.getInt(obj);
    } catch ( Exception ex ) {
      throw new RuntimeException("reading field: "+name, ex);
    }
  }
}

