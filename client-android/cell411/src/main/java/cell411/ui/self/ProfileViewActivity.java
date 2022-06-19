package cell411.ui.self;


import android.app.Service;
import android.content.Intent;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.annotation.CallSuper;
import androidx.annotation.Nullable;
import cell411.Cell411;
import cell411.base.BaseActivity;
import cell411.base.BaseApp;
import cell411.parse.XUser;
import cell411.utils.ImageUtils;
import cell411.ui.utils.ip.ImagePickerContract;
import cell411.ui.utils.ip.PicPrefs;
import cell411.utils.ImageFactory;
import cell411.utils.Util;
import cell411.utils.XLog;

import com.parse.model.ParseGeoPoint;
import com.parse.model.ParseUser;
import com.safearx.cell411.R;

public class ProfileViewActivity extends BaseActivity {
  private static final String TAG = "ProfileViewActivity";
  static {
    XLog.i(TAG, "loading class");
  }
  final ImagePickerContract mImagePickerContract;
  {
    mImagePickerContract = new ImagePickerContract(this, this::callback);
  }

  private void callback(final Integer integer) {
    PicPrefs prefs = ImagePickerContract.claimPicPref(integer);
    Bitmap bitmap = prefs.mBitmap;
    bitmap = ImageUtils.getCroppedBitmap(bitmap);
    XUser currentUser = XUser.getCurrentUser();
    ImageFactory.uploadAvatar(prefs.mBaseName+".png", bitmap, s -> {
      currentUser.setAvatar(s);
      currentUser.saveInBackground();
      onUI(()->{
        imgUser.setImageBitmap(currentUser.getAvatarPic(bitmap1 -> imgUser.setImageBitmap(bitmap1)));
      });
    });
  }

  private       ImageView         imgUser;
  private       ImageView         imgEdit;
  private       TextView          txtName;
  private       TextView          txtEmail;
  private       TextView          txtPhone;
  private       TextView          txtBloodGroup;
  private       TextView          txtEmergencyContactName;
  private       TextView          txtEmergencyContactNumber;
  private       TextView          txtAllergies;
  private       TextView          txtOtherMedicalConditions;
  private       TextView          txtProfileCompleteness;
  private       TextView          mTxtCity;
  public ProfileViewActivity() {
  }

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_profile_view);
    // Set up the action bar.
    setDisplayUpAsHome();
    imgUser = findViewById(R.id.img_user);
    imgEdit = findViewById(R.id.img_edit);
    txtName = findViewById(R.id.txt_name);
    txtEmail = findViewById(R.id.txt_email);
    mTxtCity = findViewById(R.id.txt_city_name);
    txtPhone = findViewById(R.id.txt_phone);
    txtProfileCompleteness = findViewById(R.id.txt_profile_completeness);
    txtBloodGroup = findViewById(R.id.txt_blood_group);
    txtEmergencyContactName = findViewById(R.id.txt_emergency_contact_name);
    txtEmergencyContactNumber = findViewById(R.id.txt_emergency_contact_number);
    txtAllergies = findViewById(R.id.txt_allergies);
    txtOtherMedicalConditions = findViewById(R.id.txt_other_medical_conditions);
    imgEdit.setOnClickListener(this::onClick);
    mTxtCity.setText("");
  }

  private void setAddress(TextView txtCity, String address) {
    txtCity.setText(address);
  }
  @Override
  public void populateUI() {
    super.populateUI();
    XUser user = XUser.getCurrentUser();
    ParseGeoPoint point = user.getLocation();
    if(point==null) {
      mTxtCity.setText(R.string.no_location_on_file);
    } else {
      mTxtCity.setText(R.string.waiting_for_city);
      ds().requestCity(point, address -> {
        BaseApp.get().onUI(() -> {
          setAddress(mTxtCity, address.cityPlus());
        }, 0);
      });
    }
    imgUser.setImageBitmap(user.getAvatarPic(imgUser::setImageBitmap));
    txtName.setText(user.getName());
    txtEmail.setText(user.getEmail());
    TextView           txtPhoneNot       = findViewById(R.id.txt_not);
    ImageView          imgVerified       = findViewById(R.id.img_verified);
    XBlinkingRedSymbol blinkingRedSymbol = findViewById(R.id.brs);
    TextView           txtBtnAddPhone    = findViewById(R.id.txt_btn_add_phone);
    final String       mobileNumber      = user.getString("mobileNumber");
    if (Util.isNoE(mobileNumber)) {
      txtPhone.setText(R.string.not_available);
      txtPhoneNot.setVisibility(View.GONE);
      blinkingRedSymbol.setVisibility(View.GONE);
      imgVerified.setVisibility(View.GONE);
      txtBtnAddPhone.setVisibility(View.VISIBLE);
    } else {
      txtPhone.setText(user.getMobileNumber());
      txtBtnAddPhone.setVisibility(View.GONE);
    }
    txtPhoneNot.setVisibility(View.GONE);
    blinkingRedSymbol.setVisibility(View.GONE);
    imgVerified.setVisibility(View.GONE);
    String bloodType = user.getBloodType();
    if (!Util.isNoE(bloodType) && !bloodType.equals("null")) {
      txtBloodGroup.setText(bloodType);
    } else {
      txtBloodGroup.setText(R.string.not_available);
    }
    String emergencyContactName = user.getEmergencyContactName();
    if (!Util.isNoE(emergencyContactName) && !emergencyContactName.equals("null")) {
      txtEmergencyContactName.setText(emergencyContactName);
    }
    String emergencyContactNumber = user.getEmergencyContactNumber();
    if (!Util.isNoE(emergencyContactNumber) && !emergencyContactNumber.equals("null")) {
      txtEmergencyContactNumber.setText(emergencyContactNumber);
    }
    String allergies = user.getAllergies();
    if (!Util.isNoE(allergies) && !allergies.equals("null")) {
      txtAllergies.setText(allergies);
    }
    String otherMedicalConditions = user.getOtherMedicalConditions();
    if (!Util.isNoE(otherMedicalConditions) && !otherMedicalConditions.equals("null")) {
      txtOtherMedicalConditions.setText(otherMedicalConditions);
    }
    txtProfileCompleteness.setText(getProfileCompletePercentage(user));

  }
  private String getProfileCompletePercentage(ParseUser user)
  {
    int percentage = 0;
    if (!Util.isNoE(user.getString("firstName"))) {
      percentage += 10;
    }
    if (!Util.isNoE(user.getString("mobileNumber"))) {
      percentage += 10;
    }
    if (!Util.isNoE(user.getString("mobileNumber")) && user.getBoolean("phoneVerified")) {
      percentage += 10;
    }
    if ((!Util.isNoE(user.getString("email"))) || user.getUsername().contains("@")) {
      percentage += 10;
    }
    if (!Util.isNoE(user.getString("emergencyContactName"))) {
      percentage += 10;
    }
    if (!Util.isNoE(user.getString("emergencyContactNumber"))) {
      percentage += 10;
    }
    if (!Util.isNoE(user.getString("bloodType"))) {
      percentage += 20;
    }
    if (!Util.isNoE(user.getString("allergies"))) {
      percentage += 10;
    }
    if (!Util.isNoE(user.getString("otherMedicalConditions"))) {
      percentage += 10;
    }
    return getString(R.string.profile_setup, percentage);
  }

  private void showAddPhoneDialog()
  {
    android.app.AlertDialog.Builder alert = new android.app.AlertDialog.Builder(this);
    alert.setTitle(R.string.dialog_title_add_phone);
    alert.setMessage(R.string.dialog_message_add_phone);
    alert.setCancelable(false);
    LayoutInflater inflater = (LayoutInflater) getSystemService(Service.LAYOUT_INFLATER_SERVICE);
    View           view     = inflater.inflate(R.layout.dialog_add_phone, null);
    final EditText etPhone  = view.findViewById(R.id.et_phone);
    alert.setView(view);
    alert.setNegativeButton(R.string.dialog_btn_cancel, (dialog, arg1) -> dialog.dismiss());
    alert.setPositiveButton(R.string.dialog_btn_add, (dialog, which) -> {
    });
    final android.app.AlertDialog dialog = alert.create();
    dialog.show();

    dialog.getButton(android.app.AlertDialog.BUTTON_POSITIVE).setOnClickListener(v -> {
      String phone = etPhone.getText().toString().trim();
      if (phone.isEmpty()) {
        Cell411.get().showAlertDialog(R.string.validation_mobile_number);
      }
    });
  }

  @Override
  public boolean onCreateOptionsMenu(Menu menu)
  {
    MenuInflater inflater = getMenuInflater();
    inflater.inflate(R.menu.menu_profile_view, menu);
    return true;
  }

  @Override
  public boolean onOptionsItemSelected(MenuItem item)
  {
    int itemId = item.getItemId();
    if (itemId == android.R.id.home) {
      finish();
      return true;
    } else if (itemId == R.id.action_edit_profile) {
      Intent intentProfileEdit = new Intent(this, ProfileEditActivity.class);
      startActivity(intentProfileEdit);
      return true;
    }
    return super.onOptionsItemSelected(item);
  }

  public void onClick(View view)
  {
    int id = view.getId();
    if (id == R.id.img_edit) {
      captureAndUploadImage();
    } else if (id == R.id.txt_btn_add_phone) {
      showAddPhoneDialog();
    }
  }
  @CallSuper
  @Override
  protected void onActivityResult(int requestCode, int resultCode,
                                  @Nullable Intent data)
  {
    super.onActivityResult(requestCode, resultCode, data);
  }
  public void captureAndUploadImage()
  {
    imgUser.setImageBitmap(XUser.getPlaceHolder());
    mImagePickerContract.launch(new PicPrefs(XUser.createAvatarName(), "image/*"));
  }
}

