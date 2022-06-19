package cell411.base;

import static cell411.utils.Util.getString;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import cell411.parse.XUser;
import cell411.parse.util.OnCompletionListener;
import cell411.services.R;
import cell411.utils.PrintString;
import cell411.utils.Reflect;
import cell411.utils.Util;
import cell411.utils.WeakList;
import cell411.utils.XLog;

import com.parse.ParseException;

public class BaseDialogs {
  private static final String TAG = Reflect.getTag();
  static {
    XLog.i(TAG, "loading class");
  }

  static public void onUIThread(Runnable runnable) {
    BaseApp.get().onUI(runnable,0);
  }
  static public void onUIThread(Runnable runnable, long delay) {
    BaseApp.get().onUI(runnable, delay);
  }


  public static class DialogShower extends ExtraDismissListener
    implements Runnable, DialogInterface.OnClickListener
  {
    final String mMessage;
    BaseActivity                      mActivity;
    AlertDialog.Builder               mBuilder;
    AlertDialog                       mDialog;
    Boolean                           mPositive = null;
    Integer                           mWhich    = null;
    String                            mTitle;

    public DialogShower(String title, String message, DialogInterface.OnDismissListener listener,
                        OnCompletionListener listener2)
    {
      super(listener, listener2);
      mMessage = message;
      mTitle   = title;
    }

    public Integer getWhich() {
      return mWhich;
    }

    public Boolean getPositive() {
      return mPositive;
    }

    boolean success() {
      return mPositive == Boolean.TRUE;
    }

    @Override
    public void run() {
      if (!BaseApp.isUIThread()) {
        onUIThread(this);
        return;
      }
      if (mActivity == null) {
        if ((mActivity = BaseApp.get().getCurrentActivity()) == null) {
          onUIThread(this, 500);
          return;
        }
      }
      mBuilder = new AlertDialog.Builder(mActivity, android.R.style.Theme_Material_Dialog_Alert);
      mBuilder.setMessage(mMessage);
      if(mTitle!=null)
        mBuilder.setTitle(mTitle);
      mBuilder.setPositiveButton(R.string.dialog_btn_ok, this);
      mDialog = mBuilder.create();
      mDialog.setOnDismissListener(this);
      mDialog.show();
    }

    @Override
    public void onClick(DialogInterface dialog, int which) {
      assert (dialog == mDialog);
      if (which == DialogInterface.BUTTON_POSITIVE) {
        mPositive = true;
      } else if (which == DialogInterface.BUTTON_NEGATIVE) {
        mPositive = false;
      }
      mWhich = which;
    }

  }

  static WeakList<ExtraDismissListener> mDismissListeners = new WeakList<>();

  public static void showSessionExpiredAlertDialog(OnCompletionListener listener)
  {
    XLog.i(TAG, "showSessionExpiredAlertDialog() invoked");
    XLog.i(TAG, "currentUser: %s",String.valueOf(XUser.getCurrentUser()));
    BaseActivity currentActivity = BaseApp.get().getCurrentActivity();
    AlertDialog.Builder alert = new AlertDialog.Builder(currentActivity);
    alert.setCancelable(false);
    alert.setTitle("Session Expired");
    alert.setMessage("We are sorry, you have been logged out, please log in again.");
    alert.setPositiveButton(R.string.dialog_btn_ok, Util.nullClickListener());
    DialogInterface.OnDismissListener onDismissListener = dialog -> BaseApp.get().reset();
    alert.setOnDismissListener(new ExtraDismissListener(onDismissListener, listener));
    alert.create().show();
  }

  public static boolean isDialogShowing() {
    return !mDismissListeners.isEmpty();
  }

  public static class ExtraDismissListener implements DialogInterface.OnDismissListener {
    final DialogInterface.OnDismissListener mListener;
    final OnCompletionListener              mCompletionListener;

    public ExtraDismissListener(DialogInterface.OnDismissListener listener,
                                OnCompletionListener completionListener)
    {
      mListener           = listener;
      mCompletionListener = completionListener;
      mDismissListeners.add(this);
    }
    boolean success() {
      return true;
    }

    final public void onDismiss(DialogInterface dialog) {
      mDismissListeners.remove(this);
      if (mCompletionListener != null) {
        mCompletionListener.done(success());
      }
      if (mListener != null) {
        mListener.onDismiss(dialog);
      }
    }
    protected void finalize() {
      XLog.i(TAG, "Warning, you leaked an ExtraDismissListener, that'll bite you!");
      mDismissListeners.remove(this);
    }
  }
  public static YesNoDialog showYesNoDialog(String message, OnCompletionListener listener)
  {
    YesNoDialog yesNoDialog = new YesNoDialog(listener);
    yesNoDialog.setCancelable(false);
    yesNoDialog.setButton(DialogInterface.BUTTON_POSITIVE, "Yes", yesNoDialog::onButtonClick);
    yesNoDialog.setButton(DialogInterface.BUTTON_NEGATIVE, "No", yesNoDialog::onButtonClick);
    yesNoDialog.setTitle("Query");
    yesNoDialog.setMessage(message);
    yesNoDialog.show();
    return yesNoDialog;
  }
  public static void showExceptionDialog(Throwable e, String what, OnCompletionListener listener)
  {
    if (!BaseApp.isUIThread()) {
      onUIThread(() -> showExceptionDialog(e, what, listener));
      return;
    }
    Activity activity = BaseApp.get().getCurrentActivity();
    if (activity == null) {
      onUIThread(() -> showExceptionDialog(e, what, listener), 100);
      return;
    }
    e.printStackTrace();

    PrintString message = new PrintString();
    String      title   = "Error";
    message.p("We have encountered ");
    if (e instanceof ParseException) {
      title = "Database Error";
      message.p("a database");
    } else {
      message.p("an");
    }
    message.p(" error, while ");
    message.p(what);
    message.p(
      ".  This may be a transient problem.  " + "If it continues, please contact us." + "\n");
    Integer code = Util.castAndCall(e, ParseException.class, ParseException::getCode);
    if (code != null) {
      message.pl("ParseException code: " + code);
    }
    String m = e.getMessage();
    if (!Util.isNoE(m))
      message.p("Message: '").p(m).pl("'");
    message.pl("\n");
    e.printStackTrace(message);
    showAlertDialog(title,message.toString(),null,listener);
  }
  public static DialogShower showAlertDialog(String message) {
    return showAlertDialog(null, message, null, null);
  }
  public static DialogShower showAlertDialog(@NonNull String message,
                                             @Nullable DialogInterface.OnDismissListener listener)
  {
    return showAlertDialog(null, message, listener, null);
  }
  public static DialogShower showAlertDialog(String title, String message,
                                              DialogInterface.OnDismissListener listener,
                                              OnCompletionListener listener2)
  {
    DialogShower shower = new DialogShower(title, message, listener, listener2);
    onUIThread(shower);
    return shower;
  }
  public static DialogShower showAlertDialog(@NonNull String message,
                                             @Nullable OnCompletionListener listener)
  {
    return showAlertDialog(null,message,null,listener);
  }
  public static class YesNoDialog extends AlertDialog {
    Boolean              mAnswer = null;
    ExtraDismissListener mListener;

    protected YesNoDialog(OnCompletionListener listener)
    {
      super(BaseApp.get().getCurrentActivity(),
            android.R.style.Theme_Material_Dialog_Alert);
      mListener = new ExtraDismissListener(null, listener);
      setOnDismissListener(mListener);
    }

    public void onButtonClick(DialogInterface dialog, int which) {
      assert dialog == this;
      switch (which) {
        case DialogInterface.BUTTON_POSITIVE:
        case DialogInterface.BUTTON_NEGATIVE:
          mAnswer = which == BUTTON_POSITIVE;
          break;
        default:
          mAnswer = null;
          break;
      }
    }
  }

}
