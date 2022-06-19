package cell411.utils;

import androidx.annotation.NonNull;

public class LazyMessage {
  public static final String TAG = "LazyMessage";
  Object mMsg;
  Object[] mArgs;

  public LazyMessage(String msg, Object... args) {
    mMsg = msg;
    mArgs = args;
  }

  @NonNull
  public String toString() {
    Class<R> rc = R.class;
    XLog.i(TAG, "rc=" + rc);
    if (mMsg instanceof Exception) {
      Exception e = (Exception) mMsg;
      mMsg = e.getMessage();
    }
    if (!(mMsg instanceof String)) {
      mMsg = String.valueOf(mMsg);
    }
    if (mArgs != null && mArgs.length != 0) {
      mMsg = Util.format((String) mMsg, mArgs);
    }
    return (String) mMsg;
  }
}
