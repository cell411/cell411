package cell411.logic;

import androidx.annotation.CallSuper;

import com.parse.ParseQuery;
import com.parse.model.ParseObject;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashSet;
import java.util.Iterator;

import cell411.parse.XUser;
import cell411.utils.Timer;

public class FriendWatcher extends Watcher<XUser> {

  public FriendWatcher() {
    super("friends", XUser.class);
  }

  @Override
  public ParseQuery<XUser> query() {
    Timer timer = lqs().getTimer();
    timer.add("generating query for %s",getName());
    RelationWatcher watcher = lqs().getRelationWatcher();
    if (!watcher.hasDoneInitialQuery()) {
      timer.add("aborting:  Relations not ready");
      return null;
    }
    RelationWatcher.Rel rel = watcher.getRel(XUser.getCurrentUser(),
      "friends", "_User");
    HashSet<String> oldIds = new HashSet<>(mData.keySet());
    timer.add("  old friend count: %d", oldIds.size());
    HashSet<String> ids = new HashSet<>(rel.getRelatedIds());
    timer.add("  new friend count: %d", ids.size());
    oldIds.removeAll(ids);
    timer.add("  %d oldIds no longer in set", oldIds.size());
    for(String id : oldIds) {
      mData.remove(id);
    }
    timer.add("  %d oldIds removed",oldIds.size());
    timer.add("  %d friends remain", mData.size());
    Iterator<String> it = ids.iterator();
    while (it.hasNext()) {
      String id = it.next();
      XUser friend = mData.get(id);
      if (friend == null) {
        timer.add("  No value for id %s, need update", id);
      } else {
        Date updated = friend.getUpdatedAt();
        Date current = watcher.getDate(id);
        if (updated.equals(current)) {
          timer.add("  friend %s is up to date", friend.getName());
          it.remove();
        } else {
          timer.add("  friend %s needs freshening", friend.getName());
        }
      }
    }
    timer.add("  %d updates needed", ids.size());
    ParseQuery<XUser> query = XUser.q();
    query.whereContainedIn("objectId", rel.getRelatedIds());
    timer.add("Query generated");
    if(ids.size()==0) {
      timer.add("  no updates needed, returning null");
    }
    return query;
  }

  @CallSuper
  @Override
  void greetObject(XUser po, ArrayList<ParseObject> list) {
    super.greetObject(po, list);
    po.getAvatarPic(null);
    po.getThumbNailPic(null);
  }
}
