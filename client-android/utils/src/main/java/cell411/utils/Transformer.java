package cell411.utils;

import androidx.annotation.NonNull;

import java.util.Iterator;

public class Transformer<InType, OutType> implements Iterable<OutType> {
  final Iterator<InType> mIterator;

  public Transformer(Iterable<InType> iterable) {
    this(iterable.iterator());
  }

  public Transformer(Iterator<InType> iterator) {
    mIterator = iterator;
  }

  public OutType transform(InType next) {
    throw new RuntimeException("Not Implemented");
  }

  @Override @NonNull public Iterator<OutType> iterator() {
    return new Iterator<OutType>() {
      @Override public boolean hasNext() {
        return mIterator.hasNext();
      }

      @Override public OutType next() {
        return transform(mIterator.next());
      }
    };
  }
}
