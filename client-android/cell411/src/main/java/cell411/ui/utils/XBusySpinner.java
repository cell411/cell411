package cell411.ui.utils;

import android.content.Context;
import android.util.AttributeSet;

import cell411.base.BaseAnim;
import com.safearx.cell411.R;

public class XBusySpinner extends BaseAnim {
  static int[] mFrames =
    new int[]{R.drawable.spinner_150_00, R.drawable.spinner_150_01, R.drawable.spinner_150_02,
              R.drawable.spinner_150_03, R.drawable.spinner_150_04, R.drawable.spinner_150_05,
              R.drawable.spinner_150_06, R.drawable.spinner_150_07, R.drawable.spinner_150_08,
              R.drawable.spinner_150_09, R.drawable.spinner_150_10, R.drawable.spinner_150_11,
              R.drawable.spinner_150_12, R.drawable.spinner_150_13, R.drawable.spinner_150_14,
              R.drawable.spinner_150_15, R.drawable.spinner_150_16, R.drawable.spinner_150_17};

  public XBusySpinner(Context context)
  {
    this(context,null);
  }

  public XBusySpinner(Context context, AttributeSet attrs)
  {
    this(context, attrs,0);
  }

  public XBusySpinner(Context context, AttributeSet attrs, int defStyle)
  {
    super(context, attrs, defStyle);
  }

  @Override
  public int[] getFrameIds() {
    return mFrames;
  }
  @Override
  public int getDuration() {
    return 1800;
  }
}

