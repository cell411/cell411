package cell411.ui.self;

import android.content.Context;
import android.util.AttributeSet;

import cell411.base.BaseAnim;
import cell411.utils.Reflect;
import com.safearx.cell411.R;

public class XBlinkingRedSymbol extends BaseAnim {
  public static final  String TAG     = Reflect.getTag();
  private static final int[]  mFrames = {R.drawable.red_blink_0, R.drawable.red_blink_1};

  public XBlinkingRedSymbol(Context context)
  {
    this(context,null);
  }

  public XBlinkingRedSymbol(Context context, AttributeSet attrs)
  {
    this(context,attrs,0);
  }

  public XBlinkingRedSymbol(Context context, AttributeSet attrs, int defStyle)
  {
    super(context, attrs, defStyle);
  }

  @Override
  public int[] getFrameIds() {
    return mFrames;
  }
  @Override
  public int getDuration() {
    return 1000;
  }
}

