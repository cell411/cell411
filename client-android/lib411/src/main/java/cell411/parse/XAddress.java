package cell411.parse;

import android.location.Location;

import cell411.utils.Util;

import java.util.Arrays;
import java.util.List;

public class XAddress extends XCity {
  public final String   mAddress;

  public XAddress(String country, String state, String city, String address, Location location) {
    super(country,state,city,location);
    mAddress = address;
  }

  public XAddress() {
    this(null, null, null, null, null);
  }

  public String toString() {
    String res = super.cityPlus();
    if(Util.isNoE(res)) {
      return mAddress;
    } else if (Util.isNoE(mAddress)) {
      return res;
    } else {
      List<String> list = Arrays.asList(res, mAddress);
      String       joined  = Util.join(", ", list);
      return joined;
    }
  }
}
