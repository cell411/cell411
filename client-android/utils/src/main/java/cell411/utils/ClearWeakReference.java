package cell411.utils;

import androidx.annotation.NonNull;

import java.lang.ref.ReferenceQueue;
import java.lang.ref.WeakReference;

public class ClearWeakReference<T> extends WeakReference<T> {
  @SuppressWarnings("unused")
  public ClearWeakReference(T referent, ReferenceQueue<? super T> q) {
    super(referent, q);
  }

  public ClearWeakReference(T referent) {
    super(referent);
  }

  @Override
  public boolean enqueue() {
    return super.enqueue();
  }

  @Override
  public T get() {
    return super.get();
  }

  @Override
  public void clear() {
    super.clear();
  }

  @NonNull
  @Override
  public String toString() {
    return "WeakRef[" + hashCode() + "," + get() + "]";
  }
}
