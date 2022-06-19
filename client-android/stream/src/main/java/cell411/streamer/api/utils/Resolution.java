package cell411.streamer.api.utils;

import java.io.Serializable;
import java.util.Locale;

/**
 * Created by mekya on 28/03/2017.
 */
public class Resolution implements Serializable {
  public final int width;
  public final int height;

  public Resolution(int width, int height) {
    this.width = width;
    this.height = height;
  }

  public String toString() {
    return String.format(Locale.US, "[%d x %d]", width, height);
  }
}