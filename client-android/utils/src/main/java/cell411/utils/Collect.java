package cell411.utils;

import androidx.annotation.NonNull;

import java.util.AbstractList;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;


public class Collect {
  public static <T> Iterable<T> wrap(Iterator<T> iterator) {
    return () -> iterator;
  }

  public static <T> Iterable<T> wrap(T[] i) {
    return () -> new Iterator<T>() {
      int pos = 0;

      @Override
      public boolean hasNext() {
        return pos < i.length;
      }

      @Override
      public T next() {
        return i[pos++];
      }
    };
  }

  @NonNull
  public static <E, C extends Collection<E>, T extends E> C addAll(@NonNull C c, Iterator<T> i) {
    return addAll(c, wrap(i));
  }
  @NonNull
  public static <E, C extends Collection<E>, T extends E> C addAll(@NonNull C c, Iterable<T> i) {
    i.forEach(c::add);
    return c;
  }
  @NonNull
  public static <E, C extends Collection<E>, T extends E> C replaceAll(@NonNull C c, Iterator<T> i)
  {
    c.clear();
    return addAll(c, i);
  }

  @NonNull
  public static <E, C extends Collection<E>, T extends E> C replaceAll(@NonNull C c, Iterable<T> i)
  {
    c.clear();
    return addAll(c,i);
  }

  public static <Type> ArrayList<Type> flatten(ArrayList<List<Type>> listList) {
    int size = 0;
    for(List<Type> list : listList) {
      size+=list.size();
    }
    ArrayList<Type> res = new ArrayList<>(size);
    for (List<Type> list : listList) {
      res.addAll(list);
    }
    return res;
  }
  public static <X> List<X> wrapArray(X[] x) {
    return new AbstractList<X>() {
      @Override
      public int size() {
        return x.length;
      }
      @Override
      public X get(int index) {
        return x[index];
      }
    };
  }

  @NonNull
  @SafeVarargs
  public static <X, C extends Collection<X>> C addAll(@NonNull C c, X... xs) {
    return addAll(c,wrap(xs));
  }

  @NonNull
  @SafeVarargs
  public static <X, C extends Collection<X>> C replaceAll(@NonNull C c, X... xs) {
    return replaceAll(c,wrap(xs));
  }

  @SafeVarargs
  public static <X> List<X> asList(X ... xs) {
    return wrapArray(xs);
  }


  public static class EmptyIterator<XType> implements Iterator<XType> {
    @Override
    public boolean hasNext() {
      return false;
    }

    @Override
    public XType next() {
      throw new ArrayIndexOutOfBoundsException("Iterated past end");
    }
  }
}
