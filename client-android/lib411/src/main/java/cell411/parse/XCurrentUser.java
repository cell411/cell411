package cell411.parse;

import com.parse.model.ParseUser;

public class XCurrentUser {
  private static XCurrentUser smInstance;
  public static XCurrentUser get() {
    if(smInstance==null)
      smInstance=new XCurrentUser();
    return smInstance;
  }
  public static void clear() {
    smInstance=null;
  }
  XUser mUser;
  public XUser getUser() {
    if(mUser==null)
      mUser=(XUser) ParseUser.getCurrentUser();
    return mUser;
  }
}
