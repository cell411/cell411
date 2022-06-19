package cell411.ui.friends;

import static cell411.enums.RequestType.FriendApprove;
import static cell411.enums.RequestType.FriendCancel;
import static cell411.enums.RequestType.FriendReject;
import static cell411.enums.RequestType.FriendResend;

import android.graphics.Bitmap;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
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
import cell411.base.BaseFragment;
import cell411.enums.RequestType;
import cell411.logic.LQListener;
import cell411.logic.LiveQueryService;
import cell411.logic.RequestWatcher;
import cell411.logic.Watcher;
import cell411.parse.XRequest;
import cell411.parse.XUser;
import cell411.parse.util.XItem;
import cell411.ui.self.ProfileImageActivity;
import cell411.ui.utils.RVAdapter;
import cell411.utils.ViewType;
import cell411.utils.XLog;


/**
 * Created by Sachin on 18-04-2016.
 */
public class FriendRequestFragment extends BaseFragment {
  private static final String TAG = "FriendRequestFragment";

  static {
    XLog.i(TAG, "Loading Class");
  }

  private final RequestListAdapter mRequestListAdapter = new RequestListAdapter();
  private RequestWatcher mRequestWatcher;

  public FriendRequestFragment() {
    super(R.layout.fragment_friend_requests);
  }

  @Override
  public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
    super.onViewCreated(view, savedInstanceState);
    RecyclerView recyclerView = view.findViewById(R.id.rv_requests);
    final TextView txtNoRequests = view.findViewById(R.id.txt_no_requests);
    // use this setting to improve performance if you know that changes
    // in content do not change the layout size of the RecyclerView
    recyclerView.setHasFixedSize(true);
    // use a linear layout manager
    LinearLayoutManager linearLayoutManager = new LinearLayoutManager(getActivity());
    recyclerView.setLayoutManager(linearLayoutManager);
    mRequestListAdapter.mItems.add(new XItem("", "Loading Data ..."));
    recyclerView.setAdapter(mRequestListAdapter);
    txtNoRequests.setVisibility(View.VISIBLE);
    txtNoRequests.setVisibility(View.GONE);
    mRequestListAdapter.registerAdapterDataObserver(new RVAdapter() {
      @Override
      public void onChanged() {
        if (mRequestListAdapter.mItems.size() == 0) {
          txtNoRequests.setVisibility(View.VISIBLE);
        } else {
          txtNoRequests.setVisibility(View.GONE);
        }
      }
    });
  }

  @MainThread
  @CallSuper
  @Override
  public void onResume() {
    super.onResume();
    getRequestWatcher().addListener(mRequestListAdapter);
  }

  @MainThread
  @CallSuper
  @Override
  public void onPause() {
    super.onPause();
  }

  @Override
  public void loadData() {

  }

  @Override
  public void prepareToLoad() {

  }

  @Override
  public void populateUI() {
    mRequestListAdapter.change(getRequestWatcher());
  }

  void friendRequestAction(XRequest req, boolean ownedByMe, boolean positive) {
    final RequestType requestType;
    if (ownedByMe) {
      if (positive) {
        requestType = FriendResend;
      } else {
        requestType = FriendCancel;
      }
    } else {
      if (positive) {
        requestType = FriendApprove;
      } else {
        requestType = FriendReject;
      }
    }

    ds().handleRequest(requestType, req, null);
  }



  public RequestWatcher getRequestWatcher() {
    if(mRequestWatcher==null) {
      LiveQueryService service = lqs();
      if(service==null)
        return null;
      mRequestWatcher = service.getRequestWatcher();
    }
    return mRequestWatcher;
  }

  public static class RequestViewHolder extends RecyclerView.ViewHolder {
    public XUser otherUser;
    public ImageView imgUser;
    public boolean ownedByMe;
    public TextView txtUserName;
    public TextView txtBtnAccept;
    public TextView txtBtnReject;
    public TextView txtInfo;
    public View view;

    public RequestViewHolder(View v, ViewType viewType) {
      super(v);
      view = v;
      switch (viewType) {
        case vtRequest:
          imgUser = v.findViewById(R.id.img_user);
          txtUserName = v.findViewById(R.id.txt_name);
          txtBtnAccept = v.findViewById(R.id.btn_accept);
          txtBtnReject = v.findViewById(R.id.btn_reject);
          break;
        case vtString:
        case vtNull:
          txtInfo = v.findViewById(R.id.txt_title);
          break;
      }
    }
  }

  class RequestListAdapter extends RecyclerView.Adapter<RequestViewHolder>
    implements LQListener<XRequest> {
    public final List<XItem> mItems = new ArrayList<>();
    private final XItem mSentTitle = new XItem("", "Sent");
    private final XItem mReceivedTitle = new XItem("", "Received");
    private final List<XItem> miReq = new ArrayList<>();
    private final List<XItem> moReq = new ArrayList<>();


    public RequestListAdapter() {
      mItems.add(new XItem("", "Loading Data"));
    }

    public int compare(boolean b1, boolean b2) {
      return (b1 ? -1 : 0) + (b2 ? 1 : 0);
    }

    public int compare(XRequest r1, XRequest r2) {
      int comp1 = compare(r1.ownedByCurrent(), r2.ownedByCurrent());
      if (comp1 == 0) {
        if (r1.ownedByCurrent()) {
          comp1 = compare(r1.getSentTo(), r2.getSentTo());
        } else {
          comp1 = compare(r1.getOwner(), r2.getOwner());
        }
      }
      return comp1;
    }

    public int compare(int i1, int i2) {
      return i1 - i2;
    }

    public int compare(XItem o1, XItem o2) {
      ViewType vt1 = o1.getViewType();
      ViewType vt2 = o2.getViewType();
      if (vt1 != vt2) {
        return compare(vt1.ordinal(), vt2.ordinal());
      }
      switch (vt1) {
        case vtNull:
          return compare(o1.hashCode(), o2.hashCode());
        case vtRequest:
          return compare(o1.getRequest(), o2.getRequest());
        default:
        case vtString:
          return compare(o1.getText(), o2.getText());
      }
    }

    private int compare(XUser u1, XUser u2) {
      int res = compare(u1.getName(), u2.getName());
      if (res == 0)
        res = compare(u1.getObjectId(), u2.getObjectId());
      return res;
    }

    private int compare(String s1, String s2) {
      return String.CASE_INSENSITIVE_ORDER.compare(s1, s2);
    }

    @NonNull
    public RequestViewHolder onCreateViewHolder(@NonNull ViewGroup parent,
                                                                      int viewType) {
      View v;
      ViewType vt = ViewType.valueOf(viewType);
      switch (vt) {
        case vtRequest:
          v = LayoutInflater.from(parent.getContext())
            .inflate(R.layout.cell_friend_request, parent, false);
          break;
        case vtNull:
        case vtString:
          v = LayoutInflater.from(parent.getContext())
            .inflate(R.layout.cell_public_cell_title, parent, false);
          break;
        default:
          String msg = "Unexpected viewType: " + viewType;
          throw new RuntimeException(msg);
      }
      return new RequestViewHolder(v, vt);
    }

    @Override
    public int getItemCount() {
      return mItems.size();
    }

    public void onBindViewHolder(@NonNull RequestViewHolder vh, int position) {
      // - get element from your data set at this position
      // - replace the contents of the view with that element
      XItem item = mItems.get(position);
      final String objectId = item.getObjectId();
      switch (item.getViewType()) {
        case vtRequest:
          final XRequest req = item.getRequest();
          vh.ownedByMe = req.ownedByCurrent();
          if (vh.ownedByMe) {
            vh.otherUser = req.getSentTo();
          } else {
            vh.otherUser = req.getOwner();
          }
          if (vh.otherUser == null) {
            return;
          }
          Bitmap current = vh.otherUser.getThumbNailPic(bitmap -> {
            for (int i = 0; i < mItems.size(); i++) {
              XItem item1 = mItems.get(i);
              if (item1.getObjectId().equals(objectId))
                notifyItemChanged(i);
            }
          });
          if (current == null)
            current = XUser.getPlaceHolder();

          vh.imgUser.setImageBitmap(current);
          vh.imgUser.setOnClickListener(
            view -> ProfileImageActivity.start(getActivity(), vh.otherUser));

          vh.txtUserName.setText(vh.otherUser.getName());
          if (vh.ownedByMe) {
            vh.txtBtnAccept.setText(R.string.resend);
            vh.txtBtnReject.setText(R.string.cancel);
          } else {
            vh.txtBtnAccept.setText(R.string.accept);
            vh.txtBtnReject.setText(R.string.reject);
          }
          vh.txtBtnAccept.setOnClickListener(view -> friendRequestAction(req, vh.ownedByMe, true));
          vh.txtBtnReject.setOnClickListener(view -> friendRequestAction(req, vh.ownedByMe, false));

          vh.itemView.setOnClickListener(view -> UserActivity.start(getActivity(), vh.otherUser));

          break;
        case vtString:
          final String text = item.getText();
          vh.txtInfo.setText(text);
          break;
        case vtNull:
          vh.view.setVisibility(View.INVISIBLE);
          break;
      }
    }

    @Override
    public int getItemViewType(int position) {
      super.getItemViewType(position);
      return mItems.get(position).getViewType().ordinal();
    }

    @Override
    public void change(Watcher<XRequest> watcher) {
      mItems.clear();
      moReq.clear();
      miReq.clear();
      for (XRequest req : watcher.getData()) {
        if (req.getCell() != null)
          continue;
        if (req.ownedByCurrent()) {
          moReq.add(new XItem(req));
        } else {
          miReq.add(new XItem(req));
        }
      }
      buildList();
    }

    private void buildList() {
      miReq.sort(this::compare);
      moReq.sort(this::compare);
      mItems.clear();
      mItems.add(mReceivedTitle);
      mItems.addAll(miReq);
      mItems.add(mSentTitle);
      mItems.addAll(moReq);
      for (int i = 0; i < 4; i++) {
        mItems.add(new XItem());
      }
      if (Cell411.isUIThread()) {
        Cell411.now(this::notifyDataSetChanged);
      } else {
        Cell411.get().onUI(this::notifyDataSetChanged);
      }
    }
  }
}

