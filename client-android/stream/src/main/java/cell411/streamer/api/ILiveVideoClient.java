package cell411.streamer.api;

import android.app.Activity;
import android.opengl.GLSurfaceView;

/**
 * Created by Nobody. (dev@copblock.app)
 *
 *
 * This represents the requester of a broadcast, who must
 * provide certain things to the broadcast service.  He must
 * obtain permissions as needed, he must provide the surface
 * unto which the video is projected ( if any ... but for now
 * you have to ) and he must provide an activity that does
 * unspecified other shit which should be specified and included
 * in this interface.
 *
 */
public interface ILiveVideoClient {
  GLSurfaceView getSurfaceView();
  Activity getActivity();
  void showEncoderExistDialog();
  void requestPermission();
  boolean isPermissionGranted();
}
