package cell411.ui.alerts;

import static cell411.Cell411.TIME_TO_LIVE_FOR_CHAT_ON_ALERTS;
import static cell411.utils.ViewType.vtAlert;
import static cell411.utils.ViewType.vtString;

import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.safearx.cell411.R;

import java.util.ArrayList;

import cell411.Cell411;
import cell411.base.BaseActivity;
import cell411.base.BaseFragment;
import cell411.enums.ProblemType;
import cell411.logic.AlertWatcher;
import cell411.logic.LQListener;
import cell411.logic.LiveQueryService;
import cell411.logic.Watcher;
import cell411.methods.AddFriendModules;
import cell411.parse.XAlert;
import cell411.parse.util.XItem;
import cell411.ui.self.ProfileImageActivity;
import cell411.ui.utils.CircularImageView;
import cell411.utils.Util;
import cell411.utils.XLog;

/**
 * Created by Sachin on 18-04-2016.
 */
public class TabAlertFragment extends BaseFragment {
  private static final String TAG = TabAlertFragment.class.getSimpleName();

  static {
    XLog.i(TAG, "loading class");
  }

  private final AlertsListAdapter mAdapter = new AlertsListAdapter();
  private AlertWatcher mAlertWatcher = null;
  private RecyclerView mRecycler;

  public TabAlertFragment() {
    super(R.layout.fragment_tab_alerts);
    LiveQueryService liveQueryService = Cell411.get().lqs();
    if(liveQueryService!=null)
      setAlertWatcher(liveQueryService.getAlertWatcher());
  }

  @Override
  public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
    super.onViewCreated(view, savedInstanceState);
    mRecycler = view.findViewById(R.id.rv_alerts);
    // use this setting to improve performance if you know that changes
    // in content do not change the layout size of the RecyclerView
    mAdapter.mItems.add(new XItem("", "Loading Data"));
    mRecycler.setAdapter(mAdapter);
    mRecycler.setHasFixedSize(true);
    // use a linear layout manager
    LinearLayoutManager linearLayoutManager = new LinearLayoutManager(getActivity());
    mRecycler.setLayoutManager(linearLayoutManager);
  }

  @Override
  public void loadData() {
    super.loadData();
  }

  public void populateUI() {
    super.populateUI();
  }

  public void onPause() {
    super.onPause();
    getAlertWatcher().removeListener(mAdapter);
  }

  public void onResume() {
    super.onResume();
    getAlertWatcher().addListener(mAdapter);
  }

  public AlertWatcher getAlertWatcher() {
    return mAlertWatcher;
  }

  public void setAlertWatcher(AlertWatcher alertWatcher) {
    mAlertWatcher = alertWatcher;
  }

  public class AlertsListAdapter extends RecyclerView.Adapter<ViewHolder>
    implements LQListener<XAlert> {
    private final ArrayList<XItem> mItems = new ArrayList<>();

    public AlertsListAdapter() {
    }

    // Provide a suitable constructor (depends on the kind of dataset)

    public void onAlertClicked(View v) {
      XItem item = mAdapter.mItems.get(mRecycler.getChildAdapterPosition(v));
      if (item.getViewType() == vtAlert) {
        XAlert alert = item.getAlert();
        Intent intent = new Intent(Cell411.get().getCurrentActivity(),
          AlertDetailActivity.class);
        intent.putExtra("objectId", alert.getObjectId());
        startActivity(intent);
      }
    }

    public void setData(ArrayList<XItem> items) {
      int minCount = Math.min(mItems.size(),items.size());
      if ( mItems.size() > minCount ) {
        int maxCount=mItems.size();
        while(mItems.size()>minCount) {
          mItems.remove(minCount);
        }
        notifyItemRangeRemoved(minCount,maxCount);
      }
      if(minCount>0) {
        for(int i=0;i<minCount;i++) {
          mItems.set(i,items.get(i));
        }
        notifyItemRangeChanged(0,minCount);
      }
      if(items.size()>minCount) {
        for (int i = minCount; i < items.size(); i++) {
          mItems.add(items.get(i));
        }
        notifyItemRangeInserted(minCount, items.size());
      }
    }

    // Create new views (invoked by the layout manager)
    @NonNull
    @Override
    public TabAlertFragment.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent,
                                                          int viewType) {
      // create a new view
      View v;
      if (viewType == vtAlert.ordinal()) {
        v = LayoutInflater.from(parent.getContext()).inflate(R.layout.cell_alert, parent, false);
      } else if (viewType == vtString.ordinal()) {
        v = LayoutInflater.from(parent.getContext()).inflate(R.layout.cell_footer, parent, false);
      } else {
        throw new IllegalArgumentException("viewType should be ALERT or FOOTER");
      }
      // set the view's size, margins, padding(s) and layout parameters
      TabAlertFragment.ViewHolder vh = new TabAlertFragment.ViewHolder(v, viewType);
      v.setOnClickListener(this::onAlertClicked);
      return vh;
    }

    // Replace the contents of a view (invoked by the layout manager)
    @Override
    public void onBindViewHolder(@NonNull final TabAlertFragment.ViewHolder viewHolder,
                                 final int position) {
      XItem item = mItems.get(position);
      // - get element from your data set at this position
      // - replace the contents of the view with that element
      if (getItemViewType(position) == vtAlert.ordinal()) {
        final XAlert alert = item.getAlert();
        if (alert.getOwner() == null)
          return;
        String description;
        String issuer;
        if (alert.isSelfAlert()) {
          issuer = "You";
        } else {
          issuer = alert.getOwner().getName();

        }
        ProblemType problemType = alert.getProblemType();
        description = issuer + " issued a " + problemType + " alert";

        viewHolder.txtAlert.setText(description);
        viewHolder.txtAlertTime.setText(Util.formatDateTime(alert.getCreatedAt()));
        final BaseActivity activity = (BaseActivity) getActivity();
        viewHolder.imgUser.setImageBitmap(alert.getOwner().getThumbNailPic((bmp) -> {
          XLog.i(TAG, "Loaded Bitmap: " + bmp);
          notifyItemChanged(mItems.indexOf(item));
        }));
        viewHolder.imgUser.setOnClickListener(
          view -> ProfileImageActivity.start(activity, alert.getOwner()));
        ProblemTypeInfo problemTypeInfo = ProblemTypeInfo.valueOf(alert.getProblemType().ordinal());
        viewHolder.imgAlertType.setImageResource(problemTypeInfo.getImageRes());
        viewHolder.imgAlertType.setBackgroundResource(problemTypeInfo.getBGDrawable());
        if (alert.isSelfAlert()) {
          viewHolder.llBtnFlag.setVisibility(View.GONE);
        } else {
          viewHolder.llBtnFlag.setVisibility(View.VISIBLE);
          viewHolder.llBtnFlag.setBackgroundResource(R.drawable.bg_user_flag);
        }
        viewHolder.llBtnFlag.setOnClickListener(view -> showFlagAlertDialog(alert));
        if (System.currentTimeMillis() >=
          alert.getCreatedAt().getTime() + TIME_TO_LIVE_FOR_CHAT_ON_ALERTS) {
          viewHolder.imgChat.setVisibility(View.GONE);
        } else {
          viewHolder.imgChat.setVisibility(View.VISIBLE);
          viewHolder.imgChat.setOnClickListener(view -> Cell411.get().openChat(alert));
        }
      } else {
        viewHolder.txtInfo.setText(item.getText());
      }
    }

    @Override
    public int getItemViewType(int position) {
      super.getItemViewType(position);
      return mItems.get(position).getViewType().ordinal();
    }

    // Return the size of your dataset (invoked by the layout manager)
    @Override
    public int getItemCount() {
      return mItems.size();
    }

    void showFlagAlertDialog(final XAlert cell411Alert) {
      AddFriendModules.showFlagAlertDialog(getActivity(), cell411Alert.getOwner(), null);
    }

    @Override
    public void change(final Watcher<XAlert> watcher) {
      setData(Util.transform(watcher.getData(), XItem::new));
    }
  }

  // Provide a reference to the views for each data item
  // Complex data items may need more than one view per item, and
  // you provide access to all the views for a data item in a view holder
  public class ViewHolder extends RecyclerView.ViewHolder {
    // each data item is just a string in this case
    private TextView txtAlert;
    private TextView txtAlertTime;
    private LinearLayout llBtnFlag;
    private CircularImageView imgUser;
    private ImageView imgChat;
    private ImageView imgAlertType;
    private TextView txtInfo;

    public ViewHolder(View view, int type) {
      super(view);
      if (type == vtAlert.ordinal()) {
        txtAlert = view.findViewById(R.id.txt_alert);
        txtAlertTime = view.findViewById(R.id.txt_alert_time);
        llBtnFlag = view.findViewById(R.id.rl_btn_flag);
        imgUser = view.findViewById(R.id.img_user);
        imgChat = view.findViewById(R.id.img_chat);
        imgAlertType = view.findViewById(R.id.img_alert_type);
      } else if (type == vtString.ordinal()) {
        txtInfo = view.findViewById(R.id.txt_info);
      }
    }
  }
}

