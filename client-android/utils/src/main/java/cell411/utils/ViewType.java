package cell411.utils;

import java.util.EnumMap;

public enum ViewType {
  // Here are the actual enum items, declared with random values
  vtNull(false),
  vtAlert(true),
  vtRequest(true),
  vtString(false),
  vtUser(true),
  vtPrivateCell(true),
  vtPublicCell(true);

  private final boolean mIsParseObject;
  ViewType(boolean isParseObject) {
    mIsParseObject=isParseObject;
  }
  public boolean isParseObject() {
    return mIsParseObject;
  }
  public static ViewType valueOf(int intViewType)
  {
    ViewType[] values = values();
    final int i = intViewType - values[0].ordinal();
    if (i >= 0 && i < values.length && values[i].ordinal() == intViewType) {
      return values[i];
    }
    for (ViewType viewType : values) {
      if (viewType.ordinal() == intViewType) {
        return viewType;
      }
    }
    throw new IllegalArgumentException("No ViewType with ordinal " + intViewType);
  }
}

