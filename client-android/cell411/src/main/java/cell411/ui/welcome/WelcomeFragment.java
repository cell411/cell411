package cell411.ui.welcome;

import android.os.Bundle;
import android.view.View;

import androidx.annotation.NonNull;

import com.safearx.cell411.R;

import java.util.Arrays;
import java.util.List;

import javax.annotation.Nullable;

import cell411.base.BaseFragment;
import cell411.base.FragmentFactory;
import cell411.base.SelectFragment;
import cell411.parse.util.XParse;
import cell411.utils.Reflect;
import cell411.utils.Util;
import cell411.utils.XLog;

/**
 * Created by Sachin on 14-04-2016.
 */
public class WelcomeFragment extends SelectFragment {
  public static final String TAG = Reflect.getTag();
  static final List<Class<? extends BaseFragment>> smClasses = Arrays.asList(
    StartFragment.class,
    PermissionFragment.class,
    GalleryFragment.class,
    UserConsentFragment.class,
    SelectRingtoneFragment.class
  );
  static {
    XLog.i(TAG, "loading class: " + WelcomeFragment.class);
  }
  static final List<FragmentFactory> smFactories =
    Util.transform(smClasses, FragmentFactory::fromClass);

  public WelcomeFragment() {
    super(R.layout.activity_welcome);
  }

  @Override
  public List<FragmentFactory> createFactories() {
    return smFactories;
  }

  @Override
  public void onResume() {
    super.onResume();
    app().addStateObserver(this::onSystemStateChange);
    onSystemStateChange(app().getState(),null);
  }

  @Override
  public void onPause() {
    super.onPause();
    app().removeStateObserver(this::onSystemStateChange);
  }

  private void onSystemStateChange(@Nullable XParse.State newState,
                                   @Nullable XParse.State oldState) {
    if (newState == null) {
      return;
    }
    switch (newState) {
      default:
        break;
      case WaitingForLogin:
        selectFragment(smClasses.indexOf(GalleryFragment.class));
        break;
      case WaitingForPermission:
        selectFragment(smClasses.indexOf(PermissionFragment.class));
        break;
      case WaitingForConsent:
        selectFragment(smClasses.indexOf(UserConsentFragment.class));
        break;
      case WaitingForRingtones:
        selectFragment(smClasses.indexOf(SelectRingtoneFragment.class));
        break;
    }
  }

  @Override
  public void onViewCreated(@NonNull final View view,
                            @androidx.annotation.Nullable final Bundle savedInstanceState) {
    super.onViewCreated(view, savedInstanceState);
    selectFragment(smClasses.indexOf(BaseFragment.class));
  }

}
