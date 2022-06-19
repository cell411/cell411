package cell411.ui.cells;

import static cell411.utils.ViewType.vtNull;

import android.content.Context;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.CompoundButton;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.RadioButton;
import android.widget.SeekBar;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.SearchView;

import com.parse.ParseQuery;
import com.parse.model.ParseGeoPoint;
import com.safearx.cell411.R;

import java.util.ArrayList;
import java.util.List;

import cell411.Cell411;
import cell411.base.BaseApp;
import cell411.base.BaseFragment;
import cell411.methods.CellDialogs;
import cell411.parse.XPublicCell;
import cell411.parse.XUser;
import cell411.parse.util.XItem;
import cell411.services.DataService;
import cell411.utils.LocationUtil;
import cell411.utils.Reflect;
import cell411.utils.Util;
import cell411.utils.ViewType;
import cell411.utils.XLog;

public class PublicCellSearchFragment extends BaseFragment {
  private final String TAG = "ExploreCellActivity";
  private SearchView mSearchView;
  private SeekBar sbRadius;
  private RadioButton rbNearBy;
  private ListView mCellView;
  private TextView mTextRadius;
  private CellListAdapter mCellListAdapter;
  private QueryRunner mRunner;
  private boolean mReadyToLoad = false;

  public PublicCellSearchFragment() {
    super(R.layout.explore_cells_fragment);
  }

  @Override
  public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
    super.onViewCreated(view, savedInstanceState);
    mCellListAdapter = new CellListAdapter(getContext(), R.layout.cell_public_cell);
    mCellView = view.findViewById(R.id.lvCells);
    mCellView.setAdapter(mCellListAdapter);
    mTextRadius = view.findViewById(R.id.txt_radius);
    mSearchView = view.findViewById(R.id.searchview);
    rbNearBy = view.findViewById(R.id.rb_nearby);
    sbRadius = view.findViewById(R.id.sb_radius);
    mSearchView.setIconifiedByDefault(false);
    mSearchView.setOnQueryTextListener(new SearchView.OnQueryTextListener() {
      @Override
      public boolean onQueryTextSubmit(String query) {
        mReadyToLoad = true;
        refresh();
        return true;
      }

      @Override
      public boolean onQueryTextChange(String query) {
        return true;
      }
    });
    sbRadius.setProgress(Cell411.get()
      .getAppPrefs()
      .getInt("SearchRadius", 100));
    sbRadius.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
      @Override
      public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
        mTextRadius.setText(LocationUtil.formatDistance(progress));
      }

      @Override
      public void onStartTrackingTouch(SeekBar seekBar) {
      }

      @Override
      public void onStopTrackingTouch(SeekBar seekBar) {
        mReadyToLoad = true;
        refresh();
      }
    });
    rbNearBy.setOnCheckedChangeListener(this::onCheckedChanged);
    mSearchView.setEnabled(true);
    sbRadius.setEnabled(true);
    rbNearBy.setEnabled(true);
    showSoftKeyboard();
  }

  @Override
  public void onPause() {
    super.onPause();
    mRunner = null;
    SharedPreferences.Editor ed = Cell411.get()
      .getAppPrefs()
      .edit();
    ed.putInt("SearchRadius", sbRadius.getProgress());
    ed.apply();
  }

  @Override
  public void onResume() {
    super.onResume();
    showSoftKeyboard();
    mSearchView.setEnabled(true);
    sbRadius.setEnabled(true);
    rbNearBy.setEnabled(true);
  }

  @Override
  public void prepareToLoad() {
    Reflect.announce(true);

    mRunner = new QueryRunner(constructQuery(), mCellListAdapter);
  }

  public void loadData() {
    Reflect.announce(true);

    if (!mReadyToLoad)
      return;
    mReadyToLoad = false;
    mRunner.run();
  }

  private ParseQuery<XPublicCell> constructQuery() {
    ParseQuery<XPublicCell> cellQuery = ParseQuery.getQuery("PublicCell");
    cellQuery.whereNotEqualTo("owner", XUser.getCurrentUser());
    if (rbNearBy != null && rbNearBy.isChecked()) {
      ParseGeoPoint currentLocation = loc().getParseGeoPoint();
      int searchRadius = sbRadius.getProgress();
      if (currentLocation != null)
        cellQuery.whereWithinMiles("location", currentLocation, searchRadius);
    }
    String searchRegex = constructRegex();
    if (searchRegex.length() > 0) {
      cellQuery.whereMatches("name", searchRegex, "i");
    }
    return cellQuery;
  }

  @NonNull
  private String constructRegex() {
    String query = mSearchView.getQuery()
      .toString();
    String[] queryStringArr = query.trim()
      .split(" ");
    StringBuilder searchRegex = new StringBuilder(queryStringArr[0]);
    for (int i = 1; i < queryStringArr.length; i++) {
      searchRegex.append("|")
        .append(queryStringArr[i]);
    }
    XLog.i(TAG, "searchRegex: " + searchRegex);
    return searchRegex.toString();
  }

  private void onJoinButtonClicked(View view) {
    int pos = mCellView.getPositionForView(view);
    XItem item = (XItem) mCellView.getAdapter()
      .getItem(pos);
    if (item.getViewType() != ViewType.vtPublicCell) {
      Cell411.get()
        .showAlertDialog("That button is not conencted to a cell");
      return;
    }
    CellDialogs.joinCell(item.getPublicCell(), success -> {
      if (success) {
        Cell411.get()
          .showAlertDialog("Request sent");
      } else {
        Cell411.get()
          .showAlertDialog("Failed to send request");
      }
    });
  }

  private void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
    refresh();
  }

  private void onCellClicked(View view) {
    int position = mCellView.getPositionForView(view);
    XItem item = mCellListAdapter.getItem(position);
    if (item.getViewType() != ViewType.vtPublicCell) {
      return;
    }
    PublicCellMembersActivity.start(activity(), item.getPublicCell());
  }

  private class QueryRunner implements Runnable {
    final int mLimit = 50;
    @NonNull
    private final ParseQuery<XPublicCell> mQuery;
    @NonNull
    private final CellListAdapter mAdapter;
    private List<XPublicCell> mBatch;

    QueryRunner(@NonNull ParseQuery<XPublicCell> query, @NonNull CellListAdapter adapter) {
      mQuery = query;
      mBatch = null;
      mAdapter = adapter;
      mAdapter.clear();
    }

    @Override
    public void run() {
      if (mRunner != this) {
        return;
      }
      if (Cell411.isUIThread()) {
        if (mBatch.size() == 0) {
          for (int i = 0; i < 4; i++) {
            mAdapter.add(new XItem());
          }
          return;
        }
        mAdapter.addAll(Util.transform(mBatch, XItem::new));
        String text = mAdapter.getCount() + " Cells";
        mTextRadius.setText(text);
        mQuery.setSkip(mAdapter.getCount());

        ds().onDS(this, 10);
      } else if (DataService.onDataServerThread()) {
        int count = mAdapter.getCount();
        count = Math.min(250 - count, mLimit);
        if (count < 0)
          return;
        mQuery.setLimit(count);
        mBatch = mQuery.find();
        BaseApp.get().onUI(this, 0);
      } else {
        throw new Error("We should not be in this thread!");
      }
    }
  }

  class CellListAdapter extends ArrayAdapter<XItem> {
    private final LayoutInflater mInflater;

    public CellListAdapter(Context context, int resource) {
      super(context, resource, new ArrayList<>());
      mInflater = getLayoutInflater();
    }

    @Override
    public boolean areAllItemsEnabled() {
      return false;
    }

    @Override
    public boolean isEnabled(int position) {
      return getItem(position).getViewType() != vtNull;
    }

    public View getView(final int position, View cellView, ViewGroup parent) {
      ViewHolder holder;
      if (cellView == null) {
        holder = new ViewHolder(mInflater, parent);
      } else {
        holder = (ViewHolder) cellView.getTag();
      }
      final XItem item = getItem(position);
      holder.mTxtCellName.setVisibility(View.VISIBLE);
      if (item.getViewType() == ViewType.vtPublicCell) {
        final XPublicCell publicCell = item.getPublicCell();
        holder.mTxtCellName.setText(publicCell.getName());
        holder.mImgVerified.setVisibility(publicCell.isVerified() ? View.VISIBLE : View.INVISIBLE);
        holder.mImgChat.setVisibility(View.GONE);
        holder.mBtnAction.setVisibility(View.VISIBLE);
      } else if (item.getViewType() == vtNull) {
        holder.mImgVerified.setVisibility(View.GONE);
        holder.mBtnAction.setVisibility(View.GONE);
        holder.mImgChat.setVisibility(View.GONE);
        holder.mTxtCellName.setVisibility(View.GONE);
      } else {
        holder.mImgVerified.setVisibility(View.GONE);
        holder.mBtnAction.setVisibility(View.GONE);
        holder.mImgChat.setVisibility(View.GONE);
        holder.mTxtCellName.setText(item.getText());
      }
      return holder.mCellView;
    }
  }

  private class ViewHolder {
    public ImageView mImgVerified;
    public TextView mTxtCellName;
    public ImageView mImgChat;
    public TextView mBtnAction;
    public View mCellView;

    public ViewHolder(LayoutInflater inflater, ViewGroup parent) {
      mCellView = inflater.inflate(R.layout.cell_public_cell, parent, false);
      mCellView.setTag(this);
      mImgVerified = mCellView.findViewById(R.id.img_verified);
      mTxtCellName = mCellView.findViewById(R.id.txt_cell_name);
      mImgChat = mCellView.findViewById(R.id.img_chat);
      mBtnAction = mCellView.findViewById(R.id.txt_btn_action);
      mBtnAction.setEnabled(true);
      mBtnAction.setText(R.string.join);
      mBtnAction.setOnClickListener(PublicCellSearchFragment.this::onJoinButtonClicked);
      mImgChat.setVisibility(View.GONE);
      mCellView.setOnClickListener(PublicCellSearchFragment.this::onCellClicked);
    }
  }
  public void populateUI() {

  }
}
