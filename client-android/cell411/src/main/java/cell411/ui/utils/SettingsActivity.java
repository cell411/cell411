package cell411.ui.utils;

import android.Manifest;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.content.res.ColorStateList;
import android.graphics.Color;
import android.os.Bundle;
import android.view.MenuItem;
import android.widget.SeekBar;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatDelegate;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import cell411.base.BaseActivity;

import com.google.android.material.floatingactionbutton.FloatingActionButton;
import com.parse.ParseCloud;
import com.parse.ParseQuery;
import com.parse.callback.FunctionCallback;
import com.parse.model.ParseObject;
import com.safearx.cell411.R;

import java.util.Date;
import java.util.HashMap;

import cell411.Cell411;
import cell411.methods.Dialogs;
import cell411.parse.XUser;

import cell411.ui.self.SpammedUsersActivity;
import cell411.utils.LocationUtil;
import cell411.utils.XLog;

/**
 * Created by Sachin on 19-04-2016.
 */
public class SettingsActivity extends BaseActivity {
  private static final String               TAG               = SettingsActivity.class.getSimpleName();
  private static final int                  PERMISSION_CAMERA = 1;
  private              boolean              mIsLocationAccuracyEnabled;
  private              boolean              mIsLocationUpdateEnabled;
  private              boolean              mIsDarkModeEnabled;
  private              boolean              mIsDeleteVideoEnabled;
  private              boolean              mPatrolMode;
  private              int                  mPatrolModeRadius;
  private              boolean              mUseMetric;
  private              FloatingActionButton mFabNewPublicCellAlert;
  private              FloatingActionButton mFabPatrolMode;
  private              FloatingActionButton mFabDarkMode;
  private              TextView             mTxtDownloadData;
  private              int                  mEnabledColor;
  private              int                  mDisabledColor;
  private              SharedPreferences    mPrefs;
  private              FloatingActionButton mFabDeleteVideoOption;
  private              TextView             mTxtLblMiles;
  private              TextView             mTxtLblKilometers;
  private              TextView             mTxtLblPatrolRange;
  private              TextView             mTxtPatrolRadius;
  private              FloatingActionButton mFabGPSAccurateTracking;
  private              FloatingActionButton mFabLocationUpdates;

  public static void start(Activity activity) {
    Intent intentProfileView = new Intent(activity, SettingsActivity.class);
    activity.startActivity(intentProfileView);
  }

  @Override public boolean onOptionsItemSelected(MenuItem item) {
    if (item.getItemId() == android.R.id.home) {
      finish();
      return true;
    }
    return super.onOptionsItemSelected(item);
  }

  @Override protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_settings);
    // Set up the action bar.
    setDisplayUpAsHome();
    mEnabledColor = getColor(R.color.colorAccent);
    mDisabledColor = getColor(R.color.gray_ccc);
    mFabDarkMode = findViewById(R.id.fab_dark_mode);
    mFabNewPublicCellAlert = findViewById(R.id.fab_new_public_cell_alert);
    mTxtLblMiles = findViewById(R.id.txt_lbl_miles);
    mTxtLblKilometers = findViewById(R.id.txt_lbl_kilometers);
    mTxtLblPatrolRange = findViewById(R.id.txt_lbl_patrol_range);
    mTxtPatrolRadius = findViewById(R.id.txt_patrol_radius);
    mFabGPSAccurateTracking = findViewById(R.id.fab_gps_accurate_tracking);
    mFabLocationUpdates = findViewById(R.id.fab_location_updates);
    mPrefs = Cell411.get()
                    .getAppPrefs();
    mUseMetric = mPrefs.getBoolean("useMetric", false);
    mIsDarkModeEnabled = mPrefs.getBoolean("DarkMode", false);
    mIsLocationAccuracyEnabled = mPrefs.getBoolean("LocationAccuracy", true);
    mIsLocationUpdateEnabled = mPrefs.getBoolean("LocationUpdate", true);
    setDarkModeEnabled(mIsDarkModeEnabled);
    mFabDarkMode.setOnClickListener(v -> {
      Cell411.get()
             .setDarkModeChanged(true);
      setDarkModeEnabled(!mIsDarkModeEnabled);
      if (mIsDarkModeEnabled) {
        Cell411.get().showToast("Dark Mode" + "disabled");
      } else {
        Cell411.get().showToast("Dark Mode" + "enabled");
      }
    });
    setNewPublicCellAlert(getNewPublicCellAlert());
    mFabNewPublicCellAlert.setOnClickListener(view -> {
      setNewPublicCellAlert(!getNewPublicCellAlert());
      String format = "New Public Cell Alerts " + (getNewPublicCellAlert() ? "en" : "dis") + "abled";
      Cell411.get().showToast(format);
    });
    setUseMetric(mUseMetric);
    mTxtLblMiles.setOnClickListener(v -> {
      setUseMetric(false);
      Cell411.get().showToast("Metric distances disabled");
    });
    mTxtLblKilometers.setOnClickListener(v -> {
      setUseMetric(true);
      Cell411.get().showToast("Metric distances enabled");
    });
    setLocationAccuracyEnabled(mIsLocationAccuracyEnabled);
    mFabGPSAccurateTracking.setOnClickListener(view -> {
      setLocationAccuracyEnabled(!mIsLocationAccuracyEnabled);
      String format =
        getString(R.string.gps_accurate_tracking) + (mIsLocationAccuracyEnabled ? " en" : " dis") + "abled";
      Cell411.get().showToast(format);
    });
    setLocationUpdateEnabled(mIsLocationUpdateEnabled, false);
    mFabLocationUpdates.setOnClickListener(view -> {
      setLocationUpdateEnabled(!mIsLocationUpdateEnabled, false);
      String format = getString(R.string.location_updates) + (mIsLocationUpdateEnabled ? " en" : " dis") + "abled";
      Cell411.get().showToast(format);
    });
    setNewPublicCellAlert(getNewPublicCellAlert());
    mFabLocationUpdates.setImageResource(R.drawable.img_location_enabled);
    TextView txtSpammedUsers = findViewById(R.id.txt_btn_spammed_users);
    txtSpammedUsers.setOnClickListener(v -> {
      SpammedUsersActivity.start(this);
      XLog.i(TAG, "starting spammed user activity");
    });
    mTxtDownloadData = findViewById(R.id.txt_btn_download_data);
    mTxtDownloadData.setOnClickListener(v -> downloadUserData());
    if (System.currentTimeMillis() < mPrefs.getLong("DisableDownloadUntil", 0)) {
      // If current time is less than the time until which the button should be disabled,
      // then gray out the button and disabled it
      mTxtDownloadData.setBackgroundColor(Color.GRAY);
      mTxtDownloadData.setEnabled(false);
    }
    TextView txtDeleteAccount = findViewById(R.id.txt_btn_delete_account);
    txtDeleteAccount.setOnClickListener(v -> Dialogs.showConfirmDeletionAlertDialog(this));
    applyPatrolModeSettingsIfEnabled();
    applyLiveStreamingSettingsIfEnabled();
  }

  private void setDarkModeEnabled(boolean enabled) {
    mFabDarkMode.setImageResource(R.drawable.fab_dark_mode);
    mFabDarkMode.setBackgroundTintList(ColorStateList.valueOf(enabled ? mEnabledColor : mDisabledColor));
    if (mIsDarkModeEnabled != enabled) {
      mIsDarkModeEnabled = enabled;
      AppCompatDelegate.setDefaultNightMode(
        enabled ? AppCompatDelegate.MODE_NIGHT_YES : AppCompatDelegate.MODE_NIGHT_NO);
      recreate();
    }
  }

  private void setLocationAccuracyEnabled(boolean isLocationAccuracyEnabled) {
    mIsLocationAccuracyEnabled = isLocationAccuracyEnabled;
    if (mIsLocationAccuracyEnabled) {
      mIsLocationAccuracyEnabled = false;
      mFabGPSAccurateTracking.setBackgroundTintList(ColorStateList.valueOf(mDisabledColor));
      mFabGPSAccurateTracking.setImageResource(R.drawable.fab_gps_disabled);
    } else {
      mIsLocationAccuracyEnabled = true;
      mFabGPSAccurateTracking.setBackgroundTintList(ColorStateList.valueOf(mEnabledColor));
      mFabGPSAccurateTracking.setImageResource(R.drawable.fab_gps_enabled);
    }
  }

  private void setUseMetric(boolean useMetric) {
    mUseMetric = useMetric;
    if (mUseMetric) {
      mTxtLblMiles.setBackgroundResource(R.drawable.bg_metric_un_selected);
      mTxtLblMiles.setTextColor(getColor(R.color.gray_333));
      mTxtLblKilometers.setBackgroundResource(R.drawable.bg_metric_selected);
      mTxtLblKilometers.setTextColor(getColor(R.color.white));
      mTxtLblPatrolRange.setText(R.string.km_1_80);
    } else {
      mTxtLblMiles.setBackgroundResource(R.drawable.bg_metric_selected);
      mTxtLblMiles.setTextColor(getColor(R.color.white));
      mTxtLblKilometers.setBackgroundResource(R.drawable.bg_metric_un_selected);
      mTxtLblKilometers.setTextColor(getColor(R.color.gray_333));
      mTxtLblPatrolRange.setText(R.string.miles_1_50);
    }
  }

  @Override public void onPause() {
    super.onPause();
    SharedPreferences.Editor editor = mPrefs.edit();
    editor.putBoolean("LocationAccuracy", mIsLocationAccuracyEnabled);
    editor.putString("metric", mUseMetric ? "kms" : "miles");
    editor.putBoolean("LocationUpdate", mIsLocationUpdateEnabled);
    editor.putBoolean("DarkMode", mIsDarkModeEnabled);
    boolean isLiveStreamingEnabled = getResources().getBoolean(R.bool.is_live_streaming_enabled);
    if (isLiveStreamingEnabled) {
      editor.putBoolean("DeleteVideo", mIsDeleteVideoEnabled);
    }
    editor.putInt("patrolModeRadius", mPatrolModeRadius);
    editor.apply();
  }

  @Override protected void onResume() {
    super.onResume();
  }

  private void downloadUserData() {
    mTxtDownloadData.setBackgroundColor(Color.GRAY);
    Date dateBefore7Days = new Date();
    dateBefore7Days.setTime(System.currentTimeMillis() - (1000 * 60 * 60 * 24));
    ParseQuery<ParseObject> queryAppUserLog = ParseQuery.getQuery("AppUserLog");
    queryAppUserLog.whereEqualTo("user", XUser.getCurrentUser());
    queryAppUserLog.whereEqualTo("action", 1);
    queryAppUserLog.whereGreaterThanOrEqualTo("createdAt", dateBefore7Days); // 7 days
    queryAppUserLog.orderByDescending("createdAt");
    queryAppUserLog.getFirstInBackground((object, e) -> {
      if (e == null) {
        XLog.i(TAG, "success");
        Date downloadDate = object.getCreatedAt();
        int difference = new Date().compareTo(downloadDate);
        XLog.i(TAG, "difference: " + difference);
        String msg = getString(R.string.msg_download_data_error, (7 - difference));
        showDownloadDataSuccessAlertDialog(msg);
        mTxtDownloadData.setBackgroundColor(Color.GRAY);
      } else {
        XLog.i(TAG, "error: " + e.getCode() + " - " + e.getLocalizedMessage());
        if (e.getCode() == 101) { // Response success but query found no results to return
          showDownloadDataSuccessAlertDialog(getString(R.string.msg_download_data_success));
          mTxtDownloadData.setText(R.string.btn_download_data_processing);
          HashMap<String, Object> params = new HashMap<>();
          ParseCloud.callFunctionInBackground("downloadUserData", params, (FunctionCallback<String>) (response, e1) -> {
            mTxtDownloadData.setText(R.string.btn_download_data);
            if (e1 == null) {
              long disableForMillis = 86400000; // 1000 * 60 * 60 * 24 (1 day)
              long disableTime = System.currentTimeMillis();
              long disableUntil = disableTime + disableForMillis;
              Cell411.get()
                     .getAppPrefs()
                     .edit()
                     .putLong("DisableDownloadUntil", disableUntil)
                     .apply();
            } else {
              mTxtDownloadData.setBackgroundResource(R.drawable.ripple_btn_primary);
              handleException("FIXME:  doing what?", e1, null);
            }
          });
        }
      }
    });
  }

  private void showDownloadDataSuccessAlertDialog(String msg) {
    AlertDialog.Builder alert = new AlertDialog.Builder(this);
    alert.setMessage(msg);
    alert.setPositiveButton(R.string.dialog_btn_ok, (dialogInterface, i) -> {
    });
    AlertDialog dialog = alert.create();
    dialog.show();
  }

  private void applyPatrolModeSettingsIfEnabled() {
    mFabPatrolMode = findViewById(R.id.fab_patrol_mode);
    mPatrolMode = XUser.getCurrentUser()
                          .getPatrolMode();
    mPatrolModeRadius = mPrefs.getInt("patrolModeRadius", 50);
    final SeekBar seekBarPatrolModeRadius = findViewById(R.id.sb_patrol_radius);
    mFabPatrolMode.setOnClickListener(view -> {
      setPatrolModeEnabled(!mPatrolMode);
      XLog.i(TAG, "setting patrol mode to : " + mPatrolMode);
    });
    seekBarPatrolModeRadius.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
      @Override public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
        mTxtPatrolRadius.setText(LocationUtil.formatDistance(progress, mUseMetric));
        mPatrolModeRadius = progress;
      }

      @Override public void onStartTrackingTouch(SeekBar seekBar) {
      }

      @Override public void onStopTrackingTouch(SeekBar seekBar) {
      }
    });
    seekBarPatrolModeRadius.setProgress(mPatrolModeRadius);
    if (this.mPatrolMode) {
      mFabPatrolMode.setBackgroundTintList(ColorStateList.valueOf(mEnabledColor));
    } else {
      mFabPatrolMode.setBackgroundTintList(ColorStateList.valueOf(mDisabledColor));
    }
    mFabPatrolMode.setImageResource(R.drawable.img_patrol_mode);
  }

  private void setPatrolModeEnabled(boolean value) {
    mPatrolMode = value;
    if (mPatrolMode) {
      setLocationUpdateEnabled(true, false);
    }
    mFabPatrolMode.setImageResource(R.drawable.img_patrol_mode);
    int currentColor = mPatrolMode ? mEnabledColor : mDisabledColor;
    mFabPatrolMode.setBackgroundTintList(ColorStateList.valueOf(currentColor));
    String currentState = mPatrolMode ? "enabled" : "disabled";
    Cell411.get().showToast(getString(R.string.patrol_mode) + currentState);
    mFabPatrolMode.setImageResource(R.drawable.img_patrol_mode);
    XUser.getCurrentUser()
            .put("patrolMode", mPatrolMode ? 1 : 0);
    XUser.getCurrentUser()
            .saveInBackground();
  }

  private void applyLiveStreamingSettingsIfEnabled() {
    mIsDeleteVideoEnabled = mPrefs.getBoolean("DeleteVideo", false);
    mFabDeleteVideoOption = findViewById(R.id.fab_delete_video_option);
    mFabDeleteVideoOption.setOnClickListener(view -> {
      if (mIsDeleteVideoEnabled) {
        mIsDeleteVideoEnabled = false;
        mFabDeleteVideoOption.setBackgroundTintList(ColorStateList.valueOf(mDisabledColor));
        mFabDeleteVideoOption.setImageResource(R.drawable.fab_delete_video_disabled);
        Cell411.get().showToast(getString(R.string.delete_video) + "disabled");
      } else {
        if (ContextCompat.checkSelfPermission(SettingsActivity.this, Manifest.permission.CAMERA) !=
          PackageManager.PERMISSION_GRANTED) {
          requestCameraPermission();
        } else {
          mIsDeleteVideoEnabled = true;
          mFabDeleteVideoOption.setBackgroundTintList(ColorStateList.valueOf(mEnabledColor));
          mFabDeleteVideoOption.setImageResource(R.drawable.fab_delete_video_enabled);
          showDeleteVideoAlertDialog();
        }
      }
    });
    if (mIsDeleteVideoEnabled && ContextCompat.checkSelfPermission(SettingsActivity.this, Manifest.permission.CAMERA) ==
      PackageManager.PERMISSION_GRANTED) {
      mFabDeleteVideoOption.setBackgroundTintList(ColorStateList.valueOf(mEnabledColor));
      mFabDeleteVideoOption.setImageResource(R.drawable.fab_delete_video_enabled);
    } else {
      mIsDeleteVideoEnabled = false;
      mFabDeleteVideoOption.setBackgroundTintList(ColorStateList.valueOf(mDisabledColor));
      mFabDeleteVideoOption.setImageResource(R.drawable.fab_delete_video_disabled);
    }
    TextView txtVideoSettings = findViewById(R.id.txt_btn_video_settings);
    txtVideoSettings.setOnClickListener(v -> {
//        Intent intent = new Intent(SettingsActivity.this, VideoSettingsActivity.class);
//        startActivity(intent);
    });
  }

  private void requestCameraPermission() {
    ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.CAMERA}, PERMISSION_CAMERA);
  }

  @Override protected void onActivityResult(int requestCode, int resultCode, Intent data) {
    super.onActivityResult(requestCode, resultCode, data);
  }

  @Override
  public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
    if (requestCode == PERMISSION_CAMERA) {
      if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
        mIsDeleteVideoEnabled = true;
        mFabDeleteVideoOption.setBackgroundTintList(ColorStateList.valueOf(mEnabledColor));
        mFabDeleteVideoOption.setImageResource(R.drawable.fab_delete_video_enabled);
        showDeleteVideoAlertDialog();
      }
    } else {
      super.onRequestPermissionsResult(requestCode, permissions, grantResults);
    }
  }

  private void showPatrolModeAlertDialog() {
    AlertDialog.Builder alert = new AlertDialog.Builder(this);
    String feature;
    String message;
    if (mPatrolMode && getNewPublicCellAlert()) {
      message = getString(R.string.dialog_message_disable_two_features, getString(R.string.patrol_mode),
                          getString(R.string.new_public_cell_alert));
      feature = getString(R.string.two_features_disabled, getString(R.string.patrol_mode),
                          getString(R.string.new_public_cell_alert));
    } else if (mPatrolMode) {
      message = getString(R.string.dialog_message_disable_one_feature, getString(R.string.patrol_mode));
      feature = getString(R.string.patrol_mode);
    } else if (getNewPublicCellAlert()) {
      message = getString(R.string.dialog_message_disable_one_feature, getString(R.string.new_public_cell_alert));
      feature = getString(R.string.new_public_cell_alert);
    } else {
      return;
    }
    alert.setMessage(message);
    alert.setNegativeButton(R.string.dialog_btn_cancel, (dialog, arg1) -> {
      XLog.i(TAG, "cancel location update disable");
      setLocationUpdateEnabled(true, false);
    });
    alert.setPositiveButton(R.string.dialog_btn_yes, (dialog, which) -> {
      setLocationUpdateEnabled(false, false);
      Cell411.get().showToast(feature + "disabled");
    });
    AlertDialog dialog = alert.create();
    dialog.show();
  }

  private void setLocationUpdateEnabled(boolean enabled, boolean changed) {
    if (enabled) {
      mFabLocationUpdates.setBackgroundTintList(ColorStateList.valueOf(mEnabledColor));
      mFabLocationUpdates.setImageResource(R.drawable.img_location_enabled);
    } else {
      mFabLocationUpdates.setBackgroundTintList(ColorStateList.valueOf(mDisabledColor));
      mFabLocationUpdates.setImageResource(R.drawable.img_location_enabled);
    }
    if (!changed) {
      return;
    }
    showPatrolModeAlertDialog();
    if (!enabled) {
      setPatrolModeEnabled(false);
      setNewPublicCellAlert(false);
      if (mPatrolMode) {
        setPatrolModeEnabled(false);
      }
      if (getNewPublicCellAlert()) {
        setNewPublicCellAlert(false);
      }
    }
  }

  private void showDeleteVideoAlertDialog() {
    AlertDialog.Builder alert = new AlertDialog.Builder(this);
    alert.setMessage(R.string.dialog_message_video_delete_alert);
    alert.setOnCancelListener(
      dialogInterface -> Cell411.get().showToast(getString(R.string.delete_video) + "enabled"));
    alert.setPositiveButton(R.string.dialog_btn_ok, (dialog, which) -> Cell411.get().showToast(
      getString(R.string.delete_video) + "enabled"));
    AlertDialog dialog = alert.create();
    dialog.show();
  }

  // Instead of storing state, we use the actual data in the user object.
  public boolean getNewPublicCellAlert() {
    return XUser.getCurrentUser()
                   .getNewPublicCellAlert();
  }

  // When we update the user object, though, we have some side effects.
  public void setNewPublicCellAlert(boolean enable) {
    final XUser currentUser = XUser.getCurrentUser();
    currentUser.setNewPublicCellAlert(enable);
    currentUser.saveInBackground();
    final int color = enable ? mEnabledColor : mDisabledColor;
    final int drawable = enable ? R.drawable.fab_new_public_cell_enabled : R.drawable.fab_new_public_cell_disabled;
    mFabNewPublicCellAlert.setBackgroundTintList(ColorStateList.valueOf(color));
    mFabNewPublicCellAlert.setImageResource(drawable);
    if (enable) {
      setLocationUpdateEnabled(true, false);
    }
  }
}

