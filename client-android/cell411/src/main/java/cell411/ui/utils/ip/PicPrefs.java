package cell411.ui.utils.ip;

import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.io.File;

import cell411.utils.NetUtils;
import cell411.utils.Util;

@SuppressWarnings("SameParameterValue")
public class PicPrefs {
  public String mMimeType;
  public String mBaseName;
  public Bitmap mBitmap;
  public Uri mUri;
  public File mFile;

  public PicPrefs(  String basename, String mimeType, Uri uri,
                  File file) {
    mMimeType = mimeType;
    mBaseName = basename;
    mUri = uri;
    mFile = file;
    mBitmap = null;
  }

  public PicPrefs(String basename, String mimeType) {
    this(basename, mimeType, null, null);
  }

  public PicPrefs() {
    this(null,null);
  }

  @NonNull
  public String toString() {
    return Util.format("PicPrefs(name=%s,\n   mimetype=%s,\n   )",
      mBaseName, mMimeType);
  }


  public void updateFromIntent(final Intent intent)
  {
    mBaseName=intent.getStringExtra("baseName");
    mMimeType=intent.getStringExtra("mimeType");
    mUri= getUri(intent, "uri");
    mFile = getFile(intent, "file");
  }

  @Nullable
  private Uri getUri(final Intent intent, String key) {
    String string = intent.getStringExtra(key);
    if(string==null)
      return null;
    else
      return NetUtils.toUri(string);
  }

  @Nullable
  private File getFile(final Intent intent, String key) {
    String file = intent.getStringExtra(key);
    if(file==null)
      return null;
    else
      return new File(file);
  }

  public void addToIntent(final Intent intent) {
    if(mBaseName!=null)
      intent.putExtra("baseName", mBaseName);
    if(mMimeType!=null)
      intent.putExtra("mimeType", mMimeType);
    if(mUri!=null)
      intent.putExtra("uri", mUri.toString());
    if(mFile!=null)
      intent.putExtra("file", mFile.getAbsolutePath());
  }
}
