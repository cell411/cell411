package cell411.parse;

import com.parse.codec.ParseDecoder;
import com.parse.model.ParseObject;

import cell411.json.JSONObject;
import cell411.services.DataService;
import cell411.utils.Reflect;
import cell411.utils.XLog;

// This implements the general IObject interface, and adds the one
// this which all objects except users have:  an owner.
//
// Users own themselves.

public abstract class XObject extends ParseObject implements IObject {
  private final static String      TAG = Reflect.getTag();
  protected static XUser smCurrentUser = XCurrentUser.get().getUser();

  public XObject() {
    XLog.i(TAG, getClass().getSimpleName() + " created.");
  }


  Boolean mOwnedByCurrent;
  public boolean ownedByCurrent() {
    if(mOwnedByCurrent==null) {
      XUser mOwner=getOwner();
      if(mOwner==null)
        return false;
      mOwnedByCurrent = mOwner.hasSameId(smCurrentUser);
    }
    return mOwnedByCurrent;
  }
  public final XUser getOwner() {
    return (XUser) getParseUser("owner");
  }

  public final void setOwner(XUser user) {
    put("owner", user);
  }

  public final boolean equals(Object o) {
    if (this == o) {
      return true;
    }
    if (o instanceof XObject) {
      return getObjectId().equals(((XObject) o).getObjectId());
    } else if (o instanceof String) {
      return getObjectId().equals(o);
    } else {
      return false;
    }
  }
}