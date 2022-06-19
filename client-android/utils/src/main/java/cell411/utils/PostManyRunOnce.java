package cell411.utils;

import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;

import java.util.ArrayList;

public class PostManyRunOnce {
  private final static String TAG = Reflect.getTag();
  private final static ArrayList<PostManyRunOnce> smInstances = new ArrayList<>();

  static {
    XLog.i(TAG, "loadng class");
  }

  final @NonNull
  Runnable mPayload;
  int mPostCount = 0;
  long mLastPost = 0;
  private final Runnable mRunnable = new RealRunnable(this);

  {
    ArrayList<PostManyRunOnce> list;
    synchronized (PostManyRunOnce.class) {
      smInstances.add(this);
      list = new ArrayList<>(smInstances);
    }
  }

  public PostManyRunOnce(@NonNull Runnable payload) {
    mPayload = payload;
  }

  public void selfStart(Handler target) {
    selfStart(target, 0);
  }

  public void selfStart(Handler target, long delay) {
    assert (target.getLooper() != Looper.getMainLooper());
    target.postDelayed(mRunnable, delay);
  }

  public boolean equals(Object object) {
    return super.equals(object);
  }

  public int hashCode() {
    return super.hashCode();
  }

  public void run() {
    --mPostCount;
    if (mPostCount > 0)
      return;
    mPostCount = 0;
    mPayload.run();
  }

  public void posted() {
    ++mPostCount;
    mLastPost = System.currentTimeMillis();
  }

  static class RealRunnable implements Runnable {
    PostManyRunOnce mOwner;
    Throwable mCreation = new Throwable();

    public RealRunnable(PostManyRunOnce owner) {
      mOwner = owner;
    }

    @Override
    public void run() {
      if (mOwner.mPostCount <= 0) {
        Throwable dummy = new Throwable();
        dummy.printStackTrace();
      }
      mOwner.run();
    }
  }
}
