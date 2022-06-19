package cell411.utils;

import android.os.HandlerThread;

public class HandlerThreadPlus extends HandlerThread {
  private final static String TAG = Reflect.getTag();
  static int smCount = 0;
  static HandlerThreadPlus smDemo = new HandlerThreadPlus("DEMO MODEL!");
  static CarefulHandler smHandler = smDemo.getHandler();
  static HandlerThreadPlus[] smShowRoom = new HandlerThreadPlus[3];
  static Runnable smRunnable = new Runnable() {
    @Override
    public void run() {
      System.out.println("We have a thread.");

    }
  };

  public static HandlerThreadPlus createThread(String name) {
    return new HandlerThreadPlus(name);
  }
  public HandlerThreadPlus() {
    super("STOCK");
  }

  static String genName(String base) {
    return Util.format("%s #%d", base, ++smCount);
  }

  static {
    XLog.i(TAG, Reflect.currentSimpleClassName() + " is loading");
  }
  // This is like a HandlerThread, except it starts itself, and it
  // creates a Handler, as well as a looper.
  //
  // We try to syncronize it so that the handler is created before the
  // constructor returns, allowing you to create a final static field
  // for the Thread, and then another for the Handler.
  protected CarefulHandler mHandler;
  protected boolean        mComplete;

  public HandlerThreadPlus(String name) {
    super(genName(name));
    start();
    synchronized (this) {
      while (mHandler == null) {
        ThreadUtil.wait(this, 100);
      }
      mComplete = true;
    }
  }

  @Override
  protected void onLooperPrepared() {
    synchronized (this) {
      super.onLooperPrepared();
      mHandler = new CarefulHandler(getLooper());
      ThreadUtil.waitUntil(this, () -> mComplete);
    }

  }

  public synchronized CarefulHandler getHandler() {
    ThreadUtil.waitUntil(this, () -> mHandler != null);
    return mHandler;
  }

  public boolean isCurrentThread() {
    return currentThread() == this;
  }
}
