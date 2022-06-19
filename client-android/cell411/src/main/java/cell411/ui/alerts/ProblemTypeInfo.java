package cell411.ui.alerts;

import static com.safearx.cell411.R.color.alert_un_recognized;
import static com.safearx.cell411.R.drawable.bg_alert_un_recognized_icon;
import static cell411.enums.ProblemType.Arrested;
import static cell411.enums.ProblemType.BrokenCar;
import static cell411.enums.ProblemType.Bullied;
import static cell411.enums.ProblemType.CarAccident;
import static cell411.enums.ProblemType.CopBlocking;
import static cell411.enums.ProblemType.Crime;
import static cell411.enums.ProblemType.Danger;
import static cell411.enums.ProblemType.Fire;
import static cell411.enums.ProblemType.General;
import static cell411.enums.ProblemType.Hijack;
import static cell411.enums.ProblemType.Medical;
import static cell411.enums.ProblemType.NaturalDisaster;
import static cell411.enums.ProblemType.Panic;
import static cell411.enums.ProblemType.Photo;
import static cell411.enums.ProblemType.PhysicalAbuse;
import static cell411.enums.ProblemType.PulledOver;
import static cell411.enums.ProblemType.Trapped;
import static cell411.enums.ProblemType.UN_RECOGNIZED;
import static cell411.enums.ProblemType.Video;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.safearx.cell411.R;

import java.util.Locale;
import java.util.TreeMap;

import cell411.Cell411;
import cell411.enums.ProblemType;

public class ProblemTypeInfo {
  public static final String TAG = ProblemTypeInfo.class.getSimpleName();
  private static final Factory factory = new Factory();
  private static final TreeMap<String, ProblemTypeInfo> smReverseMapping = factory.reverseMapping;
  private static final ProblemTypeInfo[] smInfos = factory.infos;
  private static String[] smExtras;
  private final ProblemType mType;
  private final String mAlertKey;
  private final String mResString;
  private final String mAlertTitle;
  private final int mAlertHeadImage;
  private final int mAlertBGDrawable;
  private final int mAlertBackground;

  ProblemTypeInfo(ProblemType type, int resId, String alertKey, int alert_head_image,
                  int alert_bg_drawable,
                  int alert_background_pulled_over, int alertTitle) {

    mResString = getString(resId);
    mAlertKey = alertKey;
    mAlertBackground = getColorRes(alert_background_pulled_over);
    mAlertBGDrawable = alert_bg_drawable;
    mAlertTitle = getString(alertTitle);
    mAlertHeadImage = alert_head_image;
    mType = type;
  }

  static ProblemTypeInfo makeInfo(ProblemType pt) {
    switch (pt) {
      default:
      case UN_RECOGNIZED:
        return new ProblemTypeInfo(UN_RECOGNIZED, R.string.alert_un_recognized, "Unrecognized",
          R.drawable.alert_head_un_recognized, bg_alert_un_recognized_icon,
          R.color.alert_un_recognized, alert_un_recognized);
      case BrokenCar:
        return new ProblemTypeInfo(BrokenCar, R.string.alert_broken_car, "Vehicle Broken",
          R.drawable.alert_head_broken_car,
          R.drawable.bg_alert_broken_car_icon, R.color.alert_background_broken_car,
          R.string.send_vehicle_broken_alert);
      case Bullied:
        return new ProblemTypeInfo(Bullied, R.string.alert_bullied, "Bullied",
          R.drawable.alert_head_bullied,
          R.drawable.bg_alert_bullied_icon, R.color.alert_background_bullied,
          R.string.send_bullied_alert);
      case Crime:
        return new ProblemTypeInfo(Crime, R.string.alert_criminal, "Crime",
          R.drawable.alert_head_criminal,
          R.drawable.bg_alert_criminal_icon, R.color.alert_background_criminal,
          R.string.send_crime_alert);
      case General:
        return new ProblemTypeInfo(General, R.string.alert_general, "General",
          R.drawable.alert_head_general,
          R.drawable.bg_alert_general_icon, R.color.alert_background_general,
          R.string.send_general_alert);
      case PulledOver:
        return new ProblemTypeInfo(PulledOver, R.string.alert_pulled_over, "Vehicle Pulled",
          R.drawable.alert_head_pulled_over, R.drawable.bg_alert_pulled_over_icon,
          R.color.alert_background_pulled_over, R.string.send_vehicle_pulled_over_alert);
      case Danger:
        return new ProblemTypeInfo(Danger, R.string.alert_danger, "Danger",
          R.drawable.alert_head_danger,
          R.drawable.bg_alert_danger_icon, R.color.alert_background_danger,
          R.string.send_danger_alert);
      case Video:
        return new ProblemTypeInfo(Video, R.string.alert_video, "Video",
          R.drawable.alert_head_video,
          R.drawable.bg_alert_video_icon, R.color.alert_background_video,
          R.string.stream_and_share_live_video_with);
      case Photo:
        return new ProblemTypeInfo(Photo, R.string.alert_photo, "Photo",
          R.drawable.alert_head_photo,
          R.drawable.bg_alert_photo_icon, R.color.alert_background_photo,
          R.string.send_photo_alert);
      case Fire:
        return new ProblemTypeInfo(Fire, R.string.alert_fire, "Fire", R.drawable.alert_head_fire,
          R.drawable.bg_alert_fire_icon, R.color.alert_background_fire, R.string.send_fire_alert);
      case Medical:
        return new ProblemTypeInfo(Medical, R.string.alert_medical, "Medical",
          R.drawable.alert_head_medical,
          R.drawable.bg_alert_medical_icon, R.color.alert_background_medical,
          R.string.send_medical_attention_alert);
      case CopBlocking:
        return new ProblemTypeInfo(CopBlocking, R.string.alert_police_interaction, "Cop Blocking",
          R.drawable.alert_head_police_interaction, R.drawable.bg_alert_police_interaction_icon,
          R.color.alert_background_police_interaction, R.string.send_police_interaction_alert);
      case Arrested:
        return new ProblemTypeInfo(Arrested, R.string.alert_police_arrest, "Arrested",
          R.drawable.alert_head_police_arrest, R.drawable.bg_alert_police_arrest_icon,
          R.color.alert_background_police_arrest, R.string.send_arrested_alert);
      case Hijack:
        return new ProblemTypeInfo(Hijack, R.string.alert_hijack, "Hijack",
          R.drawable.alert_head_hijack,
          R.drawable.bg_alert_hijack_icon, R.color.alert_background_hijack,
          R.string.send_hijack_alert);
      case Panic:
        return new ProblemTypeInfo(Panic, R.string.alert_panic, "Panic",
          R.drawable.alert_head_panic,
          R.drawable.bg_alert_panic_icon, R.color.alert_panic, R.string.send_panic_alert);
      case Trapped:
        return new ProblemTypeInfo(Trapped, R.string.alert_trapped, "Trapped",
          R.drawable.alert_head_trapped,
          R.drawable.bg_alert_trapped_icon, R.color.alert_background_trapped,
          R.string.send_being_trapped_alert);
      case CarAccident:
        return new ProblemTypeInfo(CarAccident, R.string.alert_car_accident, "Car Accident",
          R.drawable.alert_head_car_accident, R.drawable.bg_alert_broken_car_icon,
          R.color.alert_background_car_accident, R.string.send_car_accident_alert);
      case NaturalDisaster:
        return new ProblemTypeInfo(NaturalDisaster, R.string.alert_natural_disaster,
          "Natural Disaster",
          R.drawable.alert_head_natural_disaster, R.drawable.bg_alert_natural_disaster_icon,
          R.color.alert_background_natural_disaster, R.string.send_natural_disaster_alert);
//      case PRE_AUTHORIZATION:
//        return new ProblemTypeInfo(PRE_AUTHORIZATION, R.string.alert_pre_authorisation, "Pre-Authorized",
//                                   R.drawable.alert_head_un_recognized, R.drawable.bg_alert_natural_disaster_icon,
//                                   R.color.alert_pre_authorisation, R.string.send_pre_authorisation_alert);
      case PhysicalAbuse:
        return new ProblemTypeInfo(PhysicalAbuse, R.string.alert_physical_abuse, "Physical Abuse",
          R.drawable.alert_head_physical_abuse, R.drawable.bg_alert_physical_abuse_icon,
          R.color.alert_background_physical_abuse, R.string.send_physical_abuse_alert);
//      case CUSTOM:
//        return new ProblemTypeInfo(CUSTOM, R.string.alert_custom, "Custom", R.drawable.alert_head_criminal,
//                                   R.drawable.bg_alert_police_arrest, R.color.alert_pre_authorisation,
//                                   R.string.alert_un_recognized);
    }
  }

  public static ProblemTypeInfo[] values() {
    return smInfos;
  }

  public static String lc(String str) {
    if(str==null)
      return null;
    else
      return str.toLowerCase(Locale.US);
  };
  public static ProblemTypeInfo fromString(@Nullable String key) {
    if (key == null)
      key = UN_RECOGNIZED.toString();
    ProblemTypeInfo info = smReverseMapping.get(lc(key));
    if (info == null)
      return smInfos[0];
    else
      return info;
  }

  public static ProblemTypeInfo valueOf(int idx) {
    if (idx >= 0 && idx < smInfos.length) {
      return smInfos[idx];
    } else {
      return smInfos[0];
    }
  }

  public static ProblemTypeInfo valueOf(ProblemType pt) {
    return valueOf(pt.ordinal());
  }

  static String getString(int resId) {
    return Cell411.getResString(resId);
  }

  static int getColorRes(int resId) {
    return Cell411.get()
      .getColorRes(resId);
  }

  public ProblemType getType() {
    return mType;
  }

  public String getTitle() {
    return mAlertTitle;
  }

  public int getBackgroundColor() {
    return mAlertBackground;
  }

  public int getBGDrawable() {
    return mAlertBGDrawable;
  }

  public int getImageRes() {
    return mAlertHeadImage;
  }

  @NonNull
  public String resString() {
    return mResString;
  }

  @NonNull
  public String alertKey() {
    return mAlertKey;
  }

  public String name() {
    return mType.name();
  }

  static class Factory {
    TreeMap<String, ProblemTypeInfo> reverseMapping;
    ProblemTypeInfo[] infos;

    Factory() {
      reverseMapping = createReverseMapping();
      assert (infos != null);
    }
    private TreeMap<String, ProblemTypeInfo> createReverseMapping() {
      ProblemType[] types = ProblemType.values();
      infos = new ProblemTypeInfo[types.length];
      TreeMap<String, ProblemTypeInfo> reverseMapping = new TreeMap<>();
      for (int i = 0; i < types.length; i++) {
        infos[i] = makeInfo(types[i]);
        
        put(reverseMapping,lc(types[i].toString()), infos[i]);
        put(reverseMapping,lc(infos[i].mAlertKey), infos[i]);
        put(reverseMapping,lc(infos[i].mAlertTitle), infos[i]);
        put(reverseMapping,lc(infos[i].mResString), infos[i]);
        put(reverseMapping,lc(infos[i].name()), infos[i]);
      }
      smExtras = new String[]{
        "CRIMINAL", "Crime",
        "DANGER", "Danger",
        "FALLEN", "Fallen",
        "FIRE", "Fire",
        "GENERAL", "General",
        "HIJACK", "Hijack",
        "MEDICAL", "Medical",
        "NATURAL_DISASTER", "Natural Disaster",
        "PANIC", "Panic",
        "PHOTO", "Photo",
        "PHYSICAL_ABUSE", "Physical Abuse",
        "POLICE_ARREST", "Arrested",
        "POLICE_INTERACTION", "Cop Blocking",
        "PRE_AUTHORISATION", "Pre Authorisation",
        "PULLED_OVER", "Vehicle Pulled",
        "TRAPPED", "Trapped",
        "UNRECOGNIZED", "Unrecognized",
        "VIDEO", "Video",
      };
      for (int i = 0; i < smExtras.length; ) {
        String key1 = ProblemType.clean(smExtras[i++]);
        String key2 = ProblemType.clean(smExtras[i++]);
        try {
          ProblemTypeInfo pti = reverseMapping.get(key1);
          if(pti==null)
            pti=reverseMapping.get(key2);

          reverseMapping.put(key1,pti);
          reverseMapping.put(key2,pti);
        } catch (Exception e) {
          System.out.println(smExtras[i-1]);
          System.out.println(smExtras[i-2]);
        }
      }
      TreeMap<String, ProblemType> otherMap = new TreeMap<>();
      for (String key : reverseMapping.keySet()) {
        ProblemTypeInfo info = reverseMapping.get(key);
        if (info != null)
          otherMap.put(key, info.getType());
      }
      ProblemType.setMap(otherMap);
      return reverseMapping;
    }

    private void put(final TreeMap<String, ProblemTypeInfo> reverseMapping,
                     String str, final ProblemTypeInfo info)
    {
      reverseMapping.put(ProblemType.clean(str),info);
    }
  }
}
