package cell411.ui.cells;

import static cell411.utils.ViewType.vtUser;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.appcompat.app.ActionBar;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.google.android.material.floatingactionbutton.FloatingActionButton;
import com.safearx.cell411.R;

import java.util.ArrayList;
import java.util.HashSet;

import cell411.base.BaseActivity;
import cell411.logic.RelationWatcher;
import cell411.parse.XPrivateCell;
import cell411.parse.XUser;
import cell411.parse.util.XItem;
import cell411.services.DataService;
import cell411.ui.friends.SelectFriendsActivity;
import cell411.ui.friends.UserActivity;
import cell411.ui.utils.CircularImageView;
import cell411.utils.ImageFactory;
import cell411.utils.XLog;

/**
 * Created by Sachin on 7/13/2015.
 */
public class PrivateCellMembersActivity extends BaseActivity {
  private static final String TAG = "PrivateCellMembersActivity";
  private final MemberAdapter memberAdapter = new MemberAdapter();
  private final HashSet<String> mMembers = new HashSet<>();
  private RecyclerView recyclerView;
  private RelativeLayout rlSticky;
  private XPrivateCell mPrivateCell;

  public static void start(Activity activity, XPrivateCell cell) {
    Intent intent = new Intent(activity, PrivateCellMembersActivity.class);
    intent.putExtra("objectId", cell.getObjectId());
    activity.startActivity(intent);
  }

  public static int compare(XUser lhs, XUser rhs) {
    int res = compare(lhs.getName(), rhs.getName());
    if (res == 0)
      res = compare(lhs.getObjectId(), rhs.getObjectId());
    return res;
  }

  private static int compare(String lhs, String rhs) {
    return String.CASE_INSENSITIVE_ORDER.compare(lhs, rhs);
  }

  public static int compare(XItem lhs, XItem rhs) {
    return compare(lhs.getUser(), rhs.getUser());
  }

  @Override
  public boolean onOptionsItemSelected(MenuItem item) {
    if (item.getItemId() == android.R.id.home) {
      finish();
      return true;
    }
    return super.onOptionsItemSelected(item);
  }

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_private_cell_members);
    final ActionBar actionBar = getSupportActionBar();
    if (actionBar != null) {
      actionBar.setDisplayHomeAsUpEnabled(true);
      actionBar.setDisplayShowHomeEnabled(true);
    }
    String objectId = getIntent().getStringExtra("objectId");

    mPrivateCell = (XPrivateCell) ds().getObject(objectId);
    setTitle(getIntent().getStringExtra("name"));
    rlSticky = findViewById(R.id.rl_sticky);
    recyclerView = findViewById(R.id.rv_nau_cells);
    recyclerView.setHasFixedSize(true);
    LinearLayoutManager linearLayoutManager = new LinearLayoutManager(this);
    recyclerView.setLayoutManager(linearLayoutManager);
    recyclerView.setAdapter(memberAdapter);
    FloatingActionButton fabAddFriend = findViewById(R.id.fab_add_friend);
    //fabAddFriend.setLabelText("Add Friends");
    fabAddFriend.setOnClickListener(v -> {
      XLog.i(TAG, "starting SelectFriendsActivity");
      SelectFriendsActivity.start(this, mPrivateCell);
    });
    rlSticky.setVisibility(View.GONE);
  }

  @Override
  protected void onResume() {
    super.onResume();
    refresh();
  }

  @Override
  public void prepareToLoad() {

  }

  @Override
  public void loadData() {
    RelationWatcher watcher = relWatcher();
    RelationWatcher.Rel rel = watcher.getRel(mPrivateCell, "members", "_User");
    mMembers.clear();
    mMembers.addAll(rel.getRelatedIds());
  }

  @Override
  public void populateUI() {
    memberAdapter.setData();
  }

  public class MemberAdapter extends RecyclerView.Adapter<ViewHolder> {
    private final int VIEW_TYPE_APP_USER = vtUser.ordinal();
    public ArrayList<XItem> mItems = new ArrayList<>();
    private final View.OnClickListener mOnClickListener = new View.OnClickListener() {
      @Override
      public void onClick(View v) {
        int position = recyclerView.getChildAdapterPosition(v);
        XItem item = mItems.get(position);
        if (item.getViewType() != vtUser)
          return;
        XUser user = item.getUser();
        UserActivity.start(PrivateCellMembersActivity.this, user);
      }
    };

    // Provide a suitable constructor (depends on the kind of data set)
    public MemberAdapter() {
    }

    // Create new views (invoked by the layout manager)
    @Override
    @NonNull
    public PrivateCellMembersActivity.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
      XLog.i(TAG, "onCreateViewHolder()");
      // create a new view
      View v = null;
      if (viewType == VIEW_TYPE_APP_USER) {
        v = LayoutInflater.from(parent.getContext())
          .inflate(R.layout.cell_friends_new, parent, false);
      }
      // set the view's size, margins, paddings and layout parameters
      PrivateCellMembersActivity.ViewHolder
        vh = new PrivateCellMembersActivity.ViewHolder(this, v, viewType);
      if (viewType == VIEW_TYPE_APP_USER) {
        v.setOnClickListener(mOnClickListener);
      }
      return vh;
    }

    // Replace the contents of a view (invoked by the layout manager)
    @Override
    public void onBindViewHolder(@NonNull final PrivateCellMembersActivity.ViewHolder viewHolder,
                                 final int position) {
      // - get element from your data set at this position
      // - replace the contents of the view with that element
      if (getItemViewType(position) == VIEW_TYPE_APP_USER) {
        final XItem item = mItems.get(position);
        final XUser user = item.getUser();
        XLog.i(TAG, "user=" + user);
        final String name = user.getName();
        viewHolder.txtName.setText(name);
        if (user.getInt("isDeleted") == 1) {
          viewHolder.txtName.setTextColor(getColor(R.color.text_disabled_hint_icon));
        } else {
          viewHolder.txtName.setTextColor(getColor(R.color.text_primary));
        }
        ImageFactory.ImageListener listener = (bmp) ->
          notifyItemChanged(find(mItems,(user)));
//        viewHolder.imgUser.setImageDrawable(user.getThumbNail());
        viewHolder.imgUser.setImageBitmap(user.getThumbNailPic(listener));
      }
    }

    @Override
    public int getItemViewType(int position) {
      super.getItemViewType(position);
      return VIEW_TYPE_APP_USER;
    }

    // Return the size of your data set (invoked by the layout manager)
    @Override
    public int getItemCount() {
      return mItems.size();
    }

    public void setData() {
      mItems.clear();
      for (String id : mMembers) {
        XUser user = DataService.get().getUser(id);
          XItem item = new XItem(user);
          mItems.add(item);
      }
      mItems.sort(PrivateCellMembersActivity::compare);
      notifyDataSetChanged();
      rlSticky.setVisibility(getItemCount() == 0 ? View.VISIBLE : View.GONE);
    }


  }

  private int find(ArrayList<XItem> items, XUser user) {
    for(int i=0;i<items.size();i++) {
      if(items.get(i).getObjectId().equals(user.getObjectId()))
        return i;
    }
    return -1;
  }

  // Provide a reference to the views for each data item
  // Complex data items may need more than one view per item, and
  // you provide access to all the views for a data item in a view holder
  public class ViewHolder extends RecyclerView.ViewHolder {
    private final MemberAdapter mMemberAdapter;
    // each data item is just a string in this case
    private CircularImageView imgUser;
    private TextView txtName;

    public ViewHolder(final MemberAdapter memberAdapter, View view,
                      int type) {
      super(view);
      mMemberAdapter = memberAdapter;
      if (type == mMemberAdapter.VIEW_TYPE_APP_USER) {
        imgUser = view.findViewById(R.id.img_user);
        txtName = view.findViewById(R.id.txt_name);
      }
    }
  }
}

