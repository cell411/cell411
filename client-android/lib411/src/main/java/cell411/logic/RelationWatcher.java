package cell411.logic;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.parse.ParseCloud;
import com.parse.ParseException;
import com.parse.ParseQuery;
import com.parse.callback.FindCallback;
import com.parse.livequery.SubscriptionHandler;
import com.parse.model.ParseObject;
import com.parse.model.ParseRelation;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Observable;
import java.util.Set;

import cell411.base.BaseContext;
import cell411.json.JSON;
import cell411.json.JSONArray;
import cell411.json.JSONObject;
import cell411.parse.XBaseCell;
import cell411.parse.XPublicCell;
import cell411.parse.XRelationshipUpdate;
import cell411.parse.XUser;
import cell411.services.DataService;
import cell411.utils.Collect;
import cell411.utils.PrintString;
import cell411.utils.Reflect;
import cell411.utils.Timer;
import cell411.utils.Util;
import cell411.utils.XLog;
import okhttp3.internal.annotations.EverythingIsNonNull;

// The data is pretty minimal, but if we come up without
// net, we need it.
@SuppressWarnings("unused")
public class RelationWatcher
  extends CacheObject
  implements BaseContext {
  private static final String TAG = Reflect.getTag();

  static {
    XLog.i(TAG, "loading class");
  }

  private final RelMap mRelMap = new RelMap();
  private final UpdateWatcher mUpdateWatcher = new UpdateWatcher();
  private final Map<String, Date> mDates = new HashMap<>();
  private final HashSet<String> mBlocksWrite = new HashSet<>();
  private final Set<String> mAllBlocks = Collections.unmodifiableSet(mBlocksWrite);
  private final LiveQueryService mService;
  String fmt = "%20s %15s %15s %20s %6s %d";
  private JSONArray mJsonArray;

  public RelationWatcher(LiveQueryService service) {
    super("Relations");
    mService = service;
  }

  public void loadFromNet() {
    LiveQueryService service = lqs();
    Timer timer = service.getTimer();
    timer.add("loading from net");
    timer.add(" calling UpdateWatcher.loadFromNet");
    mUpdateWatcher.loadFromNet();
    timer.add("  UpdateWatcher.loadFromNet returned");
    Map<String, String> params = new HashMap<>();
    ArrayList<Object> rawResult = ParseCloud.run("relations", params);
    timer.add("  Got array of length %d", rawResult.size());
    mJsonArray = new JSONArray(rawResult);
    timer.add("  Converted to json array of length %d", mJsonArray.length());
    acceptData(mJsonArray);
    timer.add("  Data: %d rels, %d dates", mRelMap.size(), mDates.size());
    timer.add("load from net complete");
  }

  @Override
  public void saveToCache() {
    jsonToFile(mJsonArray);
  }

  public void prepare() {

  }

  void acceptData(JSONArray result) {
    Map<String, Date> dates = new HashMap<>();
    {
      JSONObject rawDates = result.getJSONObject(0);
      if (rawDates != null) {
        for (String key : rawDates.keySet()) {
          dates.put(String.valueOf(key), new Date(rawDates.getLong(key)));
        }
      }
    }
    RelMap mRelMap = new RelMap();

    for (int i = 1; i < result.length(); i++) {
      JSONArray list = result.getJSONArray(i);
      ArrayList<String> strings = new ArrayList<>(list.length());
      for (int j = 0; j < list.length(); j++) {
        strings.add(list.getString(j));
      }
      Iterator<String> iterator = strings.iterator();
      String className = iterator.next();
      String objectId = iterator.next();

      String name = iterator.next();
      boolean rev = Boolean.TRUE.equals(JSON.toBoolean(iterator.next()));
      String relClass = iterator.next();
      Rel rel = new Rel(className, objectId, name, rev, relClass, Collect.wrap(iterator));
      rel.setSource(strings);
      mRelMap.put(rel);
    }
    setData(mRelMap, dates);
  }

  public synchronized void setData(RelMap relMap, Map<String, Date> dates) {
    mRelMap.clear();
    mRelMap.putAll(relMap);
    mDates.clear();
    mDates.putAll(dates);
  }

  public Date getDate(String objectId) {
    return mDates.get(objectId);
  }

  public Rel getRel(String className, String id, String relation, String relatedClass) {
    return mRelMap.get(makeKey(className, id, relation, relatedClass));
  }

  public Rel getRel(ParseObject owner, String name, String relatedClass) {
    return getRel(owner.getClassName(), owner.getObjectId(), name, relatedClass);
  }

  private String makeKey(String className, String id, String relationship, String relatedClass) {
    byte[][] bytes = new byte[][]{
      className.getBytes(),
      new byte[]{' '},
      id.getBytes(),
      new byte[]{' '},
      relationship.getBytes(),
      new byte[]{' '},
      relatedClass.getBytes()
    };
    int length = 0;
    for (byte[] arr : bytes) {
      length += arr.length;
    }
    byte[] res = new byte[length];
    int p=0;
    for(byte[] arr : bytes) {
      for (byte b : arr)
        res[p++] = b;
    }
    return new String(res, 0, length);
  }

  public boolean hasDoneInitialQuery() {
    return mRelMap.size() > 0;
  }

  public Set<String> allBlocks() {
    return mAllBlocks;
  }

  public void getMembers(XBaseCell cell, FindCallback<XUser> callback) {
    ParseRelation<XUser> relation = cell.getRelation("members");
    ParseQuery<XUser> query = relation.getQuery();

    onDS(() -> {
      Runnable response;
      try {
        List<XUser> result = DataService.findFully(query);
        // FIXME:  pass object id to update service, once
        //  we have it back.
        response = () -> {
          callback.done(result, null);
        };
      } catch (ParseException pe) {
        response = () -> {
          callback.done(null, pe);
        };
      }
      onUI(response);
    });
  }

  public void removeCellMember(XPublicCell cell, XUser user) {
    lqs().later(() -> {
      ParseRelation<XUser> members = cell.getRelation("members");
      members.remove(user);
    });
  }

  public HashSet<String> getMemberIds(XBaseCell cell) {
    Rel rel = getRel(cell, "members", "_User");
    if (rel == null)
      return null;
    else
      return rel.getRelatedIds();
  }

  private String makeKey(XBaseCell cell, String members, String user) {
    return makeKey(cell.getClassName(), cell.getObjectId(),
      members, user);
  }

  public boolean isUserBlocked(XUser owner) {
    return isUserblocked(owner.getObjectId());
  }

  private boolean isUserblocked(String id) {
    return allBlocks().contains(id);
  }

  @Override
  public void clear() {

    mRelMap.clear();
    mDates.clear();
  }

  @Override
  public void loadFromCache() {
    clear();
    if(!cacheExists())
      return;
    JSONArray result = fileToJSON(JSONArray.class);
    acceptData(result);
  }

  @Override
  public void requestDataReport(PrintString ps) {
    ps.pl("Rel objects: %d", mRelMap.size());
    for (String key : mRelMap.keySet()) {
      Rel rel = mRelMap.get(key);
      if(rel!=null)
        rel.dump(ps);
      else
        ps.pl("null");
    }
    ps.pl();
  }

  public Rel getOrLoad(XPublicCell cell, String members, String user) {
    return mRelMap.getOrLoad(cell,members,user);
  }

  class RelMap extends HashMap<String, Rel> {
    public Rel put(Rel rel) {
      return put(rel.toString(), rel);
    }


    public Rel getOrLoad(XPublicCell cell, String members, String relClass) {
      String key = makeKey(cell,members,relClass);
      return computeIfAbsent(key, (xkey)->{
        ParseRelation<XUser> userRel = cell.getRelation(members);
        ParseQuery<XUser> userQuery = userRel.getQuery();
        List<XUser> users = DataService.findFully(userQuery);
        List<String> keys = Util.transform(users,ParseObject::getObjectId);
        return new Rel(cell, members, relClass, keys);
      });
    }
  }

  public interface RelListener {
    void update(Rel rel);
  }

  public class Rel extends Observable {
    final String mClassName;
    final String mId;
    final String mName;
    final String mRelClass;
    final boolean mRev;
    final Set<String> mRelated = new HashSet<>();
    List<String> mSource;

    private String getClassName() {
      return mClassName;
    }

    private String getObjectId() {
      return mId;
    }

    public List<String> getSource() {
      return mSource;
    }

    @EverythingIsNonNull
    public Rel(String className, String id, String name, boolean rev,
               String relClass, @Nullable Iterable<String> relatedIds) {
      mClassName = className;
      mId = id;
      mName = name;
      mRev = rev;
      mRelClass = relClass;
      if (relatedIds != null)
        Collect.addAll(mRelated, relatedIds);
    }
    @EverythingIsNonNull
    public Rel(ParseObject owner, String relation, String relClass,
               Iterable<String> ids) {
      this(owner.getClassName(), owner.getObjectId(), relation, false, relClass,
        ids);
    }
    public void dump(PrintString ps) {
      String line = Util.format(fmt, mClassName, mId, mName, mRelClass, mRev, mRelated.size());
      ps.pl(line);
    }

    public HashSet<String> getRelatedIds() {
      return getRelatedIds(new HashSet<>());
    }


    public <C extends Collection<String>> C getRelatedIds(C ids) {
      ids.addAll(mRelated);
      return ids;
    }

//    public boolean setRelatedIds(HashSet<String> newIds) {
//      boolean changes = mRelated.removeIf((id)->!newIds.contains(id));
//      if(mRelated.addAll(newIds))
//        changes=true;
//      if(changes)
//        setChanged();
//      return changes;
//    }
    @Override
    public int hashCode() {
      return toString().hashCode();
    }

    @NonNull
    @Override
    public String toString() {
      return makeKey(getClassName(), getObjectId(), mName, mRelClass);
    }
    void setSource(List<String> source) {
      mSource=new ArrayList<>(source);
    }

    public void setRelatedIds(HashSet<String> ids) {
      HashSet<String> added = new HashSet<>(ids);
      added.removeAll(mRelated);
      HashSet<String> removed = new HashSet<>(mRelated);
      removed.removeAll(ids);
      if(added.isEmpty() && removed.isEmpty()) {
        return;
      }
      mRelated.clear();
      mRelated.addAll(ids);
      mService.later(()->{
        ParseObject owner = DataService.get().getObject(mId);
        ParseRelation<ParseObject> relation = owner.getRelation(mName);
        ParseQuery<ParseObject> query = relation.getQuery();
        List<ParseObject> list = DataService.findFully(query);
        for(int i = 0;i <list.size();i++) {
          ParseObject object = list.get(i);
          if(!ids.contains(object.getObjectId())) {
            relation.remove(object);
          }
        }
        for(String id : ids) {
          ParseObject parseObject = DataService.get().getObject(id);
          relation.add(parseObject);
        }
        owner.save();

      });
    }
  }

  static class UpdateWatcher extends Watcher<XRelationshipUpdate> {
    private final String TAG = Reflect.getTag();

    public UpdateWatcher() {
      super("RelationshipUpdates", XRelationshipUpdate.class);
    }

    @Override
    public boolean runInitialQuery() {
      return false;
    }

    @Override
    public void saveToCache() {
    }

    @Override
    public void loadFromCache() {
    }


    @Override
    public ParseQuery<XRelationshipUpdate> query() {
      XUser currentUser = XUser.getCurrentUser();
      ParseQuery<XRelationshipUpdate> q1 = XRelationshipUpdate.q();
      ParseQuery<XRelationshipUpdate> q2 = XRelationshipUpdate.q();
      q1.whereEqualTo("owningId", currentUser.getObjectId());
      q2.whereEqualTo("relatedId", currentUser.getObjectId());
      return ParseQuery.or(q1, q2);
    }

    @Override
    void greetObject(XRelationshipUpdate update, ArrayList<ParseObject> list) {
      super.greetObject(update, list);
      XLog.i(TAG, "Class: %s ObjectId: %s", update.getClassName(), update.getObjectId());
      String owningId = update.getString("owningId");
      String relatedId = update.getString("relatedId");
      String owningClass = update.getString("owningClass");
      String relatedClass = update.getString("relatedClass");
      String owningField = update.getString("owningField");
      Rel rel = lqs().getRelationWatcher().getRel(
        owningClass, owningId, owningField, relatedClass
      );
      HashSet<String> relatedIds = rel.getRelatedIds();
      String op = update.getString("op");
      if(op==null)
        return;
      if(op.equals("AddRelation")) {
        relatedIds.add(relatedId);
      } else if (op.equals("RemoveRelation")) {
        relatedIds.remove(relatedId);
      } else {
        showToast("Idk what "+op+" means");
      }
    }

    @Override
    void onEvents(ParseQuery<XRelationshipUpdate> query, SubscriptionHandler.Event event, XRelationshipUpdate object) {
      super.onEvents(query, event, object);
    }

    private boolean equal(final String lhs, final String rhs) {
      return lhs != null && lhs.equals(rhs);
    }
  }
}
