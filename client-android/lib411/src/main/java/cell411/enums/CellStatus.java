package cell411.enums;

import androidx.annotation.StringRes;
import cell411.services.R;


public enum CellStatus {
  INITIALIZING(-1),
  JOINED(R.string.leave),
  NOT_JOINED(R.string.join),
  DENIED(-1),
  PENDING(-1),
  UN_CHANGED(-1),
  OWNER(R.string.delete);
  @StringRes
  int mAction;

  CellStatus(@StringRes int action)
  {
    mAction = action;
  }

  @StringRes public int getAction() {
    return mAction;
  }
}
