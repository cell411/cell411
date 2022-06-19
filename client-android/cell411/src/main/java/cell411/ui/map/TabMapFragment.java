package cell411.ui.map;

import android.animation.AnimatorInflater;
import android.animation.AnimatorSet;
import android.app.AlertDialog;
import android.content.res.ColorStateList;
import android.location.Location;
import android.os.Bundle;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewGroupOverlay;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.safearx.cell411.R;

import cell411.base.BaseActivity;
import cell411.base.BaseFragment;
import cell411.enums.ProblemType;
import cell411.logic.RelationWatcher;
import cell411.parse.XUser;
import cell411.ui.alerts.AlertIssuingActivity;
import cell411.utils.Util;
import cell411.utils.ValueObserver;
import cell411.utils.XLog;


public class TabMapFragment extends BaseFragment
  implements OpaqueAreaClickListener, View.OnClickListener {
  private static final String TAG = TabMapFragment.class.getSimpleName();
  static int[] mImageIds = new int[]{R.id.img_medical, R.id.img_criminal, R.id.img_pulled_over,
    R.id.img_police_interaction,
    R.id.img_police_arrest, R.id.img_panic_button, R.id.img_danger, R.id.img_broken_car,
    R.id.img_being_bullied,
    R.id.img_general, R.id.img_photo, R.id.img_video, R.id.img_fire};

  static {
    XLog.i(TAG, "loading class");
  }

  static {
    try {
      Class.forName("cell411.ui.alerts.ProblemTypeInfo");
    } catch (Throwable ignored) {
    }
  }

  private AnimatorSet mOuterRing;
  private AnimatorSet mInnerRing;
  private RelativeLayout rlRadialMenu;
  private ImageView imgLocationCenter;
  private ImageView imgPatrolMode;
  private int COLOR_ACCENT;
  private int COLOR_GRAY_CCC;
  private TextView mCity;
  private TextView mAddr;
  private TextView mCoor;
  private LinearLayout mLoc;

  public TabMapFragment() {
    super(R.layout.fragment_tab_map);
  }

  @Override
  public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
    super.onViewCreated(view, savedInstanceState);
    final BaseActivity activity = (BaseActivity) getActivity();
    assert activity != null;
    COLOR_ACCENT = activity.getColor(R.color.colorAccent);
    COLOR_GRAY_CCC = activity.getColor(R.color.gray_ccc);
    rlRadialMenu = view.findViewById(R.id.rl_radial_menu);
    RelativeLayout rlRadialMenuOuterLayer = view.findViewById(R.id.rl_outer);
    RelativeLayout rlRadialMenuInnerLayer = view.findViewById(R.id.rl_inner);
    if (Util.theGovernmentIsHonest())
      prepareAnimator(rlRadialMenuOuterLayer, rlRadialMenuInnerLayer);
    initSlices(view);
    mLoc = view.findViewById();
    mCity = new TextView(getActivity());
    mAddr = new TextView(getActivity());
    mCoor = new TextView(getActivity());
    mLoc.addView(mCoor);
    mLoc.addView(mAddr);
    mLoc.addView(mCity);
    RelativeLayout top = (RelativeLayout) view;
    loc().addObserver(this::onChange);
  }

  @SuppressWarnings("unused")
  private void showFeaturesDisabledDialog(boolean patrolMode, boolean newPublicCellAlert) {
    AlertDialog.Builder alert = new AlertDialog.Builder(getActivity());
    alert.setTitle(R.string.dialog_title_location_alert);
    String message;
    if (patrolMode && newPublicCellAlert) {
      message = getString(R.string.msg_location_two_features_disabled, getString(R.string.app_name),
        getString(R.string.feature_patrol_mode), getString(R.string.feature_new_public_cell_alert));
    } else if (patrolMode) {
      message = getString(R.string.msg_location_one_feature_disabled, getString(R.string.app_name),
        getString(R.string.feature_patrol_mode));
    } else if (newPublicCellAlert) {
      message = getString(R.string.msg_location_one_feature_disabled, getString(R.string.app_name),
        getString(R.string.feature_new_public_cell_alert));
    } else {
      return;
    }
    alert.setMessage(message);
    alert.setPositiveButton(R.string.dialog_btn_ok, (dialog, which) -> {
    });
    AlertDialog dialog = alert.create();
    dialog.show();
  }

  @Override
  public void onOpaqueAreaClicked(String tag) {
    ProblemType problemType = ProblemType.valueOf(tag);
    System.out.println("Wedge tagged " + problemType + " clicked");
    AlertIssuingActivity.start(getActivity(), problemType);
  }

  @Override
  public void onClick(View v) {
    int id = v.getId();
    if (id == R.id.img_patrol_mode_enabled) {
      togglePatrolMode();
    } else if (id == R.id.img_location_center_enabled) {
      toggleLocationCenter();
    }
  }
  public void onChange(@Nullable Location newValue, @Nullable Location oldValue) {

  }
  public void onPause() {
    super.onPause();
  }

  @Override
  public void onResume() {
    super.onResume();
    onUI(this::animateRadialMenu);
  }

  private void prepareAnimator(RelativeLayout rlRadialMenuOuterLayer,
                               RelativeLayout rlRadialMenuInnerLayer) {
    try {
      mOuterRing =
        (AnimatorSet) AnimatorInflater.loadAnimator(activity(), R.animator.radial_outer_animator);
      mOuterRing.setTarget(rlRadialMenuOuterLayer);
      mInnerRing =
        (AnimatorSet) AnimatorInflater.loadAnimator(activity(), R.animator.radial_inner_animator);
      mInnerRing.setTarget(rlRadialMenuInnerLayer);
    } catch (Throwable justDumped) {
      // Say nothing, act natural!
      justDumped.printStackTrace();
      mOuterRing = null;
      mInnerRing = null;
    }
  }


  private void initSlices(View view) {
    imgPatrolMode = view.findViewById(R.id.img_patrol_mode_enabled);
    imgLocationCenter = view.findViewById(R.id.img_location_center_enabled);
    for (int id : mImageIds) {
      PolygonImageView poly = rlRadialMenu.findViewById(id);
      poly.setOnOpaqueAreaClickListener(this);
    }
    configToggles();
  }


  public void configToggles() {
    XUser user = XUser.getCurrentUser();
    if(user==null)
      return;
    boolean patrolMode = user.getPatrolMode();
    imgPatrolMode.setOnClickListener(this);
    if (patrolMode) {
      imgPatrolMode.setBackgroundTintList(ColorStateList.valueOf(COLOR_ACCENT));
      imgPatrolMode.setBackgroundResource(R.drawable.bg_location_center_enabled);
    } else {
      imgPatrolMode.setBackgroundTintList(ColorStateList.valueOf(COLOR_GRAY_CCC));
      imgPatrolMode.setBackgroundResource(R.drawable.bg_location_center_disabled);
    }
    imgPatrolMode.setImageResource(R.drawable.img_patrol_mode);
    imgLocationCenter.setOnClickListener(this);
    imgLocationCenter.setBackgroundTintList(ColorStateList.valueOf(COLOR_ACCENT));
    imgLocationCenter.setBackgroundResource(R.drawable.bg_location_center_enabled);
    imgLocationCenter.setImageResource(R.drawable.img_loc_center);
  }

  private void togglePatrolMode() {
    final XUser currentUser = XUser.getCurrentUser();
    if(currentUser==null)
      return;
    boolean patrolMode = currentUser.getPatrolMode();
    currentUser.setPatrolMode(!patrolMode);
    currentUser.saveInBackground();
    configToggles();
  }

  private void toggleLocationCenter() {
    XUser currentUser = XUser.getCurrentUser();
    currentUser.setLocation(loc().getParseGeoPoint());
    currentUser.saveInBackground(e -> showAlertDialog("Location saved to database"));
  }

  public void animateRadialMenu() {
    if (mOuterRing != null)
      mOuterRing.start();
    if (mInnerRing != null)
      mInnerRing.start();
  }

}

