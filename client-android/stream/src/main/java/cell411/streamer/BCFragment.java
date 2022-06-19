package cell411.streamer;

import android.Manifest;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.AlertDialog.Builder;
import android.app.FragmentManager;
import android.app.FragmentTransaction;
import android.content.ActivityNotFoundException;
import android.content.ComponentName;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.ServiceConnection;
import android.content.pm.PackageManager;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.hardware.Camera;
import android.net.Uri;
import android.opengl.GLSurfaceView;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.os.IBinder;
import android.os.Looper;
import android.os.Message;
import android.provider.Settings;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.TextView;
import android.widget.Toast;
import androidx.annotation.MainThread;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.core.content.res.ResourcesCompat;
import androidx.core.widget.ContentLoadingProgressBar;
import androidx.fragment.app.Fragment;
import cell411.streamer.api.ILiveVideoBroadcaster;
import cell411.streamer.api.ILiveVideoClient;
import cell411.streamer.api.LiveVideoBroadcaster;
import cell411.streamer.api.utils.Resolution;
import cell411.streamer.api.utils.Utils;
import cell411.utils.ExceptionHandler;
import cell411.utils.Reflect;
import cell411.utils.Util;
import cell411.utils.XLog;
import com.google.android.material.snackbar.Snackbar;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicReference;

import static android.Manifest.permission.RECORD_AUDIO;

@SuppressWarnings("deprecation")
public class BCFragment extends Fragment implements ExceptionHandler, ILiveVideoClient {
  public static final String                     TAG                 =
    Reflect.currentSimpleClassName(1);
  public static final int                        PERMISSIONS_REQUEST = 8954;
  private final Timer                      mTimer      = new Timer();
  private final VBServiceConnection        mConnection = new VBServiceConnection();
  private final AtomicReference<StartTask> mStartTask  = new AtomicReference<>();
  private final       AtomicBoolean              mRecording          = new AtomicBoolean(false);
  private             TimerHandler               mTimerHandler;
  private             GLSurfaceView              mGLView;
  private             String                     mFormat;
  private             boolean                    mIsRecording        = false;
  private             boolean                    mIsMuted            = false;
  private             CameraResolutionsFragment  mCameraResolutionsDialog;
  private             ViewGroup                  mRootView;
  private             ImageButton                mSettingsButton;
  private             TextView                   mStreamLiveStatus;
  private             Button                     mToggleRecording;
  private             Button                     mToggleService;
  private             ImageButton                mMicToggle;
  private             ImageButton                mCamSwitch;
  private             ContentLoadingProgressBar  mProgressBar;
  private             UITimerTask                mTimerTask;
  private             Intent                     mServiceIntent;
  private             AlertDialog                mAlertDialog;

  /**
   * Defines callbacks for service binding, passed to bindService()
   */
  public BCFragment() {
    super(R.layout.fragment_livestream);
  }
  void later(Runnable r) {
    later(r, 0);
  }
  void later(Runnable r, long delay) {
    if (r instanceof SafeRunnable) {
      getTimerHandler().postDelayed(r, delay);
    } else {
      later(new SafeRunnable(r), delay);
    }
  }

  public void requestPermission() {
    Activity context = getActivity();
    if (context == null) {
      sendToast("Not Even On Screen!");
      return;
    }
    boolean cameraPermissionGranted =
      ContextCompat.checkSelfPermission(context, Manifest.permission.CAMERA) ==
      PackageManager.PERMISSION_GRANTED;
    boolean microPhonePermissionGranted =
      ContextCompat.checkSelfPermission(context, RECORD_AUDIO) == PackageManager.PERMISSION_GRANTED;
    final List<String> permissionList = new ArrayList<>();
    if (!cameraPermissionGranted) {
      permissionList.add(Manifest.permission.CAMERA);
    }
    if (!microPhonePermissionGranted) {
      permissionList.add(RECORD_AUDIO);
    }
    if (permissionList.size() > 0) {
      if (ActivityCompat.shouldShowRequestPermissionRationale(context,
                                                              Manifest.permission.CAMERA)) {
        Builder builder = new Builder(context);

        builder.setTitle(R.string.permission);
        builder.setMessage(getString(R.string.camera_permission_is_required));
        mAlertDialog = builder.create();
        mAlertDialog.show();
      } else if (ActivityCompat.shouldShowRequestPermissionRationale(context, RECORD_AUDIO)) {
        Builder builder = new AlertDialog.Builder(context);
        builder.setMessage(getString(R.string.microphone_permission_is_required));
        mAlertDialog = builder.create();
        mAlertDialog.show();
      } else {
        String[] permissionArray = permissionList.toArray(new String[0]);
        ActivityCompat.requestPermissions(context, permissionArray, PERMISSIONS_REQUEST);
      }
    }
  }
  @Override
  public boolean isPermissionGranted() {
    boolean cameraPermissionGranted =
      ContextCompat.checkSelfPermission(getActivity(), Manifest.permission.CAMERA) ==
      PackageManager.PERMISSION_GRANTED;
    boolean microPhonePermissionGranted =
      ContextCompat.checkSelfPermission(getActivity(), RECORD_AUDIO) ==
      PackageManager.PERMISSION_GRANTED;
    return cameraPermissionGranted && microPhonePermissionGranted;
  }


  public void triggerStopRecording() {
    if (mStartTask.get() != null) {
      mStartTask.get().cancel(true);
      // We are still starting up.  If I start tearing down, neither I, nor
      // the guy doing the startup, will know what the fuck is going on.
      //
      // So I'm going to let him know he is canceled, and wait until he gets
      // the message and kills himself before I start tearing down.
      later(this::triggerStopRecording, 100);
      return;
    }
    mToggleRecording.setText(R.string.start_broadcasting);
    mStreamLiveStatus.setVisibility(View.GONE);
    mStreamLiveStatus.setText(R.string.live_indicator);
    mSettingsButton.setVisibility(View.VISIBLE);
    if (mTimerTask != null) {
      mTimerTask.cancel();
      mTimerTask = null;
    }
    clearTimerHandler();
    ILiveVideoBroadcaster liveVideoBroadcaster = getLiveVideoBroadcaster();
    if (liveVideoBroadcaster != null) {
      liveVideoBroadcaster.stopBroadcasting();
    }
    stopService();
    mIsRecording = false;
  }
  private void clearTimerHandler() {
    mTimerHandler = null;
  }
  @Override
  public void onStart() {
    XLog.i(TAG, "onStart");
    super.onStart();
    startService();
  }

  @Override
  public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions,
                                         @NonNull int[] grantResults)
  {
    super.onRequestPermissionsResult(requestCode, permissions, grantResults);
    if (requestCode == PERMISSIONS_REQUEST) {
      if (isPermissionGranted()) {
        getLiveVideoBroadcaster().openCamera(Camera.CameraInfo.CAMERA_FACING_BACK);
      } else {
        if (ActivityCompat.shouldShowRequestPermissionRationale(getActivity(),
                                                                Manifest.permission.CAMERA) ||
            ActivityCompat.shouldShowRequestPermissionRationale(getActivity(),
                                                                Manifest.permission.RECORD_AUDIO)) {
          requestPermission();
        } else {
          AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
          builder.setTitle(R.string.permission)
                 .setMessage(getString(R.string.app_does_not_work_without_permissions))
                 .setCancelable(false)
                 .setPositiveButton(android.R.string.yes, this::startManageSettings);
          AlertDialog dialog = builder.create();
          dialog.show();
        }
      }
    }
  }
  @Override
  public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
    XLog.i(TAG, "onViewCreated");
    super.onCreate(savedInstanceState);
    mFormat         = getString(R.string.live_indicator);
    mRootView       = view.findViewById(R.id.root_layout);
    mSettingsButton = view.findViewById(R.id.settings_button);
    mSettingsButton.setOnClickListener(this::onClick);
    mStreamLiveStatus = view.findViewById(R.id.stream_live_status);
    mStreamLiveStatus.setVisibility(View.INVISIBLE);
    mToggleRecording = view.findViewById(R.id.toggle_broadcasting);
    mToggleService   = view.findViewById(R.id.toggle_service);
    if (Util.theGovernmentIsLying()) {
      mToggleService.setVisibility(View.GONE);
    } else {
      mToggleService.setOnClickListener(this::onClick);
    }
    mToggleRecording.setOnClickListener(this::onClick);
    mMicToggle = view.findViewById(R.id.mic_mute_button);
    mMicToggle.setOnClickListener(this::onClick);
    mCamSwitch = view.findViewById(R.id.switch_camera);
    mCamSwitch.setOnClickListener(this::onClick);
    setGLView(view.findViewById(R.id.cameraPreview_surfaceView));
    if (getGLView() == null) {
      throw new RuntimeException("No surfaceView");
    }
    getGLView().setEGLContextClientVersion(2);     // select GLES 2.0
  }
  private void startManageSettings(DialogInterface dialogInterface, int i) {
    try {
      Intent  intent  = new Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
      Context context = getContext();
      context = context.getApplicationContext();
      String myPackage = context.getPackageName();
      intent.setData(Uri.parse("package:" + myPackage));
      startActivity(intent);
    } catch (ActivityNotFoundException e) {
      Intent intent = new Intent(Settings.ACTION_MANAGE_APPLICATIONS_SETTINGS);
      startActivity(intent);
    }
  }
  @MainThread
  @Override
  public void onPause() {
    XLog.i(TAG, "onPause");
    super.onPause();
    //hide dialog if visible not to create leaked window exception
    if (mCameraResolutionsDialog != null && mCameraResolutionsDialog.isVisible()) {
      mCameraResolutionsDialog.dismiss();
    }
    ILiveVideoBroadcaster liveVideoBroadcaster = getLiveVideoBroadcaster();
    if (liveVideoBroadcaster != null) {
      liveVideoBroadcaster.pause();
    }
    if (mAlertDialog != null && mAlertDialog.isShowing()) {
      mAlertDialog.dismiss();
      mAlertDialog = null;
    }
  }

  @Override
  public void onConfigurationChanged(@NonNull Configuration newConfig) {
    super.onConfigurationChanged(newConfig);
    ILiveVideoBroadcaster liveVideoBroadcaster = getLiveVideoBroadcaster();
    if (liveVideoBroadcaster == null) {
      return;
    }
    if (newConfig.orientation == Configuration.ORIENTATION_LANDSCAPE ||
        newConfig.orientation == Configuration.ORIENTATION_PORTRAIT) {
      liveVideoBroadcaster.setDisplayOrientation();
    }
  }
  public void onClick(View v) {
    if (v == mMicToggle) {
      mIsMuted = !mIsMuted;
      getLiveVideoBroadcaster().setAudioEnable(!mIsMuted);
      int     drawable = mIsMuted ? R.drawable.ic_mic_mute_off_24 : R.drawable.ic_mic_mute_on_24;
      Context context  = getContext();
      assert context != null;
      Resources.Theme theme = context.getTheme();
      mMicToggle.setImageDrawable(ResourcesCompat.getDrawable(getResources(), drawable, theme));
    } else if (v == mToggleService) {
      XLog.i(TAG, "mToggleService Pressed");
      if (getLiveVideoBroadcaster() == null) {
        startService();
      } else {
        stopService();
      }
    } else if (v == mToggleRecording) {
      XLog.i(TAG, "mToggleRecording Pressed");
      if (mIsRecording) {
        triggerStopRecording();
      } else {
        triggerStartRecording();
      }
    } else if (v == mCamSwitch) {
      if (getLiveVideoBroadcaster() != null) {
        getLiveVideoBroadcaster().changeCamera();
      }
    } else if (v == mSettingsButton) {
      final Activity activity = getActivity();
      assert activity != null;
      FragmentManager      fm             = activity.getFragmentManager();
      FragmentTransaction  ft             = fm.beginTransaction();
      android.app.Fragment fragmentDialog = fm.findFragmentByTag("dialog");
      if (fragmentDialog != null) {
        ft.remove(fragmentDialog);
      }
      ArrayList<Resolution> sizeList = getLiveVideoBroadcaster().getPreviewSizeList();
      Resolution            size     = getLiveVideoBroadcaster().getPreviewSize();
      if (sizeList != null && sizeList.size() > 0) {
        mCameraResolutionsDialog = new CameraResolutionsFragment(this::setResolution);
        mCameraResolutionsDialog.setCameraResolutions(sizeList, size);
        mCameraResolutionsDialog.show(getActivity().getSupportFragmentManager(),
                                      "resolution_dialog");
      } else {
        Snackbar.make(mRootView, "No resolution available", Snackbar.LENGTH_LONG).show();
      }
    }
  }
  private void triggerStartRecording() {
    if (!mRecording.compareAndSet(false, true))
      return;
    {
       //    new Repeater() {
      //      public boolean attemptTask() {
      //        return
      if (mIsRecording) {
        return;
      }

      Intent intent = getActivity().getIntent();
      String url    = intent.getStringExtra("url");
      if (Util.isNoE(url)) {
        showAlertDialog("No URL provided!");
        return;
      }

      ILiveVideoBroadcaster lvbc = getLiveVideoBroadcaster();
      if (lvbc == null) {
        startService();
        return;
      }
      if (lvbc.isConnected()) {
        showToast("Already Connected");
        return;
      }

      mTimerTask = new UITimerTask();
      mTimer.scheduleAtFixedRate(mTimerTask, 1000, 1000);
      if (mStartTask.compareAndSet(null, new StartTask(this))) {
        mStartTask.get().execute(url);
      }
    }
  }
  private void sendToast(String text) {
    if (Looper.getMainLooper().isCurrentThread()) {
      Toast.makeText(getContext(), text, Toast.LENGTH_LONG).show();
    } else {
      later(() -> sendToast(text));
    }
  }
  public Void setResolution(Resolution size) {
    sendToast("New Resolution: " + size);
    if (getLiveVideoBroadcaster() != null) {
      getLiveVideoBroadcaster().setResolution(size);
    }
    return null;
  }
  public TimerHandler getTimerHandler() {
    if (mTimerHandler == null)
      mTimerHandler = new TimerHandler(getContext(), this);
    return mTimerHandler;
  }
  @Override
  public GLSurfaceView getSurfaceView() {
    return getGLView();
  }
  @Override
  public void showEncoderExistDialog() {
    mAlertDialog = new AlertDialog.Builder(getActivity())
      //.setTitle("")
      .setMessage(R.string.not_eligible_for_broadcast)
      .setPositiveButton(android.R.string.yes, (dialog, which) -> {
      }).show();
  }

  public GLSurfaceView getGLView() {
    return mGLView;
  }
  public void setGLView(GLSurfaceView GLView) {
    mGLView = GLView;
  }
  protected void startService() {
    //this makes service do its job until done
    if (mServiceIntent == null) {
      mServiceIntent = new Intent(getActivity(), LiveVideoBroadcaster.class);
    }
    getActivity().startService(mServiceIntent);
    getActivity().bindService(mServiceIntent, mConnection, 0);
  }
  protected void stopService() {
    //    if (mConnection.mLiveVideoBroadcaster != null) {
    //      new Repeater() {
    //
    //        @Override
    //        protected boolean attemptTask() {
    //          if (getLiveVideoBroadcaster() == null)
    //            return true;
    BCFragment.this.getActivity().unbindService(mConnection);
    BCFragment.this.getActivity().stopService(mServiceIntent);
    //          return false;
    //        }
    //      };
    //    }
  }
  private ILiveVideoBroadcaster getLiveVideoBroadcaster() {
    return mConnection.getLiveVideoBroadcaster();
  }
  @NonNull
  @Override
  public String toString() {
    return "FUCK! " + super.toString();
  }

  static class SafeRunnable implements Runnable {
    final Runnable mPayload;

    public SafeRunnable(Runnable payload)
    {
      mPayload = payload;
    }

    @Override
    public void run() {
      try {
        XLog.i("SafeRunnable", "+ Running: " + mPayload);
        mPayload.run();
      } catch (Exception e) {
        ExceptionHandler handler = new ExceptionHandler() {
        };
        handler.handleException("running", e);
      } finally {
        XLog.i("SafeRunnable", "- gninnuR: " + mPayload);
      }
    }
  }

  private static class TimerHandler extends Handler {
    static final int                       CONNECTION_LOST = 2;
    static final int                       INCREASE_TIMER  = 1;
    final        WeakReference<BCFragment> mFragmentRef;
    final        WeakReference<Context>    mContextRef;
    final        long                      sTime           = System.currentTimeMillis();

    TimerHandler(Context context, BCFragment fragment) {
      super(Looper.getMainLooper());
      mContextRef  = new WeakReference<>(context);
      mFragmentRef = new WeakReference<>(fragment);
    }

    @Override
    public void handleMessage(Message msg) {
      Context    context  = mContextRef.get();
      BCFragment fragment = mFragmentRef.get();
      if (fragment == null) {
        return;
      }
      if (context == null) {
        return;
      }
      switch (msg.what) {
        case INCREASE_TIMER:
          int elapsedTime = (int) ((System.currentTimeMillis() - sTime) / 1000);
          String text = Utils.getDurationString(fragment.mFormat, elapsedTime);
          fragment.mStreamLiveStatus.setText(text);
          fragment.mStreamLiveStatus.setVisibility(View.VISIBLE);
          break;
        case CONNECTION_LOST:
          fragment.triggerStopRecording();

          new AlertDialog.Builder(context).setMessage(R.string.broadcast_connection_lost)
                                          .setPositiveButton(android.R.string.yes, null).show();
          break;
      }
    }
  }

  private static class StartTask extends AsyncTask<String, String, Boolean> {
    private final static String TAG = Reflect.getTag();
    WeakReference<BCFragment> mContext;

    private StartTask(BCFragment context) {
      XLog.i(TAG, "Constructor");
      mContext = new WeakReference<>(context);
    }
    @MainThread
    @Override
    protected void onProgressUpdate(String... values) {
      super.onProgressUpdate(values);
    }
    @MainThread
    @Override
    protected void onCancelled(Boolean aBoolean) {
      super.onCancelled(aBoolean);
      getFragment().mStartTask.compareAndSet(this, null);
    }
    @MainThread
    @Override
    protected void onCancelled() {
      super.onCancelled();
      getFragment().mStartTask.compareAndSet(this, null);
    }
    public ContentLoadingProgressBar getProgressBar() {
      return getFragment().mProgressBar;
    }

    public void setProgressBar(ContentLoadingProgressBar progressBar) {
      getFragment().mProgressBar = progressBar;
    }

    private Context getContext() {
      BCFragment fragment = getFragment();
      Context    context  = fragment.getContext();
      assert context != null;
      return context;
    }

    @NonNull
    private BCFragment getFragment() {
      BCFragment fragment = mContext.get();
      assert fragment != null;
      return fragment;
    }

    @Override
    protected void onPreExecute() {
      if (getFragment().mStartTask.get() != this)
        return;
      XLog.i(TAG, "onPreExecute");
      Context context = getContext();
      assert context != null;
      setProgressBar(new ContentLoadingProgressBar(context));
      getProgressBar().show();
    }

    @Override
    protected Boolean doInBackground(String... url) {
      XLog.i(TAG, "doInBackground(" + url[0] + ")");
      if (getFragment().mStartTask.get() != this)
        return false;
      ILiveVideoBroadcaster liveVideoBroadcaster = getFragment().getLiveVideoBroadcaster();
      return liveVideoBroadcaster.startBroadcasting(url[0]);
    }

    @Override
    protected void onPostExecute(Boolean result) {
      XLog.i(TAG, "onPostExecute");
      if (getFragment().mStartTask.get() != this)
        return;
      getProgressBar().hide();
      BCFragment fragment = getFragment();
      fragment.mIsRecording = result;
      if (result) {
        fragment.mStreamLiveStatus.setVisibility(View.VISIBLE);
        fragment.mToggleRecording.setText(R.string.stop_broadcasting);
        fragment.mSettingsButton.setVisibility(View.GONE);
      } else {
        View root = fragment.mRootView;
        Snackbar.make(root, R.string.stream_not_started, Snackbar.LENGTH_LONG).show();
        fragment.triggerStopRecording();
      }

      fragment.mStartTask.compareAndSet(this, null);
    }
  }

  abstract class Repeater implements Runnable {
    long startTime;
    Repeater() {
      startTime = System.currentTimeMillis();
      later(this);
    }
    public boolean giveUp() {
      startTime = 0;
      return false;
    }
    @Override
    public void run() {
      if (System.currentTimeMillis() - startTime > 10000) {
        showToast("I failed!");
      } else if (attemptTask()) {
        XLog.i("Repeater", "Complete");
      } else {
        later(this, 1000);
      }
    }
    protected abstract boolean attemptTask();
  }

  private class UITimerTask extends TimerTask {
    boolean mStarted=false;

    public void run() {
      ILiveVideoBroadcaster liveVideoBroadcaster = getLiveVideoBroadcaster();
      TimerHandler          timerHandler         = getTimerHandler();
      if (liveVideoBroadcaster == null || !liveVideoBroadcaster.isConnected()) {
        // We don't fuck with this shit until we have seen it connected, at least once.
        // Until then, it's dead to us.
        if(!mStarted)
          return;
        timerHandler.obtainMessage(TimerHandler.CONNECTION_LOST).sendToTarget();
        cancel();
      }
      mStarted=true;
      timerHandler.obtainMessage(TimerHandler.INCREASE_TIMER).sendToTarget();
    }
  }

  class VBServiceConnection implements ServiceConnection {
    ILiveVideoBroadcaster mLiveVideoBroadcaster;
    @Override
    public void onBindingDied(ComponentName name) {
      ServiceConnection.super.onBindingDied(name);
    }
    @Override
    public void onNullBinding(ComponentName name) {
      ServiceConnection.super.onNullBinding(name);
    }
    @SuppressWarnings("deprecation")
    @Override
    public synchronized void onServiceConnected(ComponentName className, IBinder service)
    {
      // We've bound to LocalService, cast the IBinder and get LocalService
      // instance
      LiveVideoBroadcaster.LocalBinder binder = (LiveVideoBroadcaster.LocalBinder) service;
      if (mLiveVideoBroadcaster == null) {
        mLiveVideoBroadcaster = binder.getService();
        mLiveVideoBroadcaster.init(BCFragment.this);
        mLiveVideoBroadcaster.setAdaptiveStreaming(true);
      }
      mLiveVideoBroadcaster.openCamera(Camera.CameraInfo.CAMERA_FACING_FRONT);
    }
    @Override
    public synchronized void onServiceDisconnected(ComponentName arg0) {
      mLiveVideoBroadcaster = null;
    }

    public synchronized @Nullable ILiveVideoBroadcaster getLiveVideoBroadcaster() {
      return mLiveVideoBroadcaster;
    }
  }
}
