package cell411.streamer.api.utils;

import android.content.Context;
import android.content.SharedPreferences;

import java.util.Locale;


public class Utils {
  public static final  String            APP_SHARED_PREFERENCES = "applicationDetails";
  public static final  int               ENCODER_NOT_TESTED     = -1;
  public static final  int               ENCODER_WORKS          = 1;
  public static final  int               ENCODER_NOT_WORKS      = 0;
  private static final String            DOES_ENCODER_WORK = Utils.class.getName() + ".DOES_ENCODER_WORK";
  //public static final String
  // SHARED_PREFERENCE_FIRST_INSTALLATION="FIRST_INSTALLATION";
  private static       SharedPreferences sharedPreferences = null;

  public static String getDurationString(String format, int seconds) {
    if (seconds < 0 || seconds > 2000000)//there is an codec problem and duration is not set correctly,
    // so display meaningfull string
    {
      seconds = 0;
    }
    int hours = seconds / 3600;
    int minutes = (seconds % 3600) / 60;
    seconds = seconds % 60;
    String res = String.format(Locale.US, format, hours, minutes, seconds);
    System.out.println(res);
    return res;
  }

  public static SharedPreferences getDefaultSharedPreferences(Context context) {
    if (sharedPreferences == null) {
      sharedPreferences = context.getSharedPreferences(APP_SHARED_PREFERENCES, Context.MODE_PRIVATE);
    }
    return sharedPreferences;
  }

  public static int doesEncoderWork(Context context) {
    return getDefaultSharedPreferences(context).getInt(DOES_ENCODER_WORK, ENCODER_NOT_TESTED);
  }

  public static void setEncoderWorks(Context context, boolean works) {
    SharedPreferences sharedPreferences = getDefaultSharedPreferences(context);
    SharedPreferences.Editor editor = sharedPreferences.edit();
    editor.putInt(DOES_ENCODER_WORK, works ? ENCODER_WORKS : ENCODER_NOT_WORKS);
    editor.apply();
  }
}
