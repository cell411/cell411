package cell411.base;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.CallSuper;
import androidx.annotation.LayoutRes;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import java.util.HashMap;

import cell411.services.R;
import cell411.utils.ExceptionHandler;
import cell411.utils.Reflect;
import cell411.utils.Util;


public abstract class BaseFragment extends Fragment
  implements BaseContext, ExceptionHandler, Reloadable {
  {
    BaseContext.smInstances.add(this);
  }
  public final static String TAG = Reflect.getTag();

  final public static int FRAGMENT_KEY = 0xdeadbeaf;

  public BaseFragment() {
    super(R.layout.empty_layout);
  }
  public BaseFragment(@LayoutRes int layout) {
    super(layout);
  }

  // I override this just to move it to the top of the list you see when you are
  // looking for a method to override.


  @Nullable
  @Override
  public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
    View view = super.onCreateView(inflater, container, savedInstanceState);
    if(view!=null)
      view.setTag(FRAGMENT_KEY, this);
    return view;
  }

  @Override
  public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
    super.onViewCreated(view, savedInstanceState);
  }

  @CallSuper
  public void onResume() {
    super.onResume();
    hideSoftKeyboard();
    refresh();
  }

  @CallSuper
  public void onPause() {
    super.onPause();
  }

  public String getTitle() {
    return Util.makeWords(getClass().getSimpleName());
  }

  @Override
  public BaseActivity activity() {
    return (BaseActivity) getActivity();
  }

  public void prepareToLoad() {
    Reflect.announce(true);
  }
  public void populateUI() {
    Reflect.announce(true);

  }
  public void loadData() {
    Reflect.announce(true);
  }
}
