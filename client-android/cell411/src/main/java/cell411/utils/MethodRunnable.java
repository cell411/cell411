package cell411.utils;

import android.annotation.SuppressLint;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

import cell411.services.DataService;

public class MethodRunnable implements Runnable {
  private final Object mObject;
  Method mMethod;
  Class<?> mType;

  public MethodRunnable(final DataService target, final String name) {
    this(getClass(target), target, name);
  }

  public <X> MethodRunnable(Class<X> type, X object, String name) {
    mType = type;
    mMethod = getMethod(type, object, name);
    mObject = object;
  }

  // Calls a static, zero argument method.
  public MethodRunnable(Class<?> type, String name) {
    this(type, null, name);
  }

  @SuppressWarnings("unchecked")
  @SuppressLint("unchecked")
  static <X> Class<X> getClass(X x) {
    return (Class<X>) x.getClass();
  }

  static private Class<?>[] getTypes(Class<?>... types) {
    return types;
  }

  private static <X> Method getMethod(Class<X> type, final X object, final String name) {
    Exception ex=null;
    try {
      if (type == null && object != null)
        type = getClass(object);
      if(type!=null)
        return type.getMethod(name, getTypes());
    } catch (NoSuchMethodException e) {
      ex=e;
      e.printStackTrace();
    }
    throw new RuntimeException("Getting method", ex);
  }

  @Override
  public void run() {
    try {
      mMethod.invoke(mObject);
    } catch (IllegalAccessException | InvocationTargetException e) {
      e.printStackTrace();
    }
  }
}
