package cell411.parse;

import com.parse.ParseClassName;

import cell411.utils.XLog;

@ParseClassName("PrivacyPolicy")
public class XPrivacyPolicy extends XObject {
  public static final String TAG = XPrivacyPolicy.class.getSimpleName();

  public XPrivacyPolicy()
  {
    XLog.i(TAG, "constructor");
  }

  public String getTOSUrl() {
    return getString("tosUrl");
  }

  public String getPPUrl() {
    return getString("ppUrl");
  }
}
