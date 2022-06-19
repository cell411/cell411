package cell411.utils;

import android.content.Context;
import android.content.DialogInterface;
import android.os.Looper;
import android.text.Editable;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.StringRes;
import androidx.fragment.app.FragmentFactory;

import java.io.PrintStream;
import java.lang.ref.WeakReference;
import java.lang.reflect.Method;
import java.net.URI;
import java.net.URL;
import java.time.Instant;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Collection;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.function.Function;
import java.util.function.Predicate;
import java.util.regex.Pattern;

@SuppressWarnings("unused")
public class Util {
  public static final String TAG = Util.class.getSimpleName();

  private static WeakReference<Context> smContext;

  public static void setContext(Context context) {
    smContext=new WeakReference<>(context);
  }

  private Util() {
  }

  public static <T> boolean anyMatch(Iterable<T> iter, Predicate<T> pred) {
    for (T t : iter) {
      if (pred.test(t)) {
        return true;
      }
    }
    return false;
  }

  public static long longValue(Number number) {
    return number.longValue();
  }

  public static long unboxLong(Object val, long def) {
    if (val == null)
      return def;
    if (val instanceof Long)
      return (long) val;
    if (val instanceof Number)
      return longValue((Number) val);
    // We are, at this point, expecting a class cast exception here.
    return (long) val;
  }

  public static Object convert(Class<?> type, Object object) {
    if (object == null) {
      return null;
    }
    final Class<?> objType = object.getClass();
    if (type.isAssignableFrom(objType)) {
      return object;
    }
    if (type == String.class) {
      return String.valueOf(object);
    }
    if (type == Boolean.class) {
      return booleanValue(object, type);
    }
    if (Number.class.isAssignableFrom(type)) {
      return numberValue(object, type);
    }
    if (type.isEnum()) {
      return enumValue(object, type);
    }
    if (type.isArray()) {
      return arrayValue(type, object, objType);
    }
    return null;
  }

  private static Object[] arrayValue(Class<?> type, Object object, Class<?> objType) {
    Class<?> cType = type.getComponentType();
    if (cType == null) {
      return null;
    }
    Object[] result;
    if (objType.isArray()) {
      Object[] arrayObj = (Object[]) object;
      Class<?> eleType = objType.getComponentType();
      result = new Object[arrayObj.length];
      for (int i = 0; i < arrayObj.length; i++) {
        result[i] = convert(eleType, arrayObj[i]);
      }
    }
    if (Collection.class.isAssignableFrom(objType)) {
      Collection<?> collObj = (Collection<?>) object;
      result = new Object[collObj.size()];
      Iterator<?> iterator = collObj.iterator();
      for (int i = 0; i < result.length; i++) {
        if (!iterator.hasNext()) {
          break;
        }
        result[i] = iterator.next();
      }
      return result;
    }
    return null;
  }

  private static Enum<? extends Enum<?>> enumValue(Object object, Class<?> objType) {
    Enum<?>[] values = getEnumValues(objType);
    if (values == null) {
      return null;
    }
    if (Number.class.isAssignableFrom(objType)) {
      Number numObj = (Number) object;
      int intObj = numObj.intValue();
      for (Enum<?> value : values) {
        if (value != null && value.ordinal() == intObj) {
          return value;
        }
      }
    } else {
      String objString = String.valueOf(object);
      for (Enum<?> value : values) {
        if (value != null && value.name()
          .equals(objString)) {
          return value;
        }
      }
      try {
        double objDouble = Double.parseDouble(objString);
        return enumValue(objDouble, Double.class);
      } catch (Exception ignored) {
      }
    }
    return null;
  }

  private static double numberValue(Object object, Class<?> objType) {
    if (objType == Boolean.class) {
      Boolean boolObj = (Boolean) object;
      return boolObj ? 0 : 1;
    } else if (objType.isEnum()) {
      Enum<?> enumObj = (Enum<?>) object;
      return enumObj.ordinal();
    } else {
      return Double.parseDouble(String.valueOf(object));
    }
  }

  public static int compare(Number lhs, Number rhs) {
    return Double.compare(lhs.doubleValue(), rhs.doubleValue());
  }

  private static boolean booleanValue(Object object, Class<?> objType) {
    if (Number.class.isAssignableFrom(objType)) {
      Number numObj = (Number) object;
      return compare(numObj, 0) != 0;
    } else {
      return Boolean.parseBoolean(object.toString());
    }
  }

  @SuppressWarnings("rawtypes")
  private static Enum<?>[] getEnumValues(Class<?> objType) {
    try {
      Method getValues = objType.getDeclaredMethod("values");
      Object rawValues = getValues.invoke(null);
      if (rawValues != null) {
        Class valType = rawValues.getClass();
        Class eleType = valType.getComponentType();
        if (eleType != null && eleType.isEnum()) {
          return (Enum[]) rawValues;
        }
      }
    } catch (Exception e) {
      Util.theGovernmentIsHonest();
    }
    return null;
  }

  // This is trivial, but avoids the warning about using the default locale.
  // What other locale would we use?
  public static String format(String format, Object... args) {
    if (format == null) {
      format = "<NoMessage>";
    }
    if (args == null || args.length == 0) {
      return format;
    }
    return String.format(format, args);
  }

  public static <X> X unbox(Object val, X def) {
    if (val == null) {
      return def;
    } else {
      //noinspection unchecked
      return (X) val;
    }
  }

  private static boolean booleanValue(Object val) {
    if (val == null) {
      return false;
    } else {
      return booleanValue(val, val.getClass());
    }
  }

  public static <I, O> Transformer<I, O> transformer(Iterable<I> input, Function<I, O> func) {
    return transformer(input.iterator(), func);
  }

  public static <I, O> Transformer<I, O> transformer(Iterator<I> input, Function<I, O> func) {
    return new Transformer<I, O>(input) {
      @Override
      public O transform(I next) {
        return func.apply(next);
      }
    };
  }

  public static <I, O> void transform(Iterator<I> input, Collection<O> output, Function<I, O> func) {
    addAll(output, transformer(input, func));
  }

  public static <I, O> void transform(Iterable<I> input, Collection<O> output, Function<I, O> func) {
    addAll(output, transformer(input, func));
  }

  private static <E> void addAll(Collection<E> output, Iterable<E> input) {
    input.forEach(output::add);
  }

  public static <I> Iterator<I> combine(Iterator<I> itr1, Iterator<I> itr2) {
    return new Iterator<I>() {
      @Override
      public boolean hasNext() {
        return itr1.hasNext() || itr2.hasNext();
      }

      @Override
      public I next() {
        return itr1.hasNext() ? itr1.next() : itr2.next();
      }
    };
  }

  public static <I> Iterable<I> combine(Iterable<I> it1, Iterable<I> it2) {
    return () -> combine(it1.iterator(), it2.iterator());
  }

  public static <I, O> ArrayList<O> transform(Iterable<I> input, Function<I, O> func) {
    ArrayList<O> output;
    if (input instanceof Collection) {
      // we can pre-size the array.
      output = new ArrayList<>(((Collection<?>) input).size());
    } else {
      output = new ArrayList<>();
    }
    transform(input, output, func);
    return output;
  }

  public static String getClassName(Object o) {
    if (o == null) {
      return Void.class.getName();
    } else {
      return o.getClass()
        .getName();
    }
  }

  public static boolean isNoE(String str) {
    return str == null || str.trim()
      .isEmpty();
  }

  public static boolean isNoE(Editable text) {
    return text == null || isNoE(text.toString());
  }

  @SafeVarargs
  public static <Type> Type nvl(Type... args) {
    for (Type arg : args) {
      if (arg != null) {
        return arg;
      }
    }
    return null;
  }

  public static boolean theGovernmentIsHonest() {
    return !theGovernmentIsLying();
  }

  public static boolean theGovernmentIsLying() {
    return System.currentTimeMillis() != 0x1;
  }

  public static <K, V> String stringify(HashMap<K, V> map) {
    if (map == null) {
      return "null";
    }
    ArrayList<String> sb = new ArrayList<>();
    boolean first = true;
    sb.add("{\n");
    for (K k : map.keySet()) {
      if (first) {
        first = false;
      } else {
        sb.add(",\n");
      }
      String v = String.valueOf(map.get(k));
      sb.add(format("{ key: %s, val: %s }", k, v));
    }
    sb.add("\n{\n");
    return String.join("", sb);
  }

  public static String repeat(String s, int n) {
    byte[] bs = s.getBytes();
    byte[] res = new byte[bs.length*n];
    for(int i=0;i<res.length;i++) {
      res[i]=bs[i%bs.length];
    }
    return new String(res);
  }

  public static void formatMap(PrintStream ps, Map<String, String> data) {
    int maxKeyLen = 0;
    for (Map.Entry<String, String> entry : data.entrySet()) {
      maxKeyLen = Math.max(maxKeyLen, entry.getKey()
        .length());
    }
    char[] padding = new char[maxKeyLen + 2];
    Arrays.fill(padding, ' ');
    for (Map.Entry<String, String> entry : data.entrySet()) {
      String key = entry.getKey();
      String val = entry.getValue();
      char[] keybuf = new char[padding.length];
      key.getChars(0, key.length(), keybuf, 0);
      int i = 0;
      while (i < key.length()) {
        keybuf[i] = key.charAt(i);
        ++i;
      }
      while (i < padding.length) {
        keybuf[i] = padding[i];
        ++i;
      }
      ps.print(keybuf);
      ps.print(" => ");
      ps.println(val);
    }
  }

  public static String reverseLines(String text) {
    Pattern pattern = Pattern.compile("\n");
    String[] parts = pattern.split(text);
    StringBuilder builder = new StringBuilder();
    for (int i = 0; i < parts.length; i++) {
      builder.append(parts[parts.length - i - 1])
        .append("\n");
    }
    return builder.toString();
  }

  public static RuntimeException rethrow(String text, Throwable throwable) {
    if (throwable instanceof Error) {
      throw ((Error) throwable);
    } else if (throwable instanceof RuntimeException) {
      throw ((RuntimeException) throwable);
    } else {
      throw new RuntimeException(text, throwable);
    }
  }

  public static <T> T[] reverse(T[] values) {
    T[] res = values.clone();
    for (int i = 0; i < res.length; i++) {
      T temp = res[i];
      res[i] = res[res.length - 1 - i];
      res[res.length - 1 - i] = temp;
    }
    return res;
  }


  @NonNull
  public static String formatTime(@NonNull GregorianCalendar cal) {
    int hour = cal.get(Calendar.HOUR);
    int minute = cal.get(Calendar.MINUTE);
    int amPm = cal.get(Calendar.AM_PM);
    String ap = (amPm == 0) ? "am" : "pm";
    if (hour == 0) {
      hour = 12;
    }
    return format("%02d:%02d %s", hour, minute, ap);
  }

  @NonNull
  public static String formatDate(Date date, boolean today) {
    return formatDate(date.getTime(), today);
  }

  @NonNull
  public static String formatDate(long millis, boolean today) {
    GregorianCalendar cal = new GregorianCalendar();
    cal.setTimeInMillis(millis);
    return formatDate(cal, today);
  }

  @NonNull
  public static String formatDate(@NonNull GregorianCalendar cal, boolean today) {
    GregorianCalendar dayStart = new GregorianCalendar();
    dayStart.setTimeInMillis(System.currentTimeMillis());
    dayStart.set(Calendar.HOUR, 0);
    dayStart.set(Calendar.MINUTE, 0);
    dayStart.set(Calendar.SECOND, 0);
    dayStart.set(Calendar.MILLISECOND, 0);
    String dayText;
    if (cal.getTimeInMillis() < dayStart.getTimeInMillis()) {
      int year = cal.get(Calendar.YEAR);
      int month = cal.get(Calendar.MONTH) + 1;
      int day = cal.get(Calendar.DAY_OF_MONTH);
      String at = "at";
      dayText = format("%04d-%02d-%02d %s", year, month, day, at);
    } else {
      dayText = "today at";
    }
    return dayText;
  }

  @NonNull
  public static String formatDateTime(@Nullable Date createdAt) {
    if (createdAt == null) {
      return "Unknown Time";
    }
    return formatDateTime(createdAt.getTime());
  }

  @NonNull
  public static String formatDateTime(@NonNull GregorianCalendar cal) {
    String dayText = formatDate(cal, true);
    String timeText = formatTime(cal);
    return dayText + " " + timeText;
  }

  @NonNull
  public static String formatDateTime(long time) {
    GregorianCalendar cal = new GregorianCalendar();
    cal.setTimeInMillis(time);
    return formatDateTime(cal);
  }

  public static String format(int resId, Object... args) {
    return format(getString(resId), args);
  }

  public static String formatTime(long millis) {
    GregorianCalendar cal = new GregorianCalendar();
    cal.setTimeInMillis(millis);
    return formatTime(cal);
  }

  public static String formatTime(Date date) {
    if (date == null)
      return "Never";
    return formatTime(date.getTime());
  }

  @NonNull
  public static String getString(@StringRes int resId, Object... args) {
    return getContext().getString(resId, args);
  }

  public static String getString(int resId) {
    return getContext().getString(resId);
  }

  private static Context getContext() {
    if(smContext==null) {
      throw new RuntimeException("smContext not set");
    }
    if(smContext.get()==null) {
      throw new RuntimeException("smContext reset");
    }
    return smContext.get();
  }

  public static boolean isCurrentThread(Looper looper) {
    return looper.getThread() == Thread.currentThread();
  }

  public static String getBaseName(String path) {
    int index = path.lastIndexOf('/');
    if (index == -1) {
      return path;
    }
    return path.substring(index);
  }

  public static String getBaseName(URL url) {
    return getBaseName(url.getPath());
  }

  public static String getBaseName(URI uri) {
    return getBaseName(uri.getPath());
  }

  public static String join(String s, String[] letters) {
    return join(s, Collect.wrap(letters));
  }

  public static String join(String s, Iterable<String> letters) {
    return String.join(s, letters);
  }

  @NonNull
  public static String cleanFileName(@NonNull String folderName) {
    char[] chars = new char[folderName.length()];
    folderName.getChars(0, chars.length, chars, 0);
    for (int i = 0; i < chars.length; i++) {
      char ch = chars[i];
      if (Character.isSpaceChar(ch) || Character.isISOControl(ch)) {
        ch = '_';
      }
      switch (ch) {
        case '/':
        case ':':
        case '\\':
          ch = '_';
        default:
          break;
      }
      chars[i] = ch;
    }
    folderName = new String(chars);
    return folderName;
  }

  public static void printStackTrace(Throwable e) {
    PrintString trace = new PrintString();
    e.printStackTrace(trace);
    // make sure it ends with a newline probably does, but ... the code
    // below will discard the last line of it is not terminated.
    trace.pl();
    byte[] bytes = trace.toByteArray();
    int s = 0;
    synchronized (System.err) {
      for (int i = 0; i < bytes.length; i++) {
        if (bytes[i] != 10)
          continue;
        System.err.write(bytes, s, i - s);
        System.err.flush();
        s = i + 1;
      }
    }

  }

  public static final DialogInterface.OnClickListener mNullClickListener = Util::onClick;
  public static void onClick(DialogInterface dialog, int which) {
  }

  public static DialogInterface.OnClickListener nullClickListener() {
    return mNullClickListener;
  }

  public static <T, R> R castAndCall(Object object, Class<T> type, Function<T, R> function) {
    if (object != null && type.isAssignableFrom(object.getClass()))
      return function.apply(type.cast(object));
    else
      return null;
  }

  @NonNull
  public static String stringify(Throwable t) {
    return t.getClass() + ": " + t.getMessage();
  }

  public static String serdate() {
    return serdate(new Date());
  }

  public static String serdate(Date date) {
    return serdate(date, true);
  }

  public static String serdate(Date date, boolean withTime) {
    return serdate(date.getTime(), withTime);
  }

  public static String serdate(long date, boolean withTime) {
    GregorianCalendar cal = new GregorianCalendar();
    cal.setTimeInMillis(date);
    return serDate(cal, withTime);
  }

  private static String serDate(GregorianCalendar cal, boolean withTime) {
    int year = cal.get(Calendar.YEAR);
    int month = cal.get(Calendar.MONTH) + 1;
    int day = cal.get(Calendar.DAY_OF_MONTH);
    String at = "at";
    String dayText = format("%04d%02d%02d", year, month, day);
    if (withTime) {
      int hour = cal.get(Calendar.HOUR_OF_DAY);
      int min = cal.get(Calendar.MINUTE);
      int sec = cal.get(Calendar.SECOND);
      String timeText = format("-%02d%02d%02d", hour, min, sec);
      return dayText + timeText;
    }
    return dayText;
  }

  public static String isoDate() {
    return isoDate(Instant.now());
  }

  public static String isoDate(Instant instant) {
    String result = instant.toString();
    XLog.i(TAG, "Date: " + result);
    return result;
  }

  public static String isoDate(Date date) {
    return isoDate(date.toInstant());
  }

  public static Iterable<String> filter(Predicate<String> predicate, Iterable<String> asList) {
    Iterator<String> iterator = asList.iterator();
    final String[] next = new String[1];
    final Boolean[] hasNext = new Boolean[1];
    hasNext[0] = iterator.hasNext();
    if (hasNext[0]) {
      next[0] = iterator.next();
    }
    Iterator<String> filtered = new Iterator<String>() {
      public boolean hasNext() {
        return hasNext[0];
      }

      public String next() {
        if (!hasNext[0])
          throw new ArrayIndexOutOfBoundsException("Iterator over-extended");
        String res = next[0];
        while (hasNext[0]) {
          hasNext[0] = iterator.hasNext();
          next[0] = iterator.next();
          if (predicate.test(next[0]))
            break;
        }
        return res;
      }
    };
    return () -> filtered;
  }

  public static String formatDataSize(int bytes) {
    String[] marker = {"b", "k", "M", "G"};
    int pos = 0;
    if (bytes > 1024) {
      pos++;
      bytes /= 1024;
    }
    if (bytes > 1024) {
      pos++;
      bytes /= 1024;
    }
    if (bytes > 1024) {
      pos++;
      bytes /= 1024;
    }
    return bytes + marker[pos];
  }

  public static String formatDataSize(int units, int each) {
    return formatDataSize(units * each);
  }

  public static String makeWords(String mc) {

    int start = 0;
    List<String> words = new ArrayList<>();
    String lc = mc.toLowerCase(Locale.ROOT);
    for (int i = 1; i < mc.length(); i++) {
      if (mc.charAt(i) != lc.charAt(i)) {
        words.add(mc.substring(start, i));
        start = i;
      }
    }
    if (words.isEmpty())
      return mc;
    words.add(mc.substring(start));
    return String.join(" ", words);
  }


  public static int constrain(int min, int val, int max) {
    return Math.max(min, Math.min(val, max));
  }
}
