package cell411.utils;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.Iterator;

// This is a simple list of WeakReferences to objects.  It wraps an ArrayList
// of weak references.  When an object is added, it is wrapped in a weak ref,
// and when it is queried, it dereferences the weak ref.
//
// It uses two functions, ref and deref, to do the transformations.
//
// It removes nulls frequently.  Items may be moved when this happens.  This
// is why it does not allow access by index.  Also, it uses identify, not equals,
// to compare for removal.  And when you remove an object, it removes every copy
// of that object from the list.

public class WeakList<Type> implements Iterable<Type>
{
  final ArrayList<WeakReference<Type>> mData = new ArrayList<>();

  public WeakList() {
  }

  @SuppressWarnings("unused")
  public  WeakList(Iterable<Type> input) {
    synchronized(this) {
      Iterable<WeakReference<Type>> iterable = new Transformer<Type, WeakReference<Type>>(input) {
      };
      for (WeakReference<Type> value : iterable) {
        mData.add(value);
      }
    }
  }

  public int size() {
    return mData.size();
  }

  public synchronized void add(Type val) {
    int i=0;
    while(i<mData.size()) {
      if(deref(mData.get(i++))!=null)
        continue;
      mData.set(--i,ref(val));
      break;
    }
    while(i<mData.size()) {
      if(deref(mData.get(i++))==null)
        mData.remove(--i);
    }
    mData.add(ref(val));
  }

  public synchronized Type remove(Type object) {
    mData.removeIf((ref)->{
      Type temp = deref(ref);
      return temp==object || temp==null;
    });
    return object;
  }

  private WeakReference<Type> ref(Type val) {
    return new WeakReference<>(val);
  }

  private Type deref(WeakReference<Type> ref) {
    return ref == null ? null : ref.get();
  }

  public synchronized boolean isEmpty() {
    remove(null);
    return mData.isEmpty();
  }

  @NonNull
  @Override
  public Iterator<Type> iterator() {
    return new WeakListItr();
  }

  private class WeakListItr implements Iterator<Type> {
    Type mNext;
    @NonNull final Iterator<WeakReference<Type>> mItr;

    @Override
    public boolean hasNext() {
      return mNext != null;
    }

    @NonNull
    public Type next() {
      Type next = mNext;
      mNext = findNext();
      return next;
    }

    @Nullable
    private Type findNext() {
      Type result=null;
      while(result==null && mItr.hasNext()){
        WeakReference<Type> ref = mItr.next();
        if(ref!=null)
          result=ref.get();
      }
      return result;
    }

    WeakListItr() {
      mItr = mData.iterator();
      mNext=findNext();
    }
  }
}
