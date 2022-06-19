package cell411.ui.friends;

import static cell411.utils.ViewType.vtUser;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.CallSuper;
import androidx.annotation.MainThread;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.safearx.cell411.R;

import java.util.ArrayList;
import java.util.List;

import cell411.Cell411;
import cell411.base.BaseApp;
import cell411.base.BaseFragment;
import cell411.logic.LQListener;
import cell411.logic.LiveQueryService;
import cell411.logic.Watcher;
import cell411.methods.AddFriendModules;
import cell411.parse.XUser;
import cell411.parse.util.XItem;
import cell411.ui.self.ProfileImageActivity;
import cell411.ui.utils.CircularImageView;
import cell411.utils.Util;
import cell411.utils.ViewType;
import cell411.utils.XLog;

/**
 * Created by Sachin on 18-04-2016.
 */
@SuppressLint("NotifyDataSetChanged")
public class FriendFragment extends BaseFragment {
  public static final String TAG = "FriendsFragment";
  private final FriendListAdapter mAdapter = new FriendListAdapter();
  private RelativeLayout rlNoFriends;
  private RecyclerView mRecycler;
  View.OnLongClickListener mOnLongClickListener = this::onLongClickListener;
  private Watcher<XUser> mFriendWatcher;

  public FriendFragment() {
    super(R.layout.fragment_friends);
  }


  @Override
  public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
    super.onViewCreated(view, savedInstanceState);
    mRecycler = view.findViewById(R.id.rv_friends);
    mRecycler.setAdapter(mAdapter);
    // use this setting to improve performance if you know that changes
    // in content do not change the layout size of the RecyclerView
    mRecycler.setHasFixedSize(true);
    // use a linear layout manager
    mRecycler.setLayoutManager(new LinearLayoutManager(getActivity()));
    rlNoFriends = view.findViewById(R.id.rl_no_friends);
  }

  @MainThread
  @CallSuper
  @Override
  public void onResume() {
    super.onResume();
    LiveQueryService lqs = lqs();
    if (lqs == null)
      return;
    if (mFriendWatcher == null)
      mFriendWatcher = lqs.getFriendWatcher();
    if (mFriendWatcher != null)
      mFriendWatcher.addListener(mAdapter);
    mAdapter.change(lqs().getFriendWatcher());
  }

  @MainThread
  @CallSuper
  @Override
  public void onPause() {
    super.onPause();
    if(mFriendWatcher!=null)
      mFriendWatcher.removeListener(mAdapter);
  }

  @Override
  public void loadData() {

  }

  @Override
  public void prepareToLoad() {

  }

  @Override
  public void populateUI() {

  }

  private boolean onLongClickListener(View view) {
    showDeleteFriendDialog(mRecycler.getChildAdapterPosition(view));
    return true;
  }

  private boolean showDeleteFriendDialog(final int position) {
    final XItem item = mAdapter.getItem(position);
    if (item.getViewType() != vtUser) {
      return false;
    }
    final XUser user = item.getUser();
    AddFriendModules.showDeleteFriendDialog(getActivity(), user, success -> {
      if (success) {
        Cell411.get().showToast("Unfriended " + user.getName());
        mAdapter.mItems.remove(position);
        mAdapter.notifyDataSetChanged();
      } else {
        Cell411.get().showAlertDialog("Failed to unfriend " + user.getName());
      }
    });
    return true;
  }

  public class FriendListAdapter extends RecyclerView.Adapter<FriendListAdapter.ViewHolder>
    implements LQListener<XUser> {
    public final ArrayList<XItem> mItems = new ArrayList<>();
    private final View.OnClickListener mOnClickListener = this::onClick;

    // Provide a suitable constructor (depends on the kind of dataset)
    public FriendListAdapter() {
      mItems.add(new XItem("", "Loading Data"));
    }

    public void onClick(View v) {
      XItem item = mAdapter.getItem(mRecycler.getChildAdapterPosition(v));
      if (item.getViewType() != vtUser) {
        return;
      }
      UserActivity.start(getActivity(), item.getUser());
    }

    private XItem getItem(int position) {
      return mItems.get(position);
    }

    // Create new views (invoked by the layout manager)
    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
      LayoutInflater inf = LayoutInflater.from(parent.getContext());
      View v = inf.inflate(R.layout.cell_friend, parent, false);
      return new ViewHolder(v);
    }

    // Replace the contents of a view (invoked by the layout manager)
    @Override
    public void onBindViewHolder(final @NonNull ViewHolder viewHolder, final int position) {
      final XItem item = mItems.get(position);
      if (item.getViewType() == vtUser) {
        final XUser user = item.getUser();
        viewHolder.txtUserName.setText(user.getName());
        viewHolder.imgUser.setImageBitmap(null);
        viewHolder.itemView.setOnClickListener(null);
        viewHolder.itemView.setOnLongClickListener(null);
        viewHolder.itemView.setOnClickListener(mOnClickListener);
        viewHolder.itemView.setOnLongClickListener(mOnLongClickListener);
        Context context = getContext();
        assert context != null;
        viewHolder.txtUserName.setTextColor(
          getResources().getColor(R.color.text_primary, context.getTheme()));

        Bitmap bitmap = user.getThumbNailPic((bmp) -> {
          BaseApp.get().onUI(() -> {
            notifyItemChanged(mItems.indexOf(item));
          }, 0);
        });
        viewHolder.imgUser.setImageBitmap(bitmap);
        viewHolder.imgUser.setOnClickListener(view -> {
          XLog.i(TAG, "Starting profile image activity");
          ProfileImageActivity.start(getActivity(), user);
        });
      } else if (item.getViewType() == ViewType.vtString) {
        Context context = getContext();
        assert context != null;
        String string = item.getText();
        viewHolder.txtUserName.setText(string);
        viewHolder.imgUser.setImageBitmap(null);
        viewHolder.itemView.setOnClickListener(null);
        viewHolder.itemView.setOnLongClickListener(null);
        viewHolder.txtUserName.setTextColor(
          getResources().getColor(R.color.text_primary, context.getTheme()));
      }
    }

    // Return the size of your data set (invoked by the layout manager)
    @Override
    public int getItemCount() {
      return mItems.size();
    }

    int compare(XItem lhs, XItem rhs) {
      if (lhs.getViewType() != vtUser) {
        if (rhs.getViewType() != vtUser) {
          return String.CASE_INSENSITIVE_ORDER.compare(lhs.getText(), rhs.getText());
        } else {
          return 1;
        }
      } else if (rhs.getViewType() != vtUser) {
        return -1;
      } else {
        return lhs.getUser().nameCompare(rhs.getUser());
      }
    }

    public void change(Watcher<XUser> watcher) {
      mItems.clear();
      List<XUser> objects = watcher.getData();
      if (objects.size() == 0) {
        rlNoFriends.setVisibility(View.VISIBLE);
      } else {
        rlNoFriends.setVisibility(View.GONE);
        mItems.addAll(Util.transform(objects, XItem::new));
      }
      notifyDataSetChanged();
    }

    // Provide a reference to the views for each data item
    // Complex data items may need more than one view per item, and
    // you provide access to all the views for a data item in a view holder
    public class ViewHolder extends RecyclerView.ViewHolder {
      // each data item is just a string in this case
      private final TextView txtUserName;
      private final CircularImageView imgUser;

      public ViewHolder(View view) {
        super(view);
        txtUserName = view.findViewById(R.id.txt_name);
        imgUser = view.findViewById(R.id.img_user);
      }
    }
  }
}

