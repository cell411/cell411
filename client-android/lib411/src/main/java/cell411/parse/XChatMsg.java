package cell411.parse;

import android.graphics.drawable.Drawable;
import android.graphics.drawable.DrawableWrapper;
import cell411.services.DataService;
import cell411.services.R;
import com.parse.ParseClassName;
import com.parse.ParseQuery;
import com.parse.model.ParseFile;
import com.parse.model.ParseGeoPoint;


import cell411.utils.Util;

@ParseClassName("ChatMsg")
public class XChatMsg extends XObject {
  public static ParseQuery<XChatMsg> q() {
    return ParseQuery.getQuery(XChatMsg.class);
  }

  public static XChatMsg fakeChatMsg() {
    XChatMsg msg = create(XChatMsg.class);
    XChatRoom chatRoom = XChatRoom.fakeChatRoom();
    msg.setChatRoom(chatRoom);
    XUser owner = XUser.fakeUser();
    msg.setOwner(owner);
    msg.setText("Hey, bro, I made a million bucks off bitcoin, want to go to Mexico?");

    return msg;
  }

  public XChatRoom getChatRoom() {
    return (XChatRoom) getParseObject("chatRoom");
  }

  public void setChatRoom(XChatRoom chatRoom) {
    put("chatRoom", chatRoom);
  }

  public String getText() {
    return getString("text");
  }

  public void setText(String text) {
    if (Util.isNoE(text)) {
      remove("text");
    } else {
      put("text", text);
    }
  }

  public ParseGeoPoint getLocation() {
    return getParseGeoPoint("location");
  }

  public void setLocation(ParseGeoPoint location) {
    if (location == null) {
      remove("location");
    } else {
      put("location", location);
    }
  }
  public Drawable getBitmap() {

    Drawable drawable = ds().getDrawable(R.drawable.ic_placeholder_user);
    return new DrawableWrapper(drawable){

    };
  }
  public ParseFile getImage() {
    return getParseFile("image");
  }
  public void setImage(ParseFile parseFile) {
    put("image", parseFile);
  }
}
