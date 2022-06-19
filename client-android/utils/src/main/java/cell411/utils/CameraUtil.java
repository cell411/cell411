package cell411.utils;

import android.app.Activity;
import android.hardware.Camera;
import android.view.Surface;

@SuppressWarnings("deprecation")
public class CameraUtil {
  public static int calcFacing(Camera.CameraInfo info, int degrees) {
    int result;
    if (info.facing == Camera.CameraInfo.CAMERA_FACING_FRONT) {
      result = (info.orientation + degrees) % 360;
      result = (360 - result) % 360;  // compensate the mirror
    } else {  // back-facing
      result = (info.orientation - degrees + 360) % 360;
    }
    return result;
  }

  public static int calcFacing(Activity context, int currentCameraId) {
    Camera.CameraInfo info = new Camera.CameraInfo();
    Camera.getCameraInfo(currentCameraId, info);
    int rotation = context.getWindowManager()
                          .getDefaultDisplay()
                          .getRotation();
    int degrees;
    switch (rotation) {
      default:
      case Surface.ROTATION_0:
        degrees = 0;
        break;
      case Surface.ROTATION_90:
        degrees = 90;
        break;
      case Surface.ROTATION_180:
        degrees = 180;
        break;
      case Surface.ROTATION_270:
        degrees = 270;
        break;
    }
    return calcFacing(info, degrees);
  }
}
