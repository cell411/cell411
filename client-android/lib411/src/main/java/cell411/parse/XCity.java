package cell411.parse;

import android.location.Location;

import cell411.utils.Util;

import java.util.ArrayList;

public class XCity {
  public final String   mCountry;
  public final String   mState;
  public final String   mCity;
  public final Location mLocation;

  public XCity(String country, String state, String city, Location location) {
    mCountry = country;
    mState = state;
    mCity = city;
    mLocation = location;
  }

  public XCity() {
    this(null, null, null, null);
  }

  public String cityPlus() {
    ArrayList<String> parts = new ArrayList<>();
    if(mCity!=null)
      parts.add(mCity);
    if(mState!=null)
      parts.add(mState);
    if(mCountry!=null)
      parts.add(mCountry);
    return Util.join(", ", parts);
    //    return Util.join(", ", Util.filter((String string)->{return !Util.isNoE(string);},
//                                       Arrays.asList(mCity,mState,mCountry)
//                                       ));
  }
  static {
    XCity[] cities = new XCity[] {
      new XCity(null,null,null, null),
      new XCity("country",null,null,null),
      new XCity(null,"state",null,null),
      new XCity(null,null,"city",null),
      new XCity("country","state",null,null),
      new XCity("country",null,"city",null),
      new XCity("country","state","city",null)
    };
    String[] text = new String[] {
      "",
      "country",
      "state",
      "city",
      "state, country",
      "city, country",
      "city, state, country"
    };
    for(int i=0;i< cities.length;i++) {
      String cities_i=null,text_i=null;
      try {
        cities_i = cities[i].cityPlus();
        text_i = text[i];
        assert(cities_i.equals(text_i));
      } catch ( Throwable t ) {
        t.printStackTrace();
        System.out.println(cities[i]);
        System.out.println(text[i]);
        System.out.println(i);
        System.out.println(cities_i);
        System.out.println(text_i);
      }
    }
  }
}
