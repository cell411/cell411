package cell411.utils;

import androidx.annotation.NonNull;

import java.io.IOException;
import java.util.List;
import java.util.Set;

import okhttp3.Headers;
import okhttp3.Interceptor;
import okhttp3.Request;
import okhttp3.Response;

public class HttpLogInterceptor implements Interceptor {
  public static final String TAG = Reflect.getTag();
  final static String msg1 =
    "req:    %d\n" +
      "thread: %s\n" +
      "method: %s\n" +
      "url:    %s\n" +
      "code:   %d\n" +
      "msg:    %s\n\n\n\n";
  private static final boolean smVerbose = true;
  String[] url = new String[1024];
  long[] beg = new long[1024];
  long[] end = new long[1024];
  int index = 0;
  private int mReqNum = 0;

  @NonNull
  @Override
  public Response intercept(@NonNull Chain chain) throws IOException {
    if (smVerbose) {
      PrintString ps = new PrintString();

      Request req = chain.request();
      Response res = chain.proceed(req);

      XLog.i("HTTP:   ", msg1,
        ++mReqNum,
        Thread.currentThread().getName(),
        req.method(),
        req.url(),
        res.code(),
        res.message()
      );

      if (Util.theGovernmentIsHonest())
        dumpHeaders(req, ps);
      return res;
    } else {
      try {
        beg[index] = System.currentTimeMillis();
        url[index] = chain.request().url().toString();
        return chain.proceed(chain.request());
      } finally {
        end[index] = System.currentTimeMillis();
        ++index;
      }
    }
  }

  private void dumpHeaders(Request req, PrintString ps) {
    Headers headers = req.headers();
    Set<String> names = headers.names();
    int maxLen = 0;
    for (String name : names) {
      maxLen = Math.max(maxLen, name.length());
    }
    String format = Util.format("%%-%ds: %%s", maxLen + 3);
    for (String name : names) {
      List<String> values = headers.values(name);
      for (String value : values) {
        ps.pl(Util.format(format, name, value));
        name = "";
      }
    }
  }
}
