package cell411.utils;

/**
 * Created by Sachin on 03-06-2016.
 */
public class MemUtils {
  public static final float BYTES_IN_MB = 1024.0f * 1024.0f;

  public static float megabytesFree()
  {
    final Runtime rt = Runtime.getRuntime();
    final float bytesUsed = rt.totalMemory();
    final float mbUsed = bytesUsed / BYTES_IN_MB;
    return megabytesAvailable() - mbUsed;
  }

  public static float megabytesAvailable()
  {
    final Runtime rt = Runtime.getRuntime();
    final float bytesAvailable = rt.maxMemory();
    return bytesAvailable / BYTES_IN_MB;
  }
}

