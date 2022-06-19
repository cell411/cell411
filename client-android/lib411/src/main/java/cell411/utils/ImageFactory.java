package cell411.utils;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import cell411.base.BaseApp;
import cell411.json.JSONObject;
import cell411.parse.util.OnCompletionListener;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;
import okhttp3.ResponseBody;

import java.io.File;
import java.io.FileNotFoundException;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.function.Consumer;


public class ImageFactory {
  public final static String            TAG      = ImageFactory.class.getSimpleName();
  final static        ImageFactory      INSTANCE = new ImageFactory();
  final static        HandlerThreadPlus smThread =
    HandlerThreadPlus.createThread("ImageFactory Thread");
  final static  Handler      smMainHandler;

  public static OkHttpClient smClient;
//  static        Runnable     smCacheReporter = new CacheReporter();
  static        Bitmap       smDummy;
  final static        Handler           smHandler;
  private static final URL smUploadUrl =
    NetUtils.toURL("https://dev.copblock.app/upload/index.html");

  static {
    smHandler = smThread.getHandler();
    assert (smHandler != null);
    smMainHandler = new CarefulHandler(Looper.getMainLooper());
  }
  final HashMap<URL, CacheItem> smCache = new HashMap<>();
  static public Bitmap loadBitmapAsync(String url, final ImageListener listener) {
    return loadBitmapAsync(NetUtils.toURL(url), listener);
  }
  public static Bitmap loadBitmapAsync(URL url, ImageListener listener) {
    if (url == null) {
      return null;
    }
    XLog.i(TAG, "Request for " + url);
    CacheItem cache;
    synchronized (INSTANCE.smCache) {

      cache = INSTANCE.smCache.computeIfAbsent(url, (key) -> new CacheItem());
      if (cache.mSource == null) {
        cache.mSource = "Not Loaded";
        XLog.i(TAG, " ... And this was the first request.");
        cache.mURL = url;
        INSTANCE.smCache.put(url, cache);
        cache.mListeners.add(listener);
        XLog.i(TAG, " ... loading " + url + " in my thread");
        smHandler.post(new S3Loader(cache));
      } else if (cache.mResult != null) {
        XLog.i(TAG, " ... cache hit ... and image is loaded.  calling listener.");
        return cache.mResult;
      } else {
        XLog.i(TAG, " ... cache hit ... but image is still loading.  appending listener to list");
        cache.mListeners.add(listener);
      }
    }
    return null;
  }

  public static void saveProfileImage(@NonNull CacheItem cache) {
    saveProfileImage(cache, null);
  }
  public static void saveProfileImage(@NonNull CacheItem cache, @Nullable OnCompletionListener listener)
  {
    if(!smHandler.getLooper().isCurrentThread()) {
      smHandler.post(()-> saveProfileImage(cache, listener));
      return;
    }
    try {
      File avatarDir = ImageUtils.getAvatarDir();
      IOUtil.mkdirs(avatarDir, true);
      if (!avatarDir.isDirectory()) {
        throw new RuntimeException("Failed to make avatarDir: " + avatarDir);
      }
      cache.mFile = new File(avatarDir, ImageUtils.getBaseName(cache.mURL));
      if(cache.mEncoded!=null) {
        IOUtil.bytesToFile(cache.mFile, cache.mEncoded);
        cache.mEncoded=null;
      } else {
        ImageUtils.saveImage(cache.mFile, cache.mResult);
      }
      if (listener != null)
        listener.done(true);
    } catch ( Exception e ) {
      BaseApp.get().handleException("saving profile pic", e, null);
      if(listener!=null)
        listener.done(false);
    }
  }


  public static void uploadAvatar(final String basename, final Bitmap avatar, Consumer<String> sink)
  {
//    CacheItem cache = INSTANCE.smCache.computeIfAbsent(url, (key) -> new CacheItem());
    CacheItem cache = new CacheItem();
    cache.mURL = NetUtils.toURL("file://"+basename);
    cache.mResult=avatar;
    saveProfileImage(cache, success -> {
      if(!success) {
        BaseApp.get().showAlertDialog("Failed to save image");
        return;
      }
      String result = NetUtils.sendUpload(smUploadUrl, basename, cache.mFile, "image/png");
      if(result==null) {
        BaseApp.get().showAlertDialog("Failed to upload image");
        return;
      }
      JSONObject json = new JSONObject(result);
      sink.accept(json.getString("url"));
    });
  }

  public interface ImageListener {
    void ready(Bitmap bitmap);
  }

  static class CacheItem {
    final ArrayList<ImageListener> mListeners = new ArrayList<>();
    public File mFile;
    public byte[] mEncoded;
    int    mTries = 0;
    String mSource;
    URL    mURL;
    Bitmap mResult;
  }

  static class S3Loader implements Runnable {
    final CacheItem mCache;

    S3Loader(CacheItem cache)
    {
      mCache = cache;
    }

    @Override
    public void run() {
      if (smClient == null) {

        OkHttpClient.Builder clientBuilder = BaseApp.get().getClientBuilder();
        smClient = clientBuilder.build();
      }
      if (Thread.currentThread() == smThread) {
        if (loadFromDisk()) {
          XLog.i(TAG, "loadedFromDisk");
          mCache.mSource = "Disk";
        } else if (loadFromNet()) {
          XLog.i(TAG, "loadedFromNetwork");
          mCache.mSource = "Network";
        } else if (mCache.mTries < 3) {
          mCache.mTries++;
          smHandler.postDelayed(this, 30000);
        } else {
          mCache.mSource = "Dummy";
          mCache.mResult = smDummy;
        }
        smMainHandler.post(this);
      } else if (Looper.getMainLooper().isCurrentThread()) {
        notifyListeners();
      } else {
        throw new RuntimeException("We should not be in this thread.");
      }
    }
    private boolean loadFromDisk() {
      try {
        String fileName = ImageUtils.getBaseName(mCache.mURL);
        File   file     = new File(ImageUtils.getAvatarDir(), fileName);
        if (!file.exists())
          return false;
        mCache.mFile=file;
        byte[]          data   = IOUtil.fileToBytes(file);
        mCache.mResult = BitmapFactory.decodeByteArray(data, 0, data.length);
        if(mCache.mResult==null) {
          if(!mCache.mFile.delete())
            XLog.i(TAG, "failed to delete file");
          return false;
        } else {
          return true;
        }
      } catch (RuntimeException e) {
        return false;
      }
    }

    public boolean loadFromNet() {
      XLog.i(TAG, "ImageLoader name=" + mCache.mURL);
      XLog.i(TAG, "  running on thread: " + Thread.currentThread());
      ResponseBody body = null;
      try {
        URL url = mCache.mURL;
        mCache.mTries++;
        final Request  req  = new Request.Builder().url(url).get().build();
        final Response resp = smClient.newCall(req).execute();
        final int      code = resp.code();
        if (code == 200) {
          body = resp.body();
          assert body != null;
          mCache.mEncoded = body.bytes();
          saveProfileImage(mCache);
          return loadFromDisk();
        } else {
          XLog.i(TAG, " ... bad result code: " + code);
          XLog.i(TAG, " ... bad result code: on " + mCache.mURL);
        }
      } catch (MalformedURLException | FileNotFoundException e) {
        XLog.i(TAG, "failed to load image ..." + "  url: " + mCache.mURL + "  ex:  " + e);
        return false;
      } catch (Exception e) {
        XLog.i(TAG, "failed to load image ... " + "url: : " + mCache.mURL + "exception: " + e);
        return false;
      } finally {
        if (body != null) {
          body.close();
        }
      }
      return false;
    }

    public void notifyListeners() {
      ArrayList<ImageListener> listeners;
      synchronized (INSTANCE.smCache) {
        listeners = new ArrayList<>(mCache.mListeners);
        mCache.mListeners.clear();
      }

      for (ImageListener listener : listeners) {
        listener.ready(mCache.mResult);
      }
    }
  }


}

