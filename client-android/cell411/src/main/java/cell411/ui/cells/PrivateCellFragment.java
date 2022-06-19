package cell411.ui.cells;

import static cell411.utils.ViewType.vtNull;
import static cell411.utils.ViewType.vtPrivateCell;
import static cell411.utils.ViewType.vtString;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.google.android.material.floatingactionbutton.FloatingActionButton;
import com.safearx.cell411.R;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

import cell411.Cell411;
import cell411.base.BaseFragment;
import cell411.logic.LQListener;
import cell411.logic.LiveQueryService;
import cell411.logic.CellWatcher;
import cell411.logic.Watcher;
import cell411.methods.CellDialogs;
import cell411.parse.XPrivateCell;
import cell411.parse.util.XItem;
import cell411.utils.Util;
import cell411.utils.ViewType;
import cell411.utils.XLog;

/**
 * Created by Sachin on 18-04-2016.
 */
public class PrivateCellFragment extends BaseFragment {
  public static final String BROADCAST_ACTION_NEW_PRIVATE_CELL =
    "com.safearx.cell411.NEW_PRIVATE_CELL_RECEIVER";
  public static final String TAG = PrivateCellFragment.class.getSimpleName();

  static {
    XLog.i(TAG, "loading class");
  }

  private final CellListAdapter mCellListAdapter;
  private final LiveQueryService mService;
  private final CellWatcher<XPrivateCell> mOwnedPrivateCellWatcher;

  private RecyclerView mRecyclerView;
  private static final Comparator<? super XItem> smComparator =
    Comparator.comparing(XItem::getText)
      .thenComparing(XItem::getObjectId);

  public PrivateCellFragment() {
    super(R.layout.fragment_private_cells);
    mService = Cell411.get().lqs();
    mOwnedPrivateCellWatcher = mService.getPrivateCellWatcher();
    mCellListAdapter = new CellListAdapter();
    mOwnedPrivateCellWatcher.addListener(mCellListAdapter);
  }

  @Override
  public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
    super.onViewCreated(view, savedInstanceState);
    FloatingActionButton fab = view.findViewById(R.id.fab);
    fab.hide();
    mRecyclerView = view.findViewById(R.id.fragment_private_cells);
    mRecyclerView.setLayoutManager(new LinearLayoutManager(getActivity()));
    mRecyclerView.setAdapter(mCellListAdapter);
  }



  // Provide a reference to the views for each data item
  // Complex data items may need more than one view per item, and
  // you provide access to all the views for a data item in a view holder
  public static class ViewHolder extends RecyclerView.ViewHolder {
    // each data item is just a string in this case
    private TextView txtCellName;
    private TextView txtInfo;

    public ViewHolder(View view, int type) {
      super(view);
      if (type == vtPrivateCell.ordinal()) {
        txtCellName = view.findViewById(R.id.txt_cell_name);
      } else {
        txtInfo = view.findViewById(R.id.txt_info);
      }
    }
  }

  public class CellListAdapter extends RecyclerView.Adapter<ViewHolder>
    implements LQListener<XPrivateCell> {
    public final ArrayList<XItem> mItems = new ArrayList<>();
    private final View.OnClickListener mOnClickListener = this::onClick;
    private final View.OnLongClickListener mOnLongClickListener = this::onLongClick;

    public CellListAdapter() {
      mItems.add(new XItem("", "Loading Data..."));
    }

    public void onClick(View v) {
      int position = mRecyclerView.getChildAdapterPosition(v);
      XItem item = mItems.get(position);
      if (item.getViewType() != vtPrivateCell) {
        return;
      }
      XPrivateCell cell = item.getPrivateCell();
      PrivateCellMembersActivity.start(getActivity(), cell);
    }

    public boolean onLongClick(View v) {
      int position = mRecyclerView.getChildAdapterPosition(v);
      if (position >= mItems.size()) {
        return false;
      }
      XItem item = mItems.get(position);
      if (item.getViewType() != vtPrivateCell) {
        return false;
      }
      final XPrivateCell privateCell = item.getPrivateCell();
      if (privateCell.getCellType() == 5) {
        CellDialogs.showDeleteCellDialog(getActivity(), privateCell, success -> {
          if (success) {
            Cell411.get().showToast("Cell " + privateCell.getName() + " deleted");
          } else {
            Cell411.get().showToast("Cell " + privateCell.getName() + " not deleted");
          }
          refresh();
        });
      } else {
        Cell411.get().showToast("Default Cells cannot be deleted");
      }
      return false;
    }

    // Create new views (invoked by the layout manager)
    @NonNull
    @Override
    public PrivateCellFragment.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent,
                                                             int viewType) {
      assert mService.mPrivateCellWatcher == mOwnedPrivateCellWatcher;
      // create a new view
      View v = null;
      if (viewType == vtPrivateCell.ordinal()) {
        v = LayoutInflater.from(parent.getContext())
          .inflate(R.layout.cell_private_cell, parent, false);
      } else if (viewType == vtString.ordinal()) {
        v = LayoutInflater.from(parent.getContext())
          .inflate(R.layout.cell_footer, parent, false);
      } else if (viewType == vtNull.ordinal()) {
        v = new View(getContext());
      }
      // set the view's size, margins, padding's and layout parameters
      PrivateCellFragment.ViewHolder vh = new ViewHolder(v, viewType);
      if (v != null) {
        if (viewType == vtPrivateCell.ordinal()) {
          v.setOnClickListener(mOnClickListener);
          v.setOnLongClickListener(mOnLongClickListener);
        }
      }
      return vh;
    }

    // Replace the contents of a view (invoked by the layout manager)
    @Override
    public void onBindViewHolder(final @NonNull PrivateCellFragment.ViewHolder viewHolder,
                                 final int position) {
      // - get element from your data set at this position
      // - replace the contents of the view with that element
      XItem item = mItems.get(position);
      ViewType viewType = item.getViewType();
      if (viewType == vtPrivateCell) {
        viewHolder.txtCellName.setText(item.getPrivateCell()
          .getName());
      } else if (viewType == vtString) {
        viewHolder.txtInfo.setText(item.getText());
      } else if (viewType == vtNull) {
        XLog.i(TAG, "Say nothing, act natural");
      } else {
        throw new IllegalArgumentException("viewType==" + viewType);
      }
    }

    public ViewType getViewType(int position) {
      return getItem(position).getViewType();
    }

    @Override
    public int getItemViewType(int position) {
      return getViewType(position).ordinal();
    }

    private XItem getItem(int position) {
      return mItems.get(position);
    }

    @Override
    public int getItemCount() {
      return mItems.size();
    }

    public void change(final Watcher<XPrivateCell> watcher) {
      List<XPrivateCell> objects = watcher.getData();
      int oldSize = mItems.size();
      int newSize = objects.size();
      ArrayList<XItem> newItems = Util.transform(objects, XItem::new);
      mItems.clear();
      mItems.addAll(newItems);
      mItems.sort(smComparator);
      if(oldSize < newSize) {
        if(oldSize>0)
          notifyItemRangeChanged(0,oldSize);
        notifyItemRangeInserted(oldSize,newSize);
      } else if ( newSize < oldSize) {
        if(newSize>0)
          notifyItemRangeChanged(0,newSize);
        notifyItemRangeRemoved(newSize,oldSize);
      } else {
        notifyItemRangeChanged(0,newSize);
      }
    }
  }

  public void prepareToLoad() {}
  public void populateUI() {

  }
  public void loadData() {

  }
}

