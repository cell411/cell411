package cell411.ui.self;

import android.app.AlertDialog;
import android.content.Context;
import android.graphics.Color;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;

import cell411.base.BaseActivity;
import com.parse.ParseQuery;
import com.safearx.cell411.R;

import java.util.ArrayList;
import java.util.Locale;

import cell411.Cell411;
import cell411.enums.BloodType;
import cell411.methods.UtilityMethods;
import cell411.parse.CountryInfo;
import cell411.parse.XUser;
import cell411.utils.XLog;

/**
 * Created by Sachin on 19-04-2016.
 */
public class ProfileEditActivity extends BaseActivity implements View.OnClickListener {
  private static final String                 TAG       = "ProfileEditActivity";
  private              EditText               etFirstName;
  private              EditText               etLastName;
  private              EditText               etEmail;
  private              EditText               etMobileNumber;
  private              EditText               etEmergencyContactName;
  private              EditText               etEmergencyContactPhone;
  private              EditText               etAllergies;
  private              EditText               etOtherMedicalConditions;
  private              android.widget.Spinner spCountryCode;
  private              android.widget.Spinner spEmergencyCountryCode;
  private              ArrayList<CountryInfo> list;
  private              ArrayList<CountryInfo> listEmergencyPhoneCountryCode;
  private              TextView               txtLblAMinus;
  private              TextView               txtLblAPlus;
  private              TextView               txtLblBMinus;
  private              TextView               txtLblBPlus;
  private              TextView               txtLblABMinus;
  private              TextView               txtLblABPlus;
  private              TextView               txtLblOMinus;
  private              TextView               txtLblOPlus;
  private              BloodType              bloodType = null;

  @Override public boolean onCreateOptionsMenu(Menu menu)
  {
    MenuInflater inflater = getMenuInflater();
    inflater.inflate(R.menu.menu_profile_edit, menu);
    return true;
  }

  @Override public boolean onOptionsItemSelected(MenuItem item)
  {
    int itemId = item.getItemId();
    if (itemId == android.R.id.home) {
      finish();
      return true;
    } else if (itemId == R.id.action_done) {
      updateProfile();
      return true;
    }
    return super.onOptionsItemSelected(item);
  }

  @Override protected void onCreate(Bundle savedInstanceState)
  {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_profile_edit);
    // Set up the action bar.
    setDisplayUpAsHome();
    XUser user = XUser.getCurrentUser();
    etFirstName = findViewById(R.id.et_first_name);
    etLastName = findViewById(R.id.et_last_name);
    etEmail = findViewById(R.id.et_email);
    etMobileNumber = findViewById(R.id.et_mobile);
    etEmergencyContactName = findViewById(R.id.et_emergency_name);
    etEmergencyContactPhone = findViewById(R.id.et_emergency_mobile);
    txtLblAMinus = findViewById(R.id.txt_lbl_a_minus);
    txtLblAPlus = findViewById(R.id.txt_lbl_a_plus);
    txtLblBMinus = findViewById(R.id.txt_lbl_b_minus);
    txtLblBPlus = findViewById(R.id.txt_lbl_b_plus);
    txtLblABMinus = findViewById(R.id.txt_lbl_ab_minus);
    txtLblABPlus = findViewById(R.id.txt_lbl_ab_plus);
    txtLblOMinus = findViewById(R.id.txt_lbl_o_minus);
    txtLblOPlus = findViewById(R.id.txt_lbl_o_plus);
    txtLblAMinus.setOnClickListener(this);
    txtLblAPlus.setOnClickListener(this);
    txtLblBMinus.setOnClickListener(this);
    txtLblBPlus.setOnClickListener(this);
    txtLblABMinus.setOnClickListener(this);
    txtLblABPlus.setOnClickListener(this);
    txtLblOMinus.setOnClickListener(this);
    txtLblOPlus.setOnClickListener(this);
    etAllergies = findViewById(R.id.et_allergies);
    etOtherMedicalConditions = findViewById(R.id.et_other_medical_conditions);
    etFirstName.setText(user.getFirstName());
    etLastName.setText(user.getLastName());
    if (user.getUsername()
            .contains("@")) {
      etEmail.setText(user.getUsername());
    } else {
      etEmail.setText(user.getEmail());
    }
    list = new ArrayList<>();
    UtilityMethods.initializeCountryCodeList(list);
    list.add(0, new CountryInfo(getString(R.string.code), getString(R.string.code), null));
    spCountryCode = findViewById(R.id.sp_country_code);
    final CountryListAdapter countryListAdapter = new CountryListAdapter(this, R.layout.cell_country, list);
    countryListAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
    spCountryCode.setAdapter(countryListAdapter);
    spCountryCode.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
      @Override public void onItemSelected(AdapterView<?> adapterView, View view, int position, long l)
      {
        CountryInfo countryInfo = (CountryInfo) spCountryCode.getSelectedItem();
        for (CountryInfo info : list) {
          info.selected = false;
        }
        countryInfo.selected = true;
        XLog.i(TAG,
               "countryInfo: " + countryInfo.name + " (" + countryInfo.shortCode + ") + " + countryInfo.dialingCode);
        XLog.i(TAG, "position: " + position);
        countryListAdapter.notifyDataSetChanged();
      }

      @Override public void onNothingSelected(AdapterView<?> adapterView)
      {
      }
    });
    listEmergencyPhoneCountryCode = new ArrayList<>();
    UtilityMethods.initializeCountryCodeList(listEmergencyPhoneCountryCode);
    listEmergencyPhoneCountryCode.add(0, new CountryInfo(getString(R.string.code), getString(R.string.code), null));
    spEmergencyCountryCode = findViewById(R.id.sp_emergency_mobile_country_code);
    final CountryListAdapter countryListAdapterEmergencyNumber = new CountryListAdapter(this, R.layout.cell_country,
                                                                                        listEmergencyPhoneCountryCode);
    countryListAdapterEmergencyNumber.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
    spEmergencyCountryCode.setAdapter(countryListAdapterEmergencyNumber);
    spEmergencyCountryCode.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
      @Override public void onItemSelected(AdapterView<?> adapterView, View view, int position, long l)
      {
        CountryInfo countryInfo = (CountryInfo) spEmergencyCountryCode.getSelectedItem();
        for (CountryInfo info : listEmergencyPhoneCountryCode) {
          info.selected = false;
        }
        countryInfo.selected = true;
        countryListAdapterEmergencyNumber.notifyDataSetChanged();
        XLog.i(TAG,
               "countryInfo: " + countryInfo.name + " (" + countryInfo.shortCode + ") + " + countryInfo.dialingCode);
        XLog.i(TAG, "position: " + position);
      }

      @Override public void onNothingSelected(AdapterView<?> adapterView)
      {
      }
    });
    String mobileNumber = user.getMobileNumber();
    String emergencyContactNumber = user.getEmergencyContactNumber();
    UtilityMethods.setPhoneAndCountryCode(mobileNumber, etMobileNumber, spCountryCode, list);
    UtilityMethods.setPhoneAndCountryCode(emergencyContactNumber, etEmergencyContactPhone, spEmergencyCountryCode,
                                          list);
    String bloodTypeStr = user.getBloodType();
    if (bloodTypeStr != null && !bloodTypeStr.isEmpty() && !bloodTypeStr.equals("null")) {
      BloodType.forString(bloodTypeStr);
    }
    String emergencyContactName = user.getEmergencyContactName();
    if (emergencyContactName != null && !emergencyContactName.isEmpty() && !emergencyContactName.equals("null")) {
      etEmergencyContactName.setText(emergencyContactName);
    }
    String allergies = user.getAllergies();
    if (allergies != null && !allergies.isEmpty() && !allergies.equals("null")) {
      etAllergies.setText(allergies);
    }
    String otherMedicalConditions = user.getOtherMedicalConditions();
    if (otherMedicalConditions != null && !otherMedicalConditions.isEmpty() && !otherMedicalConditions.equals("null")) {
      etOtherMedicalConditions.setText(otherMedicalConditions);
    }
  }

  @Override protected void onResume()
  {
    super.onResume();
    UtilityMethods.setPhoneAndCountryCode(XUser.getCurrentUser()
                                                  .getString("mobileNumber"), etMobileNumber, spCountryCode, list);
  }

  @Override public void onClick(View v)
  {
    int id = v.getId();
    if (id == R.id.txt_lbl_a_minus) {
      selectBloodType(BloodType.A_MINUS);
    } else if (id == R.id.txt_lbl_a_plus) {
      selectBloodType(BloodType.A_PLUS);
    } else if (id == R.id.txt_lbl_b_minus) {
      selectBloodType(BloodType.B_MINUS);
    } else if (id == R.id.txt_lbl_b_plus) {
      selectBloodType(BloodType.B_PLUS);
    } else if (id == R.id.txt_lbl_ab_minus) {
      selectBloodType(BloodType.AB_MINUS);
    } else if (id == R.id.txt_lbl_ab_plus) {
      selectBloodType(BloodType.AB_PLUS);
    } else if (id == R.id.txt_lbl_o_minus) {
      selectBloodType(BloodType.O_MINUS);
    } else if (id == R.id.txt_lbl_o_plus) {
      selectBloodType(BloodType.O_PLUS);
    }
  }

  private void updateProfile()
  {
    final String email = etEmail.getText()
                                .toString()
                                .toLowerCase(Locale.US)
                                .trim();
    String firstName = etFirstName.getText()
                                  .toString()
                                  .trim();
    String lastName = etLastName.getText()
                                .toString()
                                .trim();
    String mobileNumber = etMobileNumber.getText()
                                        .toString()
                                        .trim();
    String countryCode = "";
    if (spCountryCode.getSelectedItemPosition() > 0) {
      countryCode = ((CountryInfo) spCountryCode.getSelectedItem()).dialingCode;
    }
    // Check if the mobile number is changed, user needs to re-verify it
    // if the number is changed
    final String newMobileNumber = XUser.getCurrentUser()
                                           .getMobileNumber();
    boolean mobileNumberChanged = newMobileNumber == null || !newMobileNumber.replaceAll("[\\D]+", "")
                                                                             .equals(countryCode + mobileNumber);
    if (email.isEmpty() && XUser.getCurrentUser()
                                   .getUsername()
                                   .contains("@")) {
      Cell411.get().showToast(R.string.please_enter_email);
    } else if (firstName.isEmpty()) {
      Cell411.get().showToast(R.string.please_enter_first_name);
    } else if (lastName.isEmpty()) {
      Cell411.get().showToast(R.string.please_enter_lastname);
    } else if (mobileNumber.isEmpty() && XUser.getCurrentUser()
                                                 .getUsername()
                                                 .contains("@")) {
      Cell411.get().showToast(R.string.please_enter_mobile_number);
    } else if (spCountryCode.getSelectedItemPosition() < 1 && XUser.getCurrentUser()
                                                                      .getUsername()
                                                                      .contains("@")) {
      Cell411.get().showToast(R.string.please_select_country_code);
    } else {
      final XUser parseUser = XUser.getCurrentUser();
      if (mobileNumberChanged) {
        // Check if the mobile number is not already registered
        ParseQuery<XUser> userParseQuery = ParseQuery.getQuery("_User");
        userParseQuery.whereNotEqualTo("objectId", XUser.getCurrentUser()
                                                           .getObjectId());
        userParseQuery.whereEqualTo("mobileNumber", countryCode + mobileNumber.trim());
        userParseQuery.findInBackground((objects, e) -> {
          if (e == null) {
            if (objects == null || objects.size() == 0) { // no records found, hence
              checkEmailAndSave(parseUser, email);
            } else {
              Cell411.get().showToast(R.string.mobile_already_registered);
            }
          } else {
            handleException("FIXME:  doing what?", e, null);
          }
        });
      } else {
        checkEmailAndSave(parseUser, email);
      }
    }
  }

  private void checkEmailAndSave(final XUser parseUser, final String email)
  {
    final XUser currentUser = XUser.getCurrentUser();
    final String objectId = currentUser.getObjectId();
    if (currentUser.getUsername()
                   .contains("@")) {
      ParseQuery<XUser> userParseQuery = ParseQuery.getQuery("_User");
      userParseQuery.whereEqualTo("email", email);
      userParseQuery.findInBackground((list, e) -> {
        System.out.println("entering done");
        boolean fail = false;
        if (e != null) {
          handleException("FIXME:  doing what?", e, null);
          return;
        }
        if (list != null && list.size() > 0) {
          System.out.println(currentUser.getObjectId());
          System.out.println(currentUser.getEmail());
          for (XUser user : list) {
            if (user.getObjectId()
                    .equals(objectId)) {
              continue;
            }
            fail = true;
            break;
          }
        }
        if (fail) {
          showEmailAlreadyRegisteredAlert(email);
        } else {
          parseUser.setUsername(email.toLowerCase(Locale.US)
                                     .trim());
          saveUser(parseUser);
        }
      });
    } else if (!email.isEmpty()) {
      XLog.i("ProfileEditActivity", "!email.isEmpty()");
      ParseQuery<XUser> userParseQuery = ParseQuery.getQuery("_User");
      userParseQuery.whereEqualTo("username", email);
      userParseQuery.findInBackground((list, e) -> {
        if (e == null) {
          if (list == null || list.size() == 0) {
            parseUser.setEmail(email.toLowerCase(Locale.US)
                                    .trim());
            saveUser(parseUser);
          } else {
            // show email already registered
            showEmailAlreadyRegisteredAlert(email);
          }
        } else {
          handleException("FIXME:  doing what?", e, null);
        }
      });
    } else {
      saveUser(parseUser);
    }
  }

  private void showEmailAlreadyRegisteredAlert(String email)
  {
    AlertDialog.Builder alert = new AlertDialog.Builder(this);
    alert.setMessage(email + " " + getString(R.string.email_already_registered));
    alert.setPositiveButton(R.string.dialog_btn_ok, (dialog, which) -> dialog.dismiss());
    alert.create()
         .show();
  }

  /*
  Method to actually update values on Parse db
   */
  private void saveUser(final XUser parseUser)
  {
    String firstName = etFirstName.getText()
                                  .toString()
                                  .trim();
    String lastName = etLastName.getText()
                                .toString()
                                .trim();
    String countryCode = "";
    if (spCountryCode.getSelectedItemPosition() > 0) {
      countryCode = ((CountryInfo) spCountryCode.getSelectedItem()).dialingCode;
    }
    final String mobileNumber = etMobileNumber.getText()
                                              .toString()
                                              .trim();
    String emergencyCountryCode = "";
    if (spEmergencyCountryCode.getSelectedItemPosition() > 0) {
      emergencyCountryCode = ((CountryInfo) spEmergencyCountryCode.getSelectedItem()).dialingCode;
    }
    String emergencyContactName = etEmergencyContactName.getText()
                                                        .toString()
                                                        .trim();
    String emergencyContactPhone = etEmergencyContactPhone.getText()
                                                          .toString()
                                                          .trim();
    String bType = "";
    if (bloodType != null) {
      bType = bloodType.altName();
    }
    String allergies = etAllergies.getText()
                                  .toString()
                                  .trim();
    String otherMedicalConditions = etOtherMedicalConditions.getText()
                                                            .toString()
                                                            .trim();
    if (!mobileNumber.isEmpty()) {
      parseUser.put("mobileNumber", countryCode + mobileNumber.trim());
    } else {
      parseUser.put("mobileNumber", mobileNumber.trim());
    }
    parseUser.put("firstName", firstName.trim());
    parseUser.put("lastName", lastName.trim());
    parseUser.put("emergencyContactName", emergencyContactName.trim());
    if (!emergencyContactPhone.isEmpty()) {
      parseUser.put("emergencyContactNumber", emergencyCountryCode + emergencyContactPhone.trim());
    } else {
      parseUser.put("emergencyContactNumber", emergencyContactPhone.trim());
    }
    parseUser.put("bloodType", bType);
    parseUser.put("allergies", allergies.trim());
    parseUser.put("otherMedicalConditions", otherMedicalConditions.trim());
    parseUser.saveInBackground(e -> {
      {
        if (e == null) {
          // Make an API call to LMA server for the updated user information
          Cell411.get().showToast(R.string.account_updated_successfully);
          finish();
        } else {
          handleException("FIXME:  doing what?", e, null);
        }
      }
    });
  }

  private void selectBloodType(BloodType bType)
  {
    txtLblAMinus.setBackgroundResource(R.drawable.bg_blood_group_gray_border);
    txtLblAMinus.setTextColor(Color.parseColor("#999999"));
    txtLblAPlus.setBackgroundResource(R.drawable.bg_blood_group_gray_border);
    txtLblAPlus.setTextColor(Color.parseColor("#999999"));
    txtLblBMinus.setBackgroundResource(R.drawable.bg_blood_group_gray_border);
    txtLblBMinus.setTextColor(Color.parseColor("#999999"));
    txtLblBPlus.setBackgroundResource(R.drawable.bg_blood_group_gray_border);
    txtLblBPlus.setTextColor(Color.parseColor("#999999"));
    txtLblABMinus.setBackgroundResource(R.drawable.bg_blood_group_gray_border);
    txtLblABMinus.setTextColor(Color.parseColor("#999999"));
    txtLblABPlus.setBackgroundResource(R.drawable.bg_blood_group_gray_border);
    txtLblABPlus.setTextColor(Color.parseColor("#999999"));
    txtLblOMinus.setBackgroundResource(R.drawable.bg_blood_group_gray_border);
    txtLblOMinus.setTextColor(Color.parseColor("#999999"));
    txtLblOPlus.setBackgroundResource(R.drawable.bg_blood_group_gray_border);
    txtLblOPlus.setTextColor(Color.parseColor("#999999"));
    switch (bType) {
      case A_MINUS:
        if (bloodType != null && bloodType == BloodType.A_MINUS) {
          bloodType = null;
          return;
        }
        txtLblAMinus.setBackgroundResource(R.drawable.bg_blood_group_highlight);
        txtLblAMinus.setTextColor(Color.WHITE);
        bloodType = BloodType.A_MINUS;
        break;
      case A_PLUS:
        if (bloodType != null && bloodType == BloodType.A_PLUS) {
          bloodType = null;
          return;
        }
        txtLblAPlus.setBackgroundResource(R.drawable.bg_blood_group_highlight);
        txtLblAPlus.setTextColor(Color.WHITE);
        bloodType = BloodType.A_PLUS;
        break;
      case B_MINUS:
        if (bloodType != null && bloodType == BloodType.B_MINUS) {
          bloodType = null;
          return;
        }
        txtLblBMinus.setBackgroundResource(R.drawable.bg_blood_group_highlight);
        txtLblBMinus.setTextColor(Color.WHITE);
        bloodType = BloodType.B_MINUS;
        break;
      case B_PLUS:
        if (bloodType != null && bloodType == BloodType.B_PLUS) {
          bloodType = null;
          return;
        }
        txtLblBPlus.setBackgroundResource(R.drawable.bg_blood_group_highlight);
        txtLblBPlus.setTextColor(Color.WHITE);
        bloodType = BloodType.B_PLUS;
        break;
      case AB_MINUS:
        if (bloodType != null && bloodType == BloodType.AB_MINUS) {
          bloodType = null;
          return;
        }
        txtLblABMinus.setBackgroundResource(R.drawable.bg_blood_group_highlight);
        txtLblABMinus.setTextColor(Color.WHITE);
        bloodType = BloodType.AB_MINUS;
        break;
      case AB_PLUS:
        if (bloodType != null && bloodType == BloodType.AB_PLUS) {
          bloodType = null;
          return;
        }
        txtLblABPlus.setBackgroundResource(R.drawable.bg_blood_group_highlight);
        txtLblABPlus.setTextColor(Color.WHITE);
        bloodType = BloodType.AB_PLUS;
        break;
      case O_MINUS:
        if (bloodType != null && bloodType == BloodType.O_MINUS) {
          bloodType = null;
          return;
        }
        txtLblOMinus.setBackgroundResource(R.drawable.bg_blood_group_highlight);
        txtLblOMinus.setTextColor(Color.WHITE);
        bloodType = BloodType.O_MINUS;
        break;
      case O_PLUS:
        if (bloodType != null && bloodType == BloodType.O_PLUS) {
          bloodType = null;
          return;
        }
        txtLblOPlus.setBackgroundResource(R.drawable.bg_blood_group_highlight);
        txtLblOPlus.setTextColor(Color.WHITE);
        bloodType = BloodType.O_PLUS;
        break;
    }
  }

  private static class ItemViewHolder {
    TextView  txtCountryName;
    TextView  txtCountryCode;
    ImageView imgFlag;
    ImageView imgTick;
  }

  private class CountryListAdapter extends ArrayAdapter<CountryInfo> {
    private final ArrayList<CountryInfo> list;
    private final int                    resourceId;
    private final LayoutInflater         inflater;

    public CountryListAdapter(Context context, int resourceId, ArrayList<CountryInfo> list)
    {
      super(context, resourceId, list);
      this.list = list;
      this.resourceId = resourceId;
      inflater = getLayoutInflater();
    }

    @Override public View getView(final int position, View convertView, ViewGroup parent)
    {
      ItemViewHolder holder;
      CountryInfo item = list.get(position);
      if (convertView == null) {
        holder = new ItemViewHolder();
        convertView = inflater.inflate(R.layout.cell_country_code, null);
        holder.txtCountryCode = convertView.findViewById(R.id.txt_country_code);
        convertView.setTag(holder);
      }
      holder = (ItemViewHolder) convertView.getTag();
      if (item.shortCode == null) {
        holder.txtCountryCode.setText(item.name);
        holder.txtCountryCode.setTextColor(getColor(R.color.highlight_color_light));
      } else {
        final String text = "+" + item.dialingCode;
        holder.txtCountryCode.setText(text);
      }
      return convertView;
    }

    @Override public View getDropDownView(int position, View convertView, @NonNull ViewGroup parent)
    {
      ItemViewHolder holder;
      CountryInfo item = list.get(position);
      if (convertView == null) {
        holder = new ItemViewHolder();
        convertView = inflater.inflate(resourceId, null);
        holder.txtCountryName = convertView.findViewById(R.id.txt_country_name);
        holder.imgFlag = convertView.findViewById(R.id.img_flag);
        holder.imgTick = convertView.findViewById(R.id.img_tick);
        convertView.setTag(holder);
      }
      holder = (ItemViewHolder) convertView.getTag();
      if (item.shortCode == null) {
        holder.txtCountryName.setText(item.name);
        holder.imgFlag.setImageBitmap(null);
        holder.imgTick.setVisibility(View.GONE);
      } else {
        final String text = item.name + " +" + item.dialingCode;
        holder.txtCountryName.setText(text);
        holder.imgFlag.setImageResource(item.flagId);
        if (item.selected) {
          holder.imgTick.setVisibility(View.VISIBLE);
        } else {
          holder.imgTick.setVisibility(View.GONE);
        }
      }
      return convertView;
    }
  }
}

