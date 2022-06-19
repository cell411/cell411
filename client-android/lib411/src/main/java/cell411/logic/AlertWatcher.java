package cell411.logic;

import android.location.Location;

import com.parse.ParseQuery;
import com.parse.model.ParseGeoPoint;
import com.parse.model.ParseObject;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashSet;
import java.util.Set;

import cell411.parse.XAlert;
import cell411.parse.XChatRoom;
import cell411.services.LocationService;
import cell411.utils.LocationUtil;


public class AlertWatcher extends Watcher<XAlert> {

  private ParseGeoPoint mLocation;
  private ParseGeoPoint mQueryLocation;

  public AlertWatcher() {
    super("Alerts", XAlert.class);
  }

  @Override
  void greetObject(XAlert object, ArrayList<ParseObject> list) {
    super.greetObject(object, list);
    checkIn(list, object.getParseObject("owner"));
    checkIn(list, object.getParseObject("sentTo"));
  }

  @Override
  public ParseQuery<XAlert> query() {
    ParseQuery<XAlert> query = ParseQuery.getQuery(mType);
    ParseGeoPoint location = getLocation();
    if (location == null)
      return null;
    query.whereWithinMiles("location", location, getMaxMiles());
    RelationWatcher relations = lqs().getRelationWatcher();
    Set<String> allBlocks = relations.allBlocks();
    query.whereNotContainedIn("owner", allBlocks);
    query.whereGreaterThan("createdAt", new Date(System.currentTimeMillis() - 86400 * 1000));
    return query;
  }

  public void loadFromNet() {
    super.loadFromNet();
    HashSet<String> chats = new HashSet<>();
    for (XAlert alert : mData.values()) {
      XChatRoom room = alert.getChatRoom();
      if (room != null)
        chats.add(room.getObjectId());
    }
    lqs().getChatRoomWatcher().setEntities(getName(), chats);
  }

  @Override
  public void prepare() {
    LocationService locationService = loc();
    locationService.addObserver(this::onLocationChanged);
  }

  private void onLocationChanged(final Location location, final Location location1) {
    setLocation(LocationUtil.getGeoPoint(location));
    if (getLocation() == null)
      return;
    if (mQueryLocation != null && mQueryLocation.distanceInMilesTo(getLocation()) > 10) {
      mQueryLocation = null;
    }
    if (mQueryLocation == null) {
      if (mQuery != null) {
        lqs().unsubscribe(mQuery);
        mQuery = null;
      }
    }
    if (mQuery == null) {
      mQuery = query();
    }
  }

  public int getMaxMiles() {
    return 50;
  }

  private ParseGeoPoint getLocation() {
    if (mLocation == null)
      mLocation = LocationUtil.getGeoPoint(loc().getParseGeoPoint());
    return mLocation;
  }

  public void setLocation(ParseGeoPoint location) {
    mLocation = location;
  }

  public void setLocation(Location location) {
    setLocation(LocationUtil.getGeoPoint(location));
  }
}
