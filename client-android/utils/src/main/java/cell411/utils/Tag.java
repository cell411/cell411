package cell411.utils;

import androidx.annotation.NonNull;

public class Tag implements XLog.Tag {
  String mTag;

  public Tag(String tag) {
    mTag = tag;
  }

  @NonNull
  public String toString() {
    return mTag;
  }
}
