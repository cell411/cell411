package cell411.base;

import android.content.Intent;
import android.os.Bundle;
import android.view.inputmethod.InputMethodManager;

import androidx.annotation.CallSuper;
import androidx.annotation.Nullable;
import androidx.appcompat.app.ActionBar;
import androidx.appcompat.app.AppCompatActivity;

public abstract class BaseActivity extends AppCompatActivity
  implements BaseContext {
  public static String TAG = BaseActivity.class.getSimpleName();

  public BaseActivity() {
    super();
  }

  public BaseActivity(int activity_gallery) {
    super(activity_gallery);
  }


  @SuppressWarnings("deprecation")
  @Override
  public void startActivityForResult(Intent intent, int requestCode,
                                     @Nullable Bundle options) {
    if (BaseDialogs.isDialogShowing()) {
      onUI(() ->
        startActivityForResult(intent, requestCode, options), 500);
    } else {
      super.startActivityForResult(intent, requestCode, options);
    }
  }

  @CallSuper
  @Override
  protected void onActivityResult(int requestCode, int resultCode,
                                  @Nullable Intent data) {
    super.onActivityResult(requestCode, resultCode, data);
  }

  public void refresh() {
    BaseApp.get().refresh();
  }

  @Override
  public void startActivity(Intent intent, @Nullable Bundle options) {
    if (BaseDialogs.isDialogShowing())
      onUI(() -> startActivity(intent, options), 500);
    else
      super.startActivity(intent, options);
  }

  public void finish() {
    if (BaseDialogs.isDialogShowing())
      onUI(this::finish, 500);
    else
      super.finish();
  }


  @Override
  public BaseActivity activity() {
    return this;
  }

  @Override
  protected void onPause() {
    super.onPause();
  }

  protected void onResume() {
    super.onResume();
    hideSoftKeyboard();
  }

  public void setDisplayUpAsHome() {
    final ActionBar actionBar = getSupportActionBar();
    if (actionBar != null) {
      actionBar.setDisplayHomeAsUpEnabled(true);
      actionBar.setDisplayShowHomeEnabled(true);
    }
  }

  public void hideSoftKeyboard() {
    if (getCurrentFocus() != null) {
      InputMethodManager inputMethodManager =
        (InputMethodManager) getSystemService(INPUT_METHOD_SERVICE);
      inputMethodManager.hideSoftInputFromWindow(getCurrentFocus().getWindowToken(), 0);
    }
  }

  public void showSoftKeyboard() {
    if (getCurrentFocus() != null) {
      InputMethodManager inputMethodManager =
        (InputMethodManager) getSystemService(INPUT_METHOD_SERVICE);
      inputMethodManager.showSoftInput(getCurrentFocus(), 0);
    }
  }

  public void fragmentComplete(BaseFragment fragmentIgnored) {

  }

  public void prepareToLoad() {

  }

  public void loadData() {

  }

  public void populateUI() {

  }

}