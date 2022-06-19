package cell411.ui.map;

import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnTouchListener;

import androidx.appcompat.widget.AppCompatImageView;

import com.safearx.cell411.R;

public class PolygonImageView extends AppCompatImageView implements OnTouchListener {
  public final static String                  TAG = PolygonImageView.class.getSimpleName();
  private final       String                  mTag;
  private             OpaqueAreaClickListener mOpaqueAreaClickListener;

  public PolygonImageView(Context context, AttributeSet attrs)
  {
    super(context, attrs);
    TypedArray a = getContext().obtainStyledAttributes(attrs, R.styleable.PolygonImageView, 0, 0);
    mTag = a.getString(R.styleable.PolygonImageView_tag);
    a.recycle();
    this.setOnTouchListener(this);
  }

  public void setOnOpaqueAreaClickListener(OpaqueAreaClickListener opAreaClickListener)
  {
    mOpaqueAreaClickListener = opAreaClickListener;
    this.setDrawingCacheEnabled(true);
  }

  @Override public void onWindowFocusChanged(boolean hasWindowFocus)
  {
    super.onWindowFocusChanged(hasWindowFocus);
    this.setDrawingCacheEnabled(true);
  }

  @Override public boolean onTouch(View v, MotionEvent event)
  {
    if (event.getAction() == MotionEvent.ACTION_DOWN) {
      Bitmap bmp = v.getDrawingCache();
      int color, x = (int) event.getX(), y = (int) event.getY();
      try {
        color = bmp.getPixel(x, y);
        if (color != Color.TRANSPARENT) {
          mOpaqueAreaClickListener.onOpaqueAreaClicked(mTag);
          return true;
        } else {
          return false;
        }
      } catch (Exception e) {
        e.printStackTrace();
      }
    }
    return false;
  }
}

