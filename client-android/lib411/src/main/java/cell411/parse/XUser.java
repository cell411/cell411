package cell411.parse;

import static cell411.utils.ImageFactory.loadBitmapAsync;

import android.graphics.Bitmap;
import android.graphics.Bitmap.Config;
import android.graphics.Canvas;
import android.graphics.drawable.Drawable;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.content.res.AppCompatResources;

import com.parse.Parse;
import com.parse.ParseClassName;
import com.parse.ParseException;
import com.parse.ParseQuery;
import com.parse.model.ParseGeoPoint;
import com.parse.model.ParseObject;
import com.parse.model.ParseRelation;
import com.parse.model.ParseUser;

import java.util.ArrayList;
import java.util.Arrays;

import cell411.base.BaseApp;
import cell411.services.DataService;
import cell411.services.R;
import cell411.utils.ImageFactory;
import cell411.utils.Util;

/**
 * Created by Sachin on 7/12/2015.
 */
@SuppressWarnings("unused")
@ParseClassName("_User")
public class XUser extends ParseUser implements IObject {
  public static final String TAG = "XUser";
  public static final Bitmap smPlaceHolder;
  private static final ParseQuery<XUser> smNullQuery;

  static {
    smPlaceHolder = Bitmap.createBitmap(300, 300, Config.ARGB_8888);
    Canvas canvas = new Canvas(smPlaceHolder);

    int id = R.drawable.ic_placeholder_user;
    final Drawable drawable = AppCompatResources.getDrawable(BaseApp.get(), id);
    if (drawable != null) {
      drawable.setBounds(0, 0, 300, 300);
      drawable.draw(canvas);
    }
  }

  static {
    smNullQuery = XUser.q();
    smNullQuery.whereDoesNotExist("objectId");
  }

  private Bitmap mThumbNail;
  private Bitmap mAvatar;

  public XUser() {
  }

  public static Bitmap getPlaceHolder() {
    return smPlaceHolder;
  }

  static XUser smCurrentUser;
  static final Runnable smClearUser = new Runnable() {
    @Override
    public void run() {
      smCurrentUser=null;
    }
  };
  static {
    BaseApp.get().registerLogoutAction(smClearUser);
  }

  @NonNull
  public static XUser getCurrentUser() {
    if(!Parse.isInitialized())
      throw new IllegalStateException("You must initialize Parse first!");
    if(smCurrentUser!=null)
      return smCurrentUser;

    try {
      smCurrentUser = XCurrentUser.get().getUser();
      return smCurrentUser;
    } catch (NullPointerException e) {
      throw Util.rethrow("getting current user", e);
    }
  }

  public static String getResString(int resId) {
    return DataService.getResString(resId);
  }

  public static XUser queryUsersWithEmail(String email) {
    try {
      ArrayList<ParseQuery<XUser>> queries = new ArrayList<>();
      ParseQuery<XUser> query = ParseQuery.getQuery("_User");
      query.whereEqualTo("username", email);
      queries.add(query);
      query = ParseQuery.getQuery("_User");
      query.whereEqualTo("email", email);
      queries.add(query);
      query = ParseQuery.or(queries);
      return query.getFirst();
    } catch (ParseException pe) {

      sObj.ds().showToast("user load failed: " + email);
      return null;
    }
  }

  public static ParseQuery<XUser> q() {
    return ParseQuery.getQuery(XUser.class);
  }

  public static ParseQuery<XUser> queryAllFriends(XUser user) {
    ParseRelation<XUser> rFFriends = user.getRelation("friends");
    ParseQuery<XUser> qFFriends = rFFriends.getQuery();
    ParseQuery<XUser> qRFriends = q().whereEqualTo("friends", user);
    return ParseQuery.or(qFFriends, qRFriends);
  }

  public static XUser from(State state) {
    XUser object = new XUser();
    synchronized (object.mutex) {
      ParseObject.State newState;
      if (state.isComplete()) {
        newState = state;
      } else {
        newState = object.getState().newBuilder().apply(state).build();
      }
      object.setState(newState);
    }
    return object;
  }

  public static ParseQuery<XRequest> queryRequestsSentBy() {
    // User received
    final ParseUser currentUser = ParseUser.getCurrentUser();
    ParseQuery<XRequest> query = ParseQuery.getQuery(XRequest.class);
    query.whereEqualTo("owner", currentUser.getObjectId());
    return query;
  }

  public static ParseQuery<XRequest> queryRequestsSentTo() {
    // User received
    final ParseUser currentUser = ParseUser.getCurrentUser();
    ParseQuery<XRequest> query = ParseQuery.getQuery(XRequest.class);
    query.whereEqualTo("sentTo", currentUser.getObjectId());
    return query;
  }

  public static String createAvatarName() {
    String serdate = Util.serdate();
    XUser user = getCurrentUser();
    String objectId = user.getObjectId();
    return "avatar." + objectId + "." + serdate;
  }

  public static XUser fakeUser() {
    XUser owner = create(XUser.class);
    owner.setFirstName("Some");
    owner.setLastName("Body");
    //owner.setAvatarBitmap(XUser.getPlaceHolder());
    return owner;
  }

  public final boolean equals(Object o) {
    if (this == o) {
      return true;
    }
    if (o instanceof ParseObject) {
      ParseObject other = (ParseObject) o;
      return other.hasSameId(this);
    } else if (o instanceof String) {
      return getObjectId().equals(o);
    } else {
      return false;
    }
  }

  public String getMobileNumber() {
    return getString("mobileNumber");
  }

  public void setMobileNumber(String newNumber) {
    put("mobileNumber", newNumber);
  }

  public Bitmap getAvatarPic(@Nullable ImageFactory.ImageListener listener) {
    if (mAvatar != null)
      return mAvatar;
    if (has("avatar"))
      mAvatar = loadBitmapAsync(getString("avatar"), bitmap -> {
        mAvatar = bitmap;
        if(listener!=null)
          listener.ready(bitmap);
      });
    else if (has("thumbNail"))
      mAvatar = getThumbNailPic(bitmap -> {
        mAvatar = bitmap;
        if(listener!=null)
          listener.ready(bitmap);
      });
    if (mAvatar != null)
      return mAvatar;
    return getPlaceHolder();
  }

  public Bitmap getThumbNailPic(ImageFactory.ImageListener listener) {
    if (mThumbNail != null) {
      return mThumbNail;
    }
    if (has("thumbNail")) {
      String url = getString("thumbNail");
      mThumbNail = loadBitmapAsync(url, bitmap -> {
        mThumbNail = bitmap;
        if(listener!=null)
          listener.ready(bitmap);
      });
      if (mThumbNail != null)
        return mThumbNail;
    } else {
      fetchIfNeededInBackground();
    }
    return getPlaceHolder();
  }

  @Override
  public String getEmail() {
    String res = getString("email");
    if (res == null || res.isEmpty()) {
      String un = getUsername();
      if (un == null)
        return "";
      if (un.contains("@")) {
        res = un;
      } else {
        res = "";
      }
    }
    return res;
  }

  public ParseGeoPoint getLocation() {
    return getParseGeoPoint("location");
  }

  public void setLocation(ParseGeoPoint point) {
    put("location", point);
  }

  public String getFirstName() {
    return getString("firstName");
  }

  public void setFirstName(String firstName) {
    if (Util.isNoE(firstName)) {
      return;
    }
    put("firstName", firstName);
  }

  public String getLastName() {
    return getString("lastName");
  }

  public void setLastName(String lastName) {
    if (Util.isNoE(lastName)) {
      return;
    }
    put("lastName", lastName);
  }

  public String getName() {
    String f;// = getFirstName();
    if (isDataAvailable("firstName")) {
      f = getFirstName();
    } else {
      f = getObjectId();
    }
    String l;// = getLastName();
    if (isDataAvailable("lastName")) {
      l = getLastName();
    } else {
      l = getObjectId();
    }
    return f + " " + l;
  }

  public boolean getPatrolMode() {
    return getBoolean("patrolMode");
  }

  public void setPatrolMode(boolean patrolMode) {
    put("patrolMode", patrolMode);
  }

  public String getPrivilege() {
    return getString("privilege");
  }

  public void setPrivilege(String privilege) {
    put("privilege", privilege);
  }

  public boolean getNewPublicCellAlert() {
    return getInt("newPublicCellAlert") != 0;
  }

  public void setNewPublicCellAlert(boolean newPublicCellAlert) {
    put("newPublicCellAlert", newPublicCellAlert);
  }

  public int nameCompare(XUser xUser) {
    int res = getName().compareToIgnoreCase(xUser.getName());
    if (res == 0) {
      res = getObjectId().compareTo(xUser.getObjectId());
    }
    return res;
  }

  public String getBloodType() {
    return getString("bloodType");
  }

  public String getAllergies() {
    return getString("allergies");
  }

  public String getOtherMedicalConditions() {
    return getString("otherMedicalConditions");
  }

  public String getEmergencyContactNumber() {
    return getString("emergencyContactNumber");
  }

  public String getEmergencyContactName() {
    return getString("emergencyContactName");
  }

  public boolean getConsented() {
    return getBoolean("consented");
  }

  public void setConsented(boolean consented) {
    put("consented", consented);
  }

  public void setAvatar(String url) {
    mAvatar=null;
    put("avatar", url);
  }

  public void setThumbNail(String url) {
    put("thumbNail", url);
  }

  public ParseQuery<XUser> querySpamUsers() {
    ParseQuery<XUser> flaggedMe = q();
    flaggedMe.whereEqualTo("spamUsers", this);
    ParseRelation<XUser> flaggedByR = getRelation("spamUsers");
    ParseQuery<XUser> flaggedBy = flaggedByR.getQuery();
    return ParseQuery.or(Arrays.asList(flaggedBy, flaggedMe));
  }

  public ParseQuery<XUser> queryFriends() {
    ParseRelation<XUser> relation = getRelation("friends");
    return relation.getQuery();
  }

  // When you give a user a new avatar, he will get it installed
  // in all the places where it is needed.  This includes updating
  // the image factory, uploading the new version to Parse/S3,
  // and generating a new thumbnail image.
//  public void setAvatarBitmap(Bitmap bitmap, OnCompletionListener listener) {
//    ImageFactory.
//  }

  //  static XCurrentUser currentUser = XCurrentUser.smCurrentUser;


  //  public boolean hasBlocked(String objectId) {
  //    return smCurrentUser.mSpamUsers.contains(objectId);
  //  }
  //
  //  public static boolean isSpamUser(String userId) {
  //    return getCurrentUser().isFlaggedUser(userId);
  //  }
  //
  //  public static boolean isSpamUser(XUser user) {
  //    return isSpamUser(user.getObjectId());
  //  }
  //public List<XPublicCell> getJoinedPublicCells() {
  //  return Util.transform(getJoinedPublicCellIds(), DataService::staticGetPublicCell);
  //}
  //  private ArrayList<String> getJoinedPublicCellIds() {
  //    return new ArrayList<>(smCurrentUser.mJoinedCells);
  //  }
  //  public void updateLists(Map<String, Set<String>> mSrc) {
  //    smCurrentUser.updateLists(mSrc);
  //  }
  //  public HashSet<String> getBlockList() {
  //    HashSet<String> res = new HashSet<>(smCurrentUser.mUserSpams);
  //    res.addAll(smCurrentUser.mSpamUsers);
  //    return res;
  //  }
  //  public boolean isOnPendingList(String userId) {
  //    return smCurrentUser.mPendingFriends.contains(userId);
  //  }
  //  public void addFlaggedUser(XUser user, OnCompletionListener listener)
  //  {
  //    assert isCurrentUser();
  //    ParseRelation<XUser> relation = getRelation("spamUsers");
  //    smCurrentUser.mSpamUsers.add(user.getObjectId());
  //    relation.add(user);
  //    saveInBackground(e -> {
  //      listener.done(e == null);
  //      if (e != null)
  //        DataService.staticHandleException("saving user", e);
  //    });
  //  }
  //  public boolean isFlaggedUser(String userId) {
  //    assert isCurrentUser();
  //    return smCurrentUser.mSpamUsers.contains(userId);
  //  }
  //  public Set<String> getSpamUsers() {
  //    assert isCurrentUser();
  //    return new HashSet<>(smCurrentUser.mSpamUsers);
  //  }
  //  @NonNull
  //  public ArrayList<XPublicCell> getOwnedCells() {
  //    assert isCurrentUser();
  //    ArrayList<XPublicCell> res = new ArrayList<>();
  //    DataService.getObjects(res, XPublicCell.class, smCurrentUser.mOwnedCells);
  //    return res;
  //  }
  //  public ArrayList<XPublicCell> getJoinedCells() {
  //    assert isCurrentUser();
  //    ArrayList<XPublicCell> res = new ArrayList<>();
  //    DataService.getObjects(res, XPublicCell.class, smCurrentUser.mJoinedCells);
  //    return res;
  //  }
  //  @NonNull
  //  public ArrayList<XPrivateCell> getPrivateCells() {
  //    assert isCurrentUser();
  //    ArrayList<XPrivateCell> res = new ArrayList<>();
  //    DataService.getObjects(res, XPrivateCell.class, smCurrentUser.mPrivateCells);
  //    return res;
  //  }
  //  public Collection<String> getFriendIds() {
  //    assert (isCurrentUser());
  //    return new ArrayList<>(smCurrentUser.mFriends);
  //  }
  //  public XLiveRelation<XUser> getFriends() {
  //    if (mFriends == null)
  //      mFriends = new XLiveRelation<>(this, "friends");
  //    return mFriends;
  //  }

}

