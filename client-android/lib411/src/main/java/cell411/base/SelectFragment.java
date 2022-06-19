package cell411.base;

import android.os.Bundle;
import android.view.View;

import androidx.annotation.CallSuper;
import androidx.annotation.LayoutRes;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentTransaction;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.List;

import cell411.services.R;
import cell411.utils.ObservableValue;
import cell411.utils.Reflect;
import cell411.utils.XLog;

public class SelectFragment extends BaseFragment {
  protected final List<FragmentFactory> mFactories = new ArrayList<>();
  protected final ObservableValue<FragmentFactory> mCurrent = new ObservableValue<>(null);

  public SelectFragment() {
    this(R.layout.fragment_select);
  }

  public SelectFragment(@LayoutRes int layout) {
    super(layout);
  }

  public <X extends FragmentFactory, C extends Collection<X>>
  void setFactories(C c) {
      if (c.isEmpty() && mFactories.isEmpty())
        return;

      mFactories.clear();
      mFactories.addAll(c);

      if (mFactories.size() != 0) {
        selectFragment(0);
      } else if (mCurrent.get() != null) {
        selectFragment(null);
      }
  }

  public List<FragmentFactory> createFactories() {
    return Arrays.asList(FragmentFactory.fromClass(BaseFragment.class));
  }


  public void selectFragment(int index) {
    if (index < 0 || index >= mFactories.size())
      index = 0;
    FragmentFactory factory = getFactory(index);
    selectFragment(factory);
  }

  public FragmentFactory getFactory(int index) {
    return mFactories.get(index);
  }

  @Override
  @CallSuper
  public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
    super.onViewCreated(view, savedInstanceState);
    if (mFactories.isEmpty())
      setFactories(createFactories());
    else
      selectFragment(0);
  }

  public void selectFragment(FragmentFactory factory) {
    if (!isAdded()) {
      XLog.i(TAG, "Not added, hanging fire");
      onUI(() -> selectFragment(factory), 500);
      return;
    }
    if (factory == null && mCurrent.get() == null) {
      XLog.i(TAG, "factory & mCurrent are null.  Bailing.");
      return;
    }
    BaseFragment fragment = (factory != null) ? factory.get(true) : null;
    FragmentManager fm = getChildFragmentManager();
    assert fm != null;
    FragmentTransaction tr = fm.beginTransaction();
    if (fragment != null) {
      if(mCurrent.get()!=null && mCurrent.get().mFragment!=null && mCurrent.get().mFragment.isAdded()) {
        tr.remove(mCurrent.get().mFragment);
      }
      tr.replace(R.id.pager, fragment);
    } else if (mCurrent.get() != null && mCurrent.get().mFragment != null) {
      tr.remove(mCurrent.get().mFragment);
    }
    tr.commitNow();
    mCurrent.set(factory);
  }

  public String getTitle() {
    return mCurrent.get() == null ? "(null)" : mCurrent.get().getTitle();
  }

  @CallSuper
  @Override
  public void onResume() {
    super.onResume();
  }

  @CallSuper
  @Override
  public void onPause() {
    super.onPause();
  }


  private void addFragment(FragmentFactory factory) {
    mFactories.add(factory);
    selectFragment(mFactories.size()-1);
  }

  @Override
  public void prepareToLoad() {
    FragmentFactory factory = mCurrent.get();
    if(factory==null)
      return;
    BaseFragment fragment = factory.mFragment;
    if(fragment==null)
      return;
    fragment.prepareToLoad();
  }

  @Override
  public void populateUI() {
    FragmentFactory factory = mCurrent.get();
    if(factory==null)
      return;
    BaseFragment fragment = factory.mFragment;
    if(fragment==null)
      return;
    fragment.populateUI();
  }
  @Override
  public void loadData() {
    Reflect.announce(true);

    FragmentFactory factory = mCurrent.get();
    if(factory==null)
      return;
    BaseFragment fragment = factory.mFragment;
    if(fragment==null)
      return;
    fragment.loadData();
  }
}
