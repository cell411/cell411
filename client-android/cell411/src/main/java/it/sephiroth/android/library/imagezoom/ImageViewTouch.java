package it.sephiroth.android.library.imagezoom;

import android.content.Context;
import android.graphics.Matrix;
import android.graphics.Rect;
import android.graphics.RectF;
import android.graphics.drawable.Drawable;
import android.util.AttributeSet;
import android.util.Log;
import android.view.GestureDetector;
import android.view.GestureDetector.OnGestureListener;
import android.view.MotionEvent;
import android.view.ScaleGestureDetector;
import android.view.ScaleGestureDetector.OnScaleGestureListener;
import android.view.ViewConfiguration;

public class ImageViewTouch extends ImageViewTouchBase {
  static final   float                             SCROLL_DELTA_THRESHOLD = 1.0f;
  private static boolean                           isImageScalled;
  private static boolean                           isDoubleTapHappened;
  protected      ScaleGestureDetector              mScaleDetector;
  protected      GestureDetector                   mGestureDetector;
  protected      int                               mTouchSlop;
  protected      float                             mScaleFactor;
  protected      int                               mDoubleTapDirection;
  protected      OnGestureListener                 mGestureListener;
  protected      OnScaleGestureListener            mScaleListener;
  protected      boolean                           mDoubleTapEnabled      = true;
  protected      boolean                           mScaleEnabled          = true;
  protected      boolean                           mScrollEnabled         = true;
  private        OnImageViewTouchDoubleTapListener mDoubleTapListener;
  private        OnImageViewTouchSingleTapListener mSingleTapListener;
  private        OnInterceptTouchListener          mListener;

  public ImageViewTouch(Context context)
  {
    super(context);
  }

  public ImageViewTouch(Context context, AttributeSet attrs)
  {
    super(context, attrs);
  }

  @Override protected void init()
  {
    super.init();
    mTouchSlop = ViewConfiguration.get(getContext())
                                  .getScaledTouchSlop();
    mGestureListener = getGestureListener();
    mScaleListener = getScaleListener();
    setMaxScale(3F);
    setMinScale(1F);
    mScaleDetector = new ScaleGestureDetector(getContext(), mScaleListener);
    mGestureDetector = new GestureDetector(getContext(), mGestureListener, null, true);
    mListener = new OnInterceptTouchListener() {
      public InterceptType onTouchIntercept(float origX, float origY)
      {
        // TODO Auto-generated method stub
        Log.i("Is Image Scalled", String.valueOf(isImageScalled));
        return isImageScalled ? InterceptType.BOTH : InterceptType.NONE;
      }
    };
    mDoubleTapDirection = 1;
    isImageScalled = false;
    isDoubleTapHappened = false;
  }

  @Override
  protected void _setImageDrawable(final Drawable drawable, final Matrix initial_matrix, float min_zoom, float max_zoom)
  {
    super._setImageDrawable(drawable, initial_matrix, min_zoom, max_zoom);
    mScaleFactor = getMaxScale() / 3;
  }

  @Override protected void setMaxScale(float value)
  {
    // TODO Auto-generated method stub
    super.setMaxScale(value);
  }

  @Override protected void setMinScale(float value)
  {
    // TODO Auto-generated method stub
    super.setMinScale(value);
  }

  @Override protected void onZoomAnimationCompleted(float scale)
  {
    if (LOG_ENABLED) {
      Log.d(LOG_TAG, "onZoomAnimationCompleted. scale: " + scale + ", minZoom: " + getMinScale());
    }
    if (scale < getMinScale()) {
      zoomTo(getMinScale(), 50);
    }
    isImageScalled = scale != 1.0f;
  }

  public void setDoubleTapListener(OnImageViewTouchDoubleTapListener listener)
  {
    mDoubleTapListener = listener;
  }

  public void setSingleTapListener(OnImageViewTouchSingleTapListener listener)
  {
    mSingleTapListener = listener;
  }

  public void setScaleEnabled(boolean value)
  {
    mScaleEnabled = value;
  }

  public void setScrollEnabled(boolean value)
  {
    mScrollEnabled = value;
  }

  public boolean getDoubleTapEnabled()
  {
    return mDoubleTapEnabled;
  }

  public void setDoubleTapEnabled(boolean value)
  {
    mDoubleTapEnabled = value;
  }

  protected OnGestureListener getGestureListener()
  {
    return new GestureListener();
  }

  protected OnScaleGestureListener getScaleListener()
  {
    return new ScaleListener();
  }

  @Override public boolean onTouchEvent(MotionEvent event)
  {
    mScaleDetector.onTouchEvent(event);
    if (!mScaleDetector.isInProgress()) {
      mGestureDetector.onTouchEvent(event);
    }
    int action = event.getAction();
    switch (action & MotionEvent.ACTION_MASK) {
      case MotionEvent.ACTION_UP:
        if (getScale() < getMinScale()) {
          zoomTo(getMinScale(), 50);
        }
        break;
    }
    return true;
  }

  protected float onDoubleTapPost(float scale, float maxZoom)
  {
    if (mDoubleTapDirection == 1) {
      if ((scale + (mScaleFactor * 2)) <= maxZoom) {
        return scale + mScaleFactor;
      } else {
        mDoubleTapDirection = -1;
        return maxZoom;
      }
    } else {
      mDoubleTapDirection = 1;
      return 1f;
    }
  }

  public boolean onScroll(MotionEvent e1, MotionEvent e2, float distanceX, float distanceY)
  {
    if (!mScrollEnabled) {
      return false;
    }
    if (e1 == null || e2 == null) {
      return false;
    }
    if (e1.getPointerCount() > 1 || e2.getPointerCount() > 1) {
      return false;
    }
    if (mScaleDetector.isInProgress()) {
      return false;
    }
    if (getScale() == 1f) {
      return false;
    }
    mUserScaled = true;
    scrollBy(-distanceX, -distanceY);
    invalidate();
    return true;
  }

  public boolean onFling(MotionEvent e1, MotionEvent e2, float velocityX, float velocityY)
  {
    if (!mScrollEnabled) {
      return false;
    }
    if (e1.getPointerCount() > 1 || e2.getPointerCount() > 1) {
      return false;
    }
    if (mScaleDetector.isInProgress()) {
      return false;
    }
    if (getScale() == 1f) {
      return false;
    }
    float diffX = e2.getX() - e1.getX();
    float diffY = e2.getY() - e1.getY();
    if (Math.abs(velocityX) > 800 || Math.abs(velocityY) > 800) {
      mUserScaled = true;
      scrollBy(diffX / 2, diffY / 2, 300);
      invalidate();
      return true;
    }
    return false;
  }

  /**
   * Determines whether this ImageViewTouch can be scrolled.
   *
   * @param direction - positive direction value means scroll from right to left,
   *                  negative value means scroll from left to right
   * @return true if there is some more place to scroll, false - otherwise.
   */
  public boolean canScroll(int direction)
  {
    RectF bitmapRect = getBitmapRect();
    updateRect(bitmapRect, mScrollRect);
    Rect imageViewRect = new Rect();
    getGlobalVisibleRect(imageViewRect);
    if (null == bitmapRect) {
      return false;
    }
    if (bitmapRect.right >= imageViewRect.right) {
      if (direction < 0) {
        return Math.abs(bitmapRect.right - imageViewRect.right) > SCROLL_DELTA_THRESHOLD;
      }
    }
    double bitmapScrollRectDelta = Math.abs(bitmapRect.left - mScrollRect.left);
    return bitmapScrollRectDelta > SCROLL_DELTA_THRESHOLD;
  }

  public OnInterceptTouchListener getInterceptTouchListener()
  {
    return mListener;
  }

  public enum InterceptType {
    NONE,
    LEFT,
    RIGHT,
    BOTH
  }

  public interface OnInterceptTouchListener {
    /**
     * Called when a touch intercept is about to occur.
     *
     * @param origX the raw x coordinate of the initial touch
     * @param origY the raw y coordinate of the initial touch
     * @return Which type of touch, if any, should should be intercepted.
     */
    InterceptType onTouchIntercept(float origX, float origY);
  }

  public interface OnImageViewTouchDoubleTapListener {
    void onDoubleTap();
  }

  public interface OnImageViewTouchSingleTapListener {
    void onSingleTapConfirmed();
  }

  public class GestureListener extends GestureDetector.SimpleOnGestureListener {
    @Override public void onLongPress(MotionEvent e)
    {
      if (isLongClickable()) {
        if (!mScaleDetector.isInProgress()) {
          setPressed(true);
          performLongClick();
        }
      }
    }

    @Override public boolean onScroll(MotionEvent e1, MotionEvent e2, float distanceX, float distanceY)
    {
      return ImageViewTouch.this.onScroll(e1, e2, distanceX, distanceY);
    }

    @Override public boolean onFling(MotionEvent e1, MotionEvent e2, float velocityX, float velocityY)
    {
      return ImageViewTouch.this.onFling(e1, e2, velocityX, velocityY);
    }

    @Override public boolean onDoubleTap(MotionEvent e)
    {
      Log.i(LOG_TAG, "onDoubleTap. double tap enabled? " + mDoubleTapEnabled);
      if (mDoubleTapEnabled) {
        mUserScaled = true;
        float scale = getScale();
        float targetScale = scale;
        targetScale = onDoubleTapPost(scale, getMaxScale());
        targetScale = Math.min(getMaxScale(), Math.max(targetScale, getMinScale()));
        if (!isDoubleTapHappened) {
          isDoubleTapHappened = true;
          zoomTo(3.0f, e.getX(), e.getY(), DEFAULT_ANIMATION_DURATION);
        } else {
          zoomTo(1.0f, e.getX(), e.getY(), DEFAULT_ANIMATION_DURATION);
          isDoubleTapHappened = false;
        }
        invalidate();
      }
      if (null != mDoubleTapListener) {
        mDoubleTapListener.onDoubleTap();
      }
      return super.onDoubleTap(e);
    }

    @Override public boolean onSingleTapConfirmed(MotionEvent e)
    {
      if (null != mSingleTapListener) {
        mSingleTapListener.onSingleTapConfirmed();
      }
      return super.onSingleTapConfirmed(e);
    }
  }

  public class ScaleListener extends ScaleGestureDetector.SimpleOnScaleGestureListener {
    protected boolean mScaled = false;

    @Override public boolean onScale(ScaleGestureDetector detector)
    {
      float span = detector.getCurrentSpan() - detector.getPreviousSpan();
      float targetScale = getScale() * detector.getScaleFactor();
      if (mScaleEnabled) {
        if (mScaled && span != 0) {
          mUserScaled = true;
          targetScale = Math.min(getMaxScale(), Math.max(targetScale, getMinScale() - 0.1f));
          Log.i("On Scale", String.valueOf(targetScale));
          zoomTo(targetScale, detector.getFocusX(), detector.getFocusY());
          mDoubleTapDirection = 1;
          invalidate();
          isImageScalled = true;
          return true;
        }
        // This is to prevent a glitch the first time
        // image is scaled.
        if (!mScaled) {
          mScaled = true;
        }
      }
      return true;
    }
  }
}

