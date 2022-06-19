package cell411.parse;

import androidx.annotation.Nullable;

import com.parse.ParseClassName;
import com.parse.ParseQuery;
import com.parse.model.ParseGeoPoint;

import java.net.URL;

import cell411.enums.EntityType;
import cell411.enums.ProblemType;
import cell411.utils.NetUtils;
import cell411.utils.Util;

@ParseClassName("Alert")
public class XAlert extends XEntity {
  private String mFormatCreatedAt;

  public static ParseQuery<XAlert> q() {
    return ParseQuery.getQuery(XAlert.class);
  }

  public static XAlert fakeAlert() {
    XAlert alert = create(XAlert.class);
    XUser user = XUser.fakeUser();
    alert.setOwner(user);
    alert.setProblemType(ProblemType.Arrested);
    return alert;
  }

  public URL getPhoto() {
    return NetUtils.toURL(getString("photoDownloadURL"));
  }

  public URL getVideoLink() {
    return NetUtils.toURL(getString("videoDownloadURL"));
  }

  public URL getVideoStreamLink() {
    return NetUtils.toURL(getString("videoStreamURL"));
  }

  public XUser getForwardedBy() {
    return (XUser) getParseUser("forwardedBy");
  }

  public ProblemType getProblemType() {
    return ProblemType.fromString(getString("problemType"));
  }

  public void setProblemType(final ProblemType arrested) {
    if (arrested == null)
      remove("problemType");
    else {
      String value = arrested.toString();
      value=String.valueOf(ProblemType.fromString(value));
      put("problemType", value);
    }
  }

  @Nullable
  public String getNote() {
    return getString("note");
  }

  @Nullable
  public String getFormatCreatedAt() {
    if (mFormatCreatedAt == null) {
      mFormatCreatedAt = Util.formatDateTime(getCreatedAt());
    }
    return mFormatCreatedAt;
  }

  public String getStatus() {
    return getString("status");
  }

  public ParseGeoPoint getLocation() {
    return getParseGeoPoint("location");
  }


  public boolean isSelfAlert() {
    XUser owner = getOwner();
    if(owner==null)
      return false;
    XUser currentUser = XUser.getCurrentUser();
    if(currentUser==null)
      return false;
    return owner.hasSameId(currentUser);
  }

  public boolean isGlobal() {
    return getBoolean("isGlobal");
  }


  @Override
  public EntityType getType() {
    return EntityType.ALERT;
  }

  @Override
  public String getEntityName() {
    return "Chat for " + getProblemType() + " alert from " + getOwner().getName();
  }


}

