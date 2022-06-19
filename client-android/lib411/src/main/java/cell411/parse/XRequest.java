package cell411.parse;

import cell411.enums.RequestType;
import cell411.utils.XLog;
import com.parse.ParseClassName;
import com.parse.ParseQuery;


@ParseClassName("Request")
public class XRequest extends XObject {
  public static ParseQuery<XRequest> q() {
    return ParseQuery.getQuery(XRequest.class);
  }

  public static XRequest fakeRequest() {
    XUser user = XUser.fakeUser();
    XRequest request = create(XRequest.class);
    request.setOwner(user);
    request.setSentTo(XUser.getCurrentUser());
    return request;
  }

  public boolean isFriendRequest() {
    return getCell()==null;
  }

  public boolean isCellRequest() {
    return getCell() != null;
  }

  public String getStatus() {
    return getString("status");
  }

  public void setStatus(String status)
  {
    put("status", status);
  }

  public boolean isSelfAlert() {
    return getOwner().equals(XUser.getCurrentUser());
  }

  public XUser getSentTo() {
    return (XUser) getParseUser("sentTo");
  }

  public void setSentTo(XUser user) {
    put("sentTo", user);
  }

  public XPublicCell getCell() {
    return (XPublicCell) getParseObject("cell");
  }

  public RequestType getType() {
    return RequestType.valueOf(getString("type"));
  }

}

