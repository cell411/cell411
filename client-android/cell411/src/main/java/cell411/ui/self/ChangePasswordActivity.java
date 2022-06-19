package cell411.ui.self;

import android.app.Service;
import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.View;
import android.widget.EditText;
import android.widget.ProgressBar;
import android.widget.TextView;

import androidx.appcompat.app.ActionBar;

import cell411.base.BaseActivity;
import com.parse.model.ParseUser;
import com.safearx.cell411.R;

import cell411.Cell411;
import cell411.ui.welcome.RegisterActivity;
import cell411.utils.Util;

/**
 * Created by Sachin on 14-04-2016.
 */
public class ChangePasswordActivity extends BaseActivity implements View.OnClickListener {
  private EditText    etEmail;
  private EditText    etPassword;
  private ProgressBar pb;

  @Override public boolean onOptionsItemSelected(MenuItem item)
  {
    if (item.getItemId() == android.R.id.home) {
      finish();
      return true;
    }
    return super.onOptionsItemSelected(item);
  }

  @Override protected void onCreate(Bundle savedInstanceState)
  {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_login);
    // Set up the action bar.
    final ActionBar actionBar = getSupportActionBar();
    if(actionBar!=null)
      actionBar.setDisplayHomeAsUpEnabled(true);
    pb = findViewById(R.id.pb_progress);
    etEmail = findViewById(R.id.et_email);
    etPassword = findViewById(R.id.et_password);
    TextView btnLogin = findViewById(R.id.txt_btn_login);
    TextView txtBtnForgotPassword = findViewById(R.id.txt_btn_forgot_password);
    TextView txtBtnSignUp = findViewById(R.id.txt_btn_sign_up);
    btnLogin.setOnClickListener(this);
    txtBtnForgotPassword.setOnClickListener(this);
    txtBtnSignUp.setOnClickListener(this);
  }

  @Override public void onClick(View v)
  {
    int id = v.getId();
    if (id == R.id.txt_btn_login) {
      pb.setVisibility(View.VISIBLE);
    } else if (id == R.id.txt_btn_forgot_password) {
      showForgotPasswordDialog();
    } else if (id == R.id.txt_btn_sign_up) {
      Intent intentRegister = new Intent(ChangePasswordActivity.this, RegisterActivity.class);
      startActivity(intentRegister);
      finish();
    }
  }

  private void showForgotPasswordDialog()
  {
    android.app.AlertDialog.Builder alert = new android.app.AlertDialog.Builder(this);
    alert.setTitle("Forgot Password?");
    alert.setMessage("Please enter your email address and tap on Submit");
    alert.setCancelable(false);
    LayoutInflater inflater = (LayoutInflater) getSystemService(Service.LAYOUT_INFLATER_SERVICE);
    View view = inflater.inflate(R.layout.dialog_forgot_password, null);
    final ProgressBar pb = view.findViewById(R.id.pb_progress);
    final EditText etEmail = view.findViewById(R.id.et_email);
    alert.setView(view);
    alert.setNegativeButton("CANCEL", (dialog, arg1) -> dialog.dismiss());
    alert.setPositiveButton("SUBMIT", Util.nullClickListener());
    final android.app.AlertDialog dialog = alert.create();
    dialog.show();
    dialog.getButton(android.app.AlertDialog.BUTTON_POSITIVE)
          .setOnClickListener(v -> {
            if (pb.getVisibility() != View.VISIBLE) {
              final String email = etEmail.getText()
                                          .toString()
                                          .trim();
              if (email.isEmpty()) {
                Cell411.get().showToast("Please enter your email");
                return;
              }
              pb.setVisibility(View.VISIBLE);
              ParseUser.requestPasswordResetInBackground(email, e -> {
                pb.setVisibility(View.GONE);
                if (e == null) {
                  showPasswordResetSentAlert();
                } else {
                  handleException("FIXME:  doing what?", e, null);
                }
                dialog.dismiss();
              });
            }
          });
  }

  private void showPasswordResetSentAlert()
  {
    android.app.AlertDialog.Builder alert = new android.app.AlertDialog.Builder(this);
    alert.setMessage("An email has been sent with reset instructions, please check your email");
    alert.setPositiveButton("OK", Util.nullClickListener());
    final android.app.AlertDialog dialog = alert.create();
    dialog.show();
  }
}

