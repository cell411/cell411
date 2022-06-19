package cell411.ui.friends;

import android.app.AlertDialog;
import android.content.Context;
import android.content.Intent;
import android.content.res.ColorStateList;
import android.graphics.Color;
import android.os.Bundle;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import cell411.Cell411;
import cell411.base.BaseActivity;
import cell411.methods.AddFriendModules;
import cell411.parse.XAddress;
import cell411.parse.XUser;
import cell411.parse.util.OnCompletionListener;
import cell411.services.DataService;
import cell411.ui.self.ProfileImageActivity;
import cell411.utils.Util;
import cell411.utils.XLog;
import com.parse.ParseCloud;
import com.parse.ParseQuery;
import com.parse.model.ParseGeoPoint;
import com.parse.model.ParseObject;
import com.parse.model.ParseRelation;
import com.safearx.cell411.R;
import org.jetbrains.annotations.Nullable;

import java.util.HashMap;

/**
 * Created by Sachin on 08-08-2016.
 */
public class UserActivity extends BaseActivity {
  private final String         TAG = UserActivity.class.getSimpleName();
  private       TextView       mTxtAlertsSent;
  private       TextView       mTxtAlertsResponded;
  private       LinearLayout   mLinearLayout;
  private       RelativeLayout mAddFriendButton;
  private       ImageView      mAddFriendImage;
  private       TextView       mAddFriendText;
  private       RelativeLayout mSpamButton;
  private       XUser          mUser;
  private       int            COLOR_PRIMARY;
  private       int            COLOR_WHITE;
  private       TextView       mTxtCity;
  private       ImageView      mImgUser;
  private       TextView       mTextView;
  private       TextView       mTxtEmail;
  private       ImageView      mCloseImage;
  private       String         mSent;
  private       String         mResponded;
  private       boolean        mIsFriend;
  private       boolean        mHasBlocked;
  public static void start(Context context, XUser user) {
    start(context, user.getObjectId());
  }
  public static void start(Context context, String objectId)
  {
    Intent intentUser = new Intent(context, UserActivity.class);
    intentUser.putExtra("objectId", objectId);
    context.startActivity(intentUser);
  }
  public void onAddressSet(XAddress address)
  {
    mTxtCity.setText(address.cityPlus());
  }

  @Override
  protected void onCreate(Bundle savedInstanceState)
  {
    super.onCreate(savedInstanceState);
    mUser = getUser();
    if (mUser == null)
      return;
    setContentView(R.layout.activity_user);
    COLOR_PRIMARY       = getColor(R.color.highlight_color);
    COLOR_WHITE         = getColor(R.color.white);
    mImgUser            = findViewById(R.id.img_user);
    mTextView           = findViewById(R.id.txt_name);
    mTxtEmail           = findViewById(R.id.txt_email);
    mTxtCity            = findViewById(R.id.txt_city_name);
    mTxtAlertsSent      = findViewById(R.id.txt_alerts_sent);
    mTxtAlertsResponded = findViewById(R.id.txt_alerts_responded);
    mLinearLayout       = findViewById(R.id.ll_actions);
    mAddFriendButton    = findViewById(R.id.rl_btn_add_friend);
    mAddFriendImage     = findViewById(R.id.img_btn_add_friend);
    mAddFriendText      = findViewById(R.id.txt_btn_action);
    mSpamButton         = findViewById(R.id.rl_btn_spam);
    mLinearLayout.setVisibility(View.GONE);
    mCloseImage = findViewById(R.id.img_close);
    mCloseImage.setOnClickListener(v -> finish());
    mImgUser.setOnClickListener(this::showProfileImage);
    mAddFriendButton.setOnClickListener(this::onAddFriendClicked);
    mSpamButton.setOnClickListener(this::onSpamButtonClicked);
    mSpamButton.setEnabled(false);
    mLinearLayout.setVisibility(View.VISIBLE);
  }

  @Nullable
  private XUser getUser() {
    String userId = getIntent().getStringExtra("objectId");
    XLog.i(TAG, "userId" + userId);
    if (userId == null) {
      showAlertDialog("Userid is null");
      finish();
      return null;
    }
    ParseObject result;
    synchronized (DataService.class) {

      result = ds().getObject(userId);
    }
    XUser user = (XUser) result;
    if (user == null) {
      showAlertDialog("user is null");
      finish();
      return null;
    }
    XLog.i(TAG, "objectId: " + user.getObjectId());
    return user;
  }
  @Override
  public void populateUI() {
    mImgUser.setImageBitmap(mUser.getThumbNailPic(mImgUser::setImageBitmap));
    String text = "Waiting for city";
    mTxtCity.setText(text);
    if (mUser.getLocation() != null)
      ds()
                 .requestCity(mUser.getLocation(), address -> mTxtCity.setText(address.cityPlus()));
    mTxtAlertsSent.setText(mSent);
    mTxtAlertsResponded.setText(mResponded);
    mTextView.setText(mUser.getName());
    mSpamButton.setEnabled(notSpammed());
    if (isFriend()) {
      mAddFriendImage.setImageTintList(ColorStateList.valueOf(COLOR_PRIMARY));
      mAddFriendButton.setBackgroundResource(R.drawable.bg_un_friend);
      mAddFriendText.setText(R.string.un_friend);
      mAddFriendText.setTextColor(getColor(R.color.highlight_color));
      String email = mUser.getEmail();
      if (Util.isNoE(email)) {
        mTxtEmail.setVisibility(View.GONE);
      } else {
        mTxtEmail.setText(email);
      }
    } else {
      mAddFriendImage.setImageTintList(ColorStateList.valueOf(COLOR_WHITE));
      mAddFriendButton.setBackgroundResource(R.drawable.bg_cell_join);
      mAddFriendText.setText(R.string.add_friend);
      mAddFriendText.setTextColor(Color.WHITE);
      mTxtEmail.setVisibility(View.GONE);
    }
    if (mUser.getLocation() == null) {
      mTxtCity.setText(R.string.no_location_on_file);
    }
  }

  @Override
  public void prepareToLoad() {

  }

  public void loadData() {
    try {
      ParseGeoPoint location = mUser.getLocation();
      if (location != null) {

        ds().requestCity(location, this::onAddressSet);
      }
      HashMap<String, Object> params = new HashMap<>();
      params.put("user", mUser.getObjectId());
      HashMap<String, Object> result = ParseCloud.run("countAlerts", params);
      mSent      = String.valueOf(result.get("sent"));
      mResponded = String.valueOf(result.get("responded"));
      XUser                currentUser = XUser.getCurrentUser();
      ParseRelation<XUser> userR       = currentUser.getRelation("friends");
      ParseQuery<XUser>    userQ       = userR.getQuery();
      userQ.whereEqualTo("objectId", mUser.getObjectId());
      mIsFriend = userQ.count() != 0;

      userR = currentUser.getRelation("spamUsers");
      userQ = userR.getQuery();
      ParseQuery<XUser> revQ = XUser.q();
      revQ.whereEqualTo("spamUsers", currentUser);
      userQ       = ParseQuery.or(userQ, revQ);
      mHasBlocked = userQ.count() != 0;

    } catch (Throwable e) {
      handleException("loading user", e, success -> finish());
    }
  }

  private void showProfileImage(View ignored)
  {
    ProfileImageActivity.start(UserActivity.this, mUser);
  }

  private void onSpamButtonClicked(View view)
  {
    if (notSpammed()) {
      AddFriendModules.showFlagAlertDialog(
        UserActivity.this, mUser, ok -> populateUI());
    } else {
      Cell411.get().showToast(mUser.getName() + " is already blocked");
    }
  }

  private void onAddFriendClicked(View view)
  {
    mAddFriendButton.setBackgroundResource(R.drawable.bg_cell_join_processing);
    if (isFriend()) {
      // Delete this friend
      AddFriendModules.showDeleteFriendDialog(
        UserActivity.this, mUser, success -> populateUI());
    } else { // Add Friend (send friend request)
      OnCompletionListener onCompletionListener = success -> {
        if (!success)
          showFriendRequestFailedDialog();
      };

      ds().sendFriendRequest(mUser, onCompletionListener);
    }
  }

  private void showFriendRequestFailedDialog()
  {
    AlertDialog.Builder alert = new AlertDialog.Builder(this);
    alert.setMessage(R.string.cannot_send_friend_request);
    alert.setPositiveButton(R.string.dialog_btn_ok, (dialogInterface, i) -> {
    });
    AlertDialog dialog = alert.create();
    dialog.show();
  }

  public boolean isFriend()
  {
    return mIsFriend;
  }

  public boolean notSpammed()
  {
    return !mHasBlocked;
  }
}

