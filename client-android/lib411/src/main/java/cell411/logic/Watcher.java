package cell411.logic;

import androidx.annotation.CallSuper;
import androidx.annotation.NonNull;

import com.parse.ParseCloud;
import com.parse.ParseException;
import com.parse.ParseQuery;
import com.parse.http.ParseSyncUtils;
import com.parse.livequery.SubscriptionHandler.Event;
import com.parse.model.ParseObject;
import com.parse.model.ParseRelation;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;

import cell411.base.BaseApp;
import cell411.base.BaseContext;
import cell411.parse.XBaseCell;
import cell411.parse.XPublicCell;
import cell411.parse.XUser;
import cell411.utils.PrintString;
import cell411.utils.Reflect;
import cell411.utils.Timer;
import cell411.utils.Util;
import cell411.utils.XLog;

public abstract class Watcher<X extends ParseObject>
  extends CacheObject
  implements BaseContext
{
  final private static String TAG = Reflect.getTag();
  static {
    XLog.i(TAG, "loading class");
  }
  final protected ArrayList<LQListener<X>> mListeners = new ArrayList<>();
  final protected Map<String, X> mData = new HashMap<>();
  final protected Class<X> mType;
  final protected ArrayList<ParseObject> mExtras = new ArrayList<>();
  protected ParseQuery<X> mQuery;
  volatile protected Date mLastBatch;

  Watcher(String name, Class<X> type) {
    super(name);
    mType = type;
  }

  public void prepare() {

  }
  public void addListener(LQListener<X> listener) {
    removeListener(listener);
    mListeners.add(listener);
    listener.change(this);
  }

  public void removeListener(final LQListener<X> listener) {
    while(mListeners.contains(listener))
      mListeners.remove(listener);
  }


//  @CallSuper
//  public void run() {
//    assert lqs().isCurrentThread();
//    if(!BaseApp.get().isConnected()) {
//      return;
//    }
//    boolean fresh = (mLastBatch == null);
//    ParseQuery<X> query = query();
//    if (query == null)
//      return;
//    lqs().subscribe(query, this::onEvents);
//    try {
//      if (fresh) {
//        load(query);
//      } else {
//        update(query);
//      }
//      if(mLastBatch == null) {
//        mLastBatch= new Date();
//      }
//      ArrayList<ParseObject> list = new ArrayList<>();
//        for (X x : mData.values()) {
//          greetObject(x, list);
//        }
//      done();
//      saveCache();
//    } catch (ParseException pe) {
//      lqs().handleException("Running Query", pe);
//      done(pe);
//    } catch (Exception pe) {
//      lqs().handleException("Running Query", pe);
//      done(new ParseException(ParseException.OTHER_CAUSE, "Exception", pe));
//    }
//  }

  @Override
  public void saveToCache() {
    getTimer().add("%s starting saveCache (%d)", getName(), mData.size());
    getCoder().saveData(getCacheFile(), mData, mExtras, mLastBatch);
    getTimer().add("%s finished saveCache (%d)", getName(), mData.size());
  }

  @Override
  public void requestDataReport(PrintString ps) {
    ps.p("Name: ").pl(getName());
    for(String key : mData.keySet()) {
      ps.p("  id: ").pl(key);
    }
    ps.pl();
  }

  public void loadFromCache() {
    getTimer().add("%s starting loadCache (%d)", getName(), mData.size());
    if(!cacheExists()) {
      getTimer().add("  ... %s ... cacheFile does not exist", getName());
      return;
    }
    final Map<String, X> data = new HashMap<>();
    getData(data);
    HashMap<String,ParseObject> extras = new HashMap<>();
    String text = fileToString();
    mLastBatch = getCoder().loadData(text, data, extras);
    getTimer().add("%s finished loadCache (%d)", getName(), mData.size());
    mData.clear();
    mData.putAll(data);
  }

  // We want to make sure that we synchronize access to the
  // data.  We copy it in a synchronized method before we let anyboty
  // else touch it.  To get data in, you pass your data into a 
  // synchronized method, and we copy it again.
  public synchronized void setData(HashMap<String,X> data) {
    mData.clear();
    mData.putAll(data);
  }
  public synchronized void getData(Map<String,X> data) {
    data.clear();
    data.putAll(mData);
  }
  public synchronized List<X> getData() {
    return new ArrayList<>(mData.values());
  }
  public boolean runInitialQuery() {
    return true;
  }
  public void loadFromNet() {
    Date batchDate = new Date();
    LiveQueryService lqs = lqs();
    Timer timer = lqs.getTimer();
    ParseQuery<X> query = query();
    if(query!=null) {
      lqs().subscribe(query, this::onEvents);
    }
    if(query!=null && runInitialQuery()) {
      timer.add("%s starting load (%d)", getName(), mData.size());
      int count = 0;
      List<X> batch;

      do {
        query.setSkip(count);
        batch = query.find();

        count += batch.size();
        for (X x : batch)
          mData.put(x.getObjectId(), x);

      } while (batch.size() != 0);

      timer.add("%s finished load (%d)", getName(), mData.size());
      timer.add("  greeting objects");
    }
    ArrayList<ParseObject> list = new ArrayList<>();
    for(X x : mData.values()) {
      greetObject(x, list);
    }
    mLastBatch=batchDate;
    timer.add("list has %d objects", list.size());
  }

  protected void checkIn(final ArrayList<ParseObject> parseObjects, final ParseObject parseObject) {
    if (parseObject == null)
      return;
    parseObject.fetchIfNeeded();
    parseObjects.add(parseObject);
  }

  protected abstract ParseQuery<X> query();

  @CallSuper
  void greetObject(X po, ArrayList<ParseObject> list) {
    if (po != null)
      po.fetchIfNeeded();
    if(po instanceof XBaseCell) {
      XBaseCell cell = (XBaseCell) po;
      XUser owner = cell.getOwner();
      owner.fetchIfNeeded();
//      ParseRelation<XUser> memberR = cell.getRelation("members");
//      ParseQuery<XUser> memberQ = memberR.getQuery();
//      List<XUser> users = memberQ.find();
//      List<String> ids = Util.transform(users, XUser::getObjectId);
//      RelationWatcher watcher = lqs().getRelationWatcher();
//      RelationWatcher.Rel rel = watcher.getRel(cell,"members","_User");
//      rel.setRelatedIds(new HashSet<>(ids));
    }
  }

  void onEvents(ParseQuery<X> query, Event event, X object) {
    XLog.i(TAG, "Event for query: %s", query);
    XLog.i(TAG, "          event: %s", event);
    XLog.i(TAG, "         object: %s", object);

    lqs().later(() -> {
      ArrayList<ParseObject> needs = new ArrayList<>();
      synchronized(mData) {
        switch (event) {
          case CREATE:
          case ENTER:
          case UPDATE:
            greetObject(object, needs);
            mData.put(object.getObjectId(), object);
            break;
          case LEAVE:
          case DELETE:
            mData.remove(object.getObjectId());
            break;
        }
      }

      onUI(() -> {
        ArrayList<LQListener<X>> listeners = new ArrayList<>(mListeners);
        while(listeners.contains(null))
          listeners.remove(null);
        for (LQListener<X> listener : listeners) {
          listener.onEvents(this, event, object);
        }
        lqs().later(()->{
          saveToCache();
        });
      });
    });
  }


  void done(ParseException e) {
    if (mListeners.isEmpty())
      return;
    final ArrayList<LQListener<X>> listeners = new ArrayList<>(mListeners);
    listeners.remove(null);
    Runnable run = () -> {
      for (LQListener<X> listener : listeners) {
        listener.done(this, e);
      }
    };
    if(BaseApp.isUIThread()) {
      run.run();
    } else {
      onUI(run);
    }
  }

  public int size() {
    return mData.size();
  }

  @NonNull
  public String toString() {
    return Util.format("Watcher{name=%s,items=%s}", getName(),size());
  }

  public void clear() {
    mData.clear();
  }
}
