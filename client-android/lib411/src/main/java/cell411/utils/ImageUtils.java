package cell411.utils;

import android.content.res.Resources;
import android.content.res.Resources.Theme;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.Bitmap.Config;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Matrix;
import android.graphics.Rect;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Environment;
import android.provider.MediaStore;
import android.util.DisplayMetrics;
import android.util.Size;
import androidx.activity.result.contract.ActivityResultContracts.TakePicture;
import androidx.annotation.DrawableRes;
import androidx.annotation.NonNull;
import androidx.core.content.FileProvider;
import androidx.core.content.res.ResourcesCompat;
import androidx.core.util.Pair;
import androidx.exifinterface.media.ExifInterface;
import cell411.base.BaseApp;
import cell411.services.R;

import javax.annotation.Nullable;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URL;

import static android.os.Environment.DIRECTORY_PICTURES;

public class ImageUtils {
  private static final String         TAG              = Reflect.getTag();
  private static final String         JPEG_FILE_SUFFIX = ".jpg";
  private static final DisplayMetrics mDisplayMetrics;
  static {
    Resources resources = getResources();
    mDisplayMetrics = resources.getDisplayMetrics();
  }
  public static void setFlavor(String flavor) {
    mFlavor=flavor;
  }

  private static String mFlavor;

  public static int getOrientation(final String filePath)
  {
    if (Util.isNoE(filePath)) {
      return 0;
    }
    try {
      final ExifInterface
        exifInterface = new ExifInterface(filePath);

      int orientation = exifInterface.getAttributeInt(ExifInterface.TAG_ORIENTATION,
                                           ExifInterface.ORIENTATION_NORMAL);
      return exifOrientationToDegrees(orientation);
    } catch (final IOException ignored) {
    }
    return 0;
  }


  @Nullable
  public static Pair<File,Uri> createUriAndFile(String name, String authority) {
    try {
      BaseApp app        = getApp();
      File            storageDir = app.getExternalFilesDir(DIRECTORY_PICTURES);
      File            imageF     = File.createTempFile(name, JPEG_FILE_SUFFIX, storageDir);
      XLog.i(TAG, "file exists: "+imageF.exists());
      Uri uri = FileProvider.getUriForFile(app, authority, imageF);
      return new Pair<>(imageF,uri);
    } catch (IOException e) {
      throw Util.rethrow("getting uri", e);
    }
  }
  //  public void takePicture(String name) {
  //    try {
  //      if (mUri != null)
  //        throw new IllegalStateException("Uri already pending");
  //
  //      try {
  //        File storageDir = getApp().getExternalFilesDir(Environment.DIRECTORY_PICTURES);
  //        File imageF     = File.createTempFile(name, JPEG_FILE_SUFFIX, storageDir);
  //        UploadPicture.mCurrentPhotoPath = imageF.getAbsolutePath();
  //        mUri                            = IOUtil.getUriForFile(getApp().getCurrentActivity(), imageF);
  //      } catch (IOException e) {
  //        e.printStackTrace();
  //        XLog.i(TAG, "IOException: " + e.getMessage());
  //      }
  //      //      smTPLauncher.launch(mPendingOperation);
  //    } catch (Exception ex) {
  //      handleException("takingPicture", ex);
  //      mUri = null;
  //    }
  //  }

  static public File getMediaOutputDir(String type) {
    // To be safe, you should check that the SDCard is mounted
    // using Environment.getExternalStorageState() before doing

    File mediaStorageDir = new File(getApp().getExternalFilesDir(type),
      "cell411/"+mFlavor);

    if (!mediaStorageDir.mkdirs() && !mediaStorageDir.exists()) {

      getApp().showAlertDialog(
        "mediaStorageDir " + mediaStorageDir + " does not exist, and creation failed");
      return null;
    }
    return mediaStorageDir;
  }


  @NonNull
  public static File getAvatarDir() {
    BaseApp app = BaseApp.get();
    File cacheDir = app.getCacheDir();
    return new File(cacheDir, "avatars");

  }


  public static Bitmap getCroppedBitmap(@androidx.annotation.Nullable Bitmap bmp) {
    if (bmp == null) {
      return null;
    }
    if(bmp.getWidth()==bmp.getHeight())
      return bmp;
    int         size   = Math.min(bmp.getWidth(), bmp.getHeight());
    Bitmap      output = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888);
    Canvas      canvas = new Canvas(output);
    canvas.drawARGB(0, 0, 0, 0);
    Rect rectDest;
    Rect rectSrc;
    if (bmp.getWidth() < bmp.getHeight()) {
      double diff = bmp.getHeight() - bmp.getWidth();
      rectSrc  = new Rect(0, (int) diff / 2, bmp.getWidth(), bmp.getHeight() - ((int) diff / 2));
      rectDest = new Rect(0, 0, bmp.getWidth(), bmp.getWidth());
    } else {
      double diff = bmp.getWidth() - bmp.getHeight();
      rectSrc  = new Rect((int) diff / 2, 0, bmp.getWidth() - ((int) diff / 2), bmp.getHeight());
      rectDest = new Rect(0, 0, bmp.getHeight(), bmp.getHeight());
    }
    canvas.drawBitmap(bmp, rectSrc, rectDest, null);
    return output;

  }

  public static File saveImage(File file, Bitmap bitmap) {
    return saveImage(file, bitmap, Bitmap.CompressFormat.PNG);
  }

  public static File saveImage(File file, Bitmap bitmap, Bitmap.CompressFormat format)
  {
    XLog.i(TAG, Reflect.currentMethodName() + " invoked");
    if (bitmap == null)
      return null;
    if (!file.isAbsolute()) {
      File directory = new File(getMediaOutputDir(DIRECTORY_PICTURES),
                                "Cell411");
      IOUtil.mkdirs(directory,true);
      file = new File(directory, file.getName());
    }
    XLog.i(TAG, "saving to " + file);
    try (
      OutputStream out = IOUtil.newOutputStream(file)
    ) {
      bitmap.compress(format, 100, out);
      out.flush();
      XLog.i(TAG, "File Written");
      return file.getAbsoluteFile();
    } catch (Throwable throwable) {
      throw Util.rethrow("saving image", throwable);
    }
  }

  public static String getBaseName(URL url) {
    String fileName = url.toString();
    int    pos      = fileName.lastIndexOf('/');
    fileName = fileName.substring(pos + 1);
    return fileName;
  }

  public static Bitmap makeThumbnail(@androidx.annotation.Nullable Bitmap bmp) {
    bmp = getCroppedBitmap(bmp);
    Bitmap output = Bitmap.createBitmap(300, 300, Bitmap.Config.ARGB_8888);
    Canvas canvas = new Canvas(output);
    Rect   rectDest;
    Rect   rectSrc;
    rectSrc=new Rect(0,0,bmp.getHeight(),bmp.getHeight());
    rectDest=new Rect(0,0,output.getWidth(),output.getHeight());
    canvas.drawBitmap(bmp, rectSrc, rectDest, null);
    return output;
  }
  public static float rotationForImage(Uri uri)
  {
    Cursor c = null;
    try {
      if (uri.getScheme().equals("content")) {
        //From the media gallery
        String[] projection = {MediaStore.Images.ImageColumns.ORIENTATION};
        c = getApp().getContentResolver().query(uri, projection, null, null, null);
        if (c.moveToFirst()) {
          c.getInt(0);
        }
      } else if (uri.getScheme().equals("file")) {
        //From a file saved by the camera
        ExifInterface exif = new ExifInterface(uri.getPath());
        int rotation = (int) exifOrientationToDegrees(
          exif.getAttributeInt(ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_NORMAL));
        exif.setAttribute(ExifInterface.TAG_ORIENTATION, "" + ExifInterface.ORIENTATION_NORMAL);
        exif.saveAttributes();
        return rotation;
      }
      return 0;
    } catch (IOException e) {
      XLog.e(TAG, "Error checking exif", e);
      return 0;
    } finally {
      if (c != null) {
        c.close();
      }
    }
  }
  public static int exifOrientationToDegrees(int exifOrientation)
  {
    if (exifOrientation == ExifInterface.ORIENTATION_ROTATE_90) {
      return 90;
    } else if (exifOrientation == ExifInterface.ORIENTATION_ROTATE_180) {
      return 180;
    } else if (exifOrientation == ExifInterface.ORIENTATION_ROTATE_270) {
      return 270;
    }
    return 0;
  }

  @Nullable
  public static Bitmap rotateBitmap(Bitmap bmp, float rotation) {
    if (rotation != 0) {
      //New rotation matrix
      Matrix matrix = new Matrix();
      matrix.preRotate(rotation);
      bmp = Bitmap.createBitmap(bmp, 0, 0, bmp.getWidth(), bmp.getHeight(), matrix, true);
      if (bmp == null) {
        XLog.i(TAG, "2: Bitmap is null");
      }
    }
    if (bmp == null) {
      XLog.i(TAG, "bmp is null");
    }
    return bmp;

  }
  public static Bitmap loadCameraImage(File file)
  {
    String path=file.getAbsolutePath();
    Bitmap bitmap =
      decodeSampledBitmapFromResource(path, 300,
                                      300);

    float rotation = ImageUtils.getOrientation(path);
    if (rotation != 0) {
      Matrix matrix2 = new Matrix();
      matrix2.preRotate(rotation);
      bitmap =
        Bitmap.createBitmap(bitmap, 0, 0, bitmap.getWidth(), bitmap.getHeight(), matrix2, true);
    }
    return bitmap;
  }

  //  public static void dispatchTakePictureIntent(Activity activity, int requestCode)
  //  {
  //    Intent takePictureIntent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
  //    try {
  //      String timeStamp     = Util.isoDate();
  //      String imageFileName = JPEG_FILE_PREFIX + timeStamp + "_";
  //      File   storageDir    = getApp().getExternalFilesDir(Environment.DIRECTORY_PICTURES);
  //      File   imageF        = File.createTempFile(imageFileName, JPEG_FILE_SUFFIX, storageDir);
  //      mCurrentPhotoPath = imageF.getAbsolutePath();
  //      XLog.i(TAG, "mCurrentPhotoPath: " + mCurrentPhotoPath);
  //      Uri photoURI = IOUtil.getUriForFile(getApp().getCurrentActivity(), imageF);
  //      takePictureIntent.putExtra(MediaStore.EXTRA_OUTPUT, photoURI);
  //    } catch (IOException e) {
  //      e.printStackTrace();
  //      XLog.i(TAG, "IOException: " + e.getMessage());
  //    }
  //    activity.startActivityForResult(takePictureIntent, requestCode);
  //  }

  public static float getDensity() {
    return mDisplayMetrics.density;
  }
  public static int getScreenWidth() {
    return mDisplayMetrics.widthPixels;
  }
  public static int getScreenHeight() {
    return mDisplayMetrics.heightPixels;
  }
  public static Drawable getDrawable(int id) {
    Resources res   = getResources();
    Theme     theme = getTheme();
    return ResourcesCompat.getDrawable(res, id, theme);
  }
  private static Theme getTheme() {
    return getApp().getTheme();
  }
  private static Resources getResources() {
    return getApp().getResources();
  }
  @NonNull
  public static BaseApp getApp() {
    return BaseApp.get();
  }
  public static Size getLargeIconSize() {
    Resources res = getResources();
    int wid = cell411.utils.R.dimen.compat_notification_large_icon_max_width;
    int hid = cell411.utils.R.dimen.compat_notification_large_icon_max_height;
    int width  = res.getDimensionPixelSize(wid);
    int height = res.getDimensionPixelSize(hid);
    return new Size(width, height);
  }
  static Bitmap createBitmap(Size size) {
    int    width    = size.getWidth();
    int    height   = size.getHeight();
    Config argb8888 = Config.ARGB_8888;
    return Bitmap.createBitmap(width, height, argb8888);
  }
  static Drawable setSize(Drawable drawable, Size size) {
    return setSize(drawable, size.getWidth(), size.getHeight());
  }
  public static Bitmap getLargeIconBitmap(@DrawableRes int drawableId) {
    Size     size     = getLargeIconSize();
    Drawable drawable = setSize(getDrawable(drawableId),size);
    Bitmap   bitmap   = createBitmap(size);
    Canvas   canvas   = new Canvas(bitmap);
    drawable.draw(canvas);
    return bitmap;
  }
  static Drawable setSize(Drawable drawable, int width, int height) {
    drawable.setBounds(0, 0, width, height);
    return drawable;
  }
  public static Bitmap decodeSampledBitmapFromResource(String imageFile, int reqWidth,
                                                       int reqHeight)
  {
    //    XLog.i(TA//G, "Decoding Bitmap to " + reqWidth + " * " + reqHeight);
    // First decodeObject with inJustDecodeBounds=true to check dimensions
    final BitmapFactory.Options options = new BitmapFactory.Options();
    options.inJustDecodeBounds = true;
    BitmapFactory.decodeFile(imageFile, options);
    // Calculate inSampleSize
    options.inSampleSize = StorageOperations.calculateInSampleSize(options, reqWidth, reqHeight);
    // Decode bitmap with inSampleSize set
    options.inJustDecodeBounds = false;
    //    XLog.i(T//AG, "Decoding Bitmap to sample size = " + options.inSampleSize);
    return BitmapFactory.decodeFile(imageFile, options);
  }
  public static Bitmap getBitmap(byte[] bytes) {
    return BitmapFactory.decodeByteArray(bytes,0,bytes.length);
  }
  public static Bitmap loadGalleryImage(Uri uri) {
    try (InputStream is = getApp().getContentResolver().openInputStream(uri)
    ){
      Bitmap bmp      = BitmapFactory.decodeStream(is);
      float  rotation = rotationForImage(uri);
      return ImageUtils.rotateBitmap(bmp, rotation);
    } catch (Throwable throwable) {
      throw Util.rethrow("saving Image", throwable);
    }
  }
}
