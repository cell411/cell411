package cell411;

import static cell411.FragmentTab.Size.TAB_HEIGHT_ACTIVE;
import static cell411.FragmentTab.Size.TAB_HEIGHT_INACTIVE;
import static cell411.FragmentTab.Size.TAB_MARGIN_TOP;
import static cell411.FragmentTab.Size.TAB_WIDTH;

import android.graphics.Color;
import android.graphics.Typeface;
import android.view.View;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.RelativeLayout.LayoutParams;
import android.widget.TextView;

import androidx.annotation.StringRes;

import com.safearx.cell411.R;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import cell411.base.BaseFragment;
import cell411.base.FragmentFactory;
import cell411.ui.alerts.TabAlertFragment;
import cell411.ui.cells.TabCellFragment;
import cell411.ui.chats.TabChatFragment;
import cell411.ui.friends.TabFriendFragment;
import cell411.ui.map.TabMapFragment;
import cell411.utils.Collect;
import cell411.utils.ImageUtils;
import cell411.utils.Reflect;
import cell411.utils.XLog;

public class FragmentTab
  extends FragmentFactory {
  static final int[] tab_title = new int[]{
    R.string.app_name,
    R.string.title_friends,
    R.string.title_cells,
    R.string.title_alerts,
    R.string.title_chats
  };
  static final int[] tab_layout_ids = new int[]{
    R.id.rl_tab_map,
    R.id.rl_tab_friends,
    R.id.rl_tab_cells,
    R.id.rl_tab_alerts,
    R.id.rl_tab_chats
  };
  static final int[] tab_image = new int[]{
    R.id.img_tab_map,
    R.id.img_tab_friends,
    R.id.img_tab_cells,
    R.id.img_tab_alerts,
    R.id.img_tab_chats
  };
  static final int[] tab_label = new int[]{
    R.id.txt_tab_map,
    R.id.txt_tab_friends,
    R.id.txt_tab_cells,
    R.id.txt_tab_alerts,
    R.id.txt_tab_chats
  };
  static final int[] tab_sel_draw = new int[]{
    R.drawable.tab_map_selected,
    R.drawable.tab_friend_selected,
    R.drawable.tab_cell_selected,
    R.drawable.tab_alert_selected,
    R.drawable.tab_chat_selected
  };
  static final int[] tab_uns_draw = new int[]{
    R.drawable.tab_map_unselected,
    R.drawable.tab_friend_unselected,
    R.drawable.tab_cell_unselected,
    R.drawable.tab_alert_unselected,
    R.drawable.tab_chat_unselected
  };
  static final List<FragmentTab> mFragmentTabs = new ArrayList<>();
  static final float mDensity = ImageUtils.getDensity();
  static final List<Class<? extends BaseFragment>> tab_types = new ArrayList<>();
  private static final String TAG = Reflect.getTag();
  static RelativeLayout.LayoutParams smSelLayoutParams;
  static RelativeLayout.LayoutParams smUnsLayoutParams;

  static {
    XLog.i(TAG, "loading class");
  }

  static {
    tab_types.add(TabMapFragment.class);
    tab_types.add(TabFriendFragment.class);
    tab_types.add(TabCellFragment.class);
    tab_types.add(TabAlertFragment.class);
    tab_types.add(TabChatFragment.class);
  }

  String mTitle;
  Class<? extends BaseFragment> mType;
  ImageView mImage;
  TextView mLabel;
  RelativeLayout mRelativeLayout;

  int mDrawSelected;
  int mDrawUnselected;
  BaseFragment mFragment = null;
  private int mIndex;

  static void setupTabBar(MainFragment act, View view) {
    final FragmentTab[] tabs =
      new FragmentTab[]{
        new FragmentTab(),
        new FragmentTab(),
        new FragmentTab(),
        new FragmentTab(),
        new FragmentTab()
      };
    {
      int i = 0;
      for (FragmentTab tab : tabs)
        tab.mIndex = i++;
    }

    for (FragmentTab tab : tabs) {
      int i = tab.mIndex;
      tab.mTitle = getString(tab_title[i]);
      tab.mType = tab_types.get(i);
      tab.mDrawSelected = tab_sel_draw[i];
      tab.mDrawUnselected = tab_uns_draw[i];
      tab.mRelativeLayout = view.findViewById(tab_layout_ids[i]);
      tab.mImage = view.findViewById(tab_image[i]);
      tab.mLabel = view.findViewById(tab_label[i]);
      List<View> views = Arrays.asList(tab.mImage, tab.mLabel, tab.mRelativeLayout);
      for (View control : views) {
        control.setOnClickListener(act::onClicked);
        control.setTag(tab.mIndex);
      }
      tab.setSelected(false);
    }

    mFragmentTabs.addAll(Collect.wrapArray(tabs));
  }

  static String getString(@StringRes int resId) {
    return Cell411.get().getString(resId);
  }

  public static FragmentTab get(int selectedIdx) {
    return mFragmentTabs.get(selectedIdx);
  }

//  public boolean checkFragment() {
//    if (mFragment == null) {
//      mFragment=create();
//    }
//    return mFragment != null;
//  }

  @Override
  public void setSelected(boolean selected) {
    super.setSelected(selected);
    checkParams();
    if (mImage != null) {
      int drawRes = selected ? mDrawSelected : mDrawUnselected;
      if (drawRes != 0) {
        mImage.setImageResource(drawRes);
      }
    }

    int typefaceRes = selected ? Typeface.BOLD : Typeface.NORMAL;
    int textColor = selected ? Color.WHITE : 0xfff1f1f1;

    mLabel.setTextColor(textColor);
    mLabel.setTypeface(Typeface.defaultFromStyle(typefaceRes));

  }

  private void checkParams() {
    if (smSelLayoutParams == null || smUnsLayoutParams == null) {
      if (mImage != null) {
        LayoutParams params = (LayoutParams) mImage.getLayoutParams();
        if (smSelLayoutParams == null)
          smSelLayoutParams = makeParams(params, true);
        if (smUnsLayoutParams == null)
          smUnsLayoutParams = makeParams(params, false);
      }
    }
  }

  private <X extends RelativeLayout.LayoutParams> X makeParams(X params, boolean selected) {
    if (mImage == null)
      return null;
    int top = selected ? 0 : TAB_MARGIN_TOP.getSize();

    params.height = (selected ? TAB_HEIGHT_ACTIVE : TAB_HEIGHT_INACTIVE).getSize();
    params.width = TAB_WIDTH.getSize();
    params.setMargins(0, top, 0, 0);
    mImage.setLayoutParams(params);
    return params;
  }

  //  public void setSelected(boolean selected) {
  //    if (mImage != null) {
  //      RelativeLayout.LayoutParams params = (RelativeLayout.LayoutParams) mImage
  //      .getLayoutParams();
  //      params.setMargins(0, 0, 0, 0);
  //      params.width  = TAB_WIDTH;
  //      params.height = TAB_HEIGHT_ACTIVE;
  //      mImage.setLayoutParams(params);
  //    }
  //    if (mImage != null) {
  //      RelativeLayout.LayoutParams params = (RelativeLayout.LayoutParams) mImage
  //      .getLayoutParams();
  //      params.setMargins(0, TAB_MARGIN_TOP, 0, 0);
  //      params.width  = TAB_WIDTH;
  //      params.height = TAB_HEIGHT_INACTIVE;
  //      mImage.setLayoutParams(params);
  //    }
  //       if (mDrawSelected != 0 && mImage != null)
  //        mImage.setImageResource(mDrawSelected);
  //      if (mLabel != null) {
  //        mLabel.setTypeface(mLabel.getTypeface(), Typeface.BOLD);
  //        mLabel.setTextColor(Color.WHITE);
  //      }
  //      //      getMainActivity().setTitle(mTitle);
  //    } else {
  //      if (mDrawSelected != 0 && mImage != null)
  //        mImage.setImageResource(mDrawUnselected);
  //      if (mLabel != null) {
  //        mLabel.setTextColor(Color.parseColor(COLOR_DIRTY_WHITE));
  //        mLabel.setTypeface(mLabel.getTypeface(), Typeface.NORMAL);
  //      }
  //    }
  //    if (getFragment() != null)
  //      getFragment().setSelected(selected);
  //  }
  public BaseFragment getFragment() {
    return mFragment;
  }

  public void setFragment(BaseFragment fragment) {
    mFragment = fragment;
  }

  @Override
  public BaseFragment create() {
    try {
      return mFragment = mType.newInstance();
    } catch (Exception e) {
      Cell411.get().handleException("selecting tab", e);
      return null;
    }
  }

  @Override
  public String getTitle() {
    return mTitle;
  }

  enum Size {
    TAB_HEIGHT_INACTIVE((int) (30 * mDensity + 0.5f)),
    TAB_HEIGHT_ACTIVE((int) (50 * mDensity + 0.5f)),
    TAB_WIDTH((int) (30 * mDensity + 0.5f)),
    TAB_MARGIN_TOP((int) (20 * mDensity + 0.5f));
    final int mSize;

    Size(int size) {
      mSize = size;
    }

    int getSize() {
      return mSize;
    }
  }


}