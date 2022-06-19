package cell411.utils;

import androidx.annotation.NonNull;

import java.util.AbstractSet;
import java.util.Iterator;
import java.util.NoSuchElementException;

public class SingleSet<T> extends AbstractSet<T> {
  T mMember;

  public SingleSet(T member) {
    mMember = member;
  }

  @NonNull
  @Override

  public Iterator<T> iterator() {
    return new Iterator<T>() {
      boolean mShotMyWad = false;

      @Override
      public boolean hasNext() {
        return !mShotMyWad;
      }

      @Override
      public T next() {
        if (mShotMyWad) {
          throw new NoSuchElementException("Iteration past end of set");
        }
        mShotMyWad = true;
        return mMember;
      }
    };
  }

  @Override
  public int size() {
    return 1;
  }
}
