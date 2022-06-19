package cell411;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.net.Uri;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatDelegate;
import androidx.core.app.ActivityCompat;

import com.parse.ParseCheater;

import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import cell411.base.BaseActivity;
import cell411.base.BaseApp;
import cell411.logic.LiveQueryService;
import cell411.parse.XEntity;
import cell411.utils.Collect;
import cell411.utils.NetUtils;
import cell411.utils.Reflect;
import cell411.utils.StorageOperations;
import cell411.utils.XLog;

public class Cell411 extends BaseApp {
  final public static String TAG = Reflect.getTag();
  public static final long TIME_TO_LIVE_FOR_CHAT_ON_ALERTS =
    86400 * 30 * 1000L; // 72 hours
  private static final List<String> mAllPerms = Arrays.asList(
    Manifest.permission.ACCESS_FINE_LOCATION, Manifest.permission.CAMERA,
    Manifest.permission.ACCESS_COARSE_LOCATION,
    Manifest.permission.RECORD_AUDIO,
    Manifest.permission.ACCESS_NETWORK_STATE, Manifest.permission.MODIFY_AUDIO_SETTINGS
  );
  private static Cell411 smCell411;

  static {
    XLog.i(TAG, "loading class");
  }

  private final Set<String> mMissingPerms = Collect.addAll(new HashSet<>(), mAllPerms);
  HashSet<String> mMissing = new HashSet<>();
  HashMap<String, Uri> mTones = new HashMap<>();
  private boolean mIsDarkModeChanged = false;
  private MainActivity mMainActivity;
  private NotificationCenter mNotificationCenter;

  public Cell411() {
    super();
    smCell411 = this;
  }

  @NonNull
  public static Cell411 get() {
    if (smCell411 == null)
      throw new IllegalStateException("smCell411 has been cleared!");
    return smCell411;
  }

  public static String getResString(int resId, Object... args) {
    return get().getString(resId, args);
  }

  public static String getResString(int res) {
    return get().getString(res);
  }


  public static void now(Runnable todo) {
    todo.run();
  }


  public static boolean hasPerm(BaseActivity activity, String accessFineLocation) {
    int res = ActivityCompat.checkSelfPermission(activity, accessFineLocation);
    return res == PackageManager.PERMISSION_GRANTED;
  }

  @Override
  protected void attachBaseContext(Context base) {
    super.attachBaseContext(base);
  }

  public LiveQueryService lqs() {
    return smCell411.getLiveQueryService();
  }

  public void pushCurrentActivity(BaseActivity activity) {
    if (activity instanceof MainActivity)
      mMainActivity = (MainActivity) activity;
    super.pushCurrentActivity(activity);
  }

  public void popCurrentActivity(Activity oldActivity) {
    super.popCurrentActivity(oldActivity);
  }

  MainActivity getMainActivity() {
    return mMainActivity;
  }

  @Override
  public void onCreate() {
    super.onCreate();
    Thread.setDefaultUncaughtExceptionHandler(this);

    SharedPreferences appPrefs = getAppPrefs();
    boolean isDarkModeEnabled = appPrefs.getBoolean("DarkMode", false);
    if (isDarkModeEnabled) {
      AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_YES);
    } else {
      AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_NO);
    }
    registerReceiver(getScreenOffReceiver(),
      new IntentFilter(Intent.ACTION_SCREEN_OFF));
    registerReceiver(getScreenOffReceiver(),
      new IntentFilter(Intent.ACTION_SCREEN_ON));

  }

  public boolean isDarkModeChanged() {
    return mIsDarkModeChanged;
  }

  public void setDarkModeChanged(boolean darkModeChanged) {
    mIsDarkModeChanged = darkModeChanged;
  }

  public SharedPreferences getAppPrefs() {
    return getSharedPreferences("AppPrefs", Context.MODE_PRIVATE);
  }

  public void tryRun(Runnable runnable, boolean ignoreException) {
    try {
      runnable.run();
    } catch (Throwable t) {
      if (!ignoreException)
        handleException("Running " + runnable, t);
    }
  }

  public void clearPrefs() {
    getAppPrefs().
      edit().
      clear().
      apply();
  }

  public void clearData() {
    tryRun(() -> ParseCheater.removeCredentials(), true);
    tryRun(() -> clearPrefs(), false);
    tryRun(() -> ds().clear(), true);
    tryRun(() -> StorageOperations.clearData(), true);
  }

  public void logOut() {
    clearData();
    super.logOut();
  }

  public int getColorRes(int resId) {
    return getResources().getColor(resId, getTheme());
  }

  public void openChat(XEntity entity) {
    onUI(new ChatOpener(entity));
  }

  public NotificationCenter getNotificationCenter() {
    if (mNotificationCenter == null)
      mNotificationCenter = new NotificationCenter();
    return mNotificationCenter;
  }

  public void deleteUser() {
    xpr().deleteUser();
  }

  public void reset() {
  }

  @Override
  public Set<String> getMissingPermissions(BaseActivity activity) {
    mMissingPerms.removeIf(perm -> hasPerm(activity, perm));
    return mMissingPerms;
  }

  public HashMap<String, Uri> getTones() {
    if (mTones != null)
      return mTones;
    SharedPreferences prefs;
    prefs = getSharedPreferences("Tones", Context.MODE_PRIVATE);
    for (String key : Arrays.asList("uri0", "uri1", "uri2")) {
      String rawUri = prefs.getString(key, "");
      mTones.put(key, NetUtils.toUri(rawUri));
      if (rawUri.length() == 0)
        mMissing.add(rawUri);
    }
    return mTones;
  }

  @Override
  public Set<String> getMissingRingtones(BaseActivity activity) {
    getTones();
    return mMissing;
  }

  @Override
  public void updatePermissions() {
    xpr().updatePermissions();
  }

  public void updateRingtones() {
    getNotificationCenter().restore();
    xpr().updateRingtones();
  }


  private class ChatOpener implements Runnable {
    XEntity mEntity;

    public ChatOpener(final XEntity entity) {
      mEntity = entity;
    }

    @Override
    public void run() {
      MainActivity mainActivity = getMainActivity();
      if (mainActivity == null) {
        onUI(() -> {
          openChat(mEntity);
        });
        return;
      }
      mainActivity.openChat(mEntity);
    }
  }
}
