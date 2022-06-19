package cell411.utils;

import java.util.Iterator;
import java.util.NoSuchElementException;

public class PeekIterator<T> implements Iterator<T> {
  final Iterator<T> mIterator;
  T       mNext;
  boolean mHasNext = false;

  public PeekIterator(Iterator<T> iterator) {
    mIterator = iterator;
    if (mHasNext = mIterator.hasNext()) {
      mNext = mIterator.next();
    }
  }

  public PeekIterator(Iterable<T> iterable) {
    this(iterable.iterator());
  }

  @Override public boolean hasNext() {
    return mHasNext;
  }

  @Override public T next() {
    T res = mNext;
    mHasNext = mIterator.hasNext();
    // don't leak mNext at end
    mNext = mHasNext ? mIterator.next() : null;
    return res;
  }

  public T peek() {
    if (!mHasNext) {
      throw new NoSuchElementException("Iterated past end");
    }
    return mNext;
  }
}
