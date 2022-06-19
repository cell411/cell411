package cell411.ui.welcome;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

import androidx.annotation.NonNull;

import cell411.Cell411;
import com.safearx.cell411.R;

import java.util.ArrayList;
import java.util.Locale;

import cell411.base.BaseActivity;
import cell411.methods.Dialogs;
import cell411.utils.XLog;

public class LoginActivity extends BaseActivity {
  private static final String TAG = "LoginActivity";

  static {
    XLog.i(TAG, "loading class");
  }

  private final ArrayList<Button> mButtons = new ArrayList<>();
  private EditText etEmail;
  private EditText etPassword;
  private TextView txtBtnLogin;

  public static void start(Activity activity) {
    Intent loginIntent = new Intent(activity, LoginActivity.class);
    activity.startActivity(loginIntent);
  }

  private void onLoginRes(boolean success) {
    if (success) {
      finish();
    } else {
      Cell411.get().showAlertDialog("Failed to log in.  Please try again");
      txtBtnLogin.setEnabled(true);
    }
  }

  @NonNull
  private String getPassword() {
    return etPassword.getText().toString().trim();
  }

  @NonNull
  private String getEmail() {
    return etEmail.getText().toString().trim().toLowerCase(Locale.US);
  }

  @Override protected void onCreate(Bundle savedInstanceState)
  {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_login);
    etEmail = findViewById(R.id.et_email);
    etPassword = findViewById(R.id.et_password);
    txtBtnLogin = findViewById(R.id.txt_btn_login);
    TextView txtBtnForgotPassword = findViewById(R.id.txt_btn_forgot_password);
    TextView txtBtnSignUp = findViewById(R.id.txt_btn_sign_up);
    txtBtnLogin.setOnClickListener(this::loginClicked);
    txtBtnForgotPassword.setOnClickListener(this::forgotPasswordClicked);
    txtBtnSignUp.setOnClickListener(this::signUpClicked);
    findViewById(R.id.rl_separator).setVisibility(View.GONE);
    findViewById(R.id.txt_copblock_plug).setVisibility(View.VISIBLE);
    mButtons.add(findViewById(R.id.dev1));
    mButtons.add(findViewById(R.id.dev2));
    mButtons.add(findViewById(R.id.dev3));
    mButtons.add(findViewById(R.id.dev4));
    for (Button button : mButtons) {
      button.setOnClickListener(this::quickLogin);
    }
  }

  private void forgotPasswordClicked(View view) {
    Dialogs.showForgotPasswordDialog(this);
    finish();
  }

  private void signUpClicked(View view) {
    RegisterActivity.start(this);
    finish();
  }

  private void loginClicked(View view) {
    String email = getEmail();
    String password = getPassword();
    if (email.isEmpty()) {
      Cell411.get().showToast(R.string.validation_email);
    } else if (password.isEmpty()) {
      Cell411.get().showToast(R.string.validation_password);
    } else {
      hideSoftKeyboard();
      Cell411.get().logIn(email, password, this::onLoginRes);
    }
  }

  private void quickLogin(Button view) {
    String email = view.getText().toString().toLowerCase(Locale.US) + "@copblock.app";
    etEmail.setText(email);
    etPassword.setText(R.string.bullshit_password);
    loginClicked(view);
  }

  private void quickLogin(View view) {
    if (view instanceof Button) {
      quickLogin((Button) view);
    }
  }
}

