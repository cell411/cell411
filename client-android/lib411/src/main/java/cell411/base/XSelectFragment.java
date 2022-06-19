package cell411.base;

import static cell411.utils.Util.constrain;

import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import androidx.annotation.CallSuper;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentTransaction;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.List;

import cell411.services.R;
import cell411.utils.Reflect;
import cell411.utils.XLog;

public class XSelectFragment extends BaseFragment {
  protected final List<FragmentFactory> mFactories = new ArrayList<>();
  int mIndex = -1;
  FragmentFactory mCurrent;
  private Button btnPrev;
  private Button btnNext;
  private TextView txtTitle;

  public void populateUI() {
    if(mCurrent==null)
      return;
    BaseFragment fragment = mCurrent.mFragment;
    if(fragment==null)
      return;
    fragment.populateUI();
  }
  {
    checkConstrain();
  }

  public XSelectFragment(int selectx) {
    super(selectx);
  }

  void checkConstrain() {
    assert constrain(0,0,0) == 0;
    assert constrain(0,1,0) == 0;
    assert constrain( 0, -1, 0)==0;
    assert constrain(0,0,1)==0;
    assert constrain(0,1,1)==1;
    assert constrain(0,-1, 1)==0;
  }
  public XSelectFragment() {
    this(R.layout.fragment_selectx);
  }

  public <X extends FragmentFactory, C extends Collection<X>>
  void setFactories(@NonNull C c) {
    try {
      Reflect.announce(true);
      logDumpFactories();

      mFactories.clear();
      mFactories.addAll(c);
      for (int i = 0; i < mFactories.size(); i++) {
        mFactories.get(i).mIndex = i;
      }
      if(mFactories.isEmpty()) {
        selectFragment(null);
      } else {
        selectFragment(mFactories.get(0));
      }
      logDumpFactories();
    } finally {
      Reflect.announceStr(false);
    }
  }

  void logDumpFactories() {
    Reflect.announce(true);
    XLog.i(TAG, "factories: ");
    XLog.i(TAG, "{");
    XLog.i(TAG, "min: %d max: %d mIndex: %d", 0, mFactories.size()-1,
      mIndex);
    for (int i = 0; i < mFactories.size(); i++) {
      FragmentFactory factory = mFactories.get(i);

      XLog.i(TAG, "%3s %d %6s %-30s %-20s\n",
        (i == mIndex ? "*" : ""), factory.mIndex,
        getIsAdded(factory),
        factory.getTitle(),
        getSimpleName(factory)
      );
    }
    XLog.i(TAG, "}");
    Reflect.announce(false);
  }

  // always returns 8 characters.
  String getIsAdded(FragmentFactory factory) {
    if (factory == null)
      return " (NULL) ";
    else if (factory.get(false) == null)
      return " (null) ";
    else
      return factory.get(false).isAdded() ? "  true  " : "  false ";
  }

  String getSimpleName(FragmentFactory factory) {
    if (factory == null)
      return "(null factory)";
    else if (factory.get(false) == null)
      return "(null fragment)";
    else
      return factory.get(false).getClass().getSimpleName();
  }

  public List<FragmentFactory> createFactories() {
    return Arrays.asList(FragmentFactory.fromClass(BaseFragment.class));
  }


  public void selectFragment() {
    logDumpFactories();
    selectFragment(getFactory(mIndex));
    logDumpFactories();
  }

  public FragmentFactory getFactory(int index) {
    FragmentFactory factory = mFactories.get(index);
    assert factory.mIndex==index;
    return factory;
  }

  public void selectFragment(int of) {
    selectFragment(getFactory(of));
  }

  @Override
  @CallSuper
  public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
    Reflect.announce(true);
    super.onViewCreated(view, savedInstanceState);
    btnNext = view.findViewById(R.id.btn_next);
    btnPrev = view.findViewById(R.id.btn_prev);
    txtTitle = view.findViewById(R.id.page_title);
    // views that cannot, for whatever reason, set their
    // factories here may call the method themselves.
    //
    // See the MainFragment for an example.
    if (mFactories.isEmpty())
      setFactories(createFactories());
    if (btnNext != null || btnPrev != null) {
      if(btnNext==null || btnPrev==null)
        showAlertDialog("If you set either btnPrev or btnNext, you should do both.");
      btnNext.setOnClickListener(this::onNextPrevClick);
      btnPrev.setOnClickListener(this::onNextPrevClick);
    }
    mIndex=0;
    selectFragment();
    Reflect.announce(false);
  }

  int nextPrev(int mIndex, int btn, int items) {
    mIndex=constrain(0,mIndex,items-1);
    mIndex+=btn;
    mIndex=constrain(0,mIndex,items-1);
    return mIndex;
  }

  private void onNextPrevClick(View view) {
    Reflect.announce(true);
    logDumpFactories();

    try {
      mIndex=constrain(mIndex,0,mFactories.size()-1);
      assert view==btnPrev || view==btnNext;
      mIndex=nextPrev(mIndex, view==btnPrev?-1:1, mFactories.size());
      assert(mIndex>=0 && (mFactories.size()==0 || mIndex<mFactories.size()));
      selectFragment();
    } finally {
      logDumpFactories();
      Reflect.announce(true);
    }
  }

  public int color(boolean enabled, boolean foreground) {
    return (enabled == foreground) ? 0xffffffff : 0xff000000;
  }

  public void enableButton(Button btn, boolean enabled) {
    Reflect.announce(true);
    if(btn==null)
      return;
    XLog.i(TAG, "Button: "+btn.getText());
    XLog.i(TAG, "enabled: "+enabled);
    XLog.i(TAG, "mIndex: "+mIndex);
    XLog.i(TAG, "size: "+mFactories.size());

    btn.setEnabled(true);//enabled);
    btn.setBackground(new ColorDrawable(color(enabled, false)));
    btn.setTextColor(color(enabled, true));
    XLog.i(TAG, "text: %10s enabled: %6s enabled: %6s\n",
      btn.getText(), btn.isEnabled(), enabled);
  }

  public void selectFragment(FragmentFactory factory) {
    if (!isAdded()) {
      XLog.i(TAG, "Not added, hanging fire");
      onUI(() -> selectFragment(factory), 500);
      return;
    }
    XLog.i(TAG, "here!");
    if (factory == null && mCurrent == null) {
      XLog.i(TAG, "factory & mCurrent are null.  Bailing.");
      return;
    }
    mIndex=mFactories.indexOf(factory);

    enableButton(btnPrev, mIndex>0);
    enableButton(btnNext, mIndex<mFactories.size()-1);
    BaseFragment fragment = (factory != null) ? factory.get(true) : null;
    FragmentManager fm = getChildFragmentManager();
    assert fm != null;
    FragmentTransaction tr = fm.beginTransaction();
    if (fragment != null) {
      XLog.i(TAG, "Case 1");
      tr.replace(R.id.pager, fragment);
    } else if (mCurrent != null && mCurrent.mFragment != null) {
      XLog.i(TAG, "Case 2");
      tr.remove(mCurrent.mFragment);
    } else {
      XLog.i(TAG, "Case 3");
    }
    tr.commitNow();
    mCurrent = factory;
    if(txtTitle!=null)
      txtTitle.setText(getTitle());
  }

  public String getTitle() {
    return mCurrent == null ? "(null)" : mCurrent.getTitle();
  }

  @CallSuper
  @Override
  public void onResume() {
    super.onResume();
    enableButton(btnPrev, mIndex>0);
    enableButton(btnNext, mIndex<mFactories.size()-1);
  }

  @CallSuper
  @Override
  public void onPause() {
    super.onPause();
  }


  @Override
  public void loadData() {
    if(mCurrent==null)
      return;
    BaseFragment fragment = mCurrent.mFragment;
    if(fragment==null)
      return;
    fragment.loadData();
  }

 

  @Override
  public void prepareToLoad() {
    if(mCurrent==null)
      return;
    BaseFragment fragment = mCurrent.mFragment;
    if(fragment==null)
      return;
    fragment.prepareToLoad();

  }
}
