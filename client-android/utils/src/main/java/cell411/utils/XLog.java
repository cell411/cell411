package cell411.utils;

import static android.util.Log.DEBUG;
import static android.util.Log.ERROR;
import static android.util.Log.INFO;
import static android.util.Log.VERBOSE;
import static android.util.Log.WARN;

import android.util.Log;

import androidx.annotation.NonNull;

import java.io.ByteArrayOutputStream;
import java.io.PrintStream;
import java.util.Locale;

@SuppressWarnings("unused")
public final class XLog {
  static final String TAG = Reflect.getTag();
  static final PrintStream oldOut = System.out;
  static PrintStream smPrintString = new PrintStream(oldOut){
    public void println() {
      check();
      super.println();
    }
    public void println(String str) {
      check();
      super.println(str);
    }
    public void write(int val) {
      check();
      super.write(val);
    }
    public void write(byte[] bytes, int off, int len) {
      check();
      super.write(bytes,off,len);
    }
    public void printn(Object obj) {
      check();
      super.println(obj);
    }

    @Override
    public void flush() {
      super.flush();
    }

    @Override
    public void close() {
      check();
      super.close();
    }

    @Override
    public boolean checkError() {
      check();
      return super.checkError();
    }

    @Override
    protected void setError() {
      check();
      super.setError();
    }

    @Override
    protected void clearError() {
      check();
      super.clearError();
    }

    @Override
    public void print(boolean b) {
      check();
      super.print(b);
    }

    @Override
    public void print(char c) {
      check();
      super.print(c);
    }

    @Override
    public void print(int i) {
      check();
      super.print(i);
    }

    @Override
    public void print(long l) {
      check();
      super.print(l);
    }

    @Override
    public void print(float f) {
      check();
      super.print(f);
    }

    @Override
    public void print(double d) {
      check();
      super.print(d);
    }

    @Override
    public void print(char[] s) {
      check();
      super.print(s);
    }

    @Override
    public void print(String s) {
      check();
      super.print(s);
    }

    @Override
    public void print(Object obj) {
      check();
      super.print(obj);
    }

    @Override
    public void println(boolean x) {
      check();
      super.println(x);
    }

    @Override
    public void println(char x) {
      check();
      super.println(x);
    }

    @Override
    public void println(int x) {
      check();
      super.println(x);
    }

    @Override
    public void println(long x) {
      check();
      super.println(x);
    }

    @Override
    public void println(float x) {
      check();
      super.println(x);
    }

    @Override
    public void println(double x) {
      check();
      super.println(x);
    }

    @Override
    public void println(char[] x) {
      check();
      super.println(x);
    }

    @Override
    public void println(Object x) {
      check();
      super.println(x);
    }

    @Override
    public PrintStream printf(String format, Object... args) {
      check();
      return super.printf(format, args);
    }

    @Override
    public PrintStream printf(Locale l, String format, Object... args) {
      check();
      return super.printf(l, format, args);
    }

    @Override
    public PrintStream format(String format, Object... args) {
      check();
      return super.format(format, args);
    }

    @Override
    public PrintStream format(Locale l, String format, Object... args) {
      check();
      return super.format(l, format, args);
    }

    @Override
    @NonNull
    public PrintStream append(CharSequence csq) {
      check();
      return super.append(csq);
    }

    @Override
    @NonNull
    public PrintStream append(CharSequence csq, int start, int end) {
      check();
      return super.append(csq, start, end);
    }

    @Override
    @NonNull
    public PrintStream append(char c) {
      check();
      return super.append(c);
    }
    public void check() {
      flush();
    }
  };
  static {
    System.setOut(smPrintString);
  }
  static final ILog smLog = new AndroidLog();

  public static ILog getLog() {
    return smLog;
  }
  private XLog() {
  }

  public static boolean isLoggable(String tag, int level) {
    return getLog().isLoggable(tag, level);
  }

  public static int d(String tag, LazyMessage msg) {
    if (!isLoggable(tag, DEBUG)) {
      return 0;
    }
    return getLog().d(tag, msg.toString(), null);
  }

  public static int d(String tag, String msg, Throwable tr, Object... args) {
    if (!isLoggable(tag, DEBUG)) {
      return 0;
    }
    if (args != null && args.length > 0) {
      msg = Util.format(msg, args);
    }
    return getLog().v(tag, msg, tr);
  }

  public static int d(String tag, String msg, Object... args) {
    if (!isLoggable(tag, DEBUG)) {
      return 0;
    }
    if (args != null && args.length > 0) {
      msg = Util.format(msg, args);
    }
    return getLog().d(tag, msg, null);
  }

  public static int e(String tag, LazyMessage msg) {
    if (!isLoggable(tag, ERROR)) {
      return 0;
    }
    return getLog().e(tag, msg.toString(), null);
  }

  public static int e(String tag, String msg, Object... args) {
    if (!isLoggable(tag, ERROR)) {
      return 0;
    }
    if (args != null && args.length > 0) {
      msg = Util.format(msg, args);
    }
    return getLog().e(tag, msg, null);
  }

  public static int e(String tag, String msg, Throwable tr, Object... args) {
    if (!isLoggable(tag, ERROR)) {
      return 0;
    }
    if (args != null && args.length > 0) {
      msg = Util.format(msg, args);
    }
    return getLog().e(tag, msg, tr);
  }

  public static int i(String tag, LazyMessage msg) {
    int res = 0;
    if (isLoggable(tag, INFO)) {
      res = getLog().i(tag, msg.toString(), null);
    }
    return res;
  }

  public static int i(String tag, String msg, Object... args) {
    if (!isLoggable(tag, INFO)) {
      return 0;
    }
    if (args != null && args.length > 0) {
      msg = Util.format(msg, args);
    }
    return getLog().i(tag, msg, null);
  }

  public static int i(String tag, String msg, Throwable tr, Object... args) {
    if (!isLoggable(tag, INFO)) {
      return 0;
    }
    if (args != null && args.length > 0) {
      msg = Util.format(msg, args);
    }
    return getLog().i(tag, msg, tr);
  }

  public static int v(String tag, LazyMessage msg) {
    int res = 0;
    if (isLoggable(tag, VERBOSE)) {
      res = getLog().v(tag, msg.toString(), null);
    }
    return res;
  }

  public static int v(String tag, String msg, Object... args) {
    if (!isLoggable(tag, VERBOSE)) {
      return 0;
    }
    if (args != null && args.length > 0) {
      msg = Util.format(msg, args);
    }
    return getLog().v(tag, msg, null);
  }

  public static int v(String tag, String msg, Throwable tr, Object... args) {
    if (!isLoggable(tag, VERBOSE)) {
      return 0;
    }
    if (args != null && args.length > 0) {
      msg = Util.format(msg, args);
    }
    return getLog().v(tag, msg, tr);
  }

  public static int w(String tag, LazyMessage msg) {
    if (!isLoggable(tag, WARN)) {
      return 0;
    }
    return getLog().w(tag, msg.toString(), null);
  }

  public static int w(String tag, String msg, Object... args) {
    if (!isLoggable(tag, WARN)) {
      return 0;
    }
    if (args != null && args.length > 0) {
      msg = Util.format(msg, args);
    }
    return getLog().w(tag, msg, null);
  }

  public static int w(String tag, String msg, Throwable tr, Object... args) {
    if (!isLoggable(tag, WARN)) {
      return 0;
    }
    if (args != null && args.length > 0) {
      msg = Util.format(msg, args);
    }
    return getLog().w(tag, msg, tr);
  }

  public static int w(String tag, Throwable tr) {
    if (!isLoggable(tag, WARN)) {
      return 0;
    }
    return getLog().w(tag, "exception", tr);
  }

  public static boolean isLoggable(Tag tag, int level) {
    return getLog().isLoggable(tag, level);
  }

  public static int d(Tag tag, LazyMessage msg) {
    if (!isLoggable(tag, DEBUG)) {
      return 0;
    }
    return getLog().d(tag, msg.toString(), null);
  }

  public static int d(Tag tag, String msg, Throwable tr, Object... args) {
    if (!isLoggable(tag, DEBUG)) {
      return 0;
    }
    if (args != null && args.length > 0) {
      msg = Util.format(msg, args);
    }
    return getLog().v(tag, msg, tr);
  }

  public static int d(Tag tag, String msg, Object... args) {
    if (!isLoggable(tag, DEBUG)) {
      return 0;
    }
    if (args != null && args.length > 0) {
      msg = Util.format(msg, args);
    }
    return getLog().d(tag, msg, null);
  }

  public static int e(Tag tag, LazyMessage msg) {
    if (!isLoggable(tag, ERROR)) {
      return 0;
    }
    return getLog().e(tag, msg.toString(), null);
  }

  public static int e(Tag tag, String msg, Object... args) {
    if (!isLoggable(tag, ERROR)) {
      return 0;
    }
    if (args != null && args.length > 0) {
      msg = Util.format(msg, args);
    }
    return getLog().e(tag, msg, null);
  }

  public static int e(Tag tag, String msg, Throwable tr, Object... args) {
    if (!isLoggable(tag, ERROR)) {
      return 0;
    }
    if (args != null && args.length > 0) {
      msg = Util.format(msg, args);
    }
    return getLog().e(tag, msg, tr);
  }

  public static int i(Tag tag, LazyMessage msg) {
    int res = 0;
    if (isLoggable(tag, INFO)) {
      res = getLog().i(tag, msg.toString(), null);
    }
    return res;
  }

  public static int i(Tag tag, String msg, Object... args) {
    if (!isLoggable(tag, INFO)) {
      return 0;
    }
    if (args != null && args.length > 0) {
      msg = Util.format(msg, args);
    }
    return getLog().i(tag, msg, null);
  }

  public static int i(Tag tag, String msg, Throwable tr, Object... args) {
    if (!isLoggable(tag, INFO)) {
      return 0;
    }
    if (args != null && args.length > 0) {
      msg = Util.format(msg, args);
    }
    return getLog().i(tag, msg, tr);
  }

  public static int v(Tag tag, LazyMessage msg) {
    int res = 0;
    if (isLoggable(tag, VERBOSE)) {
      res = getLog().v(tag, msg.toString(), null);
    }
    return res;
  }

  public static int v(Tag tag, String msg, Object... args) {
    if (!isLoggable(tag, VERBOSE)) {
      return 0;
    }
    if (args != null && args.length > 0) {
      msg = Util.format(msg, args);
    }
    return getLog().v(tag, msg, null);
  }

  public static int v(Tag tag, String msg, Throwable tr, Object... args) {
    if (!isLoggable(tag, VERBOSE)) {
      return 0;
    }
    if (args != null && args.length > 0) {
      msg = Util.format(msg, args);
    }
    return getLog().v(tag, msg, tr);
  }

  public static int w(Tag tag, LazyMessage msg) {
    if (!isLoggable(tag, WARN)) {
      return 0;
    }
    return getLog().w(tag, msg.toString(), null);
  }

  public static int w(Tag tag, String msg, Object... args) {
    if (!isLoggable(tag, WARN)) {
      return 0;
    }
    if (args != null && args.length > 0) {
      msg = Util.format(msg, args);
    }
    return getLog().w(tag, msg, null);
  }

  public static int w(Tag tag, String msg, Throwable tr, Object... args) {
    if (!isLoggable(tag, WARN)) {
      return 0;
    }
    if (args != null && args.length > 0) {
      msg = Util.format(msg, args);
    }
    return getLog().w(tag, msg, tr);
  }

  public static int w(Tag tag, Throwable tr) {
    if (!isLoggable(tag, WARN)) {
      return 0;
    }
    return getLog().w(tag, "exception", tr);
  }

  public interface Tag {
    @NonNull
    String toString();
  }


  public interface ILog {
    boolean isLoggable(String tag, int level);

    int d(String tag, String msg, Throwable tr);

    int e(String tag, String msg, Throwable tr);

    int i(String tag, String msg, Throwable tr);

    int v(String tag, String msg, Throwable tr);

    int w(String tag, String msg, Throwable tr);

    default boolean isLoggable(Tag tag, int level) {
      return isLoggable(String.valueOf(tag), level);
    }

    default int d(Tag tag, String msg, Throwable tr) {
      return d(String.valueOf(tag), msg, tr);
    }

    default int e(Tag tag, String msg, Throwable tr) {
      return e(String.valueOf(tag), msg, tr);
    }

    default int i(Tag tag, String msg, Throwable tr) {
      return i(String.valueOf(tag), msg, tr);
    }

    default int v(Tag tag, String msg, Throwable tr) {
      return v(String.valueOf(tag), msg, tr);
    }

    default int w(Tag tag, String msg, Throwable tr) {
      return e(String.valueOf(tag), msg, tr);
    }
  }

  static abstract class StreamLog implements ILog {

    final PrintStream mStream = createStream();

//    {
//      PrintStream saveOut = System.out;
//      PrintStream saveErr = System.err;
//
//      System.setOut(mStream);
//      System.setErr(mStream);
//    }

    abstract PrintStream createStream();

    @Override
    public boolean isLoggable(String tag, int level) {
      return true;
    }

    @Override
    public int d(String tag, String msg, Throwable tr) {
      mStream.println("D/" + tag + ": " + msg);
      if (tr != null) {
        mStream.println(Log.getStackTraceString(tr));
      }
//      if (mNext != null) {
//        mNext.d(tag, msg, tr);
//      }
      return 0;
    }

    @Override
    public int e(String tag, String msg, Throwable tr) {
      mStream.println("E/" + tag + ": " + msg);
      if (tr != null) {
        mStream.println(Log.getStackTraceString(tr));
      }
//      if (mNext != null) {
//        mNext.e(tag, msg, tr);
//      }
      return 0;
    }

    @Override
    public int i(String tag, String msg, Throwable tr) {
      mStream.println("I/" + tag + ": " + msg);
      if (tr != null) {
        mStream.println(Log.getStackTraceString(tr));
      }
//      if (mNext != null) {
//        mNext.i(tag, msg, tr);
//      }
      return 0;
    }

    @Override
    public int v(String tag, String msg, Throwable tr) {
      mStream.println("V/" + tag + ": " + msg);
      if (tr != null) {
        mStream.println(Log.getStackTraceString(tr));
      }
//      if (mNext != null) {
//        mNext.v(tag, msg, tr);
//      }
      return 0;
    }

    @Override
    public int w(String tag, String msg, Throwable tr) {
      mStream.println("W/" + tag + ": " + msg);
      if (tr != null) {
        mStream.println(Log.getStackTraceString(tr));
      }
//      if (mNext != null) {
//        mNext.w(tag, msg, tr);
//      }
      return 0;
    }
  }

  // This ILog just forwards whatever it gets to the Android log.
  // However, one could implement the same interface and do something
  // totally different.
  static final class AndroidLog implements ILog {
    public boolean isLoggable(String tag, int level) {
      return true;
    }

    public int d(String tag, String msg, Throwable tr) {
      return Log.v(tag, msg, tr);
    }

    public int e(String tag, String msg, Throwable tr) {
      return Log.e(tag, msg, tr);
    }

    public int i(String tag, String msg, Throwable tr) {
      if(msg.contains("EmergencyContact")) {
        XLog.i(TAG, "HERE!");
      }
      return Log.i(tag, msg, tr);
    }

    public int v(String tag, String msg, Throwable tr) {
      return Log.v(tag, msg, tr);
    }

    public int w(String tag, String msg, Throwable tr) {
      return Log.w(tag, msg, tr);
    }
  }

  private static class NetLog extends StreamLog {

    private PhoneHome mPhoneHome;

    public NetLog() {

    }
    public NetLog(PhoneHome home) {
      mPhoneHome = home;
    }

    @Override
    PrintStream createStream() {
      if(mPhoneHome==null)
        mPhoneHome = new PhoneHome();
      return new PrintStream( mPhoneHome.getStream() );
    }
  }
}
