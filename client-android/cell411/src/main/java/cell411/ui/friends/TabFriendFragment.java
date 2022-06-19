package cell411.ui.friends;

import android.os.Bundle;
import android.view.View;

import androidx.annotation.CallSuper;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.viewpager.widget.PagerTabStrip;

//import com.github.clans.fab.FloatingActionMenu;
//import com.google.zxing.integration.android.IntentIntegrator;
//import com.google.zxing.integration.android.IntentResult;
import com.safearx.cell411.R;

import java.util.Arrays;
import java.util.List;

import cell411.base.FragmentFactory;
import cell411.base.SelectFragment;
import cell411.base.XSelectFragment;
import cell411.utils.XLog;

/**
 * Created by Sachin on 18-04-2016.
 */
public class TabFriendFragment extends XSelectFragment {
  public static final String TAG = "TabFriendsFragment";


  static {
    XLog.i(TAG, "loading class");
  }

  public List<FragmentFactory> createFactories() {
    return Arrays.asList(
      FragmentFactory.fromClass(FriendFragment.class, "Friends"),
      FragmentFactory.fromClass(FriendRequestFragment.class, "Requests"),
      FragmentFactory.fromClass(FriendSearchFragment.class, "Search"));
  }

}

