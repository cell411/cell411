package cell411.utils;

import androidx.annotation.NonNull;

import java.io.ByteArrayOutputStream;
import java.io.Closeable;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.UnsupportedEncodingException;
import java.nio.file.Files;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

@SuppressWarnings("unused")
public class IOUtil {
  private static final String   TAG       = "IOUtil";
  static               Catching mCatching = new Catching();
  static               Throwing mThrowing = new Throwing();
  static int count = 0;
  public static void mkdirs(File parentFile, boolean includeLast)
  {
    if (parentFile == null) {
      return;
    }
    if (includeLast) {
      if (parentFile.isDirectory()) {
        return;
      } else if (parentFile.exists()) {
        throw new RuntimeException(parentFile + " exists, and is not a directory");
      } else {
        mkdirs(parentFile.getParentFile(), true);
      }
      if (parentFile.mkdir()) {
        XLog.i(TAG, "created: " + parentFile);
      }
    } else {
      mkdirs(parentFile.getParentFile(), true);
    }
  }

  public static String bin2hex(byte[] array)
  {
    PrintString sb = new PrintString();
    for (byte b : array) {
      sb.printf("%02x", (b & 0xff));
    }
    return sb.toString();
  }

  public static String md5Hex(@NonNull String message)
  {
    try {
      MessageDigest md = MessageDigest.getInstance("MD5");
      return bin2hex(md.digest(message.getBytes("CP1252")));
    } catch (NoSuchAlgorithmException | UnsupportedEncodingException ex) {
      throw new RuntimeException("digesting text", ex);
    }
  }

  public static byte[] streamToBytes(InputStream is) {
    return mCatching.streamToBytes(is);
  }
  public static String fileToString(File file)
  {
    return mCatching.fileToString(file);
  }
  public static int stringToFile(File file, String save) {
    return mCatching.stringToFile(file, save);
  }
  public static int bytesToFile(File file, byte[] bytes) {
    return mCatching.bytesToFile(file, bytes);
  }
  public static byte[] fileToBytes(File file) {
    return mCatching.fileToBytes(file);
  }
  /**
   * Closes {@code closeable}, ignoring any checked exceptions. Does nothing if {@code closeable} is
   * null.
   */
  public static void closeQuietly(Closeable closeable) {
    if (closeable != null) {
      try {
        closeable.close();
      } catch (RuntimeException rethrown) {
        throw rethrown;
      } catch (Exception ignored) {
      }
    }
  }
  public static void delete(File cacheFile) {
    if (cacheFile.exists() && cacheFile.delete()) {
      ++count;
    } else {
      --count;
    }
    if (count == 0)
      XLog.i(TAG, "ZERO!");
  }
  public static boolean createNewFile(File photoFile) {
    try {
      return photoFile.createNewFile();
    } catch (IOException e) {
      throw Util.rethrow("creating file", e);
    }
  }

  public static void close(AutoCloseable out) {
    if(out!=null) {
      try {
        out.close();
      } catch (Exception e) {
        XLog.i(TAG, "Exception: "+e);
        XLog.i(TAG, "  Closing: "+out);
      }
    }
  }
  public static OutputStream newOutputStream(File file) {
    try {
      return Files.newOutputStream(file.toPath());
    } catch ( Exception e ) {
      throw new RuntimeException("opening "+file, e);
    }
  }

  static class Throwing {
    public static byte[] streamToBytes(InputStream is) throws IOException {
      ByteArrayOutputStream os;
      try {
        os = new ByteArrayOutputStream(1024);
        byte[] buffer = new byte[1024];
        int    len;
        while ((len = is.read(buffer)) >= 0) {
          os.write(buffer, 0, len);
        }
        return os.toByteArray();
      } finally {
        closeQuietly(is);
      }
    }

    public static String fileToString(File file) throws IOException {
      byte[] bytes = streamToBytes(Files.newInputStream(file.toPath()));
      return new String(bytes);

    }

    public static int stringToFile(File cacheFile, String string) throws IOException {
      return bytesToFile(cacheFile, string.getBytes());
    }

    public static int bytesToFile(File cacheFile, byte[] bytes) throws IOException {

      return bytesToStream(Files.newOutputStream(cacheFile.toPath()), bytes);
    }
    public static int bytesToStream(OutputStream fos, byte[] bytes) throws IOException {
      try {
        fos.write(bytes);
        return bytes.length;
      } finally {
        closeQuietly(fos);
      }
    }
    public static byte[] fileToBytes(File file) throws IOException {
      return streamToBytes(Files.newInputStream(file.toPath()));
    }
  }

  public static class Catching {
    Catching() {
    }

    public String fileToString(File file)
    {
      try {
        return Throwing.fileToString(file);
      } catch (IOException ex) {
        throw new RuntimeException("reading file: " + file, ex);
      }
    }

    public int stringToFile(File file, String save) {
      try {
        return Throwing.stringToFile(file, save);
      } catch (IOException ex) {
        throw rethrowException("writing file: " + file+" ex: "+ex,
          ex);
      }
    }

    private RuntimeException rethrowException(String s, Throwable ex) {
      throw new RuntimeException(s,ex);
    }

    public byte[] streamToBytes(InputStream is) {
      try {
        return Throwing.streamToBytes(is);
      } catch (Exception ex) {
        throw rethrowException("reading InputStream: " + is, ex);
      }
    }


    public byte[] fileToBytes(File file) {
      try {
        return Throwing.fileToBytes(file);
      } catch (Exception ex) {
        throw rethrowException("reading File: " + file, ex);
      }
    }
    public int bytesToFile(File file, byte[] bytes) {
      try {
        return Throwing.bytesToFile(file, bytes);
      } catch (Exception ex) {
        throw rethrowException("writing file: " + file, ex);
      }
    }
  }
}
