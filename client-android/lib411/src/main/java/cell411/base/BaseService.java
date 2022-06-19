package cell411.base;

import static android.os.PowerManager.ACQUIRE_CAUSES_WAKEUP;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.Binder;
import android.os.IBinder;
import android.os.PowerManager;
import android.os.PowerManager.WakeLock;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;

import java.util.ArrayList;

import cell411.services.R;
import cell411.utils.CarefulHandler;
import cell411.utils.HandlerThreadPlus;
import cell411.utils.Reflect;
import cell411.utils.ThreadUtil;
import cell411.utils.XLog;

public class BaseService extends Service implements BaseContext
{
  static int FULL_WAKE_LOCK = Reflect.getInt(PowerManager.class,"FULL_WAKE_LOCK");

  public static final String FOREGROUND = "ForeGround";
  static final ArrayList<BaseService> smAllServices = new ArrayList<>();
  private static final String TAG = Reflect.getTag();
  private static final int ID_FOREGROUND = 19841776;
  private static final HandlerThreadPlus smStarterThread
    = HandlerThreadPlus.createThread("Starter");
  private static final CarefulHandler smStarter;


  static {
//    smStarterThread = new HandlerThreadPlus("Starter");
    smStarter = smStarterThread.getHandler();
  }

  private boolean mForeground = false;
  private NotificationChannel mChannel;

  protected BaseService() {
    Log.i(TAG, getClass().getSimpleName() + " created");
    Log.i(TAG, "  on " + Thread.currentThread());
    smAllServices.add(this);
  }

  public static <Type extends BaseService> Conn<Type> getConnection(Context context,
                                                                    Class<Type> type,
                                                                    boolean foreground) {
    XLog.i(TAG, "getConnection(" + type + "," + foreground);
    return new Conn<>(context, type, foreground);
  }


  @NonNull
  @Override
  public final IBinder onBind(Intent intent) {
    XLog.i(TAG, "onBind: " + getClass().getSimpleName());
    return new LocalBinder();
  }

  @Override
  public void onCreate() {
    XLog.i(getClass().getSimpleName(), "onCreate");
    super.onCreate();
  }

  @Override
  public int onStartCommand(Intent intent, int flags, int startId) {
    super.onStartCommand(intent, flags, startId);
    mForeground = intent != null && intent.getBooleanExtra(FOREGROUND, mForeground);
    if (mForeground)
      showNotification();
    return START_STICKY;
  }

  public void showNotification() {
    NotificationManagerCompat nm = NotificationManagerCompat.from(this);
    if (mChannel == null) {
      mChannel =
        new NotificationChannel(FOREGROUND, FOREGROUND, NotificationManager.IMPORTANCE_LOW);
      mChannel.setShowBadge(false);
      nm.createNotificationChannel(mChannel);
    }
    Class<?> type = null;
    try {
      type = Class.forName("cell411.MainActivity");
    } catch (ClassNotFoundException e) {
      e.printStackTrace();
    }

    Intent notificationIntent = new Intent(this, type);
    PendingIntent pendingIntent =
      PendingIntent.getActivity(this, 0, notificationIntent, PendingIntent.FLAG_IMMUTABLE);
    NotificationCompat.Builder notificationBuilder =
      new NotificationCompat.Builder(this, FOREGROUND);
    notificationBuilder.setSmallIcon(R.mipmap.appicon);
    notificationBuilder.setOngoing(true);
    notificationBuilder.setPriority(NotificationCompat.PRIORITY_MIN);
    notificationBuilder.setShowWhen(false);
    notificationBuilder.setWhen(0);
    notificationBuilder.setContentTitle(getClass().getSimpleName());
    notificationBuilder.setChannelId(FOREGROUND);

    String message = "The Service Is Running";
    notificationBuilder.setContentText(message);

    notificationBuilder.setStyle(new NotificationCompat.BigTextStyle().bigText(message));
    if (pendingIntent != null)
      notificationBuilder.setContentIntent(pendingIntent);

    if (mForeground) {
      startForeground(ID_FOREGROUND, notificationBuilder.build());
    } else {
      nm.notify(ID_FOREGROUND, notificationBuilder.build());
    }
  }

  @Override
  public BaseActivity activity() {
    return BaseApp.get().activity();
  }

  public static class Conn<Type> implements ServiceConnection {
    private final Context mContext;
    private final Intent mIntent;
    private final boolean mForeground;
    private final Class<Type> mType;
    LocalBinder mLocalBinder;
    Type mService;
    ComponentName mName;
    int tries = 0;
    private WakeLock mLock = null;

    private Conn(Context context, Class<Type> type, boolean foreground) {
      Class<PowerManager> pmc = PowerManager.class;
      PowerManager pm = pmc.cast(context.getSystemService(pmc));
      int flags = FULL_WAKE_LOCK | ACQUIRE_CAUSES_WAKEUP;
      if (pm != null)
        mLock = pm.newWakeLock(flags, TAG);
      if (mLock != null)
        mLock.acquire(5000);

      mContext = context;
      mIntent = new Intent(context, type);
      mIntent.putExtra(FOREGROUND, foreground);
      mForeground = foreground;
      mType = type;
      smStarter.post(this::startService);

    }

    private void startService() {
      try {
        XLog.i(TAG, "starting: " + mType.getSimpleName());
        Context context = mContext;
        if (mForeground) {
          context.startForegroundService(mIntent);
        } else {
          context.startService(mIntent);
        }
        context.bindService(mIntent, this, BIND_ABOVE_CLIENT);
        ThreadUtil.waitUntil(this, this::isReady);
        mLock.release();
      } catch (IllegalStateException e) {
        XLog.i(TAG, "Exception: " + e + " looping");
      } finally {
        if (!isReady()) {
          tries++;
          int delay = (int) (tries * 2000 * Math.random());
          XLog.i(TAG, "tries: %d delay: %d", tries, delay);
          mLock.acquire(delay + 5000);
          smStarter.postDelayed(this::startService, delay);

        }
      }
    }

    public Type getService() {
      if(mLocalBinder==null)
        return null;
      return mType.cast(mLocalBinder.getService());
    }

    @Override
    public void onServiceConnected(ComponentName name, IBinder service) {
      mName = name;
      mLocalBinder = (LocalBinder) service;
      mService = mType.cast(mLocalBinder.getService());
    }

    @Override
    public void onServiceDisconnected(ComponentName name) {
      mService = null;
      startService();
    }

    public boolean isReady() {
      return mService != null;
    }
  }

  public class LocalBinder extends Binder {
    public BaseService getService() {
      return BaseService.this;
    }
  }
}
