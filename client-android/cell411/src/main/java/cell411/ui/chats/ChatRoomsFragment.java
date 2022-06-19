package cell411.ui.chats;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RelativeLayout;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.FragmentActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import cell411.Cell411;
import cell411.enums.EntityType;
import cell411.base.BaseFragment;
import cell411.logic.ChatRoomWatcher;
import cell411.logic.LQListener;
import cell411.logic.LiveQueryService;
import cell411.logic.Watcher;
import cell411.parse.XChatRoom;
import cell411.parse.XEntity;

import cell411.utils.Util;
import cell411.utils.XLog;
import com.google.android.material.floatingactionbutton.FloatingActionButton;
import com.safearx.cell411.R;

import java.util.ArrayList;

/**
 * Created by Sachin on 06-02-2017.
 */
public class ChatRoomsFragment extends BaseFragment {
  private final static String TAG = "TabChatsFragment";

  static {
    XLog.i(TAG, "loading class");
  }

  private RelativeLayout      rlChatRoomEmpty;
  private RecyclerView        mRecyclerView;
  private final ChatRoomListAdapter mAdapter;
  private final ChatRoomWatcher mChatRoomWatcher;

  public ChatRoomsFragment() {
    super(R.layout.fragment_chat_rooms);
    mAdapter = new ChatRoomListAdapter();
    LiveQueryService service = Cell411.get().lqs();

    mChatRoomWatcher = service.getChatRoomWatcher();
  }

  @Override
  public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
    mRecyclerView   = view.findViewById(R.id.rv_chat_room);
    mRecyclerView.setHasFixedSize(true);
    FragmentActivity activity = getActivity();
    mRecyclerView.setLayoutManager(new LinearLayoutManager(activity));
    if (activity == null) {
      throw new NullPointerException("activity is null");
    }
    mRecyclerView.setAdapter(mAdapter);
    FloatingActionButton fabNewChat = view.findViewById(R.id.fab_new_chat);
    fabNewChat.setOnClickListener(this::onNewChatClick);
  }

  public void onNewChatClick(View view) {
    Intent intentNewChat = new Intent(getActivity(), NewChatActivity.class);
    startActivity(intentNewChat);
  }

  @Override
  public void onStop() {
    super.onStop();
  }

  @SuppressLint("NotifyDataSetChanged")
  public void loadData() {
    super.loadData();
//    assert DataService.isCurrentThread();
//
//    final ArrayList<XChatRoom> rooms       = new ArrayList<>();
//    XUser                      currentUser = XUser.getCurrentUser();
//    {
//      ParseQuery<XPublicCell> ownedCells = ParseQuery.getQuery(XPublicCell.class);
//      ownedCells.whereEqualTo("owner", currentUser);
//      ParseQuery<XPublicCell> joinedCells = ParseQuery.getQuery(XPublicCell.class);
//      joinedCells.whereEqualTo("members", currentUser);
//      ParseQuery<XPublicCell> publicCells = ParseQuery.or(Arrays.asList(ownedCells, joinedCells));
//      publicCells.whereExists("chatRoom");
//      publicCells.include("chatRoom");
//      publicCells.include("owner");
//
//      List<XPublicCell> cells = ds().findFully(publicCells);
//      for (XPublicCell cell : cells) {
//        XChatRoom room = cell.getChatRoom();
//        rooms.add(room);
//        room.getEntity();
//      }
//    }
//    {
//      ParseQuery<XPrivateCell> ownedCells = ParseQuery.getQuery(XPrivateCell.class);
//      ownedCells.whereEqualTo("owner", currentUser);
//      ParseQuery<XPrivateCell> joinedCells = ParseQuery.getQuery(XPrivateCell.class);
//      joinedCells.whereEqualTo("members", currentUser);
//      ParseQuery<XPrivateCell> publicCells = ParseQuery.or(Arrays.asList(ownedCells, joinedCells));
//      publicCells.whereExists("chatRoom");
//      publicCells.include("chatRoom");
//      publicCells.include("owner");
//
//      List<XPrivateCell> cells = ds().findFully(publicCells);
//      for (XPrivateCell cell : cells) {
//        XChatRoom room = cell.getChatRoom();
//        rooms.add(room);
//        room.getEntity();
//      }
//    }
//    {
//      ParseQuery<XResponse> responseQuery = XResponse.q();
//      responseQuery.whereEqualTo("owner", currentUser);
//      ParseQuery<XAlert> alertQuery1 = XAlert.q();
//      alertQuery1.whereMatchesKeyInQuery("objectId", "alert", responseQuery);
//      ParseQuery<XAlert> alertQuery2 = XAlert.q();
//      alertQuery2.whereEqualTo("owner", currentUser);
//      ParseQuery<XAlert> alertQuery = ParseQuery.or(Arrays.asList(alertQuery1, alertQuery2));
//      alertQuery.whereExists("chatRoom");
//      List<XAlert> alerts = alertQuery.find();
//      for (XAlert alert : alerts) {
//        XChatRoom room = alert.getChatRoom();
//        rooms.add(room);
//        room.getEntity();
//      }
//    }
//    BaseApplication.get().onUIThread(() -> {
//      chatRoomListAdapter.replaceData(rooms);
//      if (chatRoomListAdapter.getItemCount() > 0) {
//        if(rlChatRoomEmpty!=null)
//          rlChatRoomEmpty.setVisibility(View.GONE);
//        if(mRecyclerView!=null)
//          mRecyclerView.setVisibility(View.VISIBLE);
//      } else {
//        if(rlChatRoomEmpty!=null)
//          rlChatRoomEmpty.setVisibility(View.VISIBLE);
//        if(mRecyclerView!=null)
//          mRecyclerView.setVisibility(View.INVISIBLE);
//      }
//    });
  }

  public class ChatRoomListAdapter
    extends RecyclerView.Adapter<ChatRoomListAdapter.ChatRoomViewHolder>
    implements LQListener<XChatRoom>
  {
    private static final int                  VIEW_TYPE_PUBLIC_CELL  = 0;
    private static final int                  VIEW_TYPE_ALERT        = 1;
    private static final int                  VIEW_TYPE_PRIVATE_CELL = 2;
    public final         ArrayList<XChatRoom> mChatRooms             = new ArrayList<>();


    public ChatRoomListAdapter() {
    }

    public void onChatRoomClick(View v) {
      int       position = mRecyclerView.getChildAdapterPosition(v);
      XChatRoom room     = mChatRooms.get(position);
      Cell411.get().openChat(room.getEntity());
    }
    public boolean onChatRoomLongClick(View v) {
      int position = mRecyclerView.getChildAdapterPosition(v);
      // Delete this friend
      showDeleteChatRoomDialog(position);
      return false;
    }
    @Override
    @NonNull
    public ChatRoomViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
      View v =
        LayoutInflater.from(parent.getContext()).inflate(R.layout.cell_chat_room, parent, false);
      ChatRoomViewHolder vh = new ChatRoomViewHolder(v);
      v.setOnClickListener(this::onChatRoomClick);
      v.setOnLongClickListener(this::onChatRoomLongClick);
      return vh;
    }

    @Override
    public void onBindViewHolder(@NonNull ChatRoomViewHolder chatRoomViewHolder, int position) {
      final XChatRoom chatRoom = mChatRooms.get(position);
      chatRoomViewHolder.txtTime.setText(Util.formatTime(chatRoom.getLastMsgTime()));
      chatRoomViewHolder.txtChatRoomName.setText(chatRoom.getEntity().getEntityName());
    }

    @Override
    public int getItemViewType(int position) {
      super.getItemViewType(position);
      XChatRoom  xChatRoom = mChatRooms.get(position);
      XEntity    entity    = xChatRoom.getEntity();
      EntityType type      = entity.getType();
      if (type == EntityType.PUBLIC_CELL) {
        return VIEW_TYPE_PUBLIC_CELL;
      } else if (type == EntityType.PRIVATE_CELL) {
        return VIEW_TYPE_PRIVATE_CELL;
      } else if (type == EntityType.ALERT) {
        return VIEW_TYPE_ALERT;
      } else {
        throw new RuntimeException("Unexpected ItemViewType");
      }
    }

    // Return the size of your data set (invoked by the layout manager)
    @Override
    public int getItemCount() {
      return mChatRooms.size();
    }

    private void showDeleteChatRoomDialog(final int position) {
      assert Cell411.isUIThread();

      final FragmentActivity activity = getActivity();
      assert activity != null;
      AlertDialog.Builder alert = new AlertDialog.Builder(activity);
      alert.setMessage(R.string.dialog_msg_delete_chat);
      alert.setNegativeButton(R.string.dialog_btn_cancel, Util.nullClickListener());
      alert.setPositiveButton(R.string.dialog_btn_yes, (dialogInterface, i) -> {
        mAdapter.mChatRooms.remove(position);
        mAdapter.notifyItemRemoved(position);
        refreshViews();
      });
      AlertDialog dialog = alert.create();
      dialog.show();
    }

    private void refreshViews() {
      if (mChatRooms.size() > 0) {
        rlChatRoomEmpty.setVisibility(View.GONE);
      } else {
        rlChatRoomEmpty.setVisibility(View.VISIBLE);
      }
    }

    public void change(Watcher<XChatRoom> watcher) {
      mChatRooms.clear();
      mChatRooms.addAll(watcher.getData());
      Cell411.now(this::notifyDataSetChanged);
    }

    // Provide a reference to the views for each data item
    // Complex data items may need more than one view per item, and
    // you provide access to all the views for a data item in a view holder
    public class ChatRoomViewHolder extends RecyclerView.ViewHolder {
      // each data item is just a string in this case
      private final TextView txtChatRoomName;
      private final TextView txtTime;

      public ChatRoomViewHolder(View view) {
        super(view);
        txtChatRoomName = view.findViewById(R.id.txt_chat_room_name);
        txtTime         = view.findViewById(R.id.txt_time);
      }
    }
  }
}

