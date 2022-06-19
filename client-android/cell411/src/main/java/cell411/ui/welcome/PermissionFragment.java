package cell411.ui.welcome;

import android.os.Bundle;
import android.view.View;
import android.widget.TextView;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.safearx.cell411.R;

import java.util.Collection;
import java.util.Map;

import cell411.base.BaseApp;
import cell411.base.BaseFragment;
import cell411.utils.Reflect;
import cell411.utils.XLog;

public class PermissionFragment extends BaseFragment {
  private final static String TAG = Reflect.getTag();

  static {
    XLog.i(TAG, "loading class");
  }

  ActivityResultContracts.RequestMultiplePermissions mContract =
    new ActivityResultContracts.RequestMultiplePermissions();
  ActivityResultLauncher<String[]> mLauncher = registerForActivityResult(mContract, this::callback);

  public PermissionFragment() {
    super(R.layout.activity_permission);
  }

  private void callback(final Map<String, Boolean> results) {
    BaseApp.get().updatePermissions();
  }

  @Override
  public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
    super.onViewCreated(view, savedInstanceState);

    TextView txtPermissionTitle = view.findViewById(R.id.txt_title);
    String title = getString(R.string.permission_title, getString(R.string.app_name));
    txtPermissionTitle.setText(title);
    TextView txtBtnGrantAccess = view.findViewById(R.id.txt_btn_grant_access);
    BaseApp app = BaseApp.get();
    Collection<String> missingPerms = app.getMissingPermissions(activity());
    String[] missingPermArray = missingPerms.toArray(new String[0]);
    txtBtnGrantAccess.setOnClickListener(v -> {
      mLauncher.launch(missingPermArray);
    });
  }
}

