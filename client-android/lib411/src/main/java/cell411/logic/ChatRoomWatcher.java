package cell411.logic;

import com.parse.ParseQuery;

import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import cell411.parse.XChatRoom;

public class ChatRoomWatcher extends Watcher<XChatRoom> {
  private final Map<String,Set<String>> mChatRoomSources = new HashMap<>();
  private final Set<String> mChatRoomIds = new HashSet<>();

  public void setEntities(String name, Collection<String> ids) {
//    mChatRoomSources.put(name, new HashSet<>(ids));
//    mChatRoomIds.clear();
//    for(Set<String> set : mChatRoomSources.values()) {
//      for(String val : set) {
//        if(val!=null)
//          mChatRoomIds.add(val);
//      }
//    }
////    if(mChatRoomIds.size()>0 || !mData.isEmpty())
//      lqs().runMeLast(this);
  }


  ChatRoomWatcher(final LiveQueryService service) {
    super("ChatRooms", XChatRoom.class);
  }

  @Override
  protected ParseQuery<XChatRoom> query() {
    if(mChatRoomIds.isEmpty())
      return null;
    ParseQuery<XChatRoom> query = XChatRoom.q();
    query.whereContainedIn("objectId", mChatRoomIds);
    return query;
  }
}
