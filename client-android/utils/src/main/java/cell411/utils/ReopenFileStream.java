package cell411.utils;

import androidx.annotation.NonNull;

import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;

public class ReopenFileStream extends OutputStream {
  final File mFileName;
  byte[] buf = new byte[1024 * 1024];
  int    pos = 0;

  public ReopenFileStream(File fileName) {
    mFileName = fileName;
    write("ReopenFileStream created");
  }

  public void mkdirs(@NonNull File file) {
    file = file.getParentFile();
    if (file == null) {
      return;
    }
    if (!file.exists()) {
      mkdirs(file);
    } else if (!file.isDirectory()) {
      throw new RuntimeException("Not a directory: " + file);
    }
  }

  public void write(String string) {
    write(string.getBytes(StandardCharsets.UTF_8));
  }

  @Override public void write(byte[] b) {
    write(b, 0, b.length);
  }

  @Override public void write(byte[] b, int off, int len) {
    for (int i = off; i < off + len; i++) {
      write(b[i]);
    }
  }

  @Override public void write(int b) {
    if (b == 13) {
      return;
    }
    buf[pos++] = (byte) b;
    if (b == 10) {
      try {
        mkdirs(mFileName);
        FileOutputStream fos = new FileOutputStream(mFileName, true);
        fos.write(buf, 0, pos);
        fos.close();
        pos = 0;
      } catch (Throwable ignored) {
      }
    }
  }
}
