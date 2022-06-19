package cell411.utils;

import androidx.annotation.Nullable;

import cell411.base.BaseApp;

public class ObserveLater<VT> implements Runnable, ValueObserver<VT> {
  final ValueObserver<VT> mPayload;
  VT mOld;
  VT mNew;

  public ObserveLater(ValueObserver<VT> payload) {
    mPayload = payload;
  }

  public void run() {
    mPayload.onChange(mNew, mOld);
  }

  @Override public void onChange(VT value, VT oldValue) {
    mOld = oldValue;
    mNew = value;
    BaseApp.get().onUI(this,0);
  }

  @SuppressWarnings("EqualsWhichDoesntCheckParameterClass") @Override public boolean equals(@Nullable Object obj) {
    return obj == this || obj == mPayload;
  }
}
