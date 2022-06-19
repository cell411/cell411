package cell411.ui.cells;

import static cell411.utils.ViewType.vtNull;

import android.annotation.SuppressLint;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.safearx.cell411.R;

import java.util.ArrayList;
import java.util.List;

import cell411.Cell411;
import cell411.base.BaseActivity;
import cell411.base.BaseApp;
import cell411.base.BaseFragment;
import cell411.logic.LQListener;
import cell411.logic.LiveQueryService;
import cell411.logic.Watcher;
import cell411.methods.CellDialogs;
import cell411.parse.XBaseCell;
import cell411.parse.XPublicCell;
import cell411.parse.util.XItem;
import cell411.utils.Collect;
import cell411.utils.Util;
import cell411.utils.ViewType;
import cell411.utils.XLog;

/**
 * Created by Sachin on 18-04-2016.
 */
public class PublicCellFragment extends BaseFragment {
  public static final String TAG = "PublicCellsFragment";
  final private CellListAdapter mAdapter = new CellListAdapter();
  private final LQListener<XPublicCell> mWatcherListener;
  private Watcher<XPublicCell> mPublicCellWatcher;

  {
    mWatcherListener = watcher -> mAdapter.setData(watcher.getData());
  }

  public PublicCellFragment() {
    super(R.layout.fragment_public_cells);
  }

  @Override
  public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
    RecyclerView recyclerView = view.findViewById(com.safearx.cell411.R.id.rv_public_cells);
    recyclerView.setHasFixedSize(false);
    recyclerView.setAdapter(mAdapter);
    recyclerView.setLayoutManager(new LinearLayoutManager(getActivity()));
    LiveQueryService mService = Cell411.get().lqs();
    mPublicCellWatcher = mService.getPublicCellWatcher();
    mAdapter.setData(null);
  }

  @Override
  public void onResume() {
    super.onResume();
    mPublicCellWatcher.addListener(mWatcherListener);
  }

  @Override
  public void onPause() {
    super.onPause();
    mPublicCellWatcher.removeListener(mWatcherListener);
  }

  public static class ViewHolder extends RecyclerView.ViewHolder {
    final View mView;
    final ViewType mViewType;
    final TextView txtCellName;
    final TextView txtBtnAction;
    final TextView txtTitle;
    final ImageView imgVerified;
    final ImageView imgChat;
    final TextView txtInfo;
    final ProgressBar pb;

    public ViewHolder(View view, ViewType viewType) {
      super(view);
      mView = view;
      mViewType = viewType;
      switch (viewType) {
        default:
          throw new Error("Unexpected view type: " + viewType);
        case vtString:
          txtInfo = view.findViewById(com.safearx.cell411.R.id.txt_info);
          pb = view.findViewById(com.safearx.cell411.R.id.pb_progress);
          txtTitle = view.findViewById(com.safearx.cell411.R.id.txt_title);
          txtCellName = null;
          txtBtnAction = null;
          imgChat = null;
          imgVerified = null;
          break;
        case vtPublicCell:
          txtTitle = null;
          txtCellName = view.findViewById(com.safearx.cell411.R.id.txt_cell_name);
          txtBtnAction = view.findViewById(com.safearx.cell411.R.id.txt_btn_action);
          imgChat = view.findViewById(com.safearx.cell411.R.id.img_chat);
          imgVerified = view.findViewById(com.safearx.cell411.R.id.img_verified);
          txtInfo = null;
          pb = null;
          break;
        case vtNull:
          txtTitle = null;
          txtInfo = view.findViewById(com.safearx.cell411.R.id.txt_info);
          pb = view.findViewById(com.safearx.cell411.R.id.pb_progress);
          txtCellName = null;
          txtBtnAction = null;
          imgChat = null;
          imgVerified = null;
          break;
      }
    }

    public ViewType getViewType() {
      return mViewType;
    }
  }

  public class CellListAdapter extends RecyclerView.Adapter<ViewHolder> {
    final List<XItem> mItems = new ArrayList<>();
    final List<XPublicCell> mOwned = new ArrayList<>();
    final List<XPublicCell> mJoined = new ArrayList<>();
    final XItem mOwnedTitle = new XItem("owned", "Owned Cells");
    final XItem mJoinedTitle = new XItem("joined", "Joined Cells");

    @Override
    @NonNull
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int intViewType) {
      ViewType viewType = ViewType.valueOf(intViewType);
      View v = null;
      if (viewType == ViewType.vtString) {
        v = LayoutInflater.from(parent.getContext())
          .inflate(com.safearx.cell411.R.layout.cell_public_cell_title, parent, false);
      } else if (viewType == ViewType.vtPublicCell) {
        v = LayoutInflater.from(parent.getContext())
          .inflate(com.safearx.cell411.R.layout.cell_public_cell, parent, false);
      } else if (viewType == vtNull) {
        v = LayoutInflater.from(parent.getContext())
          .inflate(com.safearx.cell411.R.layout.cell_footer, parent, false);
      }
      return new ViewHolder(v, viewType);
    }

    @Override
    public void onBindViewHolder(@NonNull final ViewHolder viewHolder, final int position) {
      final XItem item = getItem(position);
      ViewType viewType = item.getViewType();
      if (viewType != viewHolder.mViewType) {
        throw new Error("Mismatched viewtypes: " + viewHolder.mViewType + " and " + viewType);
      }
      switch (viewType) {
        case vtPublicCell: {
          final XPublicCell cell = item.getPublicCell();
          assert viewHolder.txtCellName != null;
          assert viewHolder.txtBtnAction != null;
          viewHolder.txtCellName.setText(cell.getName());
          viewHolder.txtBtnAction.setVisibility(View.VISIBLE);
          viewHolder.txtBtnAction.setBackgroundResource(com.safearx.cell411.R.drawable.bg_cell_leave);
          viewHolder.txtBtnAction.setTextColor(getColor(com.safearx.cell411.R.color.red));
          switch (cell.getStatus()) {
            case OWNER:
              viewHolder.txtBtnAction.setText(com.safearx.cell411.R.string.delete);
              viewHolder.txtBtnAction.setOnClickListener(
                view -> CellDialogs.showDeleteCellDialog(getActivity(), cell, success -> {
                  if (success) {
                    Cell411.get().showToast("Cell deleted.");
                  } else {
                    Cell411.get().showAlertDialog("Failed to delete cell");
                  }
                }));
              break;
            case JOINED:
              viewHolder.txtBtnAction.setText(com.safearx.cell411.R.string.leave);
              viewHolder.txtBtnAction.setOnClickListener(
                view -> CellDialogs.showLeaveCellDialog(getActivity(), cell, null));
              break;
            case NOT_JOINED:
              viewHolder.txtBtnAction.setText(com.safearx.cell411.R.string.join);
              viewHolder.txtBtnAction.setOnClickListener(view -> {
                getActivity();
                CellDialogs.joinCell(cell, success -> {
                  if (success) {
                    Cell411.get().showToast("A request has been sent to the owner of cell " + cell.getName());
                  } else {
                    Cell411.get().showAlertDialog("Cell join failed");
                  }
                });
              });
              break;
            default:
              throw new RuntimeException("Unexpected status: " + cell.getStatus());
          }
          assert viewHolder.imgVerified != null;
          assert viewHolder.imgChat != null;
          viewHolder.imgVerified.setVisibility((cell.getVerificationStatus() == 1) ? View.VISIBLE : View.INVISIBLE);
          viewHolder.imgChat.setVisibility(View.VISIBLE);
          viewHolder.imgChat.setOnClickListener(view -> {
            XLog.i(TAG, "starting chat activity");
            Cell411.get()
              .openChat(cell);
          });
          viewHolder.mView.setOnClickListener(v -> {
            XLog.i(TAG, "starting members activity");
            PublicCellMembersActivity.start(activity(), item.getPublicCell());
          });
          break;
        }
        case vtString:
          assert viewHolder.txtTitle != null;
          viewHolder.txtTitle.setText(item.getText());
          break;
        case vtNull:
          if (viewHolder.txtInfo != null) {
            viewHolder.txtInfo.setVisibility(View.INVISIBLE);
          }
          if (viewHolder.pb != null) {
            viewHolder.pb.setVisibility(View.GONE);
          }
          break;
        default:
          throw new RuntimeException();
      }
    }

    @Override
    public int getItemViewType(int position) {
      return getItemViewType(getItem(position)).ordinal();
    }

    @Override
    public int getItemCount() {
      return mItems.size();
    }

    public int getColor(int resId) {
      final BaseActivity activity = (BaseActivity) getActivity();
      assert activity != null;
      return activity.getColor(resId);
    }

    public XItem getItem(int position) {
      return mItems.get(position);
    }

    public ViewType getItemViewType(XItem item) {
      return item.getViewType();
    }

    @SuppressLint("NotifyDataSetChanged")
    public void setData(List<XPublicCell> items) {
      mItems.clear();
      mOwned.clear();
      mJoined.clear();
      if (items == null) {
        mItems.addAll(Collect.asList(new XItem("", "Loading Data ...")));
      } else {
        for (XPublicCell cell : items) {
          if (cell.ownedByCurrent()) {
            mOwned.add(cell);
          } else {
            mJoined.add(cell);
          }
        }
        mOwned.sort(XBaseCell::nameCompare);
        mJoined.sort(XBaseCell::nameCompare);
        mItems.add(mOwnedTitle);
        mItems.addAll(XItem.asList(mOwned));
        mItems.add(mJoinedTitle);
        mItems.addAll(XItem.asList(mJoined));
        for (int i = 0; i < 4; i++) {
          mItems.add(new XItem());
        }
        notifyDataSetChanged();
      }
      BaseApp.get().onUI(this::notifyDataSetChanged, 0);
    }
  }
  public void loadData() {

  }
  public void populateUI() {

  }
  public void prepareToLoad() {}

}