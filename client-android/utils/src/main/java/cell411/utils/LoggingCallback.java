package cell411.utils;

import android.os.Handler;
import android.os.Message;

import androidx.annotation.NonNull;

public class LoggingCallback implements Handler.Callback {
  public static final String TAG = Reflect.getTag();
  @Override
  public boolean handleMessage(
    @NonNull
      Message msg)
  {
    XLog.e(TAG, "msg: "+msg);
    return false;
  }
}
