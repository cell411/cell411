package cell411.base;

import androidx.annotation.CallSuper;

public class EmptyFragment extends BaseFragment {
  public EmptyFragment(int layout) {
    super(layout);
  }

  @CallSuper
  @Override
  public void loadData() {
  }

  @CallSuper
  @Override
  public void prepareToLoad() {
  }

  @Override
  public void populateUI() {

  }
}

