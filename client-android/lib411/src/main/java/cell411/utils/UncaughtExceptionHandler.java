package cell411.utils;

import cell411.base.BaseApp;

public class UncaughtExceptionHandler
{
  public static final String TAG = Reflect.getTag();

  public static void registerCurrentThread() {
    Thread.setDefaultUncaughtExceptionHandler(UncaughtExceptionHandler::uncaughtException);
  }

  public static void uncaughtException(Thread thread, Throwable throwable) {
    XLog.e(TAG, "uncaught exception in thread " + thread);
    XLog.e(TAG, "  throwable: " + throwable);
    BaseApp.get().handleException("running thread "+thread, throwable);
  }
}
