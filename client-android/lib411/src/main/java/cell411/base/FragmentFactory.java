package cell411.base;

import androidx.annotation.CallSuper;
import androidx.annotation.NonNull;

import cell411.services.R;
import cell411.utils.Util;

public abstract class FragmentFactory
  implements Cloneable
{
  BaseFragment mFragment;

  @CallSuper
  public void setSelected(boolean selected){

  };

  public abstract BaseFragment create();

  public BaseFragment get(boolean create) {
    if(mFragment==null && create)
      mFragment=create();
    return mFragment;
  }

  public abstract String getTitle();


  public static FragmentFactory fromClass(Class<? extends BaseFragment> type) {
    return fromClass(type, null);
  }

  public static FragmentFactory fromClass(Class<? extends BaseFragment> type, String title) {
    return new ClassFactory(type, title);
  }

  @NonNull
  public Object clone() {
    try {
      return super.clone();
    } catch ( CloneNotSupportedException ex ) {
      throw new RuntimeException("clone FragmentFactory", ex);
    }
  }

  public void init() {
  }

  private static class ClassFactory extends FragmentFactory {
    private final Class<? extends BaseFragment> mType;
    private final String mTitle;

    public ClassFactory(Class<? extends BaseFragment> type, String title) {
      mType = type;
      if(title==null)
        title=Util.makeWords(type.getSimpleName());
      mTitle = title;
    }

    @Override
    public BaseFragment create() {
      try {
        return mType.newInstance();
      } catch (IllegalAccessException | InstantiationException e) {
        BaseApp.get().handleException("creating fragment", e);
        return new EmptyFragment(R.layout.empty_layout);
      }
    }


    public String getTitle() {
      return mTitle;
    }
  }
  int mIndex=-1;
}
