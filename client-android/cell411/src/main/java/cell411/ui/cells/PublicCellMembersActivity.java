package cell411.ui.cells;

import static cell411.utils.ViewType.vtString;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.app.Service;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.appcompat.app.ActionBar;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.google.android.material.floatingactionbutton.FloatingActionButton;
import com.parse.ParseQuery;
import com.safearx.cell411.R;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;

import cell411.Cell411;
import cell411.base.BaseActivity;
import cell411.enums.CellCategory;
import cell411.enums.CellStatus;
import cell411.enums.RequestType;
import cell411.logic.FriendWatcher;
import cell411.logic.LQListener;
import cell411.logic.LiveQueryService;
import cell411.logic.RelationWatcher;
import cell411.methods.AddFriendModules;
import cell411.methods.CellDialogs;
import cell411.parse.XPublicCell;
import cell411.parse.XUser;
import cell411.parse.util.XItem;
import cell411.services.DataService;
import cell411.ui.friends.UserActivity;
import cell411.ui.utils.CircularImageView;
import cell411.utils.Collect;
import cell411.utils.Util;
import cell411.utils.ViewType;
import cell411.utils.XLog;

/**
 * Created by Sachin on 7/13/2015.
 */
@SuppressLint("NotifyDataSetChanged")
public class PublicCellMembersActivity extends BaseActivity {
  private static final String TAG = "PublicCellMembersActivity";
  private final MemberListAdapter mMemberListAdapter = new MemberListAdapter();
  private final List<XUser> mFriendList = new ArrayList<>();
  private final List<XUser> mMemberList = new ArrayList<>();
  private final LQListener<XUser> mFriendListener = (watcher -> {
    Collect.replaceAll(mFriendList, watcher.getData());
    refresh();
  });
  private TextView mTxtStatus;
  private TextView mTxtTotalMembers;
  private MenuItem mJoinMenuItem;
  private FloatingActionButton mFabChat;
  private TextView mTxtCity;
  private TextView mTxtCellName;
  private TextView mTxtCellCategory;
  private TextView mTxtDescription;
  private boolean mShowJoin = false;
  private RecyclerView mRecyclerView;
  private FriendWatcher mFriendWatcher;
  private LiveQueryService mService;
  private String mObjectId;
  private XPublicCell mPublicCell;

  public static void start(BaseActivity activity, final XPublicCell cell) {
    Intent intent = new Intent(activity, PublicCellMembersActivity.class);
    if (!cell.isComplete())
      cell.fetchInBackground();
    intent.putExtra("objectId", cell.getObjectId());
    activity.startActivity(intent);
  }

  private static void showRequestVerificationDialog(BaseActivity activity, XPublicCell publicCell) {
    AlertDialog.Builder alert = new AlertDialog.Builder(activity);
    alert.setTitle(R.string.request_verification);
    LayoutInflater inflater = (LayoutInflater) activity.getSystemService(Service.LAYOUT_INFLATER_SERVICE);
    View view = inflater.inflate(R.layout.layout_request_verification, null);
    final TextView txtBtnRequestVerification = view.findViewById(R.id.txt_btn_request_verification);
    final int verificationStatus = publicCell.getVerificationStatus();
    XLog.i(TAG, "verificationStatus: " + verificationStatus);
    if (verificationStatus == 1) { // APPROVED
      txtBtnRequestVerification.setText(R.string.officially_verified);
      txtBtnRequestVerification.setBackgroundColor(Color.parseColor("#008000"));
      txtBtnRequestVerification.setEnabled(false);
    } else if (verificationStatus == -1) { // PENDING
      txtBtnRequestVerification.setText(R.string.verification_pending);
      txtBtnRequestVerification.setBackgroundColor(Color.GRAY);
      txtBtnRequestVerification.setEnabled(false);
    } else if (verificationStatus == -2) { // REJECTED
      txtBtnRequestVerification.setText(R.string.not_verified);
      txtBtnRequestVerification.setBackgroundColor(Color.RED);
      txtBtnRequestVerification.setEnabled(false);
    }
    alert.setView(view);
    alert.setPositiveButton(R.string.dialog_btn_done, (dialog, which) -> dialog.dismiss());
    final AlertDialog dialog = alert.create();
    txtBtnRequestVerification.setOnClickListener(v -> {
      if (publicCell.getVerificationStatus() != -1) {
        requestVerificationOfPublicCell(activity, publicCell, txtBtnRequestVerification);
        publicCell.setVerificationStatus(-1);
      }
    });
    dialog.show();
  }

  private static void requestVerificationOfPublicCell(final BaseActivity activity,
                                                      final XPublicCell mPublicCell,
                                                      final TextView txtBtnRequestVerification) {
    mPublicCell.setVerificationStatus(-1);
    mPublicCell.saveInBackground(e -> {
      if (e != null) {
        activity.handleException("updating verification status", e, null);
        return;
      }
      // Verification request sent successfully
      txtBtnRequestVerification.setText(R.string.verification_pending);
      txtBtnRequestVerification.setBackgroundColor(Color.GRAY);
      txtBtnRequestVerification.setEnabled(false);
    });
  }

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_public_cell_members);
    final ActionBar actionBar = getSupportActionBar();
    if (actionBar != null) {
      actionBar.setDisplayHomeAsUpEnabled(true);
      actionBar.setDisplayShowHomeEnabled(true);
    }
    mTxtCellName = findViewById(R.id.txt_cell_name);
    mTxtCellCategory = findViewById(R.id.txt_cell_category);
    mTxtDescription = findViewById(R.id.txt_description);
    mTxtCity = findViewById(R.id.txt_city);
    mTxtStatus = findViewById(R.id.txt_status);
    mTxtTotalMembers = findViewById(R.id.txt_total_members);
    mFabChat = findViewById(R.id.fab_request_ride);
    mObjectId = getIntent().getStringExtra("objectId");
    mPublicCell = ds().getPublicCell(mObjectId);
    if (mPublicCell == null) {
      showAlertDialog("Failed to load cell");
      finish();
    }
    mShowJoin = false;
    mFabChat.setOnClickListener(view -> {
      Cell411.get().openChat(mPublicCell);
    });
    mRecyclerView = findViewById(R.id.list_members);
    mRecyclerView.setLayoutManager(new LinearLayoutManager(this));
    mRecyclerView.setHasFixedSize(true);
    mRecyclerView.setAdapter(mMemberListAdapter);
  }

  @Override
  protected void onPause() {
    super.onPause();
    mFriendWatcher.removeListener(mFriendListener);
  }

  @Override
  protected void onResume() {
    super.onResume();
    if (mService == null)
      mService = lqs();
    if (mFriendWatcher == null)
      mFriendWatcher = mService.getFriendWatcher();
    mFriendWatcher.addListener(mFriendListener);
  }

  @Override
  public void prepareToLoad() {

  }

  public void loadData() {
    RelationWatcher watcher = relWatcher();
    RelationWatcher.Rel rel =
      watcher.getOrLoad(mPublicCell, "members", "_User");
    HashSet<String> memberIds = rel.getRelatedIds();

    ArrayList<XUser> memberList = new ArrayList<>();
    ArrayList<String> temp = new ArrayList<>();
    for (String id : memberIds) {
      XUser user = ds().getUser(id);
      if (user == null)
        temp.add(id);
      else
        memberList.add(user);
    }
    if (!temp.isEmpty()) {
      ParseQuery<XUser> users = XUser.q();
      users.whereContainedIn("objectId", temp);
      memberList.addAll(DataService.findFully(users));
    }
    Collect.replaceAll(mMemberList, memberList);
  }

  public void populateUI() {
    if (mPublicCell == null) {
      showAlertDialog("Unable to load public cell " + mObjectId);
      return;
    }
    CellStatus status = mPublicCell.getStatus();
    if (status == CellStatus.OWNER) {
      mTxtStatus.setText(R.string.you_are_the_owner_of_this_cell);
    } else if (status == CellStatus.JOINED) {
      mTxtStatus.setText(R.string.you_are_a_member_of_this_cell);
    } else if (status == CellStatus.PENDING) {
      mFabChat.hide();
      mTxtStatus.setText(R.string.request_sent_for_approval);
    } else if (status == CellStatus.NOT_JOINED) {
      mFabChat.hide();
      mTxtStatus.setText(R.string.you_are_not_a_member_of_this_cell);
      mShowJoin = true;
    } else {
      String text = "Unexpected status: " + status.toString();
      mTxtStatus.setText(text);
    }
    mFabChat.hide();
    setTitle(mPublicCell.getName());
    mTxtCellName.setText(mPublicCell.getName());
    CellCategory category = mPublicCell.getCategory();
    mTxtCellCategory.setText(category.toString());
    if (mPublicCell.getDescription() != null) {
      mTxtDescription.setText(mPublicCell.getDescription());
    }
    String text = "Waiting for city";
    mTxtCity.setText(text);
    if (mPublicCell.getLocation() != null) {
      ds()
        .requestCity(mPublicCell.getLocation(), address -> mTxtCity.setText(address.cityPlus()));
    }
    List<XUser> users = mMemberList;
    if (mMemberList == null || mMemberList.isEmpty()) {
      mTxtTotalMembers.setText(R.string.no_members);
      return;
    }
    users.sort(XUser::nameCompare);
    List<XItem> items = new ArrayList<>(Util.transform(users, XItem::new));
    items.add(new XItem("", "No More Users"));
    mMemberListAdapter.replaceItems(items);
    String member_count = Util.format(R.string.members, items.size() - 1);
    mTxtTotalMembers.setText(member_count);
  }

  @Override
  public boolean onCreateOptionsMenu(Menu menu) {
    if (mShowJoin) {
      MenuInflater inflater = getMenuInflater();
      inflater.inflate(R.menu.menu_public_cell_members, menu);
      mJoinMenuItem = menu.findItem(R.id.action_join);
      return true;
    } else {
      if (mPublicCell.getStatus() == CellStatus.OWNER) {
        MenuInflater inflater = getMenuInflater();
        inflater.inflate(R.menu.menu_request_verification, menu);
        return true;
      } else {
        return super.onCreateOptionsMenu(menu);
      }
    }
  }

  @Override
  public boolean onPrepareOptionsMenu(Menu menu) {
    if (!mShowJoin && mJoinMenuItem != null) {
      mJoinMenuItem.setVisible(false);
    } else if (mJoinMenuItem != null) {
      if (mPublicCell.getStatus() == CellStatus.JOINED) {
        mJoinMenuItem.setTitle(R.string.leave_this_cell);
      } else {
        mJoinMenuItem.setTitle(R.string.join_this_cell);
      }
    }
    return super.onPrepareOptionsMenu(menu);
  }

  private void showRemoveMemberDialog(XUser user) {
    AlertDialog.Builder alert = new AlertDialog.Builder(this);
    alert.setMessage(Cell411.getResString(R.string.dialog_msg_remove_member, user.getName()));
    alert.setNegativeButton(R.string.dialog_btn_no, (dialogInterface, i) -> {
    });
    alert.setPositiveButton(R.string.dialog_btn_yes, (dialogInterface, i) -> {
      RelationWatcher watcher = lqs().getRelationWatcher();
      watcher.removeCellMember(mPublicCell, user);
    });
    AlertDialog dialog = alert.create();
    dialog.show();
  }

  @Override
  public boolean onOptionsItemSelected(MenuItem item) {
    int itemId = item.getItemId();
    if (itemId == android.R.id.home) {
      finish();
      return true;
    } else if (itemId == R.id.action_join) {
      if (mShowJoin) {
        if (mPublicCell != null) {
          if (mPublicCell.getStatus() == CellStatus.JOINED) {
            mFabChat.hide();
            CellDialogs.showLeaveCellDialog(PublicCellMembersActivity.this, mPublicCell, null);
          } else {
            CellDialogs.joinCell(mPublicCell, null);
          }
        } else {
          Cell411.get().showToast(R.string.please_wait);
        }
      }
      return true;
    } else if (itemId == R.id.action_request_verification) {
      showRequestVerificationDialog(this, mPublicCell);
      return true;
    } else if (itemId == R.id.action_edit_cell) {
      PublicCellCreateOrEditActivity.start(PublicCellMembersActivity.this, mPublicCell);
      return true;
    }
    return super.onOptionsItemSelected(item);
  }

  private static class ViewHolder extends RecyclerView.ViewHolder {
    private TextView txtUserName;
    private CircularImageView imgUser;
    private TextView txtRemove;
    private TextView txtBtnAddFriend;

    public ViewHolder(@NonNull View itemView) {
      super(itemView);
    }
  }

  private class MemberListAdapter extends RecyclerView.Adapter<ViewHolder> {
    final ArrayList<XItem> mItems = new ArrayList<>();

    public MemberListAdapter() {
      super();
    }

    public void replaceItems(List<XItem> items) {
      mItems.clear();
      mItems.addAll(items);
      notifyDataSetChanged();
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int i) {
      ViewType viewType = ViewType.valueOf(i);
      View v;
      if (viewType == vtString) {
        v = LayoutInflater.from(parent.getContext())
          .inflate(R.layout.cell_public_cell_title, parent, false);
      } else if (viewType == ViewType.vtUser) {
        v = LayoutInflater.from(parent.getContext())
          .inflate(R.layout.cell_user, parent, false);
      } else {
        throw new RuntimeException("Bad ViewType: " + viewType);
      }
      return new ViewHolder(v);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder viewHolder, int position) {
      final XItem item = mItems.get(position);
      ViewType viewType = item.getViewType();
      XUser currentUser = XUser.getCurrentUser();

      if (viewType == ViewType.vtUser) {
        viewHolder.txtUserName = viewHolder.itemView.findViewById(R.id.txt_name);
        viewHolder.imgUser = viewHolder.itemView.findViewById(R.id.img_user);
        viewHolder.txtBtnAddFriend = viewHolder.itemView.findViewById(R.id.txt_btn_action);
        viewHolder.txtRemove = viewHolder.itemView.findViewById(R.id.txt_btn_neg);
        final XUser user = item.getUser();
        viewHolder.itemView.setOnClickListener(this::onUserClick);
        viewHolder.txtUserName.setText(user.getName());
        viewHolder.imgUser.setImageBitmap(user.getThumbNailPic((bmp) -> {
          notifyItemChanged(mItems.indexOf(item));
        }));
        final String userId = user.getObjectId();
        String currentUserId = currentUser.getObjectId();
        final String creatorUserId = mPublicCell.getOwner()
          .getObjectId();
        if (creatorUserId.equals(currentUserId) && !userId.equals(currentUserId)) {
          viewHolder.txtRemove.setVisibility(View.VISIBLE);
          viewHolder.txtRemove.setOnClickListener(v -> {
            XLog.i(TAG, "remove clicked");
            showRemoveMemberDialog(user);
          });
        } else {
          viewHolder.txtRemove.setVisibility(View.GONE);
          viewHolder.txtRemove.setOnClickListener(null);
        }
        viewHolder.txtBtnAddFriend.setVisibility(View.VISIBLE);
        viewHolder.txtBtnAddFriend.setOnClickListener(null);
        if (currentUser.getObjectId()
          .equals(userId)) {
          viewHolder.txtBtnAddFriend.setVisibility(View.GONE);
        } else if (mFriendList.contains(user)) {
          viewHolder.txtBtnAddFriend.setText(R.string.un_friend);
          viewHolder.txtBtnAddFriend.setEnabled(true);
          viewHolder.txtBtnAddFriend.setOnClickListener(view -> {
            XLog.i(TAG, "delete friend clicked");
            AddFriendModules.showDeleteFriendDialog(PublicCellMembersActivity.this, user, null);
          });
//        } else if (currentUser.isOnPendingList(userId)) {
//          viewHolder.txtBtnAddFriend.setEnabled(true);
//          viewHolder.txtBtnAddFriend.setText(R.string.resend);
//          viewHolder.txtBtnAddFriend.setOnClickListener(v -> {
//            DataService.i()
//                       .handleRequest(RequestType.FriendRequest, user, null);
//            viewHolder.txtBtnAddFriend.setText(R.string.resend);
//            viewHolder.txtBtnAddFriend.setBackgroundResource(R.drawable.bg_cell_join);
//          });
        } else {
          viewHolder.txtBtnAddFriend.setText(R.string.add_friend);
          viewHolder.txtBtnAddFriend.setEnabled(true);
          viewHolder.txtBtnAddFriend.setOnClickListener(v -> {

            ds()
              .handleRequest(RequestType.FriendRequest, user, null);
            viewHolder.txtBtnAddFriend.setText(R.string.resend);
            viewHolder.txtBtnAddFriend.setBackgroundResource(R.drawable.bg_cell_join);
          });
        }
      } else if (viewType == vtString) {
        String text = item.getText();
        XLog.i(TAG, "text: " + text);
      } else {
        throw new IllegalArgumentException("Unexpected ViewType: " + viewType);
      }
    }

    private void onUserClick(View view) {
      int pos = mRecyclerView.getChildAdapterPosition(view);
      XItem item = mItems.get(pos);
      if (item.getViewType() != ViewType.vtUser) {
        return;
      }
      XUser user = item.getUser();
      UserActivity.start(PublicCellMembersActivity.this, user);
    }

    @Override
    public int getItemViewType(int position) {
      return mItems.get(position)
        .getViewType()
        .ordinal();
    }

    @Override
    public int getItemCount() {
      return mItems.size();
    }

    @Override
    public void onDetachedFromRecyclerView(@NonNull RecyclerView recyclerView) {
      super.onDetachedFromRecyclerView(recyclerView);
    }
  }
}
