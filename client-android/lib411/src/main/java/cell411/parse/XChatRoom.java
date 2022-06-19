package cell411.parse;

import com.parse.ParseClassName;
import com.parse.ParseQuery;

import java.util.Date;
import java.util.TreeSet;

;import cell411.base.BaseContext;

@ParseClassName("ChatRoom")
public class XChatRoom extends XObject {
  static BaseContext app = new BaseContext() {};

  TreeSet<XChatMsg> mMsgs = new TreeSet<>();

  public XChatRoom() {
    super();
  }

  public static ParseQuery<XChatRoom> q() {
    return ParseQuery.getQuery((XChatRoom.class));
  }

  public static XChatRoom fakeChatRoom() {
    XPublicCell cell = XPublicCell.fakePublicCell();
    XChatRoom chatRoom = create(XChatRoom.class);

    app.ds().setEntity(chatRoom, cell);
    return chatRoom;
  }

  public String getName() {
    String name = getString("name");
    if (name != null) {
      return name;
    }
    name = "ChatRoom #" + hashCode();
    setName(name);
    saveInBackground();
    return getName();
  }

  private void setName(String name) {
    put("name", name);
  }

  public Date getLastMsgTime() {
    if (mMsgs.isEmpty()) {
      return getCreatedAt();
    } else {
      return mMsgs.last()
                  .getCreatedAt();
    }
  }

  public XEntity getEntity() {

    return ds().getEntity(this);
  }
}
