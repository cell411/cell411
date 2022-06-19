package cell411.ui.chats;

import static cell411.ui.chats.ChatViewType.VIEW_TYPE_RECEIVED;
import static cell411.ui.chats.ChatViewType.VIEW_TYPE_RECEIVED_IMAGE;
import static cell411.ui.chats.ChatViewType.VIEW_TYPE_RECEIVED_LOCATION;
import static cell411.ui.chats.ChatViewType.VIEW_TYPE_SENT;
import static cell411.ui.chats.ChatViewType.VIEW_TYPE_SENT_IMAGE;
import static cell411.ui.chats.ChatViewType.VIEW_TYPE_SENT_LOCATION;

import android.graphics.Bitmap;
import android.graphics.Bitmap.CompressFormat;
import android.graphics.BitmapFactory;
import android.location.Location;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.activity.result.ActivityResultLauncher;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.parse.ParseQuery;
import com.parse.livequery.SubscriptionHandler.Event;
import com.parse.model.ParseFile;
import com.parse.model.ParseGeoPoint;
import com.safearx.cell411.R;

import java.io.File;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import cell411.Cell411;
import cell411.base.BaseApp;
import cell411.base.BaseFragment;
import cell411.logic.LiveQueryService;
import cell411.parse.XChatMsg;
import cell411.parse.XChatRoom;
import cell411.parse.XEntity;
import cell411.parse.XUser;
import cell411.services.DataService;
import cell411.services.LocationService;
import cell411.ui.utils.ip.ImagePickerContract;
import cell411.ui.utils.ip.PicPrefs;
import cell411.utils.ImageUtils;
import cell411.utils.LocationUtil;
import cell411.utils.Util;
import cell411.utils.XLog;


public class ChatFragment extends BaseFragment {
  public static final String TAG = "ChatActivity";
  private static final int PLAIN = R.id.rad_plain;
  private static final int LOCATION = R.id.rad_location;
  private static final int IMAGE = R.id.rad_image;
  final ArrayList<MessageSender> mQueue = new ArrayList<>();
  private final ChatListAdapter mMessages;
  private final List<XChatMsg> mList;
  private final ImagePickerContract mImagePickerContract;
  private final ActivityResultLauncher<PicPrefs> mImagePickerLauncher;
  private final XEntity mEntity;
  private LiveQueryService mLiveQueryService;
  private XChatRoom mChatRoom;
  private RelativeLayout mEmptyMarker;
  private RecyclerView mMsgView;
  private EditText mEditText;
  private Button mSendLocation;
  private Button mSendImage;
  private Button mSendPlain;
  private ParseQuery<XChatMsg> mQuery;
  private Location mLocation;

  {
    mImagePickerContract = new ImagePickerContract(this, this::callback);
  }

  {
    mImagePickerLauncher = registerForActivityResult(mImagePickerContract, this::callback);
    mMessages = new ChatListAdapter();
    mList = new ArrayList<>();
  }

  public ChatFragment(XEntity entity) {
    super(R.layout.fragment_chat);
    mEntity = entity;
  }

  private void callback(final Integer integer) {
    PicPrefs prefs = ImagePickerContract.claimPicPref(integer);
    synchronized (mQueue) {
      for (MessageSender sender : mQueue) {
        if (sender.checkComplete())
          continue;
        if (sender.mMsgType != IMAGE)
          continue;
        sender.mBitmap = prefs.mBitmap;
        assert sender.checkComplete();
        break;
      }
    }
    runQueue();
  }

  void runQueue() {
    synchronized (mQueue) {
      if (mQueue.isEmpty())
        return;
      if (!mQueue.get(0).checkComplete())
        return;
      ds().onDS(() -> {
        while (true) {
          if (mQueue.isEmpty())
            break;
          if (!mQueue.get(0).checkComplete())
            break;
          MessageSender sender = mQueue.remove(0);
          ds().onDS(sender);
        }
      });
    }
  }

  public void loadData() {
    super.loadData();
    if (mLiveQueryService == null) {
      mLiveQueryService = Cell411.get().lqs();
    }
    if (mLiveQueryService == null) {
      BaseApp.get().onUI(Cell411.get()::refresh, 500);
      return;
    }

    if (mEntity == null) {
      showAlertDialog("There is no chat room selected.  Please try again.");
      return;
    }

    mChatRoom = mEntity.getChatRoom();
    if (mChatRoom == null) {
      mChatRoom = new XChatRoom();
      mEntity.setChatRoom(mChatRoom);
      mEntity.save();
    }

    ParseQuery<XChatMsg> query = XChatMsg.q();
    query.whereEqualTo("chatRoom", mChatRoom);
    query.orderByAscending("createdAt");

    if (mQuery != null)
      mLiveQueryService.unsubscribe((mQuery));
    mQuery = query;
    mLiveQueryService.subscribe(mQuery, this::onLiveQueryEvents);

    mList.clear();

    mList.addAll(DataService.findFully(query));
  }

  private void onLiveQueryEvents(ParseQuery<XChatMsg> q, Event event, XChatMsg msg) {
    switch (event) {
      case ENTER:
      case CREATE:
        mList.add(msg);
        break;

      case LEAVE:
      case DELETE:
        mList.remove(msg);
        break;

      case UPDATE:
        for (int i = 0; i < mList.size(); i++) {
          if (mList.get(i).hasSameId(msg)) {
            mList.set(i, msg);
          }
        }
        break;
    }
    BaseApp.get().onUI(this::populateUI, 0);
  }

  @Override
  public void onResume() {
    super.onResume();
    LocationService.i().addObserver(this::locationChanged);
  }

  private void locationChanged(Location location, Location location1) {
    System.out.println("New location: " + location);
    mLocation = location;
  }

  @Override
  public void onPause() {
    super.onPause();
    LocationService.i().removeObserver(this::locationChanged);
  }

  @Override
  public void populateUI() {
    super.populateUI();
    mMessages.replaceData(mList);
    if (mList.size() == 0) {
      mEmptyMarker.setVisibility(View.VISIBLE);
      mMsgView.setVisibility(View.INVISIBLE);
    } else {
      mMsgView.setVisibility(View.VISIBLE);
      mEmptyMarker.setVisibility(View.GONE);
      mMsgView.scrollToPosition(mMessages.getItemCount() - 1);
    }
  }

  @Override
  public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
    super.onViewCreated(view, savedInstanceState);
    mEmptyMarker = view.findViewById(R.id.empty_disp);
    mMsgView = view.findViewById(R.id.msg_view);
    mEditText = view.findViewById(R.id.edit_text);
    mSendImage=view.findViewById(R.id.rad_image);
    mSendLocation=view.findViewById(R.id.rad_location);
    mSendPlain=view.findViewById(R.id.rad_plain);
    mSendImage.setOnClickListener(this::onSendClicked);
    mSendLocation.setOnClickListener(this::onSendClicked);
    mSendPlain.setOnClickListener(this::onSendClicked);
    mEmptyMarker.setVisibility(View.VISIBLE);
    mMsgView.setVisibility(View.INVISIBLE);
    mMsgView.setAdapter(mMessages);
    mMsgView.setLayoutManager(new LinearLayoutManager(Cell411.get()));
  }

  private void onSendClicked(View view) {
    int button = view.getId();
    String text = mEditText.getText().toString();
    ParseGeoPoint location = null;
    mEditText.setText("");

    if (button == R.id.rad_plain) {
      if (Util.isNoE(text)) {
        Cell411.get().showToast("Enter text, select image, or select loc");
        return;
      }
      enqueue(new MessageSender(R.id.rad_plain, location, text));
    } else if (button == R.id.rad_image) {
      mImagePickerLauncher.launch(new PicPrefs(
        makeBasename(),
        "image/*"
      ));
      enqueue(new MessageSender(button, location, null));
      if (!Util.isNoE(text)) {
        enqueue(new MessageSender(R.id.rad_plain, null, text));
      }
    } else if (button == R.id.rad_location) {
      location = LocationUtil.getGeoPoint(mLocation);
      enqueue(new MessageSender(button, location, null));
      if (!Util.isNoE(text)) {
        enqueue(new MessageSender(R.id.rad_plain, null, text));
      }
    } else {
      throw new RuntimeException("Unexpected radio button");
    }
    mEditText.setText("");
  }

  private void enqueue(MessageSender messageSender) {
    synchronized(mQueue) {
      mQueue.add(messageSender);
      runQueue();
    }
  }

  private String makeBasename() {
    return "ChatImage-" + Util.serdate();
  }

  private void handleBitmapMessage(ChatItem item) {
    XLog.i(TAG, "handleBitmapMessage");
    assert DataService.onDataServerThread();
    XChatMsg msg = item.mMsg;
    msg.fetchIfNeeded();
    ParseFile image = msg.getParseFile("image");
    if (image == null)
      return;
    item.mBitmap = getBitmap(image);
    BaseApp.get().onUI(mMessages::notifyDataSetChanged, 0);
  }

  private Bitmap getBitmap(ParseFile image) {
    byte[] bytes = image.getData();
    return ImageUtils.getBitmap(bytes);
  }

  static class ChatItem {
    final ChatViewType mViewType;
    final Date mDate;
    final XChatMsg mMsg;
    public Bitmap mBitmap;

    ChatItem(XChatMsg msg) {
      mDate = msg.getCreatedAt();
      mMsg = msg;
      boolean hasImage = msg.getImage() != null;
      boolean hasLocation = msg.getLocation() != null;
      boolean iSent = XUser.getCurrentUser().equals(msg.getOwner());
      switch ((iSent ? 0x100 : 0x000) + (hasImage ? 0x001 : 0x000) +
        (hasLocation ? 0x010 : 0x000)) {

        case 0x000:
          mViewType = VIEW_TYPE_RECEIVED;
          break;
        case 0x001:
          mViewType = VIEW_TYPE_RECEIVED_IMAGE;
          break;
        case 0x010:
        case 0x011:
          mViewType = VIEW_TYPE_RECEIVED_LOCATION;
          break;


        case 0x100:
          mViewType = VIEW_TYPE_SENT;
          break;
        case 0x101:
          mViewType = VIEW_TYPE_SENT_IMAGE;
          break;

        case 0x110:
        case 0x111:
          mViewType = VIEW_TYPE_SENT_LOCATION;
          break;

        default:
          throw new RuntimeException("Unexpected combo");
      }
    }
  }

  public static class ViewHolder extends RecyclerView.ViewHolder {
    // each data item is just a string in this case
    final TextView txtName;
    final TextView txtMsg;
    final TextView txtDate;
    final ImageView img;
    private final TextView txtTime;

    public ViewHolder(View view) {
      super(view);
      img = view.findViewById(R.id.image);
      txtDate = view.findViewById(R.id.txt_date);
      txtMsg = view.findViewById(R.id.text);
      txtName = view.findViewById(R.id.txt_name);
      txtTime = view.findViewById(R.id.txt_msg_time);
    }
  }


  public class ChatListAdapter extends RecyclerView.Adapter<ViewHolder> {
    public final ArrayList<ChatItem> mItems = new ArrayList<>();

    public ChatListAdapter() {
      mQuery = XChatMsg.q();
    }

    // Create new views (invoked by the layout manager)
    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int iViewType) {
      ChatViewType viewType = ChatViewType.valueOf(iViewType);
      switch (viewType) {
        case VIEW_TYPE_DATE:
        case VIEW_TYPE_RECEIVED:
        case VIEW_TYPE_SENT:
        case VIEW_TYPE_RECEIVED_IMAGE:
        case VIEW_TYPE_SENT_IMAGE:
        case VIEW_TYPE_RECEIVED_LOCATION:
        case VIEW_TYPE_SENT_LOCATION:
          break;
        default:
          throw new RuntimeException("Unexpected view type: " + viewType);
      }
      LayoutInflater inflater = LayoutInflater.from(parent.getContext());
      View view = inflater.inflate(viewType.getLayout(), parent, false);

      return new ViewHolder(view);
    }

    // Replace the contents of a view (invoked by the layout manager)
    @Override
    public void onBindViewHolder(@NonNull final ViewHolder vh, final int position) {
      final ChatItem item = mItems.get(position);
      if (item == null) {
        return;
      }
      final XChatMsg msg = item.mMsg;
      Bitmap bitmap = item.mBitmap;
      final XUser owner = (msg == null ? null : msg.getOwner());
      final String name = (owner == null ? null : owner.getName());
      final Date date = (msg == null ? item.mDate : msg.getCreatedAt());
      final String text = (msg == null ? null : msg.getText());
      final ParseFile imageFile = (msg == null ? null : msg.getImage());
      final boolean iSent = (XUser.getCurrentUser().hasSameId(owner));
      if (vh.txtName != null) {
        if (!iSent && name != null) {
          vh.txtName.setText(name);
          vh.txtName.setVisibility(View.VISIBLE);
        } else {
          vh.txtName.setVisibility(View.GONE);
        }
      }
      if (vh.txtDate != null) {
        if (date != null) {
          vh.txtDate.setText(Util.formatDate(date, true));
          vh.txtDate.setVisibility(View.VISIBLE);
        } else {
          vh.txtDate.setVisibility(View.GONE);
        }
      }
      if (vh.txtTime != null) {
        if (date != null) {
          vh.txtTime.setText(Util.formatTime(date));
          vh.txtTime.setVisibility(View.VISIBLE);
        } else {
          vh.txtTime.setVisibility(View.GONE);
        }
      }
      if (vh.txtMsg != null) {
        if (text != null) {
          vh.txtMsg.setText(text);
          vh.txtMsg.setVisibility(View.VISIBLE);
        } else {
          vh.txtMsg.setVisibility(View.GONE);
        }
      }
      if (vh.img != null) {
        if (bitmap != null) {
          vh.img.setImageBitmap(bitmap);
        } else if (imageFile != null) {
          if (imageFile.isDataAvailable()) {
            byte[] bytes = imageFile.getData();
            item.mBitmap = BitmapFactory.decodeByteArray(bytes, 0, bytes.length);
            vh.img.setImageBitmap(item.mBitmap);
          } else {

            ds().onDS(() -> ChatFragment.this.handleBitmapMessage(item));
          }
        } else if (vh.txtMsg != null) {
          vh.img.setVisibility(View.GONE);
          String oldText = "";
          if (vh.txtMsg.getVisibility() != View.GONE) {
            oldText = vh.txtMsg.getText().toString() + "\n\n";
          }
          oldText = oldText + "There should be an image attached to this message";
          vh.txtMsg.setVisibility(View.VISIBLE);
          vh.txtMsg.setText(oldText);
        }
      }

    }

    @Override
    public int getItemViewType(int position) {
      return mItems.get(position).mViewType.ordinal();
    }

    // Return the size of your data set (invoked by the layout manager)
    @Override
    public int getItemCount() {
      return mItems.size();
    }

    public void replaceData(List<XChatMsg> list) {
      mItems.clear();
      mItems.addAll(Util.transform(list, ChatItem::new));
      BaseApp.get().onUI(this::notifyDataSetChanged, 0);
    }

    public void add(XChatMsg xChatMsg) {
      mItems.add(new ChatItem(xChatMsg));
      BaseApp.get().onUI(this::notifyDataSetChanged, 0);
    }

    public void update(XChatMsg msg) {
      for (int i = 0; i < mItems.size(); i++) {
        if (!mItems.get(i).mMsg.hasSameId(msg))
          continue;
        mItems.remove(i);
        i--;
        BaseApp.get().onUI(this::notifyDataSetChanged, 0);
      }

    }
  }

  private class MessageSender implements Runnable {
    private final int mMsgType;
    private final ParseGeoPoint mLocation;
    private final String mText;
    private Bitmap mBitmap;

    public MessageSender(int checkedRadioButtonId, ParseGeoPoint location, String text) {
      mMsgType = checkedRadioButtonId;
      mLocation = location;
      mText = text;

    }

    boolean checkComplete() {
      boolean complete;
      switch (mMsgType) {
        case PLAIN:
          complete = true;
          break;
        case LOCATION:
          complete = mLocation != null;
          break;
        case IMAGE:
          complete = mBitmap != null;
          break;
        default:
          throw new RuntimeException("Unexpected code");
      }
      return complete;
    }

    @Override
    public void run() {
      Bitmap bitmap = null;
      if (mMsgType == R.id.rad_image) {
        if (mBitmap == null) {

          ds().onDS(this, 500);
          return;
        } else {
          bitmap = mBitmap;
          mBitmap = null;
        }
      }
      assert DataService.onDataServerThread();
      XChatMsg msg = new XChatMsg();
      msg.setOwner(XUser.getCurrentUser());
      msg.setChatRoom(mChatRoom);
      assert msg.getChatRoom() == mChatRoom;
      if (mMsgType == R.id.rad_location)
        msg.setLocation(mLocation);
      if (mMsgType == R.id.rad_image) {
        File baseName = new File("chat_image.png");
        File file = ImageUtils.saveImage(baseName, bitmap, CompressFormat.PNG);
        ParseFile parseFile = new ParseFile(file);
        parseFile.save();
        msg.setImage(parseFile);
      }
      msg.setText(mText);
      msg.save();
      ParseFile parseFile = msg.getImage();
      if (parseFile != null)
        parseFile.getDataInBackground();
      refresh();
    }
  }
}
