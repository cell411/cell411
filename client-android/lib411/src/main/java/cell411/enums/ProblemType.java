package cell411.enums;

import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

public enum ProblemType {
  UN_RECOGNIZED,
  BrokenCar,
  Bullied,
  Crime,
  General,
  PulledOver,
  Danger,
  Video,
  Photo,
  Fire,
  Medical,
  CopBlocking,
  Arrested,
  Hijack,
  Panic,
  Trapped,
  CarAccident,
  NaturalDisaster,
  PhysicalAbuse;
  public static final String TAG = ProblemType.class.getSimpleName();
  static Map<String,ProblemType> smMap = new HashMap<>();
  static {
    ProblemType[] vals = values();
    for (final ProblemType val : vals) {
      smMap.put(val.toString(), val);
    }
  }
  public static void setMap(Map<String, ProblemType> map) {
    smMap.putAll(map);
  }
  public static ProblemType fromString(String key) {
    if(key==null)
      return null;
    key=clean(key);
    return smMap.get(key);
  }
  public static String clean(String key) {
    key = key.toLowerCase();
    key = key.trim();
    key = String.join("", key.split("\\?"));
    key = String.join("", key.split("-"));
    key = String.join("", key.split("_"));
    key = String.join("", key.split(" "));
    return key;
  }

  static {
    try {
      Class.forName("cell411.ui.alerts.ProblemTypeInfo");
    } catch ( Exception ignored ) {

    }
  }
}
