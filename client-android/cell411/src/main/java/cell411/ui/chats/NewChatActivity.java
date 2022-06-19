package cell411.ui.chats;

import static cell411.Cell411.TIME_TO_LIVE_FOR_CHAT_ON_ALERTS;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.ActionBar;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import cell411.base.BaseActivity;

import com.parse.ParseQuery;
import com.safearx.cell411.R;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Date;
import java.util.List;

import cell411.Cell411;
import cell411.base.BaseApp;
import cell411.parse.XAlert;
import cell411.parse.XBaseCell;
import cell411.parse.XEntity;
import cell411.parse.XPrivateCell;
import cell411.parse.XPublicCell;
import cell411.parse.XResponse;
import cell411.parse.XUser;

import cell411.parse.util.XItem;

import cell411.ui.utils.CircularImageView;
import cell411.utils.Util;
import cell411.utils.XLog;

/**
 * Created by Sachin on 27-03-2017.
 */
public class NewChatActivity extends BaseActivity {
  private static final String          TAG = "NewChatActivity";
  private              RecyclerView    recyclerView;
  private              CellListAdapter adapterCell;
  private              TextView        txtEmpty;

  @Override public boolean onOptionsItemSelected(MenuItem item)
  {
    if (item.getItemId() == android.R.id.home) {
      finish();
      return true;
    }
    return super.onOptionsItemSelected(item);
  }


  @Override protected void onCreate(Bundle savedInstanceState)
  {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_new_chat);
    ActionBar bar = getSupportActionBar();
    if (bar != null) {
      bar.setDisplayHomeAsUpEnabled(true);
    }
    recyclerView = findViewById(R.id.rv_new_chat);
    recyclerView.setHasFixedSize(true);
    LinearLayoutManager linearLayoutManager = new LinearLayoutManager(this);
    recyclerView.setLayoutManager(linearLayoutManager);
    txtEmpty = findViewById(R.id.txt_empty);
    adapterCell = new CellListAdapter();
    recyclerView.setAdapter(adapterCell);
    adapterCell.registerAdapterDataObserver(new AdapterListener());
  }

  public void loadData() {
    super.loadData();
    ArrayList<XItem> results = new ArrayList<>();
    Collection<XItem> batch;
    batch = queryAlerts();
    if (batch.size() != 0) {
      results.addAll(batch);
    }
    batch = queryCells(XPrivateCell.class);
    if (batch.size() != 0) {
      results.addAll(batch);
    }
    batch = queryCells(XPublicCell.class);
    if (batch.size() != 0) {
      results.addAll(batch);
    }
    BaseApp.get().onUI(() -> {
      adapterCell.arrayList.clear();
      adapterCell.arrayList.addAll(results);
      BaseApp.get().onUI(adapterCell::notifyDataSetChanged,0);
    },0);
  }

  private <Type extends XBaseCell> Collection<XItem> queryCells(Class<Type> typeClass)
  {
    XUser currentUser = XUser.getCurrentUser();
    ParseQuery<Type> ownedPrivateCells = ParseQuery.getQuery(typeClass);
    ownedPrivateCells.whereEqualTo("owner", currentUser);
    ParseQuery<Type> joinedPrivateCells = ParseQuery.getQuery(typeClass);
    joinedPrivateCells.whereEqualTo("members", currentUser);
    ParseQuery<Type> combined = ParseQuery.or(Arrays.asList(ownedPrivateCells, joinedPrivateCells));
    List<Type> cells = combined.find();
    return Util.transform(cells, XItem::new);
  }

  private List<XItem> queryAlerts() {
    XLog.i(TAG, "loading alerts");
    ParseQuery<XResponse> responseQuery1 = ParseQuery.getQuery(XResponse.class);
    XUser currentUser = XUser.getCurrentUser();
    responseQuery1.whereEqualTo("owner", currentUser);
    ParseQuery<XResponse> responseQuery2 = ParseQuery.getQuery(XResponse.class);
    responseQuery2.whereEqualTo("forwardedBy", currentUser);
    ParseQuery<XResponse> responseQuery = ParseQuery.or(Arrays.asList(responseQuery1, responseQuery2));
    ParseQuery<XAlert> alertQuery1 = ParseQuery.getQuery(XAlert.class);
    alertQuery1.whereMatchesKeyInQuery("objectId", "alert", responseQuery);
    ParseQuery<XAlert> alertQuery2 = ParseQuery.getQuery(XAlert.class);
    alertQuery2.whereEqualTo("owner", currentUser);
    ParseQuery<XAlert> alertQuery = ParseQuery.or(Arrays.asList(alertQuery1, alertQuery2));
    alertQuery.include("owner");
    alertQuery.include("forwardedBy");
    alertQuery.orderByDescending("createdAt");
    long alertTime = System.currentTimeMillis() - TIME_TO_LIVE_FOR_CHAT_ON_ALERTS;
    Date minDate = new Date(alertTime);
    alertQuery.whereGreaterThan("createdAt", minDate);
    List<XAlert> alerts = alertQuery.find();
    return Util.transform(alerts, XItem::new);
  }

  public class CellListAdapter extends RecyclerView.Adapter<CellListAdapter.ViewHolder> {
    public final  ArrayList<XItem>     arrayList        = new ArrayList<>();
    private final View.OnClickListener mOnClickListener = new View.OnClickListener() {
      @Override public void onClick(View v)
      {
        int position = recyclerView.getChildAdapterPosition(v);
        XItem item = arrayList.get(position);
        Cell411.get().openChat((XEntity) item.getParseObject());
        finish();
      }
    };

    @Override @NonNull public CellListAdapter.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType)
    {
      LayoutInflater inflater = LayoutInflater.from(parent.getContext());
      View v = inflater.inflate(R.layout.cell_public_cell, parent, false);
      v.setOnClickListener(mOnClickListener);
      return new ViewHolder(v, viewType);
    }

    @Override public void onBindViewHolder(final @NonNull ViewHolder viewHolder, final int position)
    {
      XItem item = arrayList.get(position);
      // - get element from your dataset at this position
      // - replace the contents of the view with that element
      viewHolder.imgChat.setVisibility(View.GONE);
      viewHolder.txtCellName.setText(item.getText());
    }

    @Override public int getItemViewType(int position)
    {
      return arrayList.get(position)
                      .getViewType()
                      .ordinal();
    }

    // Return the size of your data set (invoked by the layout manager)
    @Override public int getItemCount()
    {
      return arrayList.size();
    }

    // Provide a reference to the views for each data item
    // Complex data items may need more than one view per item, and
    // you provide access to all the views for a data item in a view holder
    public class ViewHolder extends RecyclerView.ViewHolder {
      // each data item is just a string in this case
      private final CircularImageView imgCell;
      private final TextView          txtCellName;
      private final ImageView         imgVerified;
      private final ImageView         imgChat;

      public ViewHolder(View view, int type)
      {
        super(view);
        imgCell = view.findViewById(R.id.img_cell);
        txtCellName = view.findViewById(R.id.txt_cell_name);
        imgChat = view.findViewById(R.id.img_chat);
        imgVerified = view.findViewById(R.id.img_verified);
      }
    }
  }

  class AdapterListener extends RecyclerView.AdapterDataObserver {
    @Override public void onChanged() {
      if (adapterCell.getItemCount() == 0) {
        txtEmpty.setVisibility(View.VISIBLE);
      } else {
        txtEmpty.setVisibility(View.GONE);
      }
    }

    @Override public void onItemRangeChanged(int positionStart, int itemCount) {
      onChanged();
    }

    @Override public void onItemRangeChanged(int positionStart, int itemCount, @Nullable Object payload) {
      onChanged();
    }

    @Override public void onItemRangeInserted(int positionStart, int itemCount) {
      onChanged();
    }

    @Override public void onItemRangeRemoved(int positionStart, int itemCount) {
      onChanged();
    }

    @Override public void onItemRangeMoved(int fromPosition, int toPosition, int itemCount) {
      onChanged();
    }
  }
}

