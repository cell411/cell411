package cell411.logic;

import android.content.Intent;

import androidx.annotation.NonNull;

import com.parse.ParseQuery;
import com.parse.livequery.LiveQueryException;
import com.parse.livequery.ParseLiveQueryClient;
import com.parse.livequery.ParseLiveQueryClientCallbacks;
import com.parse.livequery.SubscriptionHandler;
import com.parse.model.ParseObject;

import java.io.File;
import java.util.ArrayList;

import cell411.base.BaseApp;
import cell411.base.BaseService;
import cell411.parse.XPrivateCell;
import cell411.parse.XPublicCell;
import cell411.utils.CarefulHandler;
import cell411.utils.HandlerThreadPlus;
import cell411.utils.ObservableValue;
import cell411.utils.PrintString;
import cell411.utils.Reflect;
import cell411.utils.Timer;
import cell411.utils.ValueObserver;
import cell411.utils.XLog;

public class LiveQueryService
  extends BaseService
  implements ICacheObject {
  private static final String TAG = Reflect.getTag();

  final HandlerThreadPlus smThread = HandlerThreadPlus.createThread("LiveQueryService");
  final CarefulHandler smHandler = smThread.getHandler();

  final ArrayList<CacheObject> mCacheObjects = new ArrayList<>();

  //  private final PostManyRunOnce mRunner = new PostManyRunOnce(this);
  private final ObservableValue<Boolean> mReady = new ObservableValue<>(false);
  private final ObservableValue<Boolean> mSystemReady = new ObservableValue<>(false);
  public CellWatcher<XPrivateCell> mPrivateCellWatcher;
  RequestWatcher mRequestWatcher;
  FriendWatcher mFriendWatcher;
  AlertWatcher mAlertWatcher;
  CellWatcher<XPublicCell> mPublicCellWatcher;
  ChatRoomWatcher mChatRoomWatcher;
  Timer mTimer;
  private ParseLiveQueryClient mClient;
  private RelationWatcher mRelationWatcher;

  public LiveQueryService() {
    XLog.i(TAG, "object created");
  }

  public boolean isDataReady() {
    return mReady.get();
  }

  public Timer getTimer() {
    if (mTimer == null)
      return new Timer();
    return mTimer;
  }

  @Override
  public String getName() {
    return toString();
  }

  @Override
  public boolean cacheExists() {
    return true;
  }

  @Override
  public File getCacheFile() {
    return null;
  }

  @Override
  public File getBackupFile() {
    return null;
  }

  @Override
  public void prepare() {

  }

  @Override
  public void loadFromCache() {
    mTimer = getTimer();
    mTimer.add("Entering loadFromCache");
    try {
      mTimer.add("Loading from cache");
      for (CacheObject cacheObject : mCacheObjects) {
        mTimer.add("calling loadFromCache on %s", cacheObject.getName());
        cacheObject.loadFromCache();
        mTimer.add("loadFromCache returned");
      }
      mTimer.add("loadFromCache complete");
      XLog.i(TAG, mTimer.toString());
    } catch (Exception e) {
      XLog.i(TAG, "Exception: %s", e);
    }
  }

  @Override
  public void loadFromNet() {
    mTimer.add("Entering loadFromNet");
    for (CacheObject cacheObject : mCacheObjects) {
      cacheObject.loadFromNet();
    }
    mTimer.add("Leaving loadFromNet");
  }

  @Override
  public void saveToCache() {
    mTimer.add("Entering saveToCache");
    for (CacheObject cacheObject : mCacheObjects) {
      mTimer.add("  Entering saveToCache for %s", cacheObject.getName());
      cacheObject.saveToCache();
      mTimer.add("  Leaving  saveToCache for %s", cacheObject.getName());
    }
    mTimer.add("Leaving  saveToCache");
    XLog.i(TAG, "timer:");
    XLog.i(TAG, mTimer.toString());
    XLog.i(TAG, "timer: complete");
  }


  public void requestDataReport(PrintString ps) {
    getRelationWatcher().requestDataReport(ps);
  }

  @Override
  public void clear() {

  }

  public void addReadyObserver(ValueObserver<Boolean> observer) {
    mReady.addObserver(observer);
  }

//  public void advance(final Runnable r) {
//    mQueue.add(r);
//    if (app().isLoggedIn())
//      mRunner.selfStart(smHandler, 50);
//  }

  public void isLoggedInChanged(Boolean newValue, Boolean oldValue) {
    updateSystemIsReady();
  }

  private void updateSystemIsReady() {
    BaseApp app = app();
    boolean dataServerReady = app.isDataServiceReady();
    boolean isLoggedIn = app.isLoggedIn();
    mSystemReady.set(dataServerReady && isLoggedIn);
  }

  private void systemIsReadyChanged(boolean newValue, boolean oldValue) {
    if (newValue == oldValue)
      return;
    if (!newValue)
      return;

    later(() -> {
      loadFromCache();
      loadFromNet();
      mReady.set(true);
      saveToCache();
    });
  }


  public void later(Runnable runnable) {
    later(runnable, 0);
  }

  public void later(Runnable runnable, int delay) {
    smHandler.postDelayed(runnable, delay);
  }
//
//  public void later(PostManyRunOnce r) {
//    r.selfStart(smHandler);
//  }
//
//  public void later(PostManyRunOnce r, long i) {
//    r.selfStart(smHandler, i);
//  }

  @Override
  public void onCreate() {
    mSystemReady.addObserver(this::systemIsReadyChanged);
    xpr().addLoggedInObserver(this::isLoggedInChanged);
    mCacheObjects.add(getRelationWatcher());
    mCacheObjects.add(getFriendWatcher());
    mCacheObjects.add(getPublicCellWatcher());
    mCacheObjects.add(getPrivateCellWatcher());
    mCacheObjects.add(getRequestWatcher());
    mCacheObjects.add(getAlertWatcher());
//    mCacheObjects.add(getChatRoomWatcher());
    updateSystemIsReady();
  }

  public <T extends ParseObject> void subscribe(ParseQuery<T> subQuery,
                                                SubscriptionHandler.HandleEventsCallback<T> callback) {
    Subscription<T> worker = new Subscription<T>(subQuery, callback) {
      public void run() {
        SubscriptionHandler<T> handler = getClient().subscribe(mQuery);
        handler.handleEvents(mCallback);
        handler.handleSubscribe(
          query -> XLog.i(TAG, "onSubscribe(" + query.getClassName() + ")"));
      }
    };
    worker.run();
//    advance(worker);
  }

  private ParseLiveQueryClient getClient() {
    if (mClient == null) {
      mClient = ParseLiveQueryClient.Factory.getClient(new Cell411SocketClientFactory());
      mClient.registerListener(new CallBacks());
    }
    return mClient;
  }

  @Override
  public int onStartCommand(Intent intent, int flags, int startId) {
    super.onStartCommand(intent, flags, startId);
    return START_STICKY;
  }

  public <T extends ParseObject> void unsubscribe(ParseQuery<T> query) {
    mClient.unsubscribe(query);
  }

  public RequestWatcher getRequestWatcher() {
    if (mRequestWatcher == null)
      mRequestWatcher = new RequestWatcher(this);
    return mRequestWatcher;
  }

  public FriendWatcher getFriendWatcher() {
    if (mFriendWatcher == null)
      mFriendWatcher = new FriendWatcher();
    return mFriendWatcher;
  }

  public RelationWatcher getRelationWatcher() {
    if (mRelationWatcher == null)
      mRelationWatcher = new RelationWatcher(this);
    return mRelationWatcher;
  }

  public AlertWatcher getAlertWatcher() {
    if (mAlertWatcher == null)
      mAlertWatcher = new AlertWatcher();
    return mAlertWatcher;
  }

  public CellWatcher<XPrivateCell> getPrivateCellWatcher() {
    if (mPrivateCellWatcher == null)
      mPrivateCellWatcher = new CellWatcher<>(this, XPrivateCell.class);
    return mPrivateCellWatcher;
  }

  public CellWatcher<XPublicCell> getPublicCellWatcher() {
    if (mPublicCellWatcher == null)
      mPublicCellWatcher = new CellWatcher<>(this, XPublicCell.class);
    return mPublicCellWatcher;
  }

  public boolean isCurrentThread() {
    return smThread.isCurrentThread();
  }

  public ChatRoomWatcher getChatRoomWatcher() {
    if (mChatRoomWatcher == null)
      mChatRoomWatcher = new ChatRoomWatcher(this);
    return mChatRoomWatcher;
  }

  private void maybeReconnect() {
    int opens = mClient.getOpens();
    smHandler.postDelayed(() -> {
        if (opens == mClient.getOpens())
          mClient.reconnect();
      },
      15000
    );
  }

  @NonNull
  public String toString() {
    return TAG;
  }

//  public void setMemberIds(XBaseCell cell, HashSet<String> memberIds) {
//    RelationWatcher.Rel rel = getRelationWatcher().getRel(cell,"members","_User");
//    rel.setRelatedIds(memberIds);
//  }

  static abstract class Subscription<T extends ParseObject> implements Runnable {
    private static final String TAG = Reflect.getTag();

    static {
      XLog.i(TAG, "loading class");
    }

    final ParseQuery<T> mQuery;
    final SubscriptionHandler.HandleEventsCallback<T> mCallback;

    public Subscription(ParseQuery<T> query, SubscriptionHandler.HandleEventsCallback<T> callback) {
      this.mQuery = query;
      this.mCallback = callback;
    }
  }

  public class CallBacks implements ParseLiveQueryClientCallbacks {
    private final String TAG = Reflect.getTag();

    @Override
    public void onLiveQueryClientConnected(ParseLiveQueryClient client) {
      XLog.i(TAG, " " + LiveQueryService.this.mClient);
    }

    @Override
    public void onLiveQueryClientDisconnected(ParseLiveQueryClient client, boolean userInitiated) {
      XLog.i(TAG, "disconnected " + LiveQueryService.this.mClient);
      maybeReconnect();
    }

    @Override
    public void onLiveQueryError(ParseLiveQueryClient client, LiveQueryException reason) {
      XLog.i(TAG, "error " + LiveQueryService.this.mClient);
      maybeReconnect();
    }

    @Override
    public void onSocketError(ParseLiveQueryClient client, Throwable reason) {
      XLog.i(TAG, "socket err " + LiveQueryService.this.mClient);
      maybeReconnect();
    }
  }
}
