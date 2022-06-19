package cell411.streamer.api;
/**
 * Created by faraklit on 13.06.2016.
 */

import android.graphics.SurfaceTexture;
import android.hardware.Camera;
import android.os.ConditionVariable;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.Looper;
import android.os.Message;
import android.util.Log;
import android.view.SurfaceHolder;

import java.io.IOException;

public class CameraProxy {
  private static final String            TAG                              = "CameraProxy";
  private static final int               RELEASE                          = 1;
  private static final int               AUTOFOCUS                        = 2;
  private static final int               CANCEL_AUTOFOCUS                 = 3;
  private static final int               SET_PREVIEW_CALLBACK_WITH_BUFFER = 4;
  private static final int               SET_PARAMETERS                   = 5;
  private static final int               START_SMOOTH_ZOOM                = 6;
  private static final int               ADD_CALLBACK_BUFFER              = 7;
  private static final int               SET_ERROR_CALLBACK               = 8;
  private static final int               SET_PREVIEW_DISPLAY              = 9;
  private static final int               START_PREVIEW                    = 10;
  private static final int               STOP_PREVIEW                     = 11;
  private static final int               OPEN_CAMERA                      = 12;
  private static final int               SET_DISPLAY_ORIENTATION          = 13;
  private static final int               SET_PREVIEW_TEXTURE              = 14;
  private final        HandlerThread     mHandlerThread;
  private final        CameraHandler     mCameraHandler;
  private final        ConditionVariable mSignal                          = new ConditionVariable();
  private              Camera            mCamera;
  private volatile     Camera.Parameters mParameters;
  private              boolean           mReleased = false;

  public CameraProxy(int cameraId) {
    mHandlerThread = new HandlerThread("Camera Proxy Thread");
    mHandlerThread.start();
    mCameraHandler = new CameraHandler(mHandlerThread.getLooper());
    mSignal.close();
    mCameraHandler.obtainMessage(OPEN_CAMERA, cameraId, 0).sendToTarget();
    mSignal.block();
    if (mCamera != null) {
      mCameraHandler.obtainMessage(SET_ERROR_CALLBACK, new ErrorCallback()).sendToTarget();
    }
  }

  public boolean isCameraAvailable() {
    return mCamera != null && !isReleased();
  }

  public void release() {
    mReleased = true;
    mSignal.close();
    mCameraHandler.sendEmptyMessage(RELEASE);
    mSignal.block();
    mHandlerThread.quitSafely();
  }

  public void autoFocus(Camera.AutoFocusCallback callback) {
    mCameraHandler.obtainMessage(AUTOFOCUS, callback).sendToTarget();
  }

  public void cancelAutoFocus() {
    mCameraHandler.sendEmptyMessage(CANCEL_AUTOFOCUS);
  }

  public void setPreviewCallbackWithBuffer(Camera.PreviewCallback callback) {
    mCameraHandler.obtainMessage(SET_PREVIEW_CALLBACK_WITH_BUFFER, callback).sendToTarget();
  }

  public Camera.Parameters getParameters() {
    return mParameters;
  }

  public void setParameters(Camera.Parameters parameters) {
    mParameters = parameters;
    mCameraHandler.obtainMessage(SET_PARAMETERS, parameters).sendToTarget();
  }

  public void startSmoothZoom(int level) {
    mCameraHandler.obtainMessage(START_SMOOTH_ZOOM, level, 0).sendToTarget();
  }

  public void addCallbackBuffer(byte[] buffer) {
    mCameraHandler.obtainMessage(ADD_CALLBACK_BUFFER, buffer).sendToTarget();
  }

  public void setPreviewDisplay(SurfaceHolder holder) {
    mSignal.close();
    mCameraHandler.obtainMessage(SET_PREVIEW_DISPLAY, holder).sendToTarget();
    mSignal.block();
  }

  public void startPreview() {
    mCameraHandler.sendEmptyMessage(START_PREVIEW);
  }

  public void stopPreview() {
    mSignal.close();
    mCameraHandler.sendEmptyMessage(STOP_PREVIEW);
    mSignal.block();
  }

  public void setDisplayOrientation(int displayOrientation) {
    mCameraHandler.obtainMessage(SET_DISPLAY_ORIENTATION, displayOrientation, 0).sendToTarget();
  }

  public void setPreviewTexture(SurfaceTexture previewTexture) {
    mCameraHandler.obtainMessage(SET_PREVIEW_TEXTURE, previewTexture).sendToTarget();
  }

  public boolean isReleased() {
    return mReleased;
  }

  private static class ErrorCallback implements Camera.ErrorCallback {
    @Override
    public void onError(int error, Camera camera) {
      Log.e(TAG, "Got camera error callback. error=" + error);
    }
  }

  private class CameraHandler extends Handler {
    public CameraHandler(Looper looper) {
      super(looper);
    }

    @Override
    public void handleMessage(final Message msg) {
      try {
        switch (msg.what) {
          case OPEN_CAMERA:
            mCamera = Camera.open(msg.arg1);
            mParameters = mCamera.getParameters();
            break;
          case SET_DISPLAY_ORIENTATION:
            mCamera.setDisplayOrientation(msg.arg1);
            break;
          case RELEASE:
            mCamera.release();
            break;
          case AUTOFOCUS:
            mCamera.autoFocus((Camera.AutoFocusCallback) msg.obj);
            break;
          case CANCEL_AUTOFOCUS:
            mCamera.cancelAutoFocus();
            break;
          case SET_PREVIEW_TEXTURE:
            mCamera.setPreviewTexture((SurfaceTexture) msg.obj);
            break;
          case SET_PARAMETERS:
            mCamera.setParameters((Camera.Parameters) msg.obj);
            break;
          case START_SMOOTH_ZOOM:
            mCamera.startSmoothZoom(msg.arg1);
            break;
          case ADD_CALLBACK_BUFFER:
            mCamera.addCallbackBuffer((byte[]) msg.obj);
            break;
          case SET_ERROR_CALLBACK:
            mCamera.setErrorCallback((Camera.ErrorCallback) msg.obj);
            break;
          case SET_PREVIEW_DISPLAY:
            mCamera.setPreviewDisplay((SurfaceHolder) msg.obj);
            break;
          case START_PREVIEW:
            mCamera.startPreview();
            break;
          case STOP_PREVIEW:
            mCamera.stopPreview();
            break;
          default:
            Log.e(TAG, "Invalid message: " + msg.what);
            break;
        }
      } catch (RuntimeException e) {
        handleException(msg, e);
      } catch (IOException e) {
        handleException(msg, new RuntimeException(e.getMessage(), e));
      }
      mSignal.open();
    }

    private void handleException(Message msg, RuntimeException e) {
      Log.e(TAG, "Camera operation failed", e);
      if (msg.what != RELEASE && mCamera != null) {
        try {
          mReleased = true;
          mCamera.release();
        } catch (Exception e2) {
          Log.e(TAG, "Failed to release camera on error", e);
        }
      }
      // throw e;
    }
  }
}