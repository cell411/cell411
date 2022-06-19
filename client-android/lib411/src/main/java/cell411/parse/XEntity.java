package cell411.parse;

import cell411.services.DataService;
import com.parse.codec.ParseDecoder;

import cell411.json.JSONObject;

import cell411.enums.EntityType;

public abstract class XEntity extends XObject {
  public abstract EntityType getType();

  public XChatRoom getChatRoom() {
    return (XChatRoom) getParseObject("chatRoom");
  }

  public void setChatRoom(XChatRoom chatRoom) {
    put("chatRoom", chatRoom);
  }

  @Override
  public State mergeFromServer(State state, JSONObject json, ParseDecoder decoder, boolean completeData) {
    State res = super.mergeFromServer(state, json, decoder, completeData);
    Object chatRoom = res.get("chatRoom");
    if(chatRoom instanceof XChatRoom)
      ds().setEntity((XChatRoom) chatRoom, this);
    return res;
  }

  abstract public String getEntityName();
}
