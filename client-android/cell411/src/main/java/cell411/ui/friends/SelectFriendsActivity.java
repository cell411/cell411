package cell411.ui.friends;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;

import androidx.annotation.CallSuper;
import androidx.appcompat.app.ActionBar;

import com.safearx.cell411.R;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;

import cell411.Cell411;
import cell411.base.BaseActivity;
import cell411.logic.FriendWatcher;
import cell411.logic.LiveQueryService;
import cell411.logic.RelationWatcher;
import cell411.parse.XPrivateCell;
import cell411.parse.XUser;
import cell411.parse.util.XItem;
import cell411.utils.Util;
import cell411.utils.XLog;

/**
 * Created by Sachin on 7/13/2015.
 */
public class SelectFriendsActivity extends BaseActivity {
  private static final String TAG = "SelectFriendsActivity";

  static {
    XLog.i(TAG, "loading Class");
  }

  private final ArrayList<XItem> mFriends = new ArrayList<>();
  private final HashSet<String> mMembers = new HashSet<>();
  private FriendListAdapter mFriendListAdapter;
  private XPrivateCell mPrivateCell;

  public SelectFriendsActivity() {
  }

  public static void start(Activity activity, XPrivateCell cell) {
    Intent intent = new Intent(activity, SelectFriendsActivity.class);
    intent.putExtra("objectId", cell.getObjectId());
    activity.startActivity(intent);
  }


  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    String objectId = getIntent().getStringExtra("objectId");

    mPrivateCell = (XPrivateCell) ds().getObject(objectId);
    if (mPrivateCell == null) {
      showToast("Cel not found");
      return;
    }
    setContentView(R.layout.activity_private_cell_friends);
    final ActionBar actionBar = getSupportActionBar();
    if (actionBar != null) {
      actionBar.setDisplayHomeAsUpEnabled(true);
      actionBar.setDisplayShowHomeEnabled(true);
    }
    ListView friendView = findViewById(R.id.list_friends);
    mFriendListAdapter = new FriendListAdapter(this);
    friendView.setAdapter(mFriendListAdapter);
    friendView.setOnItemClickListener(this::onItemClick);
  }


  public void onItemClick(AdapterView<?> adapterView, View view, int position, long l) {
    XItem item = mFriendListAdapter.getItem(position);
    item.setSelected(!item.isSelected());
    mFriendListAdapter.notifyDataSetChanged();
  }

  @Override
  public boolean onOptionsItemSelected(MenuItem item) {
    if (item.getItemId() == android.R.id.home) {
      finish();
      return true;
    }
    return super.onOptionsItemSelected(item);
  }

  public void loadData() {
    LiveQueryService service = Cell411.get().lqs();
    FriendWatcher friendWatcher = service.getFriendWatcher();
    mFriends.clear();
    mFriends.addAll(Util.transform(friendWatcher.getData(), XItem::new));

    RelationWatcher watcher = relWatcher();
    RelationWatcher.Rel rel = watcher.getRel(mPrivateCell, "members", "_User");
    HashSet<String> relatedIds = rel.getRelatedIds();
    mMembers.clear();
    mMembers.addAll(relatedIds);
  }

  @CallSuper
  @Override
  public void populateUI() {
    mFriendListAdapter.setData();
  }

  @Override
  protected void onPause() {
    super.onPause();
    HashSet<String> selectedIds = mFriendListAdapter.getSelectedIds();
    HashSet<String> newIds = new HashSet<>(selectedIds);
    newIds.removeAll(mMembers);
    HashSet<String> remIds = new HashSet<>(mMembers);
    remIds.removeAll(selectedIds);
    if (newIds.isEmpty() && remIds.isEmpty()) {
      return;
    }
    RelationWatcher watcher = lqs().getRelationWatcher();
    RelationWatcher.Rel rel = watcher.getRel(mPrivateCell, "members", "_User");
    rel.setRelatedIds(selectedIds);
  }

  @Override
  public void prepareToLoad() {

  }

  private class FriendListAdapter extends ArrayAdapter<XItem> {
    private final static int mResource = R.layout.cell_friends;
    private final LayoutInflater mInflater;

    public FriendListAdapter(Activity activity) {
      super(activity, mResource);
      mInflater = activity.getLayoutInflater();
    }

    public View getView(final int position, View cellView, ViewGroup parent) {
      ViewHolder holder;
      if (cellView == null) {
        cellView = mInflater.inflate(mResource, null);
        holder =
          new ViewHolder(cellView, R.drawable.bg_friend_selected, R.drawable.bg_friend_unselected);
      } else {
        holder = (ViewHolder) cellView.getTag();
        holder.imgUser.setImageBitmap(null);
      }
      holder.update(getItem(position));
      return cellView;
    }

    public void setData() {
      clear();
      for (XItem friend : mFriends) {
        String id = friend.getObjectId();
        friend.setSelected(mMembers.contains(id));
      }
      addAll(mFriends);
      mFriendListAdapter.sort(this::compare);
    }

    private int compare(final XItem lhs, final XItem rhs) {
      System.out.println("compare:  " + lhs.getText() + " to " + rhs.getText());
      if (lhs.isSelected() != rhs.isSelected()) {
        System.out.println("         selected: " + lhs.isSelected() + " " + rhs.isSelected());
        return lhs.isSelected() ? -1 : 1;
      } else if (!lhs.getText().equals(rhs.getText())) {
        int res = String.CASE_INSENSITIVE_ORDER.compare(lhs.getText(), rhs.getText());
        System.out.println("         name:" + lhs.getText());
        System.out.println("         name:" + rhs.getText());
        System.out.println("         name:" + res);
        return res;
      } else {
        int res = String.CASE_INSENSITIVE_ORDER.compare(lhs.getObjectId(), rhs.getObjectId());
        System.out.println("         objectId:" + res);
        return res;
      }
    }

    public HashSet<String> getSelectedIds() {
      HashSet<String> res = new HashSet<>();
      for (XItem item : mFriends) {
        if (item.isSelected()) {
          res.add(item.getObjectId());
        }
      }
      return res;
    }
  }

  private class ViewHolder {
    final private TextView txtUserName;
    final private ImageView imgUser;
    final private ImageView imgTick;
    final private int bg_selected;
    final private int bg_unselected;

    public ViewHolder(View cellView, int bg_friend_selected, int bg_friend_unselected) {
      txtUserName = cellView.findViewById(R.id.txt_name);
      imgUser = cellView.findViewById(R.id.img_user);
      imgTick = cellView.findViewById(R.id.img_tick);
      bg_selected = bg_friend_selected;
      bg_unselected = bg_friend_unselected;
      cellView.setTag(this);
    }

    public void update(XItem item) {
      ViewHolder holder = this;
      XUser user = item.getUser();
      holder.txtUserName.setText(user.getName());
      holder.imgTick.setVisibility(View.VISIBLE);
      holder.imgTick.setBackgroundResource(getBackground(item.isSelected()));
      Bitmap bitmap = user.getThumbNailPic(this::thumbNailLoaded);
      holder.imgUser.setImageBitmap(bitmap);
    }

    void thumbNailLoaded(Bitmap bitmap) {
      mFriendListAdapter.notifyDataSetChanged();
    }

    private int getBackground(boolean selected) {
      return selected ? bg_selected : bg_unselected;
    }
  }
}


