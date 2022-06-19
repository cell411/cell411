package cell411.logic;

import androidx.annotation.NonNull;

import com.parse.http.FullObjectCoder;

import java.io.File;

import cell411.base.BaseContext;
import cell411.json.JSONObject;
import cell411.utils.IOUtil;
import cell411.utils.Reflect;
import cell411.utils.XLog;

public abstract class CacheObject implements ICacheObject, BaseContext {
  private static final String TAG = Reflect.getTag();
  static {
    XLog.i(TAG, "loading file");
  }
  private final String mName;
  private final File mCacheFile;
  private final FullObjectCoder mCoder = new FullObjectCoder();

  public CacheObject(String name) {
    mName = name;
    mCacheFile = app().getJsonCacheFile(name);
  }

  public void stringToFile(String text) {
    if (getCacheFile().exists())
      getCacheFile().renameTo(getBackupFile());
    IOUtil.stringToFile(getCacheFile(), text);
  }

  public String fileToString() {
    return IOUtil.fileToString(getCacheFile());
  }

  public void jsonToFile(JSONObject object) {
    stringToFile(object.toString(2));
  }

  public void jsonToFile(Object object) {
    JSONObject wrapper = new JSONObject();
    wrapper.put("__wrapped", object);
    jsonToFile(wrapper);
  }

  @Override
  @NonNull
  public File getBackupFile() {
    return new File(getCacheFile().toString() + ".bak");
  }

  public <X> X fileToJSON(Class<X> type) {
    if (type == JSONObject.class) {
      String json = fileToString();
      JSONObject obj = new JSONObject(json);
      return type.cast(obj);
    } else {
      JSONObject wrapper = fileToJSON(JSONObject.class);
      return type.cast(wrapper.get("__wrapped"));
    }
  }
  @Override
  public boolean cacheExists() {
    return getCacheFile().exists();
  }

  @Override
  public String getName() {
    return mName;
  }

  @Override
  public File getCacheFile() {
    return mCacheFile;
  }

  public FullObjectCoder getCoder() {
    return mCoder;
  }
}
