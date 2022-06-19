package cell411.services;

import android.content.Intent;
import android.content.SharedPreferences;
import android.location.Location;
import android.os.Handler;
import android.os.Looper;
import androidx.annotation.NonNull;

import cell411.base.BaseService;
import cell411.enums.RequestType;
import cell411.parse.XAddress;
import cell411.parse.XChatRoom;
import cell411.parse.XCity;
import cell411.parse.XEntity;
import cell411.parse.XPrivateCell;
import cell411.parse.XPublicCell;
import cell411.parse.XRequest;
import cell411.parse.XUser;
import cell411.parse.util.OnCompletionListener;
import cell411.utils.CarefulHandler;
import cell411.utils.ClearWeakReference;
import cell411.utils.Collect;
import cell411.utils.HandlerThreadPlus;
import cell411.utils.LocationUtil;
import cell411.utils.NetUtils;
import cell411.utils.ObservableValue;
import cell411.utils.Reflect;
import cell411.utils.StorageOperations;
import cell411.utils.Timer;
import cell411.utils.Util;
import cell411.utils.XLog;
import com.parse.ParseCloud;
import com.parse.ParseException;
import com.parse.ParseQuery;
import com.parse.model.ParseGeoPoint;
import com.parse.model.ParseObject;
import com.parse.model.ParseRelation;

import org.jetbrains.annotations.NotNull;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;

import static cell411.enums.RequestType.CellJoinRequest;
import static cell411.enums.RequestType.FriendRequest;

@SuppressWarnings("unused")
public class DataService extends BaseService {
  public static final String            TAG       = Reflect.getTag();
  public static Timer smTimer;

  static {
    XLog.i(TAG, "loading class");
  }
  public static HashSet<ParseObject>  mNursery  = new HashSet<>();
  private static ClearWeakReference<DataService> INSTANCE;
  public final        HandlerThreadPlus smThread  =
    HandlerThreadPlus.createThread("DataService");
    // new HandlerThreadPlus("DataService #1");
  private final        CarefulHandler    mHandler  = smThread.getHandler();
  public final  ObservableValue<Long>   mLoadTime = new ObservableValue<>((long) 0);
  final         HashMap<Object, XAddress>         smCityCache    = new HashMap<>();
  private final CarefulHandler        mMainHandler;
  private final ArrayList<XAddress>  addresses      = new ArrayList<>();
  private final ArrayList<XCity>     cities         = new ArrayList<>();
  private final Map<String, String>          smChatEntity       = new HashMap<>();


  public DataService() {
    mMainHandler = new CarefulHandler(Looper.getMainLooper());
  }

  public static Handler getHandler() {
    return get().mHandler;
  }

  public static DataService get() {
    if(INSTANCE==null)
      throw new Error("DataService not initialized yet");
    return INSTANCE.get();
  }

  public void clear() {
  }
  @Override
  public void showAlertDialog(int format, Object... args) {
    super.showAlertDialog(format, args);
  }
  @Override
  public void showAlertDialog(String format, Object... args) {
    super.showAlertDialog(format, args);
  }

  public static DataService safeGet() {
    return INSTANCE!=null ? INSTANCE.get() : null;
  }

  public ParseObject getObject(String objectId) {
    return ParseObject.getObject(objectId);
  }
  public boolean isCurrentUser(XUser owner) {
    if (owner.isCurrentUser()) {
      return true;
    }
    XUser current = XUser.getCurrentUser();
    if (current == null) {
      return false;
    }
    return (current.getObjectId().equals(owner.getObjectId()));
  }
  private String getEntityId(String objectId) {
    return smChatEntity.get(objectId);
  }
  public static <Type extends ParseObject> List<Type> findFully(ParseQuery<Type> query)
  {
    ArrayList<List<Type>> listList = new ArrayList<>();
    int                   skip     = 0;
    while (true) {
      List<Type> list = query.find();
      if (list.size() == 0) {
        break;
      }
      skip += list.size();
      query.setSkip(skip);
      listList.add(list);
    }
    return Collect.flatten(listList);
  }
  public Looper getLooper() {
    return smThread.getLooper();
  }
  public  Map<String, Object> callFunction(String func, Map<String, Object> params)
  {
    assert !Looper.getMainLooper().isCurrentThread();
    return ParseCloud.run(func, params);
  }

  public static boolean onDataServerThread() {
    return Util.isCurrentThread(get().getLooper());
  }

  public static String getResString(int resId, Object... args) {

    DataService ds = get();
    return ds.getString(resId, args);
  }
  public static String getResString(int resId) {

    DataService ds = get();
    return ds.getString(resId);
  }

  public void onDS(Runnable r) {
    onDS(r,0);
  }
  public void onDS(Runnable r, long i) {
    mHandler.postDelayed(r, i);
  }
  public <I> List<I> getObjects(List<I> list, Class<I> cls, Collection<String> ids)
  {
    for (String id : ids) {
      ParseObject result;
      synchronized (DataService.class) {

        result = get().getObject(id);
      }
      ParseObject ob = result;
      if (ob == null) {
        continue;
      }
      I i = cls.cast(ob);
      list.add(i);
    }
    return list;
  }

  public XUser getUser(@NonNull String key)
  {
    ParseObject result;
    synchronized (DataService.class) {

      result = get().getObject(key);
    }
    ParseObject object = result;
    XLog.i(TAG, "" + object);
    if (object instanceof XUser) {
      return (XUser) object;
    } else {
      XLog.i(TAG, "" + object);
      return null;
    }
  }
  public void serverIsDown() {
    String parseApi = getResString(R.string.parse_api_url);
    String res      = NetUtils.loadURL(parseApi + "health");
    showAlertDialog("Server State: " + res);
  }
  public int getInstanceCount() {
    return ParseObject.getInstanceCount();
  }
  public static void removeFriend(XUser friend) {
    XUser                current = XUser.getCurrentUser();
    ParseRelation<XUser> r       = current.getRelation("friends");
    r.remove(friend);
    current.saveInBackground();
  }
  public XPublicCell getPublicCell(String id)
  {
    ParseObject result;
    synchronized (DataService.class) {

      result = get().getObject(id);
    }
    return (XPublicCell) result;
  }
  void runOnUIThread(Runnable runnable) {
    runOnUIThread(runnable, (int) (50 + 50 * Math.random()));
  }
  void runOnUIThread(Runnable runnable, int delay) {
    mMainHandler.postDelayed(runnable, delay);
  }
  public void handleResponse(XRequest request, boolean b, OnCompletionListener listener)
  {
    RequestType rt;
    if (request.isCellRequest()) {
      if (b) {
        rt = RequestType.CellJoinApprove;
      } else {
        rt = RequestType.CellJoinReject;
      }
    } else {
      if (b) {
        rt = RequestType.FriendApprove;
      } else {
        rt = RequestType.FriendReject;
      }
    }
    mHandler.post(new RequestHandler(rt, request, listener));
  }

  @Override
  public int onStartCommand(final Intent intent, final int flags, final int startId) {
    return super.onStartCommand(intent, flags, startId);
  }

  public void createPrivateCell(String cellName, OnCompletionListener listener) {
    try {
      ParseQuery<XPrivateCell> cellQuery   = ParseQuery.getQuery(XPrivateCell.class);
      final XUser              currentUser = XUser.getCurrentUser();
      cellQuery.whereEqualTo("owner", currentUser);
      cellQuery.whereNotEqualTo("type", 5);
      cellQuery.whereEqualTo("name", cellName);
      cellQuery.setLimit(1);
      List<XPrivateCell> cells = cellQuery.find();
      if (cells.size() != 0) {
        showToast("Cell " + cellName + " " + getString(R.string.already_created));
      } else {
        XPrivateCell cell = new XPrivateCell();
        cell.setOwner(currentUser);
        cell.setName(cellName);
        cell.save();
        if (listener != null) {
          listener.done(true);
        }
        showToast("created new private cell " + cellName);
      }
    } catch (Exception e) {
      if (listener != null) {
        listener.done(false);
      }
    }
  }
  public XPrivateCell getPrivateCell(String i) {
    ParseObject result;
    synchronized (DataService.class) {

      result = get().getObject(i);
    }
    return (XPrivateCell) result;
  }
  public void onCreate() {
    INSTANCE = new ClearWeakReference<>(this);
    super.onCreate();
  }

  public void handleRequest(RequestType requestType, ParseObject object,
                            OnCompletionListener listener)
  {
    get().onDS(new RequestHandler(requestType, object, listener));
  }

  public long loadTime()
  {
    return mLoadTime.get();
  }

  public List<XUser> getUsers(Collection<String> keys)
  {
    if (keys == null || keys.isEmpty()) {
      return new ArrayList<>();
    }
    ArrayList<XUser> dest = new ArrayList<>(keys.size());
    for (String key : keys) {
      XUser user = getUser(key);
      if (user != null) {
        dest.add(user);
      }
    }
    return dest;
  }
  public void handleRequest(RequestType requestType, XRequest req) {
    handleRequest(requestType, req, null);
  }
  public void flagUser(XUser user, boolean flagNotUnflag, OnCompletionListener listener) {
    Runnable runnable = () -> {
      try {
        final XUser          currentUser = XUser.getCurrentUser();
        ParseRelation<XUser> relation    = currentUser.getRelation("spamUsers");
        if(flagNotUnflag) {
          relation.add(user);
          showToast(getResString(R.string.blocked_successfully, user.getName()));
        } else {
          relation.remove(user);
          showToast(getResString(R.string.unblocked_successfully, user.getName()));
        }
        currentUser.save();
        if (listener != null) {
          get().onDS(() -> listener.done(true));
        }
      } catch (ParseException e) {
        if (listener != null) {
          get().onDS(() -> listener.done(false));
        }
        handleException("While blocking user", e, null);
      }
    };

    get().onDS(runnable);
  }
  public XEntity getEntity(XChatRoom xChatRoom) {
    ParseObject result;
    synchronized (DataService.class) {

      result = get().getObject(getEntityId(xChatRoom.getObjectId()));
    }
    return (XEntity) result;
  }
  public void setEntity(XChatRoom chatRoom, XEntity xEntity) {
    smChatEntity.put(chatRoom.getObjectId(), xEntity.getObjectId());
    smChatEntity.put(xEntity.getObjectId(), chatRoom.getObjectId());
  }

  private void reverseGeocode(ParseGeoPoint location, AddressListener listener)
  {
    Runnable runnable = () -> {
      try {
        Map<String, Object> params = new HashMap<>();
        params.put("location", location);
        params.put("type", "address");
        XAddress address = callReverseGeocode(params);
        runOnUIThread(() -> listener.setAddress(address, null));
      } catch (Throwable error) {
        runOnUIThread(() -> listener.setAddress(null, error));
      }
    };
    if (onDataServerThread()) {

      get().onDS(runnable);
    } else {
      runnable.run();
    }
  }
  public void requestCity(Location location, AddressListener listener) {
    requestCity(LocationUtil.getGeoPoint(location), listener);
  }
  public void requestCity(final ParseGeoPoint location, AddressListener listener)
  {
    XAddress result;
    synchronized (smCityCache) {
      result = smCityCache.get(location);
    }
    if (result != null) {
      if (listener != null)
        runOnUIThread(() -> listener.setAddress(result));
      return;
    }
    if (onDataServerThread()) {
      callRequestCity(location, listener);
    } else {
      get().onDS(() -> callRequestCity(location, listener));
    }
  }
  private void callRequestCity(ParseGeoPoint location, AddressListener listener) {
    try {
      Map<String, Object> params = new HashMap<>();
      params.put("location", location);
      params.put("type", "city");
      XAddress address = callReverseGeocode(params);
      updateCache(null, location, address);
      if (listener != null)
        runOnUIThread(() -> listener.setAddress(address, null));
    } catch (Throwable error) {
      if (listener != null)
        runOnUIThread(() -> listener.setAddress(null, error));
    }
  }
  private void updateCache(String text, ParseGeoPoint location, XAddress address) {
    synchronized (smCityCache) {
      if (address == null)
        return;
      ParseGeoPoint newLocation = LocationUtil.getGeoPoint(address.mLocation);
      if (location != null)
        smCityCache.put(location, address);
      if (newLocation != null)
        smCityCache.put(newLocation, address);
      if (text != null)
        smCityCache.put(text.toLowerCase(), address);
      if (address.cityPlus().split(",").length == 3) {
        smCityCache.put(address.cityPlus().toLowerCase().trim(), address);
      }
    }
  }
  public void requestCity(final String text, AddressListener listener)
  {
    XAddress result;
    synchronized (smCityCache) {
      result = smCityCache.get(text.trim().toLowerCase());
    }
    if (result != null) {
      if (listener != null)
        runOnUIThread(() -> listener.setAddress(result));
      return;
    }

    get().onDS(() -> {
      try {
        Map<String, Object> params = new HashMap<>();
        params.put("address", text);
        params.put("type", "city");
        XAddress address = callGeocode(params);
        updateCache(text, null, address);
        if (listener != null)
          runOnUIThread(() -> listener.setAddress(address, null));
      } catch (Throwable error) {
        if (listener != null)
          runOnUIThread(() -> listener.setAddress(null, error));
      }
    });
  }
  private XAddress callReverseGeocode(Map<String, Object> params) {

    Map<String, Object> res = get().callFunction("reverseGeocode", params);
    return processGeocodeResults(res);
  }
  private XAddress callGeocode(Map<String, Object> params) {

    Map<String, Object> res = get().callFunction("geocode", params);

    return processGeocodeResults(res);
  }
  @NotNull
  private XAddress processGeocodeResults(Map<String, Object> res) {
    String        address  = (String) res.get("address");
    String        city     = (String) res.get("city");
    String        state    = (String) res.get("state");
    String        country  = (String) res.get("country");
    ParseGeoPoint minPoint = (ParseGeoPoint) res.get("minPoint");
    ParseGeoPoint maxPoint = (ParseGeoPoint) res.get("maxPoint");
    Location      location = LocationUtil.getLocation((ParseGeoPoint) res.get("location"));
    return new XAddress(country, state, city, address, location);
  }
  public SharedPreferences getAppPrefs() {
    return app().getAppPrefs();
  }
  public void resetSession() {
    getAppPrefs().edit().clear().apply();
    StorageOperations.clearData();
  }
  public void sendFriendRequest(XUser user, OnCompletionListener onCompletionListener) {
    handleRequest(FriendRequest, user, onCompletionListener);
  }

  public interface AddressListener {
    void setAddress(XAddress address);
    default void setAddress(XAddress address, Throwable err) {
      if (err != null) {

        get().handleException("Geocoding", err);
      } else {
        setAddress(address);
      }
    }
  }

  static class CompletionWatcher implements Runnable {
    final Runnable             mRunnable;
    final OnCompletionListener mListener;

    CompletionWatcher(Runnable runnable, OnCompletionListener listener) {
      mRunnable = runnable;
      mListener = listener;
    }

    public void run() {
      try {
        mRunnable.run();
        mListener.done(true);
      } catch (Exception e) {

        get().handleException("Running " + mRunnable, e);
        mListener.done(false);
      }
    }
  }

  class RequestHandler implements Runnable {
    final         RequestType          mRequestType;
    final         ParseObject          mObject;
    final         XRequest             mRequest;
    final         OnCompletionListener mListener;
    private final String               mFunction;

    RequestHandler(RequestType requestType, ParseObject object, OnCompletionListener callback)
    {
      mObject      = object;
      mRequestType = requestType;
      if (callback == null)
        callback = (success) -> {
        };
      mListener = callback;
      XUser user;
      XPublicCell publicCell;
      if (mRequestType.isResponse() || mRequestType.isFollowup()) {
        mRequest = (XRequest) object;

      } else if (mRequestType == FriendRequest) {
        mRequest    = null;
      } else if (requestType == CellJoinRequest) {
        mRequest    = null;
      } else {
        throw new RuntimeException("Unexpected value");
      }
      if (mRequestType.isResponse()) {
        mFunction = "sendRequestResponse";
      } else {
        mFunction = "sendRequest";
      }
    }

    @Override
    public void run() {
      try {
        Map<String, Object> params = new HashMap<>();
        params.put("type", mRequestType);
        params.put("objectId", mObject.getObjectId());
        Map<String, Object> result = ParseCloud.run(mFunction, params);
        XLog.i(TAG, "result: " + result);
        mListener.done(true);
      } catch (ParseException pe) {
        String doing = Util.format("sending %s type %s", mFunction, mRequestType.toString());
        handleException(doing, pe, null);
        mListener.done(false);
      } catch (Throwable t) {
        t.printStackTrace();
        mListener.done(false);
      }
    }

    public void complete(boolean success) {
      if (success) {
        XUser currentUser = XUser.getCurrentUser();
        switch (mRequestType) {
          case FriendRequest:
          case CellJoinCancel:
          case CellJoinReject:
          case CellJoinResend:
          case CellJoinRequest:
          case CellRecruitRequest:
          case FriendReject:
            showAlertDialog("message sent");
            break;
          case FriendApprove: {
            showAlertDialog("Friend Added");
            break;
          }
          case CellJoinApprove: {
            showAlertDialog("Cell Join Approved");
            break;
          }
        }
        mListener.done(true);
      } else {
        mListener.done(false);
      }
    }
  }
}


