package cell411.ui;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.Nullable;

import cell411.base.BaseApp;
import cell411.base.BaseContext;
import cell411.parse.util.XParse;
import cell411.ui.self.XBlinkingRedSymbol;
import cell411.utils.Reflect;
import cell411.utils.Util;
import cell411.utils.XLog;

public class StatusBar extends LinearLayout
  implements BaseContext
{
  private static final String TAG = Reflect.getTag();
  static {
    XLog.i(TAG, "loading class");
  }
  private final TextView mStatus;
  private final XBlinkingRedSymbol mBlinker;
  private final TextView mLabel;

  public StatusBar(Context context) {
    this(context, null);
  }

  public StatusBar(Context context, @Nullable AttributeSet attrs) {
    this(context, attrs, 0);
  }

  public StatusBar(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
    this(context, attrs, defStyleAttr, 0);
  }

  public StatusBar(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes) {
    super(context, attrs, defStyleAttr, defStyleRes);
    mLabel = new TextView(context);
    mStatus = new TextView(context);
    mBlinker = new XBlinkingRedSymbol(context);
    addView(mLabel, new LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.MATCH_PARENT));
    addView(mStatus, new LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.MATCH_PARENT, 1));
    addView(mBlinker, new LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.MATCH_PARENT));
    mBlinker.setOnClickListener(this::blinkerClicked);
  }

  @Override
  public int getLayoutMode() {
    return super.getLayoutMode();
  }

  private void blinkerClicked(View view) {
    showAlertDialog(
      "The flashiing red light is telling you that you have no net " +
        "You can use the app, but you will not receive alerts, nor will " +
        "you be able to send them.");
  }

  @Override
  protected void onLayout(boolean changed, int l, int t, int r, int b) {
    super.onLayout(changed, l, t, r, b);
    XLog.i(TAG, "onLayout( %10s, %10d, %10d, %10d, %10d )", changed, l, t, r, b);

  }

  public void updateUI() {
    BaseApp app = app();
    XParse.State state = xpr().getState();
    boolean connected = app.isConnected();
//    if (mHideWhenReady) {
//      boolean hide = connected && state == XParse.State.Ready;
//      setVisibility(hide ? View.GONE : View.VISIBLE);
//    }
    if(mBlinker!=null) {
      mBlinker.setOnClickListener(this::blinkerClicked);
      mBlinker.setVisibility(connected ? View.GONE : View.VISIBLE);
    }
    if(mStatus!=null)
      mStatus.setText(Util.makeWords(String.valueOf(state)));
  }

}
