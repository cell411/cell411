package cell411.utils;

import androidx.annotation.Nullable;

public interface ValueObserver<ValueType> {
  void onChange(@Nullable ValueType newValue, @Nullable ValueType oldValue);
}
