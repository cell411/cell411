package cell411.utils;

import androidx.annotation.NonNull;
import androidx.core.util.Pair;

import java.util.ArrayList;

public class Timer {
  final ArrayList<Pair<Long, String>> mMessages = new ArrayList<>();

  public Timer() {

  }

  public synchronized void add(String string, Object... args) {
    if (args.length > 0)
      string = Util.format(string, args);
    Pair<Long, String> pair = new Pair<>(System.currentTimeMillis(), string);
    mMessages.add(pair);
  }

  @NonNull
  public synchronized String toString() {
    if (mMessages.size() == 0)
      return "Timer has No Messages";
    PrintString ps = new PrintString();
    String fmtFmt = "Timer: %%20%s|%%20%s|%%s";
    String fmt = Util.format(fmtFmt, "s", "s");
    ps.pl(fmt, "time", "elapsed", "message");
    fmt = Util.format(fmtFmt, "d", "d");
    long start = mMessages.get(0).first;
    long last = 0;
    for (Pair<Long, String> message : mMessages) {
      long time = message.first;
      String text = message.second;
      long elapsed = time - start;
      long delta = elapsed - last;
      last = elapsed;
      ps.pl(fmt, elapsed, delta, text);
    }
    return ps.toString();
  }
}
