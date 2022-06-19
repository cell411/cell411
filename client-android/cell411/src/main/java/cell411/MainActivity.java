package cell411;

import static cell411.parse.util.XParse.State.Ready;

import android.app.Activity;
import android.content.Intent;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffColorFilter;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Bundle;
import android.text.SpannableString;
import android.text.style.TextAppearanceSpan;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.ActionBarDrawerToggle;
import androidx.appcompat.widget.Toolbar;
import androidx.core.app.TaskStackBuilder;
import androidx.core.content.res.ResourcesCompat;
import androidx.core.view.GravityCompat;
import androidx.drawerlayout.widget.DrawerLayout;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentTransaction;

import com.google.android.material.navigation.NavigationView;
import com.safearx.cell411.R;

import cell411.base.BaseActivity;
import cell411.base.BaseApp;
import cell411.base.BaseFragment;
import cell411.logic.LiveQueryService;
import cell411.methods.Dialogs;
import cell411.parse.XEntity;
import cell411.parse.util.OnCompletionListener;
import cell411.parse.util.XParse.State;
import cell411.ui.NavHeaderMain;
import cell411.ui.self.ChangePasswordActivity;
import cell411.ui.self.ProfileViewActivity;
import cell411.ui.self.XBlinkingRedSymbol;
import cell411.ui.utils.AboutActivity;
import cell411.ui.utils.CustomNotificationActivity;
import cell411.ui.utils.KnowYourRightsActivity;
import cell411.ui.utils.SettingsActivity;
import cell411.ui.welcome.WelcomeFragment;
import cell411.utils.PrintString;
import cell411.utils.Reflect;
import cell411.utils.Util;
import cell411.utils.ValueObserver;
import cell411.utils.XLog;

public class MainActivity extends BaseActivity
  implements NavigationView.OnNavigationItemSelectedListener {
  private static final String TAG = Reflect.getTag();

  static {
    XLog.i(TAG, "loading class");
  }

  private final MainFragment mMainFragment = new MainFragment();
  private final WelcomeFragment mWelcomeFragment = new WelcomeFragment();
  @Nullable
  private MenuItem miNotification, miDataRefresh;
  private NavHeaderMain mNavHeaderMain;
  private long previousBackTapMillis = 0;
  private LinearLayout mStatusBar;
  private TextView mLabel;
  private TextView mStatus;
  private XBlinkingRedSymbol mBlinker;
  @Nullable
  private final ValueObserver<State> mStateChanged = this::onChange;
  private final ValueObserver<Boolean> mBooleanChanged = this::onChange;
  public MainActivity() {
    super(R.layout.activity_main);
  }

  public <X> void onChange(X newValue, X oldValue) {
    updateUi();
  }

  public void updateUi() {
    State newState = xpr().getState();
    BaseFragment fragment = newState == Ready ? mMainFragment : mWelcomeFragment;
    if (fragment != null && !fragment.isAdded()) {
      FragmentManager fm = getSupportFragmentManager();
      FragmentTransaction xaction = fm.beginTransaction();
      BaseFragment other = fragment == mMainFragment ? mWelcomeFragment : mMainFragment;
      if(other.isAdded()) {
        xaction.remove(other);
      }
      xaction.replace(R.id.pager, fragment);
      xaction.commit();
    }
    mNavHeaderMain.updateUI();
    BaseApp app = app();
    mStatus.setText(Util.makeWords(String.valueOf(newState)));
    int visibility = app.isConnected() ? View.GONE : View.VISIBLE;
    if(visibility!=mBlinker.getVisibility())
      mBlinker.setVisibility(visibility);
    boolean allSet = app.isConnected() && newState == Ready;
    if(allSet) {
      mStatusBar.setVisibility(View.GONE);
    } else {
      mStatusBar.setVisibility(View.VISIBLE);
    }
  }

  @Override
  public void onPrepareSupportNavigateUpTaskStack(@NonNull TaskStackBuilder builder) {
    super.onPrepareSupportNavigateUpTaskStack(builder);
  }

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    mStatusBar = findViewById(R.id.status_bar);
    mLabel = findViewById(R.id.lbl_status);
    if(mLabel!=null) {
      mLabel.setTextSize(20);
    }
    mStatus = findViewById(R.id.status);
    if (mStatus != null) {
      mStatus.setTextSize(20);
    }
    mBlinker = findViewById(R.id.blinker);
    Toolbar toolbar = findViewById(R.id.toolbar);
    setSupportActionBar(toolbar);
    DrawerLayout drawer = findViewById(R.id.drawer_layout);
    if (drawer != null) {
      ActionBarDrawerToggle toggle =
        new ActionBarDrawerToggle(this, drawer, toolbar, R.string.navigation_drawer_open,
          R.string.navigation_drawer_close);
      drawer.addDrawerListener(toggle);
      toggle.syncState();
    }
    setupNavigationView();
  }


  @Override
  public void prepareToLoad() {
    if (mMainFragment.isAdded()) {
      mMainFragment.prepareToLoad();
    }
    if (mWelcomeFragment.isAdded()) {
      mWelcomeFragment.prepareToLoad();
    }
  }

  @Override
  public void populateUI() {
    if (mMainFragment.isAdded())
      mMainFragment.populateUI();
    if (mWelcomeFragment.isAdded())
      mWelcomeFragment.populateUI();
  }

  @Override
  public void loadData() {
    Reflect.announce(true);
    if (mMainFragment.isAdded())
      mMainFragment.loadData();
    if (mWelcomeFragment.isAdded())
      mWelcomeFragment.loadData();
  }

  private void setupNavigationView() {
    NavigationView navigationView = findViewById(R.id.nav_view);
    if (navigationView == null) {
      return;
    }
    navigationView.setNavigationItemSelectedListener(this);
    Menu navMenu = navigationView.getMenu();
    setActionView(navMenu, R.id.nav_share_this_app);
    setActionView(navMenu, R.id.nav_rate_this_app);
    setActionView(navMenu, R.id.nav_faq_and_tutorials);
    setActionVisible(navMenu, R.id.nav_notifications);
    setActionVisible(navMenu, R.id.nav_know_your_rights);
    MenuItem miLogout = navMenu.findItem(R.id.nav_logout);
    if (miLogout != null) {
      SpannableString s = new SpannableString(miLogout.getTitle());
      s.setSpan(new TextAppearanceSpan(this, R.style.TextAppearanceLogout), 0, s.length(), 0);
      miLogout.setTitle(s);
      Drawable mDrawableLogout =
        ResourcesCompat.getDrawable(getResources(), R.drawable.nav_logout, getTheme());
      assert mDrawableLogout != null;
      mDrawableLogout.setColorFilter(
        new PorterDuffColorFilter(getColor(R.color.highlight_color_dark),
          PorterDuff.Mode.MULTIPLY));
      miLogout.setIcon(mDrawableLogout);
    }
    mNavHeaderMain = (NavHeaderMain) navigationView.inflateHeaderView(R.layout.nav_header_main);
  }

  private void setActionVisible(Menu navMenu, int itemId) {
    if (navMenu == null) {
      return;
    }
    MenuItem item = navMenu.findItem(itemId);
    if (item == null) {
      return;
    }
    item.setVisible(true);
  }

  private void setActionView(Menu navMenu, int nav_share_this_app) {
    if (navMenu == null) {
      return;
    }
    MenuItem item = navMenu.findItem(nav_share_this_app);
    if (item == null) {
      return;
    }
    item.setActionView(R.layout.layout_outside_link);
  }

  @Override
  protected void onResume() {
    super.onResume();
    Cell411 app = Cell411.get();
    app.addStateObserver(mStateChanged);
    app.addConnectionListener(mBooleanChanged);
    app.addLoggedInObserver(mBooleanChanged);

    if (Cell411.get().isDarkModeChanged()) {
      Cell411.get().setDarkModeChanged(false);
      recreate();
    }
  }

  @Override
  protected void onPause() {
    super.onPause();
    app().removeStateObserver(mStateChanged);
    app().removeConnectionListener(mBooleanChanged);
    app().removeLoggedInObserver(mBooleanChanged);
  }

  @Override
  public boolean onCreateOptionsMenu(Menu menu) {
    getMenuInflater().inflate(R.menu.menu_main, menu);
    miNotification = menu.findItem(R.id.action_notification);

    miDataRefresh = menu.findItem(R.id.data_refresh);
    return super.onCreateOptionsMenu(menu);
  }

  @Override
  public boolean onPrepareOptionsMenu(Menu menu) {
    if (miNotification != null)
      miNotification.setVisible(true);
    if (miDataRefresh != null)
      miDataRefresh.setVisible(true);
    return super.onPrepareOptionsMenu(menu);
  }

  @Override
  public boolean onOptionsItemSelected(MenuItem item) {
    if(item==null)
      return false;
    if (item == miDataRefresh) {
      assert miDataRefresh.getItemId() == R.id.data_refresh;
      String msg = "Would you like to clear the cache?";
      OnCompletionListener l = this::onDialogComplete;
      Dialogs.showYesNoDialog(msg, l);
    } else if ( item == miNotification ) {
      Intent intentCustomNotification = new Intent(this, CustomNotificationActivity.class);
      startActivity(intentCustomNotification);
      return true;
    }
    int itemId = item.getItemId();
    int home = android.R.id.home;

    if (itemId == home) {
      finish();
      return true;
    } else if (itemId == R.id.data_data) {
      LiveQueryService lqs = lqs();
      PrintString ps = new PrintString();
      lqs.requestDataReport(ps);
      showAlertDialog(ps.toString());
    }
    return super.onOptionsItemSelected(item);
  }

  private void onDialogComplete(boolean clear) {
    if (clear)
      lqs().clear();
    Cell411.get().refresh();
  }

  @Override
  public boolean onNavigationItemSelected(@NonNull MenuItem item) {
    // Handle navigation view item clicks here.
    int id = item.getItemId();
    if (id == R.id.nav_my_profile) {
      Intent intentProfileView = new Intent(this, ProfileViewActivity.class);
      startActivity(intentProfileView);
    } else if (id == R.id.nav_generate_qr) {
      Dialogs.showQRCodeDialog(this);
    } else if (id == R.id.nav_scan_qr) {
      scanQR();
    } else if (id == R.id.nav_settings) {
      SettingsActivity.start(this);
    } else if (id == R.id.nav_notifications) {
      CustomNotificationActivity.start(this);
    } else if (id == R.id.nav_know_your_rights) {
      KnowYourRightsActivity.start(this);
    } else if (id == R.id.nav_share_this_app) {
      shareThisApp();
    } else if (id == R.id.nav_rate_this_app) {
      rateThisApp();
    } else if (id == R.id.nav_faq_and_tutorials) {
      Intent intentWeb = new Intent(Intent.ACTION_VIEW);
      intentWeb.setData(Uri.parse(getString(R.string.faq_url)));
      startActivity(intentWeb);
    } else if (id == R.id.nav_change_password) {
      Intent intentChangePassword = new Intent(this, ChangePasswordActivity.class);
      startActivity(intentChangePassword);
    } else if (id == R.id.nav_about) {
      Intent intentAbout = new Intent(this, AboutActivity.class);
      startActivity(intentAbout);
    } else if (id == R.id.nav_logout) {
      Dialogs.showLogoutAlertDialog(this);
    }
    DrawerLayout drawer = findViewById(R.id.drawer_layout);
    drawer.closeDrawer(GravityCompat.START);
    return true;
  }

  private void scanQR() {
//    try {
//      IntentIntegrator integrator = new IntentIntegrator(this);
//      integrator.setCaptureActivity(CustomScannerActivity.class);
//      integrator.initiateScan();
//    } catch (Exception e) {
//      Uri marketUri = Uri.parse("market://details?id=com.google.zxing.client.android");
//      Intent marketIntent = new Intent(Intent.ACTION_VIEW, marketUri);
//      startActivity(marketIntent);
//    }
  }

  @Override
  protected void onNewIntent(final Intent intent) {
    super.onNewIntent(intent);
    System.out.println(intent.getExtras().get("Extra1"));
    System.out.println(intent.getExtras().get("Extra2"));
  }

  private void shareThisApp() {
    Intent sharingIntent = new Intent(Intent.ACTION_SEND);
    sharingIntent.setType("text/plain");
    //    sharingIntent.putExtra(Intent.EXTRA_SUBJECT,
    //                           Util.format(R.string.share_app_subject, version));
    sharingIntent.putExtra(Intent.EXTRA_TEXT,
      Util.format(R.string.share_app_text, getString(R.string.app_url)));
    startActivity(Intent.createChooser(sharingIntent, getString(R.string.share_app_title)));
  }

  private void rateThisApp() {
//    Intent rateIntent = new Intent(Intent.ACTION_VIEW);
//    rateIntent.setData(Uri.parse(getString(R.string.play_store__url)));
//    if (rateIntent.resolveActivity(getPackageManager()) != null) {
//      startActivity(rateIntent);
//    } else {
//      Cell411.get().showToast(R.string.no_browsers_installed_to_rate_app);
//    }
  }

  @Override
  public void onBackPressed() {
    DrawerLayout drawer = findViewById(R.id.drawer_layout);
    if (drawer.isDrawerOpen(GravityCompat.START)) {
      drawer.closeDrawer(GravityCompat.START);
    } else {
      // 1000 * 10 (10 seconds)
      long waitToExitForMillis = 5000;
      if (System.currentTimeMillis() - previousBackTapMillis <= waitToExitForMillis) {
        super.onBackPressed();
        BaseApp.get().onUI(new Runnable() {
          @Override
          public void run() {
            Activity activity = Cell411.get().getCurrentActivity();
            XLog.i(TAG, String.valueOf(activity));
            activity.finishAndRemoveTask();
            activity.finishActivity(0);
            activity.finish();
            activity.getApplication().onTerminate();
            BaseApp.get().onUI(() -> System.exit(0), 100);
            BaseApp.get().onUI(this, 100);
          }
        }, 0);
      } else {
        previousBackTapMillis = System.currentTimeMillis();
        Cell411.get().showToast(getString(R.string.press_return_again_to_exit));
      }
    }
  }

  public void openChat(final XEntity entity) {
    if (!mMainFragment.isAdded())
      return;
    mMainFragment.openChat(entity);
  }

  class SystemStateObserver {
    public <X> void onChange(@Nullable X newValue, @Nullable X oldValue) {
      updateUi();
    }
  }
}
