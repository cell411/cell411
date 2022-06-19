package cell411.utils;

import android.graphics.BitmapFactory;
import android.os.Environment;
import androidx.annotation.NonNull;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.OutputStream;
import java.nio.file.Files;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import static cell411.utils.IOUtil.mkdirs;

import cell411.base.BaseApp;

public class StorageOperations {
  private static final String TAG = StorageOperations.class.getSimpleName();
  private static       File   cacheDir;

  public static HashMap<String, Boolean> loadAudience()
  {
    XLog.i(TAG, Reflect.currentMethodName() + " invoked");
    HashMap<Object, Object>  tmp = readMapFile("audience.dat");
    HashMap<String, Boolean> res = new HashMap<>();
    if (tmp == null)
      return res;
    for (Object key : tmp.keySet()) {
      Object val = tmp.get(key);
      if (key instanceof String && val instanceof Boolean) {
        res.put((String) key, (Boolean) val);
      }
    }
    return res;
  }

  public static void storeAudience(HashMap<String, Boolean> audienceMap)
  {
    XLog.i(TAG, Reflect.currentMethodName() + " invoked");
    assert audienceMap != null;
    writeFileRaw("audience.dat", audienceMap);
  }

  public static void deleteAudience()
  {
    XLog.i(TAG, Reflect.currentMethodName() + " invoked");
    deleteFileAndDir("SelectedAudience");
  }

  private static void closeStream(OutputStream stream) {
    try {
      stream.close();
    } catch (Exception e) {
      // Say nothing, act natural
    }
  }

  public static void writeFileRaw(String name, Object obj) {
    ObjectOutputStream out = null;
    try {
      File file;
      if (name.startsWith("/")) {
        file = new File(name);
      } else {
        file = new File(getCacheDir(), name);
      }
      mkdirs(file.getParentFile(), false);
      XLog.i(TAG, "saved to " + file);
      out = new ObjectOutputStream(Files.newOutputStream(file.toPath()));
      out.writeObject(obj);
      XLog.i(TAG, "Object Written");
    } catch (IOException e) {
      e.printStackTrace();
    } finally {
      closeStream(out);
    }
  }


  public static int calculateInSampleSize(BitmapFactory.Options options, int reqWidth,
                                          int reqHeight)
  {
    XLog.i(TAG, Reflect.currentMethodName() + " invoked");
    // Raw height and width of image
    final int height       = options.outHeight;
    final int width        = options.outWidth;
    int       inSampleSize = 1;
    if (height > reqHeight || width > reqWidth) {
      final int halfHeight = height / 2;
      final int halfWidth  = width / 2;
      // Calculate the largest inSampleSize value that is a power of 2 and
      // keeps both
      // height and width larger than the requested height and width.
      while ((halfHeight / inSampleSize) > reqHeight && (halfWidth / inSampleSize) > reqWidth) {
        inSampleSize *= 2;
      }
    }
    return inSampleSize;
  }

  public static void deleteRecursive(@NonNull String path)
  {
    deleteRecursive(new File(getCacheDir() + "/" + path));
  }

  public static void deleteRecursive(@NonNull File fileOrDirectory)
  {
    if (fileOrDirectory.isDirectory()) {
      File[] files = fileOrDirectory.listFiles();
      if (files != null) {
        for (File child : files) {
          deleteRecursive(child);
        }
      }
    }
    if (fileOrDirectory.delete() && fileOrDirectory.exists()) {
      XLog.i(TAG, "Failed to delete " + fileOrDirectory);
    }
  }

  public static void deletePhotos()
  {
    XLog.i(TAG, Reflect.currentMethodName() + " invoked");
    // Make sure external shared storage is available
    if (getCacheDir() == null) {
      return;
    }
    File dirPhoto = new File(getCacheDir().getAbsolutePath() + "/" + "Photo");
    deleteRecursive(dirPhoto);
  }



  private static void deleteFileAndDir(String dirName) {
    XLog.i(TAG, "deleteFileAndDir(" + dirName + ")");
    deleteRecursive(dirName);
  }

  private static <T> ArrayList<T> readArrayFile(String file, Class<T> c)
  {
    XLog.i(TAG, Reflect.currentMethodName() + "(" + c + ")");
    try {
      return readFileRaw(file);
    } catch (Exception e) {
      XLog.i(TAG, Reflect.currentStackPos() + ":  " + e);
      return new ArrayList<>();
    }
  }

  public static <K, V> HashMap<K, V> readMapFile(String file)
  {
    try {
      return readFileRaw(file);
    } catch (Exception e) {
      XLog.i(TAG, Reflect.currentStackPos() + ":  " + e);
    }
    return new HashMap<>();
  }


  @SuppressWarnings("unchecked")
  private static <T> T readFileRaw(String relPath)
  {
    XLog.i(TAG, String.format("readFile(%s)", relPath));
    File file;
    if (relPath.charAt(0) == '/') {
      file = new File(relPath);
    } else {
      file = new File(getCacheDir().getAbsolutePath() + "/" + relPath);
    }
    if (!file.exists()) {
      return null;
    }
    XLog.i(TAG, "Reading " + relPath + " Directory");
    T res = null;
    try (ObjectInputStream inputStream = new ObjectInputStream(new FileInputStream(file))) {
      res = (T) inputStream.readObject();
    } catch (IOException | ClassNotFoundException e) {
      e.printStackTrace();
    }
    return res;
  }

  public static void clearData()
  {
    deletePhotos();
    deleteAudience();
  }

  public static File getCacheDir()
  {
    if (cacheDir == null) {
      // Make sure external shared storage is available
      if (Environment.MEDIA_MOUNTED.equals(Environment.getExternalStorageState())) {
        // We can read and write the media

        cacheDir = BaseApp.get().getExternalFilesDir(null);
      } else {
        // Load another directory, probably local memory

        cacheDir = BaseApp.get().getFilesDir();
      }
    }
    return cacheDir;
  }


  @SuppressWarnings({"unchecked", "rawtypes", "unused"})
  static class SavedList<C, CList extends List<C>> {
    final File mFile;

    SavedList(File file) {
      mFile = file;
    }

    public CList read() {
      CList res = readFileRaw(mFile.toString());
      if (res != null) {
        XLog.i(TAG, Util.format("read %s alerts from storage.", res.size()));
        return res;
      }
      XLog.i(TAG, Util.format("read NO alerts from storage."));
      try {
        store((CList) new ArrayList());
      } catch (Exception ex) {
        throw new RuntimeException("Creating new container at factory", ex);
      }
      // this will blow itself to hell, recursively, it it fails.
      return read();
    }

    private void store(CList maps) {
      writeFileRaw(mFile.toString(), maps);
    }

    public void append(C data) {
      CList list = read();
      list.add(data);
      store(list);
    }
  }
}

