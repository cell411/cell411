package cell411.utils;

import androidx.annotation.NonNull;
import org.jetbrains.annotations.NotNull;

import java.util.Iterator;
import java.util.function.Predicate;

public class FilterIterator<T> implements Iterator<T>, Iterable<T> {
  Iterator<T>  mIter;
  Predicate<T> mPred;
  T            mNext;
  boolean      mMore;

  public FilterIterator(Iterator<T> iter, Predicate<T> pred)
  {
    mMore = true;
    mPred = pred;
    mIter = iter;
    mNext = null;
    // we started out bringing one null to the party, but
    // now we are discrading it.
    next();
  }

  @Override public boolean hasNext()
  {
    return mMore;
  }

  @Override public T next()
  {
    T ret = mNext;
    mNext = mIter.next();
    while (!mPred.test(mNext)) {
      mMore = mIter.hasNext();
      if (!mMore) {
        break;
      }
    }
    return ret;
  }
  @NonNull
  @NotNull
  @Override
  public Iterator<T> iterator() {
    return this;
  }
}
