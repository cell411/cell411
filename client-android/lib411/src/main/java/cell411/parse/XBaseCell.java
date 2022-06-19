package cell411.parse;

import java.util.HashSet;

import cell411.base.BaseApp;
import cell411.logic.LiveQueryService;
import cell411.enums.CellStatus;

public abstract class XBaseCell extends XEntity {
  CellStatus mStatus = CellStatus.INITIALIZING;
  // if the member list is null, we do not know if we have
  // members or not.  When we load the list, it will be here,
  // even if it is empty, so we know it has been loaded.

  final public String getName() {
    return getString("name");
  }

  final public void setName(String name) {
    put("name", name);
  }

  final public CellStatus getStatus() {
    return mStatus;
  }

  final public void setStatus(CellStatus status) {
    mStatus = status;
  }

  final public synchronized HashSet<String> getMemberIds() {
    LiveQueryService lqs = BaseApp.get().lqs();
    return lqs.getRelationWatcher().getMemberIds(this);
  }
//  final public synchronized void setMemberIds(HashSet<String> memberIds) {
//    LiveQueryService lqs = BaseApp.get().lqs();
//    lqs.setMemberIds(this, memberIds);
//  }

  public int nameCompare(XBaseCell other) {
    return getName().compareTo(other.getName());
  }

}

