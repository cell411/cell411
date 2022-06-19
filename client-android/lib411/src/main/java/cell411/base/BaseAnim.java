package cell411.base;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Rect;
import android.graphics.drawable.Drawable;
import android.util.AttributeSet;
import android.view.View;
import android.view.ViewParent;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;
import androidx.viewpager.widget.ViewPager;

import java.util.ArrayList;
import java.util.Timer;
import java.util.TimerTask;

import cell411.utils.Reflect;
import cell411.utils.XLog;

public abstract class BaseAnim extends View {
  private static final String TAG = Reflect.getTag();
  static int smSerial = 0;
  static ArrayList<BaseAnim> smInstances = new ArrayList<>();

  static {
    XLog.i(TAG, "loading class");
  }

  private final Drawable[] mFrames;
  private final int mDuration;
  int mSerial = ++smSerial;
  Timer mTimer;
  TimerTask mTimerTask = new TimerTask() {
    @Override
    public void run() {
      invalidate();
    }
  };
  int mFrame = 0;
  private Rect mRect;

  public Drawable getEditModeFrame() {
    Drawable[] frames = getFrames();
    return frames[4];
  }
  public BaseAnim(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
    super(context, attrs, defStyleAttr);
    mFrames = getFrames();
    mDuration = getDuration();
    mRect = makeDrawRect();
    if (isInEditMode()) {
      setBackground(getEditModeFrame());
      return;
    }
    smInstances.add(this);
    int hash = hashCode();
    XLog.i(TAG, "Creating object: %d", hash);
    addOnLayoutChangeListener(this::onLayoutChange);
    addOnAttachStateChangeListener(new AttachStateChangeListener());
  }

  @Override
  public void setVisibility(int visibility) {
    super.setVisibility(visibility);
    if(isAttachedToWindow() && visibility==View.VISIBLE) {
      if(mTimer!=null)
        return;
      mTimer = new Timer();
      int frameDuration = mDuration / mFrames.length;
      mTimer.scheduleAtFixedRate(mTimerTask, 0, (int)(frameDuration));
    } else {
      if(mTimer==null)
        return;
      mTimer.cancel();
      mTimer=null;
    }
  }

  @NonNull
  public String toString() {
    return getClass().getSimpleName() + " #" + mSerial;
  }

  protected Rect makeDrawRect() {
    return new Rect(getPaddingLeft(), getPaddingTop(),
      getWidth() - getPaddingLeft() - getPaddingRight(),
      getHeight() - getPaddingTop() - getPaddingBottom()
    );
  }

  public abstract int[] getFrameIds();

  public Drawable[] getFrames() {
    int[] frameIds = getFrameIds();
    Context context = getContext();
    Drawable[] frames = new Drawable[frameIds.length];
    for (int i = 0; i < frames.length; i++) {
      frames[i] = ContextCompat.getDrawable(context, frameIds[i]);
    }
    return frames;
  }

  public abstract int getDuration();

  @SuppressLint("DrawAllocation")
  @Override
  protected void onDraw(Canvas canvas) {
    super.onDraw(canvas);
    if (mFrames == null)
      return;
    mFrame = mFrame % mFrames.length;
    Drawable drawable = mFrames[mFrame++];
    drawable.setBounds(mRect);
    drawable.draw(canvas);
  }

  @Override
  protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
    super.onMeasure(widthMeasureSpec, heightMeasureSpec);

  }

  private void onLayoutChange(View v, int left, int top, int right, int bottom, int oldLeft,
                              int oldTop, int oldRight, int oldBottom) {
    mRect = makeDrawRect();
  }

  private class AttachStateChangeListener implements OnAttachStateChangeListener {
    @Override
    public void onViewAttachedToWindow(View v) {
      if(v == BaseAnim.this) {
        setVisibility(getVisibility());
      }
    }

    @Override
    public void onViewDetachedFromWindow(View v) {
      if(v == BaseAnim.this) {
        setVisibility(getVisibility());
      }
    }
  }
}
