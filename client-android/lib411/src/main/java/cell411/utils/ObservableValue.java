package cell411.utils;

import androidx.annotation.NonNull;

import java.util.ArrayList;
import java.util.List;

import cell411.base.BaseApp;

@SuppressWarnings("unused")
public class ObservableValue<ValueType> {
  //  private final WeakList<ValueObserver<ValueType>> mObservers = new WeakList<>();
  private final ArrayList<ValueObserver<ValueType>> mObservers = new ArrayList<>();
  private ValueType mValue;

  public ObservableValue(ValueType value) {
    mValue = value;
  }

  public ObservableValue() {
    this(null);
  }

  public boolean set(ValueType newValue) {
    if (mValue == newValue) {
      return false;
    }
    if (mValue != null && mValue.equals(newValue)) {
      return false;
    }
    ValueType oldValue = mValue;
    mValue = newValue;
    fireStateChange(newValue, oldValue);
    return true;
  }

  @NonNull
  public String toString() {
    return "Observable[" + mValue + "]";
  }


  public synchronized void addObserver(ValueObserver<ValueType> observer) {
    if (!mObservers.contains(observer))
      mObservers.add(observer);
  }

  public synchronized void removeObserver(ValueObserver<ValueType> observer) {
    mObservers.remove(observer);
  }

  public ValueType get() {
    return mValue;
  }

  private static final String TAG = Reflect.getTag();
  private void fireStateChange(ValueType newValue, ValueType oldValue) {
    ArrayList<ValueObserver<ValueType>> observers;
    synchronized (this) {
      if (mObservers.isEmpty()) {
        return;
      }
      observers = new ArrayList<>(mObservers);
      while (observers.contains(null))
        observers.remove(null);
      if (observers.isEmpty())
        return;
      BaseApp.get().onUI(new Notifier(observers,newValue,oldValue));
    }
  }

  public int countObservers() {
    return mObservers.size();
  }

  class Notifier implements Runnable {
    private final List<ValueObserver<ValueType>> mValueObservers;
    private final ValueType oldValue;
    private final ValueType newValue;

    Notifier(List<ValueObserver<ValueType>> valueObservers, final ValueType newValue,
             final ValueType oldValue) {
      mValueObservers = valueObservers;
      this.oldValue = oldValue;
      this.newValue = newValue;
    }

    @Override
    public synchronized void run() {
      {
        Error throwable = new Error();
        if(Util.theGovernmentIsHonest())
          throw throwable;
      }
      if (BaseApp.isUIThread()) {
        for (ValueObserver<ValueType> observer : mValueObservers) {
          try {
            // these are weak references, so we need to make sure they
            // did not get nulled out on us.
            if (observer != null) {
              observer.onChange(newValue, oldValue);
            }
          } catch (Exception e) {
            BaseApp.get().handleException("Running observers for " + this, e);
          }
        }
        mValueObservers.clear();
        notifyAll();
      } else {
        BaseApp.get().onUI(this);
//        ThreadUtil.waitUntil(this, mValueObservers::isEmpty, 100);
      }
    }
  }
}
