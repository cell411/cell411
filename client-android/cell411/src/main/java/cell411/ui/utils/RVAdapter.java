package cell411.ui.utils;

import androidx.annotation.Nullable;
import androidx.recyclerview.widget.RecyclerView;

public abstract class RVAdapter extends RecyclerView.AdapterDataObserver {
  @Override
  abstract public void onChanged();
  public RVAdapter() {
    super();
  }
  @Override
  public void onItemRangeChanged(int positionStart, int itemCount) {
    onChanged();
  }
  @Override
  public void onItemRangeChanged(int positionStart, int itemCount,
                                 @Nullable  Object payload)
  {
    onChanged();
  }
  @Override
  public void onItemRangeInserted(int positionStart, int itemCount) {
    onChanged();
  }
  @Override
  public void onItemRangeRemoved(int positionStart, int itemCount) {
    onChanged();
  }
  @Override
  public void onItemRangeMoved(int fromPosition, int toPosition, int itemCount) {
    onChanged();
  }
}
