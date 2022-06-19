package cell411.ui.friends;

import static cell411.enums.RequestType.FriendRequest;
import static cell411.utils.ViewType.vtNull;
import static cell411.utils.ViewType.vtString;
import static cell411.utils.ViewType.vtUser;

import android.annotation.SuppressLint;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.SearchView;
import android.widget.TextView;

import androidx.annotation.CallSuper;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.parse.ParseQuery;
import com.safearx.cell411.R;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;

import cell411.Cell411;
import cell411.base.BaseApp;
import cell411.base.BaseFragment;
import cell411.logic.FriendWatcher;
import cell411.logic.LQListener;
import cell411.logic.LiveQueryService;
import cell411.logic.RequestWatcher;
import cell411.logic.Watcher;
import cell411.parse.XRequest;
import cell411.parse.XUser;
import cell411.parse.util.XItem;
import cell411.services.DataService;
import cell411.ui.self.ProfileImageActivity;
import cell411.ui.utils.CircularImageView;
import cell411.utils.Reflect;
import cell411.utils.Util;

/**
 * Created by Sachin on 18-04-2016.
 */
public class FriendSearchFragment extends BaseFragment {
  public static final String TAG = Reflect.getTag();
  private final UserListAdapter mAdapter = new UserListAdapter();
  private final HashSet<String> mRemoved = new HashSet<>();
  private final List<XItem> mAllItems = new ArrayList<>();
  private QueryRunner mRunner;
  private String mQuery = null;
  private TextView mCount;
  private RequestWatcher mRequestWatcher;
  private RequestListener mRequestListener;
  private FriendWatcher mFriendWatcher;
  private FriendListener mFriendListener;

  public FriendSearchFragment() {
    super(R.layout.fragment_search_friend);
  }

  @Override
  public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
    super.onViewCreated(view, savedInstanceState);
    SearchView mSearchView = view.findViewById(R.id.searchview_user);
    mCount = view.findViewById(R.id.count);
    RecyclerView mRecycler = view.findViewById(R.id.rv_users);

    mSearchView.setIconifiedByDefault(false);
    mSearchView.setOnQueryTextListener(new TextListener());
    mSearchView.setOnCloseListener(() -> false);
    mRecycler.setHasFixedSize(true);
    mRecycler.setAdapter(mAdapter);
    mRecycler.setLayoutManager(new LinearLayoutManager(getActivity()));
    LiveQueryService service = Cell411.get().lqs();
    mRequestWatcher = service.getRequestWatcher();
    mFriendWatcher = service.getFriendWatcher();
    mFriendListener = new FriendListener();
    mRequestListener = new RequestListener();
    onUI(()->{
      mSearchView.setQuery("r p",true);
    });
  }

  private String baseRegex(String str) {
    String[] letters = str.split("");
    for (int i = 0; i < letters.length; i++) {
      String letter = letters[i];
      if (letter.length() == 1 && Character.isAlphabetic(letter.charAt(0))) {
        letters[i] = "[" + letter.toLowerCase(Locale.US) + letter.toUpperCase(Locale.US) + "]";
      }
    }
    return "^" + Util.join("", letters);
  }

  ParseQuery<XUser> buildNameQuery() {
    ParseQuery<XUser> query1 = ParseQuery.getQuery("_User");
    ParseQuery<XUser> query2 = ParseQuery.getQuery("_User");
    if (mQuery.length() == 0) {
      return null;
    }
    String[] toks = mQuery.split("\\s+");
    if (toks.length > 0) {
      toks[0] = baseRegex(toks[0]);
    }
    if (toks.length > 1) {
      toks[1] = baseRegex(toks[1]);
    }
    if (toks.length > 2) {
      String msg = Util.format("Cannot build query from %d tokens", toks.length);
      Cell411.get().showAlertDialog(msg);
      return null;
    }
    if (toks.length == 2) {
      // With two tokens, one must match the first name, while
      // the other matches the last name.
      query1.whereMatches("lastName", toks[1]);
      query2.whereMatches("firstName", toks[1]);
    }
    // With one token, it can match either name.
    query1.whereMatches("firstName", toks[0]);
    query2.whereMatches("lastName", toks[0]);
    return ParseQuery.or(Arrays.asList(query1, query2));
  }

  public ParseQuery<XUser> buildQuery() {
    return buildNameQuery().orderByAscending("firstName")
      .addAscendingOrder("lastName")
      .addAscendingOrder("objectId");
  }

  public void onResume() {
    super.onResume();
    mFriendWatcher.addListener(mFriendListener);
    mRequestWatcher.addListener(mRequestListener);
  }

  public void onPause() {
    super.onPause();
    mRequestWatcher.removeListener(mRequestListener);
    mFriendWatcher.removeListener(mFriendListener);
  }

  public void prepareToLoad() {
    resetRemoved();
  }

  @CallSuper
  @Override
  public void populateUI() {

  }

  public void resetRemoved() {
    mRemoved.clear();
    removeUser(XUser.getCurrentUser());
    for (XUser user : mFriendWatcher.getData()) {
      removeUser(user);
    }
    for (XRequest request : mRequestWatcher.getData()) {
      if (request.getCell() != null)
        continue;
      removeUser(request.getOwner());
      removeUser(request.getSentTo());
    }
    mAdapter.setData(mAllItems);
    String text = mAdapter.getItemCount() + " items";
    mCount.setText(text);
  }

  private void removeUser(XUser currentUser) {
    if (currentUser != null)
      mRemoved.add(currentUser.getObjectId());
  }

  public void loadData() {
    Reflect.announce(true);
    if (Util.isNoE(mQuery)) {
      return;
    }
    // Since we are specifically interested in users to whom we are
    // not connected, we have to run the query ourselves.
    mRunner = new QueryRunner(mAdapter);

    onUI(mRunner);
  }

  public void onUserClick(View v) {
    UserViewHolder vh = (UserViewHolder) v.getTag();
    UserActivity.start(getActivity(), vh.mUser);
  }

  public void onFriendClick(View v) {
    UserViewHolder vh = (UserViewHolder) v.getTag();
    ds().handleRequest(FriendRequest, vh.mUser, this::onReqComplete);
  }

  private void onReqComplete(boolean b) {
    if (!b)
      Cell411.get().showAlertDialog("Friend Request Failed");
    // We should be able to avoid the reload ... when the request
    // appears in the LiveQuery, we will be instructed to remove
    // the counterParty.  We don't do that automatically, though
    // we could, so that we can see if that is working.
    //refresh();
  }

  public void onImageClick(View v) {
    UserViewHolder vh = (UserViewHolder) v.getTag();
    ProfileImageActivity.start(getActivity(), vh.mUser);
  }

  public static class UserViewHolder extends RecyclerView.ViewHolder {
    View mView;
    XUser mUser;
    CircularImageView mImageView;
    TextView mTextView;
    TextView mButton1;
    TextView mButton2;

    UserViewHolder(View view) {
      super(view);
      mView = view;
      mImageView = view.findViewById(R.id.img_user);
      mTextView = view.findViewById(R.id.txt_name);
      mButton1 = view.findViewById(R.id.txt_btn_action);
      mButton2 = view.findViewById(R.id.txt_btn_neg);
      mView.setTag(this);
      mImageView.setTag(this);
      mTextView.setTag(this);
      mButton1.setTag(this);
      mButton2.setTag(this);
      reset();
    }

    public void reset() {
      mUser = null;
      mView.setVisibility(View.VISIBLE);
      mView.setOnClickListener(null);
      mImageView.setVisibility(View.VISIBLE);
      mImageView.setOnClickListener(null);
      mTextView.setVisibility(View.VISIBLE);
      mTextView.setOnClickListener(null);
      mButton1.setVisibility(View.VISIBLE);
      mButton1.setOnClickListener(null);
      mButton2.setVisibility(View.GONE);
      mButton2.setOnClickListener(null);
    }
  }

  class RequestListener implements LQListener<XRequest> {
    @Override
    public void change(Watcher<XRequest> watcher) {
      resetRemoved();
    }
  }

  class FriendListener implements LQListener<XUser> {
    @Override
    public void change(Watcher<XUser> watcher) {
      resetRemoved();
    }
  }

  private class QueryRunner implements Runnable {
    final int mLimit = 100;
    private final ParseQuery<XUser> mQuery;
    @NonNull
    private final UserListAdapter mAdapter;
    private boolean mDone = false;

    QueryRunner(@NonNull UserListAdapter adapter) {
      Reflect.announce(true);

      mAdapter = adapter;
      mQuery = buildQuery();
      mQuery.setLimit(mLimit);
      mQuery.orderByAscending("firstName");
      mQuery.addAscendingOrder("lastName");
      mAllItems.clear();
    }

    @Override
    public void run() {
      Reflect.announce(true);
      if (mRunner != this) {
        return;
      }
      if (Cell411.isUIThread()) {
        if (mAllItems.isEmpty()) {
          mAdapter.setData(Collections.singletonList(
            new XItem("", "Loading Data...")));
        } else {
          mAdapter.setData(mAllItems);
        }
        if (!mDone)
          ds().onDS(this, 100);
      } else if (DataService.onDataServerThread()) {
        mQuery.setSkip(mAllItems.size());
        List<XUser> batch = mQuery.find();
        mDone = batch.size() < mLimit;
        mAllItems.addAll(Util.transform(batch, XItem::new));
        if (mDone) {
          mAllItems.add(new XItem());
          mAllItems.add(new XItem());
          mAllItems.add(new XItem());
          mAllItems.add(new XItem());
        }
        BaseApp.get().onUI(this, 10);
      } else {
        throw new Error("We should not be in this thread!");
      }
    }
  }

  public class UserListAdapter extends RecyclerView.Adapter<UserViewHolder> {
    final ArrayList<XItem> mItems = new ArrayList<>();


    @NonNull
    @Override
    public UserViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewTypeId) {
      LayoutInflater li = LayoutInflater.from(parent.getContext());
      View v = li.inflate(R.layout.cell_user, parent, false);
      return new UserViewHolder(v);
    }

    @Override
    public void onBindViewHolder(@NonNull UserViewHolder vh, int position) {
      XItem item = get(position);
      vh.reset();
      if (item.getViewType() == vtUser) {
        final XUser user = item.getUser();
        vh.mUser = user;
        vh.mView.setOnClickListener(FriendSearchFragment.this::onUserClick);
        vh.mTextView.setText(user.getName());
        vh.mTextView.setOnClickListener(FriendSearchFragment.this::onUserClick);
        vh.mImageView.setOnClickListener(FriendSearchFragment.this::onImageClick);
        vh.mButton1.setOnClickListener(FriendSearchFragment.this::onFriendClick);
        Bitmap pic = user.getThumbNailPic(bitmap1 -> {
          int index = mItems.indexOf(new XItem(user));
          notifyItemChanged(index);
        });
        vh.mImageView.setImageBitmap(pic);
      } else if (item.getViewType() == vtNull) {
        vh.mTextView.setVisibility(View.INVISIBLE);
        vh.mImageView.setVisibility(View.GONE);
        vh.mButton1.setVisibility(View.GONE);
      } else if (item.getViewType() == vtString) {
        vh.mTextView.setVisibility(View.VISIBLE);
        vh.mTextView.setText(item.getText());
        vh.mImageView.setVisibility(View.GONE);
        vh.mButton1.setVisibility(View.GONE);
      }
    }

    @Override
    public int getItemCount() {
      return mItems.size();
    }

    public XItem get(int position) {
      return mItems.get(position);
    }

    @SuppressLint("NotifyDataSetChanged")
    public void setData(List<XItem> items) {
      items = new ArrayList<>(items);
      items.removeIf(item -> mRemoved.contains(item.getObjectId()));
      int oldSize = mItems.size();
      mItems.clear();
      notifyItemRangeRemoved(0, oldSize);
      mItems.addAll(items);
      notifyItemRangeInserted(0, items.size());
    }
  }

  private class TextListener implements SearchView.OnQueryTextListener {
    @Override
    public boolean onQueryTextSubmit(String query) {
      if (Util.isNoE(query)) {
        mQuery = null;
        return true;
      } else {
        mQuery = query.trim();
      }
      refresh();
      return true;
    }

    @Override
    public boolean onQueryTextChange(String newText) {
      return false;
    }
  }
}
