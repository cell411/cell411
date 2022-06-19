package cell411.parse.util;

import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import androidx.annotation.NonNull;

import cell411.base.BaseApp;
import cell411.utils.Reflect;
import cell411.utils.XLog;

public class ObstructingHandler extends Handler {
  private final static String TAG = Reflect.getTag();
  boolean mPaused = false;
  public ObstructingHandler(Looper looper) {
    super(looper);
  }
  synchronized void setPaused(boolean paused) {
    if (mPaused == paused)
      return;
    mPaused = paused;
    if (mPaused)
      return;
    notifyAll();
  }
  @Override
  public void handleMessage(@NonNull Message msg)
  {
    if (mPaused)
      waitUntilUnpaused();
    super.handleMessage(msg);
  }
  @Override
  public void dispatchMessage(@NonNull Message msg)
  {
    if (mPaused)
      waitUntilUnpaused();
    super.dispatchMessage(msg);
  }
  @NonNull
  @Override
  public String getMessageName(@NonNull Message message)
  {
    String result = super.getMessageName(message);
    XLog.i(TAG, "name requested for " + message);
    XLog.i(TAG, "msg " + message + " named " + result);
    return result;
  }
  public synchronized void waitUntilUnpaused() {
    while (mPaused) {
      try {
        wait(60000);
        XLog.i(TAG, "I am paused, I ain't doing shit.");
      } catch (InterruptedException ignored) {
        // Say nothing, act natural!
      } catch (ThreadDeath notSurvived) {
        throw notSurvived;
      } catch (Throwable notIgnored) {
        BaseApp.get().handleException("waiting for end to pause condition", notIgnored);
      }
    }
  }
  @Override
  public boolean sendMessageAtTime(@NonNull Message msg, long uptimeMillis)
  {
    return super.sendMessageAtTime(msg, uptimeMillis);
  }
}
