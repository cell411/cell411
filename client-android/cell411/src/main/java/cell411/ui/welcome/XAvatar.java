package cell411.ui.welcome;

import android.content.Context;
import android.util.AttributeSet;
import cell411.base.BaseAnim;
import cell411.utils.Reflect;
import com.safearx.cell411.R;

public class XAvatar extends BaseAnim {
  public static final String TAG    = Reflect.getTag();
  static              int[]  frames =
    new int[]{R.drawable.gif_avatar_100_0, R.drawable.gif_avatar_100_1,
              R.drawable.gif_avatar_100_2, R.drawable.gif_avatar_100_3};
  public XAvatar(Context context)
  {
    this(context,null);
  }
  public XAvatar(Context context, AttributeSet attrs)
  {
    this(context, attrs, 0);
  }
  public XAvatar(Context context, AttributeSet attrs, int defStyle)
  {
    super(context, attrs, defStyle);
  }
  public int getDuration() {
    return 4000;
  }
  public int[] getFrameIds() {
    return frames;
  }
}

