package cell411.utils;

import cell411.utils.func.Func0;

public class ThreadUtil {

  public static void waitUntil(Object o, Func0<Boolean> cond) {
    waitUntil(o, cond, 2000);
  }

  public static void waitUntil(Object o, Func0<Boolean> cond, long timeout) {
    synchronized (o) {
      while (!cond.apply()) {
        wait(o, timeout);
      }
    }
  }

  @SuppressWarnings("SynchronizationOnLocalVariableOrMethodParameter")
  public static long wait(Object o, long timeout) {
    long endTime = System.currentTimeMillis() + timeout;
    synchronized (o) {
      try {
        o.wait(timeout);
      } catch (InterruptedException e) {
        e.printStackTrace();
      }
    }
    return endTime - System.currentTimeMillis();
  }

  public static void sleep(long i) {
    if (i < 100) {
      throw new IllegalArgumentException("Sleep should have a duration of at least 100");
    }
    sleepUntil(System.currentTimeMillis() + i);
  }

  public static void sleepUntil(final long endTime) {
    long millis = System.currentTimeMillis();
    while (millis < endTime) {
      try {
        Thread.sleep(endTime - System.currentTimeMillis());
      } catch (InterruptedException ignored) {
      }
      millis = System.currentTimeMillis();
    }
  }

}
