package cell411.logic;

import androidx.annotation.CallSuper;

import com.parse.ParseQuery;
import com.parse.model.ParseObject;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.Iterator;

import cell411.base.BaseActivity;
import cell411.enums.CellStatus;
import cell411.parse.XBaseCell;
import cell411.parse.XChatRoom;
import cell411.parse.XUser;
import cell411.utils.Timer;
import cell411.utils.XLog;

public class CellWatcher<X extends XBaseCell>
  extends Watcher<X>
{
  public BaseActivity activity(){
    return app().activity();
  }
  public CellWatcher(LiveQueryService service, Class<X> type) {
    super("CellWatcher("+type.getSimpleName()+")", type);
  }


  @Override
  protected ParseQuery<X> query() {
    Timer timer = lqs().getTimer();
    ParseQuery<X> query = ParseQuery.getQuery(mType);
    RelationWatcher watcher = lqs().getRelationWatcher();
    XUser user = XUser.getCurrentUser();
    RelationWatcher.Rel owned = watcher.getRel(user, "ownerOf",
      query.getClassName());
    RelationWatcher.Rel joined = watcher.getRel(user, "memberOf", "PublicCell");
    HashSet<String> needed = new HashSet<>();

    HashSet<String> ownedIds = owned.getRelatedIds();
    timer.add("  owned contains %d cells", ownedIds.size());
    needed.addAll(ownedIds);
    HashSet<String> joinedIds = joined.getRelatedIds();
    needed.addAll(joinedIds);
    timer.add("  joined contains %d cells", joinedIds.size());
    HashSet<String> current = new HashSet<>(mData.keySet());
    timer.add("  Current has %d cells", current.size());
    current.removeAll(needed);
    timer.add("  Of while %d are unneded", current.size());
    for(String id : current) {
      mData.remove(id);
    }
    timer.add("  extra cells removed");
    Iterator<String> it = needed.iterator();
    while(it.hasNext()) {
      String id = it.next();
      XBaseCell cell = mData.get(id);
      if(cell!=null && cell.getUpdatedAt().equals(watcher.getDate(id)))
        it.remove();
    }
    timer.add("  updates needed for %d cells", needed.size());
    if(needed.isEmpty()) {
      timer.add("returning null");
      return null;
    } else {
      query.whereContainedIn("objectId", needed);
      return query;
    }
  }

  @CallSuper
  @Override
  void greetObject(X po, ArrayList<ParseObject> list) {
    super.greetObject(po, list);
    if(po.ownedByCurrent()) {
      po.setStatus(CellStatus.OWNER);
    } else {
      po.setStatus(CellStatus.JOINED);
    }
  }

}
