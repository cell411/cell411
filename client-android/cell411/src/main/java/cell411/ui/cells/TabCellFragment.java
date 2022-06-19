package cell411.ui.cells;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.animation.AnimatorSet;
import android.animation.ObjectAnimator;
import android.os.Bundle;
import android.view.View;
import android.view.animation.OvershootInterpolator;

import androidx.annotation.CallSuper;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.github.clans.fab.FloatingActionButton;
import com.github.clans.fab.FloatingActionMenu;
import com.safearx.cell411.R;

import java.util.Arrays;
import java.util.List;

import cell411.base.FragmentFactory;
import cell411.base.XSelectFragment;
import cell411.utils.XLog;

/**
 * Created by Sachin on 18-04-2016.
 */
public class TabCellFragment extends XSelectFragment {
  private static final String TAG = "TabCellsFragment";

  static {
    XLog.i(TAG, "Loading Class");
  }

  private FloatingActionMenu menuAddCell;

  public TabCellFragment() {
    super();
  }

  @Override
  public List<FragmentFactory> createFactories() {
    return Arrays.asList(
      FragmentFactory.fromClass(PublicCellFragment.class, "Public"),
      FragmentFactory.fromClass(PrivateCellFragment.class, "Private"),
      FragmentFactory.fromClass(PublicCellSearchFragment.class, "Search"));
  }

  @CallSuper
  @Override
  public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
    super.onViewCreated(view, savedInstanceState);
//    PagerTabStrip pagerTabStrip = view.findViewById(R.id.pager_title_strip);
//    pagerTabStrip.setTabIndicatorColorResource(R.color.transparent);
    menuAddCell = view.findViewById(R.id.menu_add_cell);
    if(menuAddCell!=null)
      menuAddCell.setClosedOnTouchOutside(true);
    FloatingActionButton fabExploreCells = view.findViewById(R.id.action_explore_cells);
    FloatingActionButton fabCreatePublicCell = view.findViewById(R.id.action_create_public_cell);
    FloatingActionButton fabCreatePrivateCell = view.findViewById(R.id.action_create_private_cell);
    boolean isCreatePublicCellEnabled = getResources().getBoolean(R.bool.is_create_public_cell_enabled);
    if (isCreatePublicCellEnabled) {
      if(fabCreatePrivateCell!=null)
        fabCreatePublicCell.setOnClickListener(this::onCreatePublicCellClick);
    } else {
      if(fabCreatePrivateCell!=null)
        fabCreatePublicCell.setVisibility(View.GONE);
    }
    if(fabExploreCells!=null) {
      fabExploreCells.setOnClickListener(view1 -> {
        if (menuAddCell.isOpened()) {
          menuAddCell.close(true);
        }
        selectFragment(mFactories.get(2));
      });
    }
  }


  private void onCreatePrivateCellClick(View view) {
    if (menuAddCell.isOpened()) {
      menuAddCell.close(true);
    }
    showCreateNewCellDialog();
  }

  private void onCreatePublicCellClick(View view) {
    if (menuAddCell.isOpened()) {
      menuAddCell.close(true);
    }
    PublicCellCreateOrEditActivity.start(getActivity());
  }

  private void createCustomAnimation() {
    AnimatorSet set = new AnimatorSet();
    ObjectAnimator scaleOutX = ObjectAnimator.ofFloat(menuAddCell.getMenuIconView(), "scaleX", 1.0f, 0.2f);
    ObjectAnimator scaleOutY = ObjectAnimator.ofFloat(menuAddCell.getMenuIconView(), "scaleY", 1.0f, 0.2f);
    ObjectAnimator scaleInX = ObjectAnimator.ofFloat(menuAddCell.getMenuIconView(), "scaleX", 0.2f, 1.0f);
    ObjectAnimator scaleInY = ObjectAnimator.ofFloat(menuAddCell.getMenuIconView(), "scaleY", 0.2f, 1.0f);
    scaleOutX.setDuration(50);
    scaleOutY.setDuration(50);
    scaleInX.setDuration(150);
    scaleInY.setDuration(150);
    scaleInX.addListener(new AnimatorListenerAdapter() {
      @Override
      public void onAnimationStart(Animator animation) {
        menuAddCell.getMenuIconView()
          .setImageResource(menuAddCell.isOpened() ? R.drawable.fab_add_cell : R.drawable.fab_menu_close);
      }
    });
    set.play(scaleOutX)
      .with(scaleOutY);
    set.play(scaleInX)
      .with(scaleInY)
      .after(scaleOutX);
    set.setInterpolator(new OvershootInterpolator(2));
    menuAddCell.setIconToggleAnimatorSet(set);
  }

  private void showCreateNewCellDialog() {
//    final BaseActivity activity = (BaseActivity) getActivity();
//    if (activity == null) {
//      Cell411.get().showAlertDialog("Internal Error");
//      return;
//    }
//    AlertDialog.Builder alert = new AlertDialog.Builder(activity);
//
//    LayoutInflater inflater = (LayoutInflater) activity.getSystemService(Service.LAYOUT_INFLATER_SERVICE);
//    View view = inflater.inflate(R.layout.layout_create_cell, null);
//
//
//    <?xml version="1.0" encoding="utf-8"?>
//<RelativeLayout
//    xmlns:android="http://schemas.android.com/apk/res/android"
//    android:layout_width="match_parent"
//    android:layout_height="match_parent"
//      >
//
//    <EditText
//    android:id="@+id/et_cell_name"
//    android:layout_width="match_parent"
//    android:layout_height="50dp"
//    android:layout_margin="10dp"
//    android:hint="@string/hint_cell_name"
//    android:inputType="textCapWords"
//    android:textColor="@color/text_primary"
//      />
//</RelativeLayout>
//    final EditText etCellName = view.findViewById(R.id.et_cell_name);
//    alert.setView(view);
//    alert.setNegativeButton(R.string.dialog_btn_cancel, (dialog, arg1) -> dialog.dismiss());
//    alert.setPositiveButton(R.string.dialog_btn_ok, this::onPositivePush);
//
//    alert.show();
//
//    EnterTextDialog dialog = new EnterTextDialog();
//
//      ds().createPrivateCell(etCellName.getText()
//        .toString()
//        .trim(), this::onCellCreated);
//
//
//   }
//
  }
}
