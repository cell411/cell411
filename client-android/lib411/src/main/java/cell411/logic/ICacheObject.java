package cell411.logic;

import java.io.File;

import cell411.utils.PrintString;

public interface ICacheObject {

  String getName();

  boolean cacheExists();
  File getCacheFile();
  File getBackupFile();

  void prepare();
  void loadFromCache();
  void loadFromNet();
  void saveToCache();

  void requestDataReport(PrintString ps);
  void clear();
}
