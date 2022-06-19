package cell411.utils;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import cell411.base.BaseApp;
import cell411.parse.util.OnCompletionListener;

public interface ExceptionHandler extends Thread.UncaughtExceptionHandler
{

  default void handleException(@NonNull String activity, @NonNull Throwable pe,
                               @Nullable OnCompletionListener listener) {
    app().handleException(activity, pe, listener);
  }

  default BaseApp app() {
    return BaseApp.get();
  }

  default void showAlertDialog(String message, OnCompletionListener listener) {
    app().showAlertDialog(message, listener);
  }

  default void showToast(String message) {
    app().showToast(message);
  }

  default OnCompletionListener getListener() {
    return new OnCompletionListener() {
      @Override
      public void done(boolean success) {
        XLog.i("TAG", "complete");
      }
    };
  }

  default void handleException(@NonNull String activity, @NonNull Throwable pe) {
    handleException(activity, pe, getListener());
  }

  @Override
  default void uncaughtException(@NonNull Thread t, @NonNull Throwable e) {

    handleException("Catching the Uncaught", e);
  }

  default void showToast(String format, Object... args) {
    showToast(Util.format(format, args));
  }

  default void showToast(int format, Object... args) {
    showToast(Util.format(format, args));
  }

  default void showAlertDialog(String format, Object... args) {
    showAlertDialog(Util.format(format, args), getListener());
  }

  default void showAlertDialog(int format, Object... args) {
    showAlertDialog(Util.format(format, args));
  }

}
