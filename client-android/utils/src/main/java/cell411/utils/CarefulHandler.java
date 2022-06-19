package cell411.utils;

import android.os.Handler;
import android.os.Looper;
import android.os.Message;

import androidx.annotation.NonNull;

public class CarefulHandler extends Handler {
  //private final static String TAG = Reflect.getTag();

  static int smThreadId = 10;
  static ThreadLocal<Integer> smId = new ThreadLocal<>();
  XLog.Tag TAG = new XLog.Tag() {
    @NonNull
    public String toString() {
      if (smId.get() == null) {
        synchronized (CarefulHandler.class) {
          if (smId.get() == null) {
            smId.set(smThreadId++);
          }
          XLog.i(this, " => thread: %s", Thread.currentThread());
        }
      }

      return Util.format("THREAD-%d", smId.get());
    }
  };


  public CarefulHandler(Looper looper) {
    super(looper, new LoggingCallback());
  }

  @Override
  public void dispatchMessage(@NonNull Message msg) {
    try {
      super.dispatchMessage(msg);
    } catch (Throwable t) {
      t.printStackTrace();
    }
  }

  @Override
  public boolean sendMessageAtTime(@NonNull Message msg, long uptimeMillis) {
    Runnable callback = msg.getCallback();
    if(callback instanceof PostManyRunOnce.RealRunnable) {
      PostManyRunOnce.RealRunnable realRunnable = (PostManyRunOnce.RealRunnable) callback;
      realRunnable.mOwner.posted();
    }
    return super.sendMessageAtTime(msg, uptimeMillis);
  }

  @NonNull
  public String toString() {
    return Util.format("[CarefulHandler: %s]", getLooper().getThread());
  }
}
