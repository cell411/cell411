package cell411.parse;

import com.parse.ParseClassName;
import com.parse.ParseQuery;

import cell411.utils.XLog;

@ParseClassName("Response")
public class XResponse extends XObject {
  public static final String TAG = "Response";

  public XResponse() {
    XLog.i(TAG, "Instance Created");
  }

  public static ParseQuery<XResponse> q() {
    return ParseQuery.getQuery(XResponse.class);
  }

  public XAlert getAlert() {
    return (XAlert) getParseObject("alert");
  }

  public String getNote() {
    String note = getString("note");
    if (note == null) {
      return "";
    } else {
      return note;
    }
  }

  public void setNote(String note) {
    put("note", note);
  }

  public String getTravelTime() {
    return getString("travelTime");
  }

  public void setTravelTime(String time) {
    put("travelTime", time);
  }

  public XUser getForwardedBy() {
    return (XUser) getParseUser("forwardedBy");
  }

  public void setForwardedBy(XUser forwardedBy) {
    put("forwardedBy",forwardedBy);
  }

  public void setSeen() {
    put("seen", true);
  }
}

