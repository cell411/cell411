package cell411.ui;

import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.util.AttributeSet;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.safearx.cell411.R;

import cell411.base.BaseContext;
import cell411.parse.XUser;
import cell411.utils.Util;

public class NavHeaderMain extends RelativeLayout
  implements BaseContext
{
  private final ImageView imgUser;
  private final TextView txtName;
  private final TextView txtEmail;
  private final TextView txtBloodGroup;
  private final TextView txtVersion;

  public NavHeaderMain(Context context) {
    this(context, null);
  }

  public NavHeaderMain(Context context, AttributeSet attrs) {
    this(context, attrs, 0);
  }

  public NavHeaderMain(Context context, AttributeSet attrs, int defStyleAttr) {
    this(context, attrs, defStyleAttr, 0);
  }

  public NavHeaderMain(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes) {
    super(context, attrs, defStyleAttr, defStyleRes);

    imgUser = findViewById(R.id.img_user);
    txtName = findViewById(R.id.txt_name);
    txtEmail = findViewById(R.id.txt_email);
    txtBloodGroup = findViewById(R.id.txt_blood_group);
    txtVersion = findViewById(R.id.txt_version);
  }
  
  public String getVersion() {
    try {
      Context context = getContext();
      PackageManager manager = context.getPackageManager();
      String packageName = context.getPackageName();
      PackageInfo pInfo = manager.getPackageInfo(packageName, 0);
      
      return pInfo.versionName;
    } catch (PackageManager.NameNotFoundException e) {
      e.printStackTrace();
      return "Error";
    }
  }

  public void updateUI() {
    boolean loggedIn = app().isLoggedIn();

    if (loggedIn) {
      XUser user = XUser.getCurrentUser();
      if (imgUser != null) {
        imgUser.setImageBitmap(user.getThumbNailPic(imgUser::setImageBitmap));
      }
      if (txtName != null)
        txtName.setText(Util.nvl(user.getName(), "no name"));
      if (txtEmail != null)
        txtEmail.setText(Util.nvl(user.getEmail(), "no email"));
      if (txtBloodGroup != null) {
        txtBloodGroup.setText(Util.nvl(user.getBloodType(),
          getString(R.string.not_available)));
      }
      if(txtVersion!=null)
        txtVersion.setText(getVersion());
    }
  }
}
