package cell411.methods;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;

import com.safearx.cell411.R;

import cell411.base.BaseContext;
import cell411.parse.XUser;
import cell411.parse.util.OnCompletionListener;
import cell411.services.DataService;
import cell411.utils.Util;
import cell411.utils.XLog;

/**
 * Created by Sachin on 01-06-2016.
 */
public class AddFriendModules implements BaseContext {
  private static final String TAG = "AddFriendModules";

  public static void showDeleteFriendDialog(Context context, XUser friend,
                                            OnCompletionListener listener) {
    AlertDialog.Builder alert = new AlertDialog.Builder(context);
    alert.setMessage(app.getString(R.string.dialog_msg_unfriend, friend.getName()));
    alert.setNegativeButton(R.string.dialog_btn_cancel, (dialogInterface, i) -> {
      if (listener != null) {
        listener.done(false);
      }
    });
    alert.setPositiveButton(R.string.dialog_btn_ok, (dialogInterface, i) -> {
      DataService.removeFriend(friend);
      if (listener != null) {
        listener.done(true);
      }
    });
    AlertDialog dialog = alert.create();
    dialog.show();
  }

  public static void showFlagAlertDialog(Activity context, final XUser user) {
    showFlagAlertDialog(context,user,null);
  }

  public static void showFlagAlertDialog(Activity context, final XUser user,
                                         OnCompletionListener listener) {
    AlertDialog.Builder alert = new AlertDialog.Builder(context);
    alert.setMessage(context.getString(R.string.dialog_msg_flag_user, user.getName()));

    alert.setPositiveButton(R.string.dialog_btn_yes, (dialogInterface, i) -> {
      XLog.i(TAG, "flagging user " + user.getName());
      app.ds().flagUser(user, true, listener);
    });
    alert.setNegativeButton(R.string.dialog_btn_no, (dialog, which) -> {
    });
    AlertDialog dialog = alert.create();
    dialog.show();
  }
}