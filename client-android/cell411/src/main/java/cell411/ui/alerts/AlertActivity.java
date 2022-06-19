package cell411.ui.alerts;

import static android.text.Html.FROM_HTML_MODE_LEGACY;

import android.Manifest;
import android.content.ActivityNotFoundException;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Bundle;
import android.text.Html;
import android.text.SpannableStringBuilder;
import android.text.method.LinkMovementMethod;
import android.text.style.ClickableSpan;
import android.text.style.URLSpan;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import com.google.android.material.floatingactionbutton.FloatingActionButton;
import com.parse.ParseException;
import com.parse.ParseQuery;
import com.parse.model.ParseGeoPoint;
import com.safearx.cell411.R;

import cell411.Cell411;
import cell411.base.BaseActivity;
import cell411.base.BaseApp;
import cell411.base.EnterTextDialog;
import cell411.enums.ProblemType;
import cell411.parse.XAddress;
import cell411.parse.XAlert;
import cell411.parse.XResponse;
import cell411.parse.XUser;
import cell411.ui.friends.UserActivity;
import cell411.ui.self.ProfileImageActivity;
import cell411.ui.utils.CircularImageView;
import cell411.utils.LocationUtil;
import cell411.utils.Util;
import cell411.utils.XLog;

/**
 * Created by Sachin on 14-04-2016.
 */
public class AlertActivity extends BaseActivity implements View.OnClickListener {
  private final static int PERMISSION_CALL_PHONE = 1;
  private final String TAG =
    AlertActivity.class.getSimpleName();
  private RelativeLayout rlAdditionalInfo;
  private XAlert mAlert;
  private XUser mOwner;
  private String mobileNumber;
  private String emergencyContactNumber;
  private TextView mTxtDistance;
  private TextView mTxtLblTag;
  private LinearLayout mRlForwardedBy;
  private TextView mTxtForwardedBy;
  private FloatingActionButton mFabChat;
  private FloatingActionButton mFabNavigate;
  private FloatingActionButton mFabPhone;
  private TextView mTxtAlertTime;
  private TextView mTxtAlert;
  private RelativeLayout mRlBtnCallEmergencyContact;
  private TextView mTxtBtnCannotHelp;
  private TextView mTxtBtnHelp;
  private TextView mTxtLblBloodGroup;
  private TextView mTxtBloodGroup;
  private TextView mTxtLblAllergies;
  private TextView mTxtAllergies;
  private TextView mTxtLblOtherMedicalConditions;
  private TextView mTxtOtherMedicalConditions;
  private CircularImageView mImgUser;
  private TextView mTxtAddress;
  private TextView mTxtLblAdditionalNote;
  private TextView mTxtAdditionalNote;
  private TextView mTxtBtnExpand;
  private RelativeLayout mRlAlertContainer;
  private ImageView mImgAlertType;
  private RelativeLayout mLlAddress;
  private LinearLayout mLlAction;
  private View mViewSeparatorVertical;
  // Data is here.
  private String mObjectId;
  private XResponse mResponse;
  private View mRlMap;
  private String mCallNumber;
  private LinearLayout llAdditionalInfo;

  public static void start(BaseActivity activity, XResponse response) {
    Intent intent = new Intent(activity, AlertActivity.class);
    intent.putExtra("objectId", response.getObjectId());
    activity.startActivity(intent);
  }

  public void loadData() {
    // The response object is pre-created for you, which is
    // how you know you have access to the alert.
    //
    // You should have gotten the object from LiveQUery, but we'll
    // check and load it if you did not, and we can.
    super.loadData();

    mResponse = (XResponse) ds().getObject(mObjectId);
    if (mResponse == null) {
      ParseQuery<XResponse> responseQuery = XResponse.q();
      responseQuery.include("alert");
      responseQuery.include("alert.owner");
      responseQuery.include("forwardedBy");
      try {
        mResponse = responseQuery.get(mObjectId);
      } catch (ParseException pe) {
        handleException("loading alert/response: " + mObjectId, pe,
          this::failureDialogComplete);
        return;
      }
    }
    mResponse.setSeen();
    mResponse.saveInBackground();
    mAlert = mResponse.getAlert();
    if (mAlert == null) {
      fail("No alert for this response.");
      return;
    }
    mAlert.fetchIfNeeded();
    mOwner = mAlert.getOwner();
    if (mOwner == null) {
      fail("No owner for this alert");
      return;
    }
    mOwner.fetchIfNeeded();
    XUser forwardedBy = mResponse.getForwardedBy();
    if (forwardedBy != null)
      forwardedBy.fetchIfNeeded();
    BaseApp.get().onUI(this::alertLoaded, 0);
  }

  private void fail(String s) {
    Cell411.get().showAlertDialog(s, this::failureDialogComplete);
  }

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    mObjectId = getIntent().getStringExtra("objectId");
    if (mObjectId == null) {
      Cell411.get()
        .showAlertDialog("AlertActivity requires a response to view.  I got " + "nothing.",
          this::failureDialogComplete);
      return;
    }
    setContentView(R.layout.activity_alert);
    mTxtDistance = findViewById(R.id.txt_distance);
    ImageView imgClose = findViewById(R.id.img_close);
    mTxtAddress = findViewById(R.id.txt_city);
    mTxtLblTag = findViewById(R.id.txt_lbl_tag);
    mRlForwardedBy = findViewById(R.id.rl_forwarded_by);
    mTxtForwardedBy = findViewById(R.id.txt_forwarded_by);
    mTxtAlert = findViewById(R.id.txt_alert);
    mFabChat = findViewById(R.id.fab_chat);
    mFabNavigate = findViewById(R.id.fab_navigate);
    mFabPhone = findViewById(R.id.fab_phone);
    mTxtAlertTime = findViewById(R.id.txt_alert_time);
    mImgUser = findViewById(R.id.img_user);
    mTxtLblBloodGroup = findViewById(R.id.txt_lbl_blood_group);
    mTxtBloodGroup = findViewById(R.id.txt_blood_group);
    mTxtLblAllergies = findViewById(R.id.txt_lbl_allergies);
    mTxtAllergies = findViewById(R.id.txt_allergies);
    mTxtLblOtherMedicalConditions = findViewById(R.id.txt_lbl_other_medical_conditions);
    mTxtOtherMedicalConditions = findViewById(R.id.txt_other_medical_conditions);
    mRlBtnCallEmergencyContact = findViewById(R.id.rl_btn_call_emergency_contact);
    RelativeLayout rlBtnForwardAlert = findViewById(R.id.rl_btn_forward_alert);
    rlAdditionalInfo = findViewById(R.id.rl_additional_info);
    llAdditionalInfo = findViewById(R.id.ll_additional_info);
    mTxtLblAdditionalNote = findViewById(R.id.txt_lbl_additional_note);
    mTxtAdditionalNote = findViewById(R.id.txt_additional_note);
    mTxtBtnExpand = findViewById(R.id.txt_btn_expand);
    mTxtBtnCannotHelp = findViewById(R.id.txt_btn_cannot_help);
    mTxtBtnHelp = findViewById(R.id.txt_btn_help);
    mRlAlertContainer = findViewById(R.id.rl_alert_container);
    mImgAlertType = findViewById(R.id.img_alert_type);
    mLlAddress = findViewById(R.id.ll_address);
    mLlAction = findViewById(R.id.ll_action);
    mRlMap = findViewById(R.id.map);
    mViewSeparatorVertical = findViewById(R.id.view_separator_vertical);
    imgClose.setOnClickListener(this);
    mTxtBtnExpand.setOnClickListener(this);
    rlBtnForwardAlert.setOnClickListener(this);

    System.out.println(ds().loadTime());
  }

  private void failureDialogComplete(boolean b) {
    finish();
  }

  public void alertLoaded() {
    ds().requestCity(mAlert.getLocation(), this::setAddress);
    loc().addObserver((value, oldValue) -> {
      ParseGeoPoint point = LocationUtil.getGeoPoint(loc().getLocation());
      mTxtDistance.setVisibility(View.VISIBLE);
      mTxtDistance.setText(LocationUtil.getFormattedDistance(mAlert.getLocation(), point));
    });
    setAlertDetails();
    applyTagIfRequired();
    initializeCollapsedAndExpandedInfoViewAndProfilePic();
    applyAlertTheme();
  }

  private void applyTagIfRequired() {
    if (mAlert.isGlobal()) {
      mTxtLblTag.setVisibility(View.VISIBLE);
    } else {
      mTxtLblTag.setVisibility(View.GONE);
    }
    XUser forwardedBy = mResponse.getForwardedBy();
    if (forwardedBy != null) {
      mRlForwardedBy.setVisibility(View.VISIBLE);
      mTxtForwardedBy.setText(forwardedBy.getName());
    } else {
      mRlForwardedBy.setVisibility(View.GONE);
    }
  }

  private void setAlertDetails() {
    String description;
    String str = ProblemTypeInfo.valueOf(mAlert.getProblemType()).resString();
    XUser owner = mAlert.getOwner();
    description = getString(R.string.alert_message, owner.getName(), str);
    mTxtAlert.setText(Html.fromHtml(description, FROM_HTML_MODE_LEGACY));
    mTxtAlertTime.setText(Util.formatDateTime(mAlert.getCreatedAt()));

    ds().requestCity(mAlert.getLocation(), this::setAddress);
  }

  protected void setTextViewHTML() {
    String name = mAlert.getOwner().getName();
    String anchor = "<a href='profile'>" + name + "</a>";
    ProblemTypeInfo pti = ProblemTypeInfo.valueOf(mAlert.getProblemType());
    String desc = getString(R.string.alert_message, anchor, pti.resString());
    CharSequence sequence = Html.fromHtml(desc, FROM_HTML_MODE_LEGACY);
    SpannableStringBuilder strBuilder = new SpannableStringBuilder(sequence);
    URLSpan[] urls = strBuilder.getSpans(0, sequence.length(), URLSpan.class);
    for (URLSpan span : urls) {
      makeLinkClickable(strBuilder, span);
    }
    mTxtAlert.setText(strBuilder);
    mTxtAlert.setMovementMethod(LinkMovementMethod.getInstance());
  }

  protected void makeLinkClickable(SpannableStringBuilder strBuilder, final URLSpan span) {
    int start = strBuilder.getSpanStart(span);
    int end = strBuilder.getSpanEnd(span);
    int flags = strBuilder.getSpanFlags(span);
    ClickableSpan clickable = new ClickableSpan() {
      public void onClick(View view) {
        UserActivity.start(AlertActivity.this, mOwner);
      }
    };
    strBuilder.setSpan(clickable, start, end, flags);
    strBuilder.removeSpan(span);
  }

  private void initializeActionButtons() {

    mFabChat.setOnClickListener(this);

    mFabNavigate.setOnClickListener(this);
    if (mobileNumber != null && !mobileNumber.isEmpty()) {
      mFabPhone.setOnClickListener(this);
    } else {
      mFabPhone.hide();
    }
    if (Util.isNoE(emergencyContactNumber)) {
      mRlBtnCallEmergencyContact.setVisibility(View.GONE);
    } else {
      mRlBtnCallEmergencyContact.setOnClickListener(this);
    }
    if (mAlert.getProblemType() == ProblemType.General) {
      mTxtBtnCannotHelp.setText(R.string.reject);
      mTxtBtnHelp.setText(R.string.accept);
    }
    mTxtBtnCannotHelp.setOnClickListener(this);
    mTxtBtnCannotHelp.setVisibility(View.VISIBLE);
    mTxtBtnHelp.setOnClickListener(this);
    mTxtBtnHelp.setVisibility(View.VISIBLE);
  }

  private void initializeCollapsedAndExpandedInfoViewAndProfilePic() {
    // For collapsed additional info window
    boolean hasAdditionalNote = mAlert != null && !Util.isNoE(mAlert.getNote());
    if (hasAdditionalNote) {
      mTxtAdditionalNote.setText(mAlert.getNote());
      mTxtLblAdditionalNote.setVisibility(View.VISIBLE);
      mTxtAdditionalNote.setVisibility(View.VISIBLE);
    } else {
      mTxtLblAdditionalNote.setVisibility(View.GONE);
      mTxtAdditionalNote.setVisibility(View.GONE);
    }
    if (mAlert != null && mAlert.getProblemType() == ProblemType.Medical) {
      retrieveMedicalInfoAndProfilePicAndContactInfo();
    } else {
      // Hide the collapsed and expanded view as we don't have
      // additional info to be displayed
      if (!hasAdditionalNote) {
        rlAdditionalInfo.setVisibility(View.GONE);
      }
      retrieveProfilePicAndContactInfo();
    }
  }

  private void retrieveMedicalInfoAndProfilePicAndContactInfo() {
    mTxtLblBloodGroup.setVisibility(View.VISIBLE);
    mTxtBloodGroup.setVisibility(View.VISIBLE);
    mTxtLblAllergies.setVisibility(View.VISIBLE);
    mTxtAllergies.setVisibility(View.VISIBLE);
    mTxtLblOtherMedicalConditions.setVisibility(View.VISIBLE);
    mTxtOtherMedicalConditions.setVisibility(View.VISIBLE);
    mOwner = mAlert.getOwner();
    String bloodType = mOwner.getBloodType();
    String allergies = mOwner.getAllergies();
    String otherMedicalConditions = mOwner.getOtherMedicalConditions();
    if (bloodType != null && !bloodType.isEmpty()) {
      mTxtBloodGroup.setText(bloodType);
    }
    if (allergies != null && !allergies.isEmpty()) {
      mTxtAllergies.setText(bloodType);
    }
    if (otherMedicalConditions != null && !otherMedicalConditions.isEmpty()) {
      mTxtOtherMedicalConditions.setText(bloodType);
    }
    mImgUser.setImageBitmap(mOwner.getThumbNailPic(mImgUser::setImageBitmap));
    mImgUser.setOnClickListener(view -> {
      XLog.i(TAG, "starting profile image activity");
      UserActivity.start(AlertActivity.this, mOwner);
    });
    setTextViewHTML();
    mobileNumber = mOwner.getMobileNumber();
    emergencyContactNumber = mOwner.getEmergencyContactNumber();
    initializeActionButtons();
  }

  private void retrieveProfilePicAndContactInfo() {
    mImgUser.setImageBitmap(mOwner.getThumbNailPic(mImgUser::setImageBitmap));
    mImgUser.setOnClickListener(view -> ProfileImageActivity.start(AlertActivity.this, mOwner));
    setTextViewHTML();
    mobileNumber = mOwner.getMobileNumber();
    emergencyContactNumber = mOwner.getEmergencyContactNumber();
    initializeActionButtons();
  }

  private void applyAlertTheme() {
    mRlAlertContainer.setVisibility(View.VISIBLE);
    mImgAlertType.setVisibility(View.VISIBLE);
    ProblemType problemType = mAlert.getProblemType();
    ProblemTypeInfo problemTypeInfo = ProblemTypeInfo.valueOf(problemType);
    mRlAlertContainer.setBackgroundColor(problemTypeInfo.getBackgroundColor());
    mImgAlertType.setImageResource(problemTypeInfo.getImageRes());
    rlAdditionalInfo.setBackgroundColor(problemTypeInfo.getBackgroundColor());
    mLlAddress.setBackgroundColor(problemTypeInfo.getBackgroundColor());
    mLlAction.setBackgroundColor(problemTypeInfo.getBackgroundColor());
    mViewSeparatorVertical.setBackgroundColor(problemTypeInfo.getBackgroundColor());
  }

  @Override
  public void onClick(View v) {
    int id = v.getId();
    if (id == R.id.txt_btn_expand) {
      if (llAdditionalInfo.getVisibility() == View.GONE) {
        llAdditionalInfo.setVisibility(View.VISIBLE);
        mRlMap.setVisibility(View.GONE);
        mTxtBtnExpand.setText(R.string.expand);
      } else {
        llAdditionalInfo.setVisibility(View.GONE);
        mRlMap.setVisibility(View.VISIBLE);
        mTxtBtnExpand.setText(R.string.collapse);
      }
    } else if (id == R.id.fab_chat) {
      openChat();
    } else if (id == R.id.fab_navigate) {
      openMapForNavigation();
    } else if (id == R.id.fab_phone) {
      mCallNumber = mobileNumber;
      checkPermissionAndDialEmergencyNumber();
    } else if (id == R.id.rl_btn_call_emergency_contact) {
      mCallNumber = emergencyContactNumber;
      checkPermissionAndDialEmergencyNumber();
    } else if (id == R.id.rl_btn_forward_alert) {
      Intent intentAlertIssuing = new Intent(this, AlertIssuingActivity.class);
      ProblemTypeInfo info = ProblemTypeInfo.valueOf(mAlert.getProblemType());
      intentAlertIssuing.putExtra("info", info.alertKey());
      intentAlertIssuing.putExtra("forwardedAlertId", mAlert.getObjectId());
      startActivity(intentAlertIssuing);
    } else if (id == R.id.txt_btn_cannot_help) {
      Util.theGovernmentIsLying();
      //cannotHelpTapped();
    } else if (id == R.id.txt_btn_help) {
      helpTapped();
    } else if (id == R.id.img_close || id == R.id.txt_btn_close) {
      finish();
    }
  }

  private void checkPermissionAndDialEmergencyNumber() {
    if (ContextCompat.checkSelfPermission(this, android.Manifest.permission.CALL_PHONE) !=
      PackageManager.PERMISSION_GRANTED) {
      ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.CALL_PHONE},
        PERMISSION_CALL_PHONE);
    } else {
      dialNumber();
    }
  }

  @Override
  public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions,
                                         @NonNull int[] grantResults) {
    if (requestCode == PERMISSION_CALL_PHONE) {
      if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
        dialNumber();
      } else {
        Cell411.get().showToast("App does not have permission to make a call");
      }
    } else {
      super.onRequestPermissionsResult(requestCode, permissions, grantResults);
    }
  }

  private void dialNumber() {
    // initiate 112 phone call
    Intent callIntent = new Intent(Intent.ACTION_CALL);
    callIntent.setData(Uri.parse("tel:" + mCallNumber));
    startActivity(callIntent);
  }

  private void openChat() {
    Cell411.get().openChat(mAlert);
  }

  private void openMapForNavigation() {
    try {
      Uri gmmIntentUri = Uri.parse(
        "google.navigation:q=" + mAlert.getLocation().getLatitude() + "," +
          mAlert.getLocation().getLongitude());
      Intent mapIntent = new Intent(Intent.ACTION_VIEW, gmmIntentUri);
      mapIntent.setPackage("com.google.android.apps.maps");
      startActivity(mapIntent);
    } catch (ActivityNotFoundException e) {
      e.printStackTrace();
      Cell411.get().showToast(getString(R.string.maps_app_not_installed));
    }
  }

  private void helpTapped() {
    EnterTextDialog etDialog =
      EnterTextDialog.buildEnterTextDialog("Enter Note", "note for " + mOwner.getName(), "");
    etDialog.setOnDismissListener(dialog -> {
      String note = etDialog.getAnswer();
      announceHelp(note);
    });
    etDialog.show();
  }

  private void announceHelp(String note) {
    XUser user = XUser.getCurrentUser();
    if (user == null)
      return;

   onDS(() -> {
      try {
        mResponse.put("alert", mAlert);
        mResponse.put("owner", user);
        mResponse.put("travelTime", mTxtDistance.getText());
        mResponse.put("note", note);
        mResponse.save();
      } catch (ParseException pe) {
        handleException("sending additionalNote", pe, null);
      }
    });
  }

  private void setAddress(XAddress address) {
    mTxtAddress.setText(address.mAddress);
  }
}

