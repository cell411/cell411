package cell411;


import android.os.Bundle;
import android.view.View;

import androidx.annotation.CallSuper;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.safearx.cell411.R;

import cell411.base.BaseFragment;
import cell411.base.FragmentFactory;
import cell411.base.SelectFragment;
import cell411.parse.XEntity;
import cell411.utils.Util;
import cell411.utils.XLog;

public class MainFragment extends SelectFragment {
  private static final XLog.Tag TAG = new XLog.Tag(){
    @NonNull
    @Override
    public String toString() {
      return "MainFragment";
    }
  };

  static {
    XLog.i(TAG, "loading class");
  }


  public MainFragment() {
    super(R.layout.fragment_main);
  }

  @Override
  public void onViewCreated(@NonNull final View view, @Nullable final Bundle savedInstanceState) {
    FragmentTab.setupTabBar(this,view);
    setFactories(FragmentTab.mFragmentTabs);
    super.onViewCreated(view, savedInstanceState);
   }


  public void openChat(XEntity entity) {

  }

  public void setSelected(FragmentTab tab) {
    selectFragment(tab);
  }

  public void onClicked(View view) {
    if(view==null)
      return;
    int index = (int) view.getTag();
    FragmentFactory factory = null;
    try {
      factory = getFactory(index);
      selectFragment(factory);
    } catch ( Exception ex ) {
      String title = factory==null ? "(null)" : factory.getTitle();
      String msg = Util.format("selecting fragment: %s", title);
      handleException(msg, ex);
    }
  }

}
