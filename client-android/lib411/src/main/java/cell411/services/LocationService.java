package cell411.services;

import android.content.Context;
import android.content.SharedPreferences;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.Build;
import androidx.annotation.NonNull;

import cell411.base.BaseApp;
import cell411.base.BaseService;
import cell411.utils.LocationUtil;
import cell411.utils.ObservableValue;
import cell411.utils.Timer;
import cell411.utils.Util;
import cell411.utils.ValueObserver;
import cell411.utils.XLog;
import com.parse.model.ParseGeoPoint;

import java.util.Date;

@SuppressWarnings("unused")
public class LocationService extends BaseService {
  // final, static members
  public static final String TAG = LocationService.class.getSimpleName();
  public static Timer smTimer;

  private static LocationService smInstance;

  final private ObservableValue<Location> mLocation = new ObservableValue<>();

  private final LocationListener mListener           = mLocation::set;
  private       int              smUpdateCount       = 0;
  private       long             smLastUpdateMillis  = 0;
  private       boolean          smShowToastOnUpdate = true;
  private       boolean          smLogOnUpdate       = true;
  public LocationService()
  {
    smInstance = this;
    loadLocation();
  }

  public static LocationService i(boolean b) {
    if (smInstance != null)
      return smInstance;
    if (!b)
      return i();

    if (DataService.safeGet() == null) {
      // We don't start until after the Data Service.
      return null;
    }
    try {
      smInstance = new LocationService();

      String string = LocationUtil.formatLocation(smInstance.getLocation());
      Date date = new Date(smInstance.smLastUpdateMillis);
      System.out.println("Location: " + string);
      System.out.println(" updated: " + date);
      return smInstance;
    } catch (Throwable ignores) {
      return null;
    }
  }

  public static synchronized LocationService i() {
    return smInstance;
  }
  public void loadLocation() {
    SharedPreferences latLngPref   = app().getAppPrefs();
    double            lat          = latLngPref.getFloat("Location.Lat", (float) 42.93383800273033);
    double            lng          = latLngPref.getFloat("Location.Lng", (float) -72.27850181930877);
    long              locationTime = latLngPref.getLong("Location.Date", 0);
    Location          location     = LocationUtil.getLocation(lat, lng);
    smLastUpdateMillis = locationTime;
    mLocation.set(location);
  }
  public void storeLocation() {
    SharedPreferences        latLngPref = app().getAppPrefs();
    SharedPreferences.Editor edit       = latLngPref.edit();
    Location                 location   = mLocation.get();
    if (location != null) {
      edit.putFloat("Location.Lat", (float) location.getLatitude());
      edit.putFloat("Location.Lng", (float) location.getLongitude());
      edit.putLong("Location.Time", smLastUpdateMillis);
      edit.apply();
    }
  }
  public long locationAge() {
    return System.currentTimeMillis()-smLastUpdateMillis;
  }
  public void addObserver(ValueObserver<Location> locationValueObserver) {
    mLocation.addObserver(locationValueObserver);
    startWatching();
  }
  private boolean startWatching(String provider) {

    Context         context = ds().getApplicationContext();
    LocationManager lm      = context.getSystemService(LocationManager.class);
    try {
      lm.requestLocationUpdates(provider, 60000, 100, mListener);
      return true;
    } catch (SecurityException se) {
      BaseApp.get().handleException("Requesting location updates", se);
    }
    return false;
  }
  private void startWatching() {
    XLog.i(TAG, "Watching our location, due to " + mLocation.countObservers() + " observers");

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
      if (startWatching(LocationManager.FUSED_PROVIDER))
        return;
    }
    if (startWatching(LocationManager.GPS_PROVIDER))
      return;

    ds().showToast("The location manager is not available.  I don't know where we are!");
  }
  private void stopWatching() {

  }
  public void removeObserver(ValueObserver<Location> locationValueObserver) {
    mLocation.removeObserver(locationValueObserver);
    if (mLocation.countObservers() == 0) {
      stopWatching();
    }
  }

  public ParseGeoPoint getParseGeoPoint() {
    return LocationUtil.getGeoPoint(getLocation());
  }

  void setVerbosity(boolean showToast, boolean writeLog) {
    smShowToastOnUpdate = showToast;
    smLogOnUpdate       = writeLog;
  }

  @NonNull
  public Location getLocation() {
    Location res = mLocation.get();
    if (res == null)
      res = LocationUtil.getLocation(0, 0);
    return res;
  }

  public void onChange(Location newValue, Location oldValue) {
    smUpdateCount++;
    long   now      = System.currentTimeMillis();
    long   delta    = now - smLastUpdateMillis;
    String message1 = Util.format("%d: Got update# %d, gap was %d", now, smUpdateCount, delta);
    XLog.w(TAG, message1);
    smLastUpdateMillis = now;
    if (smLogOnUpdate || smShowToastOnUpdate) {
      final double lat      = newValue.getLatitude();
      final double lng      = newValue.getLongitude();
      final String message2 = LocationUtil.formatLocation(newValue);
      if (smShowToastOnUpdate) {

        ds().showToast(message2);
      }
      if (smLogOnUpdate) {
        XLog.i(TAG, message2);
      }
    }
    if (oldValue == null || newValue == null) {
      return;
    }
    float  distance = LocationUtil.distanceBetween(oldValue, newValue);
    String message3 = Util.format("%f meters between old and new points.", distance);
    XLog.i(TAG, message3);
  }
}

