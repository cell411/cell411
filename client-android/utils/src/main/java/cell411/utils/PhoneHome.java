package cell411.utils;

import android.os.Handler;
import android.os.HandlerThread;
import android.util.Log;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintStream;
import java.net.Socket;

public class PhoneHome {
  private static final String TAG = Reflect.getTag();
  static {
    XLog.i(TAG, "loading class");
  }
  HandlerThreadPlus mThread = new HandlerThreadPlus("Phone Home");
  Handler mHandler = mThread.getHandler();
  Runnable mRunnable = new Runnable() {
    @Override
    public void run() {
      mPrint = new PrintStream(getOutputStream());
    }
  };
  Socket mSocket;
  OutputStream mOutputStream;
  public PhoneHome() {
    mHandler.postDelayed(mRunnable,0);
  }
  OutputStream getOutputStream() {
    if (mOutputStream != null)
      return mOutputStream;

    try {
      mSocket = new Socket("dev.copblock.app", 3333);
      mOutputStream = mSocket.getOutputStream();
      return mOutputStream;
    } catch (IOException e) {
      e.printStackTrace();
      throw Util.rethrow("opening socket", e);
    }
  }
  PrintStream mPrint;
  PrintStream getStream() {
    return mPrint;
  }

}

