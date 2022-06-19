package cell411.base;

import android.app.Activity;
import android.app.Application;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.widget.Toast;

import androidx.annotation.CallSuper;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.parse.ParseCheater;
import com.parse.ParseException;
import com.parse.android.ConnectivityNotifier;

import java.io.File;
import java.lang.ref.WeakReference;
import java.net.SocketException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;
import java.util.Stack;

import cell411.logic.LiveQueryService;
import cell411.parse.util.OnCompletionListener;
import cell411.parse.util.XParse;
import cell411.services.DataService;
import cell411.services.LocationService;
import cell411.services.R;
import cell411.utils.CarefulHandler;
import cell411.utils.HandlerThreadPlus;
import cell411.utils.HttpLogInterceptor;
import cell411.utils.ObservableValue;
import cell411.utils.Reflect;
import cell411.utils.ThreadUtil;
import cell411.utils.Timer;
import cell411.utils.Util;
import cell411.utils.ValueObserver;
import cell411.utils.XLog;
import okhttp3.OkHttpClient;

public abstract class BaseApp extends Application
  implements BaseContext
{
  public final static CarefulHandler smHandler = new CarefulHandler(Looper.getMainLooper());
  private static final String TAG = Reflect.getTag();
  private final static Handler[] mRefreshHandlers = new Handler[3];
  static WeakReference<BaseApp> smInstance;
  static boolean smStarted = false;

  static {
    XLog.i(TAG, "loading class");
  }

  final Timer mTimer = new Timer();
  private final OkHttpClient.Builder mClientBuilder =
    new OkHttpClient.Builder().addInterceptor(new HttpLogInterceptor());
  private final Stack<BaseActivity> mActivityStack = new Stack<>();
  private final ScreenOffReceiver mScreenOffReceiver = new ScreenOffReceiver();
  protected HandlerThreadPlus smRefreshThread =
    HandlerThreadPlus.createThread("Refresh Thread");
  protected CarefulHandler smRefreshHandler =
    smRefreshThread.getHandler();
  protected BaseService.Conn<LocationService> mLocationServiceConn;
  protected BaseService.Conn<DataService> mDataServiceConn;
  ObservableValue<Boolean> smConnected = new ObservableValue<>(false);
  Map<String, Boolean> mStarted = new HashMap<>();
  private XParse mXParse;
  private BaseService.Conn<LiveQueryService> mLiveQueryServiceConn;

  private RefreshRunner smRunningRefresh;

  public BaseApp() {
    assert (smInstance == null);
    smInstance = new WeakReference<>(this);
  }

  public static boolean isUIThread() {
    return Util.isCurrentThread(Looper.getMainLooper());
  }

  public static BaseApp get() {
    return smInstance.get();
  }

  public static boolean isBadSessionException(Throwable e) {
    if (e instanceof ParseException) {
      ParseException pe = (ParseException) e;
      switch (pe.getCode()) {
        case ParseException.SESSION_MISSING:
        case ParseException.INVALID_LINKED_SESSION:
        case ParseException.INVALID_SESSION_TOKEN:
          return true;
      }
    }
    return false;
  }

  @Override
  protected void attachBaseContext(Context base) {
    super.attachBaseContext(base);
  }

  public CarefulHandler getHandler() {
    return smHandler;
  }

  public CarefulHandler getRefreshHandler() {
    return get().smRefreshHandler;
  }

  public File getFlavoredCacheDir() {
    File cacheDir = getCacheDir();
    cacheDir = new File(cacheDir, getString(R.string.parse_api_flavor));
    if (!cacheDir.exists() && !cacheDir.mkdirs())
      throw new RuntimeException("Feiled to create flavored cache dir");
    if (!cacheDir.isDirectory())
      throw new RuntimeException("Flavored cache dir is not a dir");
    return cacheDir;
  }

  public OkHttpClient.Builder getClientBuilder() {
    return new OkHttpClient.Builder(mClientBuilder);
  }

  public void signUp(final String email, final String password, final String firstName,
                     final String lastName,
                     final String mobileNumber, final OnCompletionListener listener) {
    xpr().signUp(email, password, firstName, lastName,
      mobileNumber, listener);
  }

  public void onUI(Runnable runnable) {
    smHandler.postDelayed(runnable, 0);
  }

  public void onUI(Runnable runnable, int delay) {
    smHandler.postDelayed(runnable, delay);
  }

  public File getJsonCacheFile(String baseName) {
    BaseApp app = BaseApp.get();
    File cacheDir = app.getFlavoredCacheDir();
    cacheDir = new File(cacheDir, "parseCache");
    cacheDir = new File(cacheDir, getString(R.string.parse_api_flavor));
    if(!cacheDir.isDirectory() && !cacheDir.mkdirs())
      XLog.i(TAG, "failed to make cacheDir: "+cacheDir);
    return new File(cacheDir, baseName + ".json");
  }

  private void setupConnectivityWatcher() {
    ConnectivityNotifier notifier = ConnectivityNotifier.getNotifier(this);
    notifier.addListener(this::networkConnectivityStatusChanged);
    setConnected(ConnectivityNotifier.isConnected(this));
  }

  public void networkConnectivityStatusChanged(Context context, Intent intent) {
    final boolean connected = ConnectivityNotifier.isConnected(this);
    getTimer().add("network connectivity status: %s", (connected ? "up" : "down"));
    onUI(() -> setConnected(connected));
  }

  @Override
  public void showToast(String msg) {
    if (isUIThread()) {
      Toast.makeText(get(), msg, Toast.LENGTH_LONG).show();
    } else {
      get().onUI(() -> showToast(msg), 0);
    }
  }

  public final void refresh() {
    BaseActivity activity = getCurrentActivity();
    if (activity != null) {
      getTimer().add("refresh requested");
      // The static variable is important here.  When the runner runs, if
      // it is not the current smRunningRefresh, it knows that another
      // refresh has already been requested, and defers to the later
      // request.  A little bit of debouncing.  We delay the post for 1/10th
      // of a second to make this more likely.
      smRunningRefresh = new RefreshRunner(activity);
      get().onUI(smRunningRefresh, 200);
    }
  }

  @CallSuper
  @Override
  public void onCreate() {
    super.onCreate();
    Util.setContext(this);
    startServices();
    registerActivityLifecycleCallbacks(new LCCallbacks());
  }

  public BaseActivity getCurrentActivity() {
    if (hasCurrentActivity()) {
      return mActivityStack.peek();
    } else {
      return null;
    }
  }

  @CallSuper
  public void popCurrentActivity(Activity oldActivity) {
    synchronized (mActivityStack) {
      getTimer().add("popping activity: %s",
        oldActivity.getClass().getSimpleName());
      BaseActivity top = mActivityStack.peek();
      if (top != oldActivity) {
        showAlertDialog("out of order");
      } else {
        mActivityStack.pop();
      }
      dumpActivityStack();
      getRefreshHandler().postDelayed(this::refresh, 500);
    }
  }

  @CallSuper
  public void pushCurrentActivity(BaseActivity activity) {
    synchronized (mActivityStack) {
      getTimer().add("pushing activity: %s",
        activity.getClass().getSimpleName());
      mActivityStack.push(activity);
      dumpActivityStack();
      getRefreshHandler().postDelayed(this::refresh, 500);
    }
  }

  private void dumpActivityStack() {
    XLog.i(TAG, "Activity Stack: {");
    for (Object obj : mActivityStack) {
      XLog.i(TAG, "   " + obj);
    }
    XLog.i(TAG, "}");
  }

  public boolean hasCurrentActivity() {
    return !mActivityStack.isEmpty();
  }

  public XParse xpr() {
    if (mXParse == null) {
      mXParse = new XParse();
      mXParse.startup();
    }
    return mXParse;
  }

  @CallSuper
  public void logOut() {
    getTimer().add("logout requested");
    mXParse.logOut();
  }

  @Override
  public void handleException(@NonNull String activity, @NonNull Throwable pe,
                              @Nullable OnCompletionListener listener) {
    getTimer().add("handleException: %s, while '%s'",
      pe, activity);
    // ThreadDeath is not really exceptional.  It is (sometimes) part of the lifecycle of threads.
    if (pe instanceof ThreadDeath) {
      System.out.println("" + pe);
      throw (ThreadDeath) pe;
    }
    if (isBadSessionException(pe)) {
      BaseDialogs.showSessionExpiredAlertDialog(
        success -> {
          try {
            Intent intent = new Intent(BaseApp.this, Class.forName("cell411.MainActivity"));
            intent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP);
            intent.addFlags(Intent.FLAG_ACTIVITY_BROUGHT_TO_FRONT);
            intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK);
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            startActivity(intent);
          } catch (ClassNotFoundException e) {
            e.printStackTrace();
          }
        }
      );
    } else if (isNetworkException(pe) && !smConnected.get()) {
      XLog.i(TAG, "Ignoring network exception while disconnected");
    } else {
      BaseDialogs.showExceptionDialog(pe, activity, listener);
    }
  }

  private boolean isNetworkException(final Throwable t) {
    if (t instanceof ParseException) {
      ParseException pe = (ParseException) t;
      Throwable cause = pe.getCause();
      if (pe.getCode() == ParseException.CONNECTION_FAILED) {
        if (cause instanceof SocketException) {
          SocketException se = (SocketException) cause;
          String message = se.getMessage();
          if (message == null)
            return false;
          else
            return message.equals("Software caused connection abort");
        }
      }
    }
    return false;
  }

  @Override
  public void showAlertDialog(String message, OnCompletionListener listener) {
    BaseDialogs.showAlertDialog(message, listener);
  }

  public boolean isConnected() {
    return smConnected.get() == Boolean.TRUE;
  }

  protected void setConnected(boolean connected) {
    smConnected.set(connected);
  }

  @Override
  public BaseActivity activity() {
    return getCurrentActivity();
  }

  public void addStateObserver(final ValueObserver<XParse.State> observer) {
    xpr().addObserver(observer);
  }

  public void removeStateObserver(final ValueObserver<XParse.State> observer) {
    xpr().removeObserver(observer);
  }

  public void addConnectionListener(ValueObserver<Boolean> listener) {
    smConnected.addObserver(listener);
  }

  public void removeConnectionListener(ValueObserver<Boolean> changed) {
    smConnected.removeObserver(changed);
  }

  public void removeLoggedInObserver(ValueObserver<Boolean> changed) {
    xpr().removeLoggedInObserver(changed);
  }
  public XParse.State getState() {
    return xpr().getState();
  }

  public void logIn(final String email, final String password,
                    final OnCompletionListener onLoginRes) {
    xpr().logIn(email, password, onLoginRes);
  }

  public LiveQueryService getLiveQueryService() {
    if (mLiveQueryServiceConn != null && mLiveQueryServiceConn.isReady())
      return mLiveQueryServiceConn.getService();
    else
      return null;
  }

  public DataService ds() {
    return mDataServiceConn.getService();
  }

  public LocationService loc() {
    return mLocationServiceConn.getService();
  }

  public Timer getTimer() {
    return mTimer;
  }

  public void reset() {
    getTimer().add("reset requested");
    try {
      ParseCheater.removeCredentials();
    } catch (Throwable throwable) {
      throwable.printStackTrace();
    }
    try {
      logOut();
    } catch (Throwable throwable) {
      throwable.printStackTrace();

    }
    logOut();
  }

  public void serviceStarted(BaseService service) {
    String name = service.getClass().getSimpleName();
    mStarted.put(name, true);
    getTimer().add(name + " ready");
   }

  public void startServices() {
    if (smRefreshThread != Thread.currentThread()) {
      smRefreshHandler.postDelayed(this::startServices, 100);
      getTimer().add("Posted to refresh thread");
      return;
    }
    getTimer().add("startServices called");
    if (isDataServiceReady() && isLiveQueryServiceReady() && isLocationServiceReady()) {
      getTimer().add("all services running");
      return;
    }
    if (smStarted) {
      getTimer().add("all services started");
      return;
    }
    boolean foreground = Util.theGovernmentIsLying();
    setupConnectivityWatcher();

    ArrayList<Runnable> todo = new ArrayList<>();


    todo.add(() -> {
      getTimer().add("DataService starting");
      mDataServiceConn = getConnection(DataService.class, foreground);
      ThreadUtil.waitUntil(this, mDataServiceConn::isReady, 200);
      xpr().updateDataService();
      getTimer().add("DataService started");
      serviceStarted(mDataServiceConn.getService());
    });

    todo.add(() -> {
      getTimer().add("LocationService starting");
      mLocationServiceConn = getConnection(LocationService.class, foreground);
      ThreadUtil.waitUntil(this, mLocationServiceConn::isReady, 200);
      getTimer().add("LocationService started");
      serviceStarted(mLocationServiceConn.getService());
    });

    todo.add(() -> {
      getTimer().add("LiveQuerySerivce starting");
      mLiveQueryServiceConn = getConnection(LiveQueryService.class, foreground);
      ThreadUtil.waitUntil(this, mLiveQueryServiceConn::isReady, 200);
      getTimer().add("LiveQueryService started");
      getLiveQueryService().addReadyObserver(this::dataReadyChanged);
      serviceStarted(mLiveQueryServiceConn.getService());
    });

    for (Runnable runnable : todo) {
      new Thread(runnable).start();
    }
    smStarted = true;
  }

  private void dataReadyChanged(Boolean newValue, Boolean oldValue) {
    if(lqs().isDataReady())
      xpr().updateLiveDataService();
  }

  public boolean isLocationServiceReady() {
    return mLocationServiceConn != null && mLocationServiceConn.isReady();
  }

  private <X extends BaseService>
  BaseService.Conn<X> getConnection(final Class<X> type, final boolean foreground) {
    return BaseService.getConnection(this, type, foreground);
  }

  public void onBootComplete() {
    getTimer().add("onBootComplete called");
    startServices();
  }

  public ScreenOffReceiver getScreenOffReceiver() {
    return mScreenOffReceiver;
  }

  public abstract Set<String> getMissingPermissions(BaseActivity activity);

  public abstract Set<String> getMissingRingtones(BaseActivity activity);

  public Set<String> getMissingPermissions() {
    return getMissingPermissions(activity());
  }

  public Set<String> getMissingRingtones() {
    return getMissingRingtones(activity());
  }

  public abstract void updatePermissions();

  public abstract void updateRingtones();

  public boolean isDataServiceReady() {
    return mDataServiceConn != null && mDataServiceConn.isReady();
  }

  public boolean isLiveQueryServiceReady() {
    return mLiveQueryServiceConn != null &&
      mLiveQueryServiceConn.isReady() &&
      getLiveQueryService().isDataReady();
  }

  public SharedPreferences getAppPrefs() {
    return getSharedPreferences("AppPrefs", Context.MODE_PRIVATE);
  }

  public void registerLogoutAction(Runnable action) {
    xpr().registerLogoutAction(action);
  }

  public abstract HashMap<String, Uri> getTones();

  public boolean isLoggedIn(){
    if(mXParse==null)
      return false;
    return mXParse.isLoggedIn();
  }

  public void addLoggedInObserver(ValueObserver<Boolean> changed) {
    xpr().addLoggedInObserver(changed);
  }


  class ScreenOffReceiver extends BroadcastReceiver {
    boolean mScreenOn = true;

    @Override
    public void onReceive(Context context, Intent intent) {
      XLog.i("TAG", intent.toString());
      mScreenOn = intent.getAction().equals(Intent.ACTION_SCREEN_ON);
      getTimer().add("ScreenOffReceiver received:  %s", mScreenOn);
    }
  }

  class RefreshRunner implements Runnable {
    final BaseActivity mActivity;
    int mStep = 0;

    public RefreshRunner(@NonNull BaseActivity activity) {
      getTimer().add("RefreshRunner created");
      this.mActivity = activity;
    }

    public void run() {
      XLog.i(TAG, "Running Refresh");
      if (smRunningRefresh != this) {
        getTimer().add("RefreshRunner superceded at step %d", mStep);
        return;
      }
      if (DataService.safeGet() == null) {
        getTimer().add("RefreshRunner postponed awaiting DataService");
        if (app().isConnected())
          smRefreshHandler.postDelayed(this, 1000);
        return;
      }
      if (mRefreshHandlers[0] == null) {
        mRefreshHandlers[0] = getHandler();
        mRefreshHandlers[1] = DataService.getHandler();
        mRefreshHandlers[2] = getHandler();
      }
      if (mActivity != getCurrentActivity()) {
        getTimer().add("Refersh Runner canceled:  on current activity");
        return;
      }
      try {
        getTimer().add("Starting step %d", mStep);

        if (!mRefreshHandlers[mStep].getLooper().isCurrentThread()) {
          mRefreshHandlers[mStep].post(this);
          return;
        }
        switch (mStep) {
          case 0:
            mActivity.prepareToLoad();
            break;
          case 1:
            mActivity.loadData();
            break;
          case 2:
            mActivity.populateUI();
            break;
        }
      } catch (Exception e) {
        handleException("Refresh step#" + mStep, e);
        return;
      } finally {
        getTimer().add("refresh finished step %d", mStep);
      }
      ++mStep;
      if (mStep < mRefreshHandlers.length)
        mRefreshHandlers[mStep].post(this);
    }
  }

  private class LCCallbacks implements ActivityLifecycleCallbacks {

    @Override
    public void onActivityCreated(Activity activity, Bundle arg1) {
      getTimer().add("activity created: %s", activity.getLocalClassName());
      XLog.i(TAG, "onActivityCreated %s", activity.getLocalClassName());
      //isInForeground = true;
    }

    @Override
    public void onActivityStarted(Activity activity) {
      getTimer().add("activity started: %s", activity.getLocalClassName());
      XLog.i(TAG, "onActivityStarted %s", activity.getLocalClassName());
    }

    @Override
    public void onActivityResumed(Activity activity) {
      getTimer().add("activity resumed: %s", activity.getLocalClassName());
      XLog.i(TAG, "onActivityResumed %s", activity.getLocalClassName());
      pushCurrentActivity((BaseActivity) activity);
    }

    @Override
    public void onActivityPaused(Activity activity) {
      getTimer().add("activity paused: %s", activity.getLocalClassName());
      XLog.e(TAG, "onActivityPaused %s", activity.getLocalClassName());
      popCurrentActivity(activity);
    }

    @Override
    public void onActivityStopped(Activity activity) {
      getTimer().add("activity stopped: %s", activity.getLocalClassName());
      XLog.i(TAG, "onActivityStopped %s", activity.getLocalClassName());
    }

    @Override
    public void onActivitySaveInstanceState(Activity activity, Bundle arg1) {
      XLog.i(TAG, "onActivitySaveInstanceState %s", activity.getLocalClassName());
    }

    @Override
    public void onActivityDestroyed(Activity activity) {
      XLog.i(TAG, "onActivityDestroyed %s", activity.getLocalClassName());
    }

  }
}
