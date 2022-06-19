package cell411.utils;

import androidx.annotation.NonNull;

import java.util.ArrayList;
import java.util.Collection;

public class NullFilterArrayList<T> extends ArrayList<T> {
  public NullFilterArrayList(Collection<T> val) {
    super();
    addAll(val);
  }

  @Override public T set(int index, T element) {
    if (element != null) {
      return super.set(index, element);
    } else {
      return null;
    }
  }

  @Override public boolean add(T t) {
    if (t == null) {
      return false;
    }
    return super.add(t);
  }

  @Override public void add(int index, T element) {
    if (element != null) {
      super.add(index, element);
    }
  }

  @Override public boolean addAll(@NonNull Collection<? extends T> c) {
    if (!c.contains(null)) {
      return super.addAll(c);
    }
    boolean res = false;
    for (T t : c) {
      if (t != null) {
        add(t);
        res = true;
      }
    }
    return res;
  }

  @Override public boolean addAll(int index, @NonNull Collection<? extends T> c) {
    if (!c.contains(null)) {
      return super.addAll(index, c);
    }
    boolean res = false;
    for (T t : c) {
      if (t != null) {
        res = true;
        add(index++, t);
      }
    }
    return res;
  }
}
