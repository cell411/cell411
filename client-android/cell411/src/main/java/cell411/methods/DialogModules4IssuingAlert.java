package cell411.methods;

import android.app.AlertDialog;
import android.content.SharedPreferences;

import com.parse.ParseCloud;
import com.parse.ParseException;

import java.util.HashMap;

import cell411.Cell411;

public class DialogModules4IssuingAlert {
  public static final String      TAG  = "DialogModules4IssuingAlert";
  final static        String[]    keys = new String[]{"PanicAlertToAllFriends", "PanicAlertToNearBy",
    "PanicAlertToPrivateCells", "PanicAlertToPublicCells"};
  final static        boolean[]   defs = new boolean[]{true, true, false, false};
  private static      AlertDialog dialog;

  public static void sendPanicAlert(final String ignore) {
    SharedPreferences prefs = Cell411.get()
                                     .getAppPrefs();
    HashMap<String, Object> params = new HashMap<>();
    for (int i = 0; i < keys.length; i++) {
      params.put(keys[i], prefs.getBoolean(keys[i], defs[i]));
    }
    try {
      ParseCloud.run("sendPanicAlert", params);
    } catch (ParseException pe) {
      Cell411.get().handleException("sending panic alert", pe, null);
    }
  }
}

