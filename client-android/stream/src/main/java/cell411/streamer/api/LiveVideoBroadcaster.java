package cell411.streamer.api;

import android.app.Activity;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.SurfaceTexture;
import android.hardware.Camera;
import android.media.AudioFormat;
import android.media.AudioRecord;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.opengl.GLSurfaceView;
import android.os.AsyncTask;
import android.os.Binder;
import android.os.HandlerThread;
import android.os.IBinder;
import android.os.Process;
import android.view.Surface;
import android.view.View;
import androidx.annotation.Nullable;
import cell411.streamer.api.encoder.AudioHandler;
import cell411.streamer.api.encoder.CameraSurfaceRenderer;
import cell411.streamer.api.encoder.TextureMovieEncoder;
import cell411.streamer.api.encoder.VideoEncoderCore;
import cell411.streamer.api.network.IMediaMuxer;
import cell411.streamer.api.network.RTMPStreamer;
import cell411.streamer.api.utils.Resolution;
import cell411.streamer.api.utils.Utils;
import cell411.streamer.R;
import cell411.utils.CameraUtil;
import cell411.utils.Reflect;
import cell411.utils.ThreadUtil;
import cell411.utils.XLog;
import com.google.android.material.snackbar.Snackbar;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;

/**
 * Created by mekya on 28/03/2017.
 */
@SuppressWarnings("deprecation")
public class LiveVideoBroadcaster extends Service
  implements ILiveVideoBroadcaster, CameraHandler.ICameraViewer,
  SurfaceTexture.OnFrameAvailableListener
{
  public static final     String                DEFAULT_VIDEO_SIZE_WIDTH  = "640";
  public static final     String                DEFAULT_VIDEO_SIZE_HEIGHT = "480";
  public final static     int                   SAMPLE_AUDIO_RATE_IN_HZ   = 44100;
  private static final    String                TAG           = Reflect.getTag();
  private static final    TextureMovieEncoder   sVideoEncoder =
    new TextureMovieEncoder();
  private volatile static CameraProxy           smCameraProxy;
  private volatile static boolean               sCameraReleased;
  private final           IBinder               mBinder                   = new LocalBinder();
  private final           int                   frameRate     = 20;
  private                 IMediaMuxer           mRtmpStreamer;
  private                 AudioRecorderThread   audioThread;
  private                 boolean               isRecording               = false;
  private                 GLSurfaceView         mGLView;
  private                 CameraSurfaceRenderer mRenderer;
  private                 CameraHandler         mCameraHandler;
  private                 AudioHandler          audioHandler;

  private ArrayList<Resolution> chosenPreviewsSizeList;
  private int                   currentCameraId          = Camera.CameraInfo.CAMERA_FACING_BACK;
  private Resolution            previewSize;
  private HandlerThread         mRtmpHandlerThread;
  private HandlerThread         audioHandlerThread;
  private ConnectivityManager   connectivityManager;
  private boolean               adaptiveStreamingEnabled = false;
  private Timer                 adaptiveStreamingTimer   = null;
  private ILiveVideoClient mClient;

  public static CameraProxy getCameraProxy() {
    return smCameraProxy;
  }
  public static void setCameraProxy(CameraProxy sCameraProxy) {
    LiveVideoBroadcaster.smCameraProxy = sCameraProxy;
  }
  private static void logMessage(String message) {
    XLog.i(TAG, message);
  }
  public boolean isConnected() {
    return mRtmpStreamer != null && mRtmpStreamer.isConnected();
  }
  @Override
  public void onFrameAvailable(SurfaceTexture surfaceTexture) {
    mGLView.requestRender();
  }
  public void pause() {
    //first making mGLView GONE is important otherwise
    //camera function is called after release exception may be thrown
    //especially in htc one x 4.4.2
    mGLView.setVisibility(View.GONE);
    stopBroadcasting();
    mGLView.queueEvent(() -> {
      // Tell the renderer that it's about to be paused so it can clean up.
      mRenderer.notifyPausing();
      if (!sCameraReleased /*|| context.equals(sCurrentActivity.get())*/) {
        releaseCamera();
      }
      mGLView.onPause();
    });
  }
  public void setDisplayOrientation() {
    if (getCameraProxy() != null) {
      getCameraProxy().setDisplayOrientation(CameraUtil.calcFacing(getContext(), currentCameraId));
      if (!isConnected()) {
        setRendererPreviewSize();
      }
    }
  }
  public ArrayList<Resolution> getPreviewSizeList() {
    return chosenPreviewsSizeList;
  }
  public Resolution getPreviewSize() {
    return previewSize;
  }
  @Override
  public int onStartCommand(Intent intent, int flags, int startId) {
    return super.onStartCommand(intent, flags, startId);
  }
  @Override
  public void onCreate() {
    super.onCreate();
  }
  @Override
  public void onDestroy() {
    if (audioHandlerThread != null)
      audioHandlerThread.quitSafely();
    if (mRtmpHandlerThread != null)
      mRtmpHandlerThread.quitSafely();
    if (mCameraHandler != null)
      mCameraHandler.invalidateHandler();
    super.onDestroy();
  }
  @Override
  public void init(ILiveVideoClient client) {
    audioHandlerThread = new HandlerThread("AudioHandlerThread", Process.THREAD_PRIORITY_AUDIO);
    audioHandlerThread.start();
    audioHandler = new AudioHandler(audioHandlerThread.getLooper());

    mClient = client;

    // Define a handler that receives camera-control messages from other
    // threads.  All calls
    // to Camera must be made on the same thread.  Note we create this
    // before the renderer
    // thread, so we know the fully-constructed object will be visible.
    mCameraHandler = new CameraHandler(this);

    mRenderer = new CameraSurfaceRenderer(mCameraHandler, sVideoEncoder);
    mGLView   = client.getSurfaceView();
    mGLView.setRenderer(mRenderer);
    mGLView.setRenderMode(GLSurfaceView.RENDERMODE_WHEN_DIRTY);
    mRtmpHandlerThread =
      new HandlerThread("RtmpStreamerThread"); //, Process.THREAD_PRIORITY_BACKGROUND);
    mRtmpHandlerThread.start();
    mRtmpStreamer       = new RTMPStreamer(mRtmpHandlerThread.getLooper());
    connectivityManager = (ConnectivityManager) this.getSystemService(Context.CONNECTIVITY_SERVICE);

  }
  public boolean hasConnection() {
    NetworkInfo activeNetwork = connectivityManager.getActiveNetworkInfo();
    return activeNetwork != null && activeNetwork.isConnected();
  }
  public boolean startBroadcasting(String rtmpUrl) {
    isRecording = false;
    if (getCameraProxy() == null || getCameraProxy().isReleased()) {
      XLog.w(TAG, "Camera should be opened before calling this function");
      return false;
    }
    if (!hasConnection()) {
      XLog.w(TAG, "There is no active network connection");
    }
    if (Utils.doesEncoderWork(getContext()) != Utils.ENCODER_WORKS) {
      XLog.w(TAG, "This device does not have hardware encoder");
      Snackbar.make(mGLView, R.string.not_eligible_for_broadcast, Snackbar.LENGTH_LONG).show();
      return false;
    }
    boolean result = mRtmpStreamer.open(rtmpUrl);
    if (result) {
      final long recordStartTime = System.currentTimeMillis();
      mGLView.queueEvent(() -> {
        mRenderer.setOptions(mRtmpStreamer);
        setRendererPreviewSize();
        // notify the renderer that we want to change the encoder's state
        mRenderer.startRecording(recordStartTime);
      });
      int minBufferSize =
        AudioRecord.getMinBufferSize(SAMPLE_AUDIO_RATE_IN_HZ, AudioFormat.CHANNEL_IN_MONO,
                                     AudioFormat.ENCODING_PCM_16BIT);
      audioHandler.startAudioEncoder(mRtmpStreamer, SAMPLE_AUDIO_RATE_IN_HZ, minBufferSize);
      audioThread = new AudioRecorderThread(SAMPLE_AUDIO_RATE_IN_HZ, recordStartTime, audioHandler);
      audioThread.start();
      isRecording = true;
      if (adaptiveStreamingEnabled) {
        adaptiveStreamingTimer = new Timer();
        adaptiveStreamingTimer.schedule(new TimerTask() {
          public int previousFrameCount;
          public int frameQueueIncreased;

          @Override
          public void run() {
            int frameCountInQueue = mRtmpStreamer.getVideoFrameCountInQueue();
            //              XLog.d(TAG, "video frameCountInQueue : " + frameCountInQueue);
            if (frameCountInQueue > previousFrameCount) {
              frameQueueIncreased++;
            } else {
              frameQueueIncreased--;
            }
            previousFrameCount = frameCountInQueue;
            if (frameQueueIncreased > 10) {
              //decrease bitrate
              logMessage("decrease bitrate");
              mGLView.queueEvent(() -> {
                int frameRate = mRenderer.getFrameRate();
                if (frameRate >= 13) {
                  frameRate -= 3;
                  mRenderer.setFrameRate(frameRate);
                } else {
                  int bitrate = mRenderer.getBitrate();
                  if (bitrate > 200000) { //200kbit
                    bitrate -= 100000;
                    mRenderer.setBitrate(bitrate);
                    // notify the renderer that we want to change the
                    // encoder's state
                    mRenderer.recorderConfigChanged();
                  }
                }
              });
              frameQueueIncreased = 0;
            }
            if (frameQueueIncreased < -10) {
              //increase bitrate
              logMessage("//increase bitrate");
              mGLView.queueEvent(() -> {
                int frameRate = mRenderer.getFrameRate();
                if (frameRate <= 27) {
                  frameRate += 3;
                  mRenderer.setFrameRate(frameRate);
                } else {
                  int bitrate = mRenderer.getBitrate();
                  if (bitrate < 2000000) { //2Mbit
                    bitrate += 100000;
                    mRenderer.setBitrate(bitrate);
                    // notify the renderer that we want to change the
                    // encoder's state
                    mRenderer.recorderConfigChanged();
                  }
                }
              });
              frameQueueIncreased = 0;
            }
          }
        }, 0, 500);
      }
    }

    return isRecording;
  }
  public void stopBroadcasting() {
    if (isRecording) {
      mGLView.queueEvent(() -> {
        // notify the renderer that we want to change the encoder's state
        mRenderer.stopRecording();
      });
      if (adaptiveStreamingTimer != null) {
        adaptiveStreamingTimer.cancel();
        adaptiveStreamingTimer = null;
      }
      if (audioThread != null) {
        audioThread.stopAudioRecording();
        audioThread = null;
      }
      if (audioHandler != null) {
        audioHandler.sendEmptyMessage(AudioHandler.END_OF_STREAM);
        audioHandler = null;
      }
      int i = 0;
      while (sVideoEncoder.isRecording()) {
        ThreadUtil.sleep(100);
        if (i > 5) {
          //timeout 250ms
          //force stop recording
          sVideoEncoder.stopRecording();
          break;
        }
        i++;
      }
    }
  }

  public void setResolution(Resolution size) {
    Camera.Parameters parameters = getCameraProxy().getParameters();
    parameters.setPreviewSize(size.width, size.height);
    parameters.setRecordingHint(true);
    logMessage("set resolution stop preview");
    getCameraProxy().stopPreview();
    getCameraProxy().setParameters(parameters);
    getCameraProxy().startPreview();
    previewSize = size;
    setRendererPreviewSize();
  }

  private void setRendererPreviewSize()
  {
    int rotation = getContext().getWindowManager().getDefaultDisplay().getRotation();

    final Resolution resolution =
      (rotation == Surface.ROTATION_0 || rotation == Surface.ROTATION_180) ? previewSize : rotate(
        previewSize);
    mGLView.queueEvent(() -> mRenderer.setCameraPreviewSize(resolution.width, resolution.height));
  }

  private Resolution rotate(Resolution previewSize) {
    int a = previewSize.height;
    int b = previewSize.width;
    return new Resolution(a, b);
  }

  @Override
  public void handleSetSurfaceTexture(SurfaceTexture st) {
    if (getCameraProxy() != null && !getContext().isFinishing() && st != null) {
      st.setOnFrameAvailableListener(this);
      getCameraProxy().stopPreview();
      getCameraProxy().setPreviewTexture(st);
      getCameraProxy().startPreview();
    }
  }


  public void openCamera(final int cameraId) {
    //check permission
    if (!mClient.isPermissionGranted()) {
      mClient.requestPermission();
      return;
    }
    if (cameraId == Camera.CameraInfo.CAMERA_FACING_FRONT &&
        !getPackageManager().hasSystemFeature(PackageManager.FEATURE_CAMERA_FRONT)) {
      //if fron camera is requested but not found, then open the back camera
      openCamera(Camera.CameraInfo.CAMERA_FACING_BACK);
      return;
    }
    currentCameraId = cameraId;
    mGLView.setVisibility(View.GONE);
    new CheckCameraTask(this).execute(currentCameraId);
  }

  private void releaseCamera() {
    CameraProxy cameraProxy = getCameraProxy();
    if (cameraProxy == null)
      return;
    try {
      logMessage("releaseCamera stop preview");
      cameraProxy.release();
      setCameraProxy(null);
      sCameraReleased = true;
      logMessage("-- camera released --");
    } catch (Exception ignored) {
    }
  }

  @Override
  public void setAdaptiveStreaming(boolean enable) {
    this.adaptiveStreamingEnabled = enable;
  }

  private int setCameraParameters(Camera.Parameters parameters) {
    List<Camera.Size> previewSizeList = parameters.getSupportedPreviewSizes();
    previewSizeList.sort((lhs, rhs) -> {
      if (lhs.height == rhs.height) {
        return Integer.compare(lhs.width, rhs.width);
      } else if (lhs.height > rhs.height) {
        return 1;
      }
      return -1;
    });
    int preferredHeight = 720;
    chosenPreviewsSizeList = new ArrayList<>();
    int        diff        = Integer.MAX_VALUE;
    Resolution choosenSize = null;
    for (Camera.Size size : previewSizeList) {
      if ((size.width % 16 == 0) && (size.height % 16 == 0)) {
        Resolution resolutionSize = new Resolution(size.width, size.height);
        chosenPreviewsSizeList.add(resolutionSize);
        int currentDiff = Math.abs(size.height - preferredHeight);
        if (currentDiff < diff) {
          diff        = currentDiff;
          choosenSize = resolutionSize;
        }
      }
    }
    int[] requestedFrameRate = new int[]{
      frameRate * 1000,
      frameRate * 1000
    };
    int[] bestFps = findBestFrameRate(parameters.getSupportedPreviewFpsRange(), requestedFrameRate);
    parameters.setPreviewFpsRange(bestFps[0], bestFps[1]);
    int len             = chosenPreviewsSizeList.size();
    int resolutionIndex = len - 1;
    if (choosenSize != null) {
      resolutionIndex = chosenPreviewsSizeList.indexOf(choosenSize);
    }
    if (resolutionIndex >= 0) {
      Resolution size = chosenPreviewsSizeList.get(resolutionIndex);
      parameters.setPreviewSize(size.width, size.height);
      parameters.setRecordingHint(true);
    }
    if (parameters.getSupportedFocusModes()
                  .contains(Camera.Parameters.FOCUS_MODE_CONTINUOUS_VIDEO)) {
      parameters.setFocusMode(Camera.Parameters.FOCUS_MODE_CONTINUOUS_VIDEO);
    }
    getCameraProxy().setDisplayOrientation(CameraUtil.calcFacing(getContext(), currentCameraId));
    if (parameters.isVideoStabilizationSupported()) {
      parameters.setVideoStabilization(true);
    }
    //sCameraDevice.setParameters(parameters);
    getCameraProxy().setParameters(parameters);
    Camera.Size size = parameters.getPreviewSize();
    this.previewSize = new Resolution(size.width, size.height);
    return len;
  }


  public int[] findBestFrameRate(List<int[]> frameRateList, int[] requestedFrameRate)
  {
    int[] bestRate         = frameRateList.get(0);
    int   requestedAverage = (requestedFrameRate[0] + requestedFrameRate[1]) / 2;
    int   bestRateAverage  = (bestRate[0] + bestRate[1]) / 2;
    int   size             = frameRateList.size();
    for (int i = 1; i < size; i++) {
      int[] rate        = frameRateList.get(i);
      int   rateAverage = (rate[0] + rate[1]) / 2;
      if (Math.abs(requestedAverage - bestRateAverage) >=
          Math.abs(requestedAverage - rateAverage)) {
        if ((Math.abs(requestedFrameRate[0] - rate[0]) <=
             Math.abs(requestedFrameRate[0] - bestRate[0])) ||
            (Math.abs(requestedFrameRate[1] - rate[1]) <=
             Math.abs(requestedFrameRate[1] - bestRate[1]))) {
          bestRate        = rate;
          bestRateAverage = rateAverage;
        }
      }
    }
    return bestRate;
  }

  public void showEncoderNotExistDialog() {
    mClient.showEncoderExistDialog();
  }

  public void changeCamera() {
    if (!getPackageManager().hasSystemFeature(PackageManager.FEATURE_CAMERA_FRONT)) {
      Snackbar.make(mGLView, R.string.only_one_camera_exists, Snackbar.LENGTH_LONG).show();
      return;
    }
    if (getCameraProxy() == null) {
      Snackbar.make(mGLView, R.string.first_call_open_camera, Snackbar.LENGTH_LONG).show();
      return;
    }
    //swap the id of the camera to be used
    if (currentCameraId == Camera.CameraInfo.CAMERA_FACING_BACK) {
      currentCameraId = Camera.CameraInfo.CAMERA_FACING_FRONT;
    } else {
      currentCameraId = Camera.CameraInfo.CAMERA_FACING_BACK;
    }
    new ConfigCamera(this).execute();
  }

  @Override
  public void setAudioEnable(boolean enable) {
    mRtmpStreamer.setAudioEnable(enable);
  }

  @Nullable
  @Override
  public IBinder onBind(Intent intent) {
    return mBinder;
  }
  public Activity getContext() {
    return mClient.getActivity();
  }

  static private class CheckCameraTask extends AsyncTask<Integer, Void, Camera.Parameters> {
    WeakReference<LiveVideoBroadcaster> mWeakLBC;
    CheckCameraTask(LiveVideoBroadcaster lbc) {
      mWeakLBC = new WeakReference<>(lbc);
    }
    @Override
    protected void onPreExecute() {
    }

    @Nullable
    @Override
    protected Camera.Parameters doInBackground(Integer... params) {
      Camera.Parameters parameters = null;
      sCameraReleased = false;
      logMessage("--- releaseCamera call in doInBackground --- ");
      LiveVideoBroadcaster lbc = mWeakLBC.get();
      if (lbc == null)
        return null;
      lbc.releaseCamera();
      try {
        int tryCount = 0;
        do {
          setCameraProxy(new CameraProxy(params[0]));
          if (getCameraProxy().isCameraAvailable()) {
            break;
          }
          Thread.sleep(1000);
          tryCount++;
        } while (tryCount <= 3);
        if (getCameraProxy().isCameraAvailable()) {
          logMessage("--- camera opened --- ");
          parameters = getCameraProxy().getParameters();
          if (parameters != null) {
            lbc.setCameraParameters(parameters);
            if (Utils.doesEncoderWork(lbc.getContext()) == Utils.ENCODER_NOT_TESTED) {
              boolean encoderWorks =
                VideoEncoderCore.doesEncoderWork(lbc.previewSize.width, lbc.previewSize.height,
                                                 300000, 20);
              Utils.setEncoderWorks(lbc.getContext(), encoderWorks);
            }
          }
        } else {
          setCameraProxy(null);
        }
        XLog.d(TAG, "onResume complete: " + this);
      } catch (Exception ignored) {
      }
      return parameters;
    }

    @Override
    protected void onPostExecute(Camera.Parameters parameters) {
      LiveVideoBroadcaster lbc = mWeakLBC.get();
      if (lbc == null)
        return;
      if (lbc.getContext().isFinishing()) {
        lbc.releaseCamera();
      } else if (getCameraProxy() != null && parameters != null) {
        lbc.mGLView.setVisibility(View.VISIBLE);
        lbc.mGLView.onResume();
        //mGLView.setAlpha(0.7f);
        lbc.setRendererPreviewSize();
        if (Utils.doesEncoderWork(lbc.getContext()) != Utils.ENCODER_WORKS) {
          lbc.showEncoderNotExistDialog();
        }
      } else {
        Snackbar.make(lbc.mGLView, R.string.camera_not_running_properly, Snackbar.LENGTH_LONG)
                .show();
      }
    }
  }

  private static class ConfigCamera extends AsyncTask<Void, Void, Camera.Parameters> {
    final WeakReference<LiveVideoBroadcaster> mWeakLBC;

    private ConfigCamera(LiveVideoBroadcaster lbc) {
      mWeakLBC = new WeakReference<>(lbc);
    }

    @Override
    protected void onPreExecute() {
      super.onPreExecute();
      LiveVideoBroadcaster lbc = mWeakLBC.get();
      if (lbc == null)
        return;
      lbc.mGLView.queueEvent(() -> {
        // Tell the renderer that it's about to be paused so it can clean
        // up.
        lbc.mRenderer.notifyPausing();
        lbc.mGLView.onPause();
      });
    }

    @Nullable
    @Override
    protected Camera.Parameters doInBackground(Void... voids) {
      LiveVideoBroadcaster lbc = mWeakLBC.get();
      if (lbc == null)
        return null;
      lbc.releaseCamera();
      try {
        setCameraProxy(new CameraProxy(lbc.currentCameraId));
        Camera.Parameters parameters = getCameraProxy().getParameters();
        if (parameters != null) {
          lbc.setCameraParameters(parameters);
          return parameters;
        }
      } catch (Exception ignored) {
      }
      return null;
    }

    @Override
    protected void onPostExecute(Camera.Parameters parameters) {
      LiveVideoBroadcaster lbc = mWeakLBC.get();
      if (lbc == null)
        return;
      super.onPostExecute(parameters);
      if (parameters != null) {
        lbc.mGLView.onResume();
        lbc.setRendererPreviewSize();
      } else {
        Snackbar.make(lbc.mGLView, R.string.camera_not_running_properly, Snackbar.LENGTH_LONG)
                .show();
      }
    }
  }

  public class LocalBinder extends Binder {
    public ILiveVideoBroadcaster getService() {
      // Return this instance of LocalService so clients can call public methods
      return LiveVideoBroadcaster.this;
    }
  }
}
