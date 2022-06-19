package cell411.ui.welcome;

import android.annotation.TargetApi;
import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.text.style.ClickableSpan;
import android.text.style.URLSpan;
import android.view.View;
import android.widget.EditText;
import android.widget.Spinner;
import android.widget.TextView;

import cell411.base.BaseActivity;
import com.safearx.cell411.R;

import org.jetbrains.annotations.NotNull;

import cell411.Cell411;
import cell411.parse.CountryInfo;
import cell411.utils.Cell411GuiUtils;
import cell411.utils.Reflect;
import cell411.utils.XLog;

/**
 * Created by Sachin on 14-04-2016.
 */
public class RegisterActivity extends BaseActivity implements View.OnClickListener {
  private static final String                 TAG = Reflect.getTag();
  static {
    XLog.i(TAG, "loading class");
  }
  private              EditText               etEmail;
  private              EditText               etPassword;
  private              EditText               etFirstName;
  private              EditText               etLastName;
  private              EditText               etMobile;
  private              Spinner                spCountryCode;

  public static void start(Activity activity) {
    Intent intent = new Intent(activity, RegisterActivity.class);
    activity.startActivity(intent);
  }

  @Override protected void onResume() {
    super.onResume();
  }

  @NotNull private ClickableSpan getClickableSpan(URLSpan span) {
    return new ClickableSpan() {
      public void onClick(View view)
      {
        if (span.getURL()
                .equals("terms")) {
          Intent intentWeb = new Intent(Intent.ACTION_VIEW);
          intentWeb.setData(Uri.parse(getString(R.string.terms_and_conditions_url)));
          startActivity(intentWeb);
        }
      }
    };
  }

  @Override public void onClick(View v)
  {
    int id = v.getId();
    if (id == R.id.txt_btn_sign_up) {
      signUp();
    } else if (id == R.id.lbl_terms_and_conditions_part_1) {
      Intent intentWeb = new Intent(Intent.ACTION_VIEW);
      intentWeb.setData(Uri.parse(getString(R.string.terms_and_conditions_url)));
      startActivity(intentWeb);
    } else if (id == R.id.txt_btn_sign_in) {
      LoginActivity.start(this);
      finish();
    }
  }

  private void signUp()
  {
    final String email = etEmail.getText()
                                .toString()
                                .trim();
    final String password = etPassword.getText()
                                      .toString()
                                      .trim();
    final String firstName = etFirstName.getText()
                                        .toString()
                                        .trim();
    final String lastName = etLastName.getText()
                                      .toString()
                                      .trim();
    String mobileNumber = etMobile.getText()
                                  .toString()
                                  .trim();
    if (email.isEmpty()) {
      Cell411.get().showToast(R.string.validation_email);
    } else if (!email.contains("@")) {
      Cell411.get().showToast(R.string.validation_email_invalid);
    } else if (password.isEmpty()) {
      Cell411.get().showToast(R.string.validation_password);
    } else if (firstName.isEmpty()) {
      Cell411.get().showToast(R.string.validation_firstname);
    } else if (lastName.isEmpty()) {
      Cell411.get().showToast(R.string.validation_lastname);
    } else if (mobileNumber.isEmpty()) {
      Cell411.get().showToast(R.string.validation_mobile_number);
    } else {
      if (!mobileNumber.startsWith("+")) {
        mobileNumber = ((CountryInfo) spCountryCode.getSelectedItem()).dialingCode + mobileNumber.trim();
      }
      Cell411.get().signUp(email, password, firstName, lastName,
        mobileNumber, this::signUpRes);
    }
  }

  private void signUpRes(boolean b) {
    if (!b) {
      Cell411.get().showAlertDialog("Failed to register.  Please try again");
      setResult(RESULT_CANCELED);
    }
    finish();
  }

  @Override protected void onActivityResult(int requestCode, int resultCode, Intent data)
  {
    super.onActivityResult(requestCode, resultCode, data);
  }

  @TargetApi(Build.VERSION_CODES.LOLLIPOP) @Override protected void onCreate(Bundle savedInstanceState)
  {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_register);
    etEmail = findViewById(R.id.et_email);
    etPassword = findViewById(R.id.et_password);
    etFirstName = findViewById(R.id.et_first_name);
    etLastName = findViewById(R.id.et_last_name);
    etMobile = findViewById(R.id.et_mobile);
    TextView txtBtnSignUp = findViewById(R.id.txt_btn_sign_up);
    TextView txtBtnTermsAndConditions = findViewById(R.id.lbl_terms_and_conditions_part_1);
    txtBtnTermsAndConditions.setOnClickListener(this);
    String text = getString(R.string.t_n_c, getString(R.string.app_name), getString(R.string.btn_terms_and_conditions));
    Cell411GuiUtils.setTextViewHTML(txtBtnTermsAndConditions, text, this::getClickableSpan);
    TextView txtBtnSignIn = findViewById(R.id.txt_btn_sign_in);
    txtBtnSignUp.setOnClickListener(this);
    txtBtnSignIn.setOnClickListener(this);
    findViewById(R.id.rl_separator).setVisibility(View.GONE);
    spCountryCode= Cell411GuiUtils.createCCSpinner(RegisterActivity.this, null, null);
  }
}

