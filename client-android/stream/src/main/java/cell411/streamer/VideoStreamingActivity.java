package cell411.streamer;

import android.content.Intent;
import android.os.Build.VERSION;
import android.os.Build.VERSION_CODES;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;

import android.view.Window;
import android.view.WindowManager.LayoutParams;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentTransaction;

import cell411.utils.CarefulHandler;
import cell411.utils.ExceptionHandler;
import cell411.utils.XLog;


public class VideoStreamingActivity extends AppCompatActivity implements ExceptionHandler {
  Handler mHandler = new CarefulHandler(Looper.getMainLooper());
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    Intent intent = getIntent();
    if(intent.getStringExtra("url")==null) {
      intent.putExtra("url", "rtmp://dev.copblock.app:9999/cell411/TestStream");
    }
    requestWindowFeature(Window.FEATURE_NO_TITLE);
    Window window = getWindow();
    window.addFlags(LayoutParams.FLAG_KEEP_SCREEN_ON);

    if (VERSION.SDK_INT >= VERSION_CODES.R) {
      window.setDecorFitsSystemWindows(false);
    } else {
      //noinspection deprecation
      window.addFlags(LayoutParams.FLAG_FULLSCREEN);
    }
    setContentView(R.layout.activity_video_streaming);
    FragmentManager     fragmentManager = getSupportFragmentManager();
    FragmentTransaction trans           = fragmentManager.beginTransaction();
    BCFragment          fragment        = new BCFragment();
    trans.replace(R.id.fragment, fragment);
    trans.commit();
    XLog.i("", "");
  }
  public boolean isCurrentThread() {
    return Looper.getMainLooper().isCurrentThread();
  }
  public void later(Runnable runnable, int delay) {
    mHandler.postDelayed(runnable, delay);
  }
  public void later(Runnable runnable) {
    later(runnable, 0);
  }
//  @Override
//  public void handleException(@NonNull String whatchaDoing, @NonNull  Throwable pe,
//                              @Nullable 
//                              OnCompletionListener listener)
//  {
//    showAlertDialog("While : "+whatchaDoing+"\n\nException: "+pe,listener);
//  }
//  @Override
//  public void showAlertDialog(String message, OnCompletionListener listener) {
//    AlertDialog.Builder builder = new AlertDialog.Builder(this);
//    builder.setMessage(message);
//    AlertDialog dialog = builder.create();
//    dialog.setOnDismissListener(dialog1 -> showToast("It's gone now."));
//    dialog.show();
//  }
  @Override
  public void showToast(String message) {
    Toast toast = Toast.makeText(this, message, Toast.LENGTH_LONG);
    toast.show();
  }
}
