package cell411.ui.welcome;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.text.style.ClickableSpan;
import android.text.style.URLSpan;
import android.view.View;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.safearx.cell411.R;

import org.jetbrains.annotations.NotNull;

import java.util.ArrayList;

import cell411.Cell411;
import cell411.base.BaseApp;
import cell411.base.BaseFragment;
import cell411.parse.XUser;
import cell411.utils.Cell411GuiUtils;

public class UserConsentFragment extends BaseFragment {
  private ArrayList<CheckBox> mCBList;

  public UserConsentFragment() {
    super(R.layout.activity_user_consent);
  }

  @Override
  public void onViewCreated(@NonNull @NotNull View view,
                            @Nullable Bundle savedInstanceState) {
    super.onViewCreated(view, savedInstanceState);
    super.onCreate(savedInstanceState);
    TextView txtTitle = view.findViewById(R.id.page_title);
    String textTitle = getString(R.string.title_privacy_policy);
    Cell411GuiUtils.setTextViewHTML(txtTitle, textTitle, PolicySpan::new);
    TextView txtDescription = view.findViewById(R.id.description);
    String textDescription = getString(R.string.description_privacy_policy);
    Cell411GuiUtils.setTextViewHTML(txtDescription, textDescription, PolicySpan::new);
    mCBList = new ArrayList<>();
    mCBList.add(view.findViewById(R.id.cb_we_dont_sell_or_give_data));
    mCBList.add(view.findViewById(R.id.cb_can_delete_account));
    mCBList.add(view.findViewById(R.id.cb_you_agree_to_process_data));
    mCBList.add(view.findViewById(R.id.cb_read_privacy_policy));
    final TextView txtBtnOk = view.findViewById(R.id.txt_btn_ok);
    CompoundButton.OnCheckedChangeListener onCheckedChangeListener =
      (compoundButton, isChecked) -> {
        if (allChecked(mCBList)) {
          txtBtnOk.setBackgroundResource(R.drawable.ripple_btn);
        } else {
          txtBtnOk.setBackgroundColor(Cell411.get().getColor(R.color.gray_999));
        }
      };
    for (CheckBox box : mCBList) {
      box.setOnCheckedChangeListener(onCheckedChangeListener);
    }
    txtBtnOk.setOnClickListener(this::onConsentClicked);
  }

  private void onConsentClicked(View view) {
    if (allChecked(mCBList)) {

      ds().onDS((() -> {
        XUser user = XUser.getCurrentUser();
        user.setConsented(true);
        user.save();
        BaseApp.get().xpr().updateConsent();
      }));
    } else {
      Cell411.get().showAlertDialog(getString(R.string.consent_instruction));
    }
  }


  private boolean allChecked(ArrayList<CheckBox> cbList) {
    for (CheckBox box : cbList) {
      if (!box.isChecked()) {
        return false;
      }
    }
    return true;
  }


  class PolicySpan extends ClickableSpan {
    private final URLSpan span;

    PolicySpan(URLSpan span) {
      this.span = span;
    }

    public void onClick(View view) {
      String url;
      String spanUrl = span.getURL();
      if (spanUrl.equalsIgnoreCase("terms")) {
        url = getString(R.string.terms_and_conditions_url);
      } else if (spanUrl.equalsIgnoreCase("privacy_policy")) {
        url = getString(R.string.privacy_policy_url);
      } else {
        Cell411.get().showAlertDialog("Unexpected link url: " + spanUrl);
        return;
      }
      Intent intentWeb = new Intent(Intent.ACTION_VIEW);
      if (!url.isEmpty()) {
        intentWeb.setData(Uri.parse(url));
      }
      startActivity(intentWeb);
    }
  }
}

