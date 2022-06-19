package cell411.ui.self;

import static cell411.utils.ViewType.vtUser;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.safearx.cell411.R;

import cell411.base.BaseActivity;
import cell411.logic.LQListener;
import cell411.logic.LiveQueryService;
import cell411.logic.RelationWatcher;
import cell411.logic.Watcher;
import cell411.parse.XUser;
import cell411.parse.util.OnCompletionListener;
import cell411.parse.util.XItem;
import cell411.parse.util.XItemList;
import cell411.utils.ImageFactory;
import cell411.utils.Reflect;
import cell411.utils.Util;
import cell411.utils.ViewType;
import cell411.utils.XLog;


/**
 * Created by Sachin on 7/13/2015.
 */
public class SpammedUsersActivity extends BaseActivity {
  private static final String TAG = Reflect.getTag();

  static {
    XLog.i(TAG, "loading class");
  }

  private RecyclerView mRecyclerView;
  private RelationWatcher mWatcher;
  LayoutInflater mInflater;
  private final SpammedUserAdapter mAdapter = new SpammedUserAdapter();

  public static void start(Activity activity) {
    Intent intent = new Intent(activity, SpammedUsersActivity.class);
    activity.startActivity(intent);
  }

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_spammed_users);
    setDisplayUpAsHome();
    mRecyclerView = findViewById(R.id.list_friends);
    LiveQueryService lqs = lqs();
    mWatcher = lqs.getRelationWatcher();
    XUser currentUser = XUser.getCurrentUser();
    mWatcher.getRel(currentUser, "spamUsers", "_User");
    mRecyclerView.setAdapter(mAdapter);
  }

  public void onResume() {
    super.onResume();
    XLog.i(TAG, "mRecyclerView: "+mRecyclerView);
  }

  @Override
  public boolean onOptionsItemSelected(MenuItem item) {
    if (item.getItemId() == android.R.id.home) {
      finish();
      return true;
    }
    return super.onOptionsItemSelected(item);
  }


//  private class SpamUsersListAdapter extends ArrayAdapter<XItem>
//    implements LQListener<XUser>
//  {
//    private final List<XItem> mItems = new ArrayList<>();
//
//    public SpamUsersListAdapter(Context context, int resource) {
//      super(context, resource);
//      mInflater = ((Activity) context).getLayoutInflater();
//    }
//
//    public int getCount() {
//      return mItems.size();
//    }
//
//    public View getView(final int position, View convertView1, ViewGroup parent) {
//      View cellView = convertView1;
//      ViewHolder viewHolder = null;
//      final XItem item = getItem(position);
//      if(item.getViewType()==vtUser) {
//        final XUser user = item.getUser();
//        if (cellView == null) {
//          viewHolder = new ViewHolder();
//          cellView = mInflater.inflate(R.layout.cell_spammed_user, parent, false);
//          viewHolder.txtDisplayName = cellView.findViewById(R.id.txt_display_name);
//          viewHolder.imgUser = cellView.findViewById(R.id.img_user);
//          viewHolder.txtUnSpam = cellView.findViewById(R.id.txt_un_spam);
//          cellView.setTag(viewHolder);
//        } else {
//          viewHolder = (ViewHolder) cellView.getTag();
//          viewHolder.imgUser.setImageResource(R.drawable.logo);
//        }
//        viewHolder.txtDisplayName.setText(user.getName());
//        viewHolder.imgUser.setImageBitmap(user.getThumbNailPic((bmp) -> {
//          notifyDataSetChanged();
//        }));
//        viewHolder.txtUnSpam.setOnClickListener(view -> unSpamUser(user));
//      }
//      return cellView;
//    }
//
//    private void unSpamUser(final XUser user) {
//      ds()
//        .flagUser(user, false, success -> {
//        });
//    }
//
//    @Override
//    public void done(final List<XUser> objects, final ParseException e) {
//      if(e!=null) {
//        handleException("loading data", e);
//        return;
//      }
//      mItems.addAll(XItem.transform(objects));
//    }
//
//    @Override
//    public void onEvents(final ParseQuery<XUser> query, final SubscriptionHandler.Event event,
//                         final XUser object) {
//
//    }
//  }
  private class ViewHolder extends RecyclerView.ViewHolder {
    private final TextView txtDisplayName;
    private final ImageView imgUser;
    private final TextView txtUnSpam;

    public ViewHolder(View view) {
      super(view);
      txtDisplayName = view.findViewById(R.id.txt_display_name);
      imgUser = view.findViewById(R.id.img_user);
      txtUnSpam = view.findViewById(R.id.txt_un_spam);
    }

    public void bind(final XItem item) {
      txtDisplayName.setText(item.getText());
      if(item.getViewType()==vtUser) {
        XUser user = item.getUser();
        imgUser.setImageBitmap(user.getAvatarPic(new ImageFactory.ImageListener() {
          @Override
          public void ready(final Bitmap bitmap) {
            mAdapter.notifyItemChanged(item);
          }
        }));
        txtUnSpam.setOnClickListener(this::unspam);
        txtUnSpam.setTag(item);
      }
    }
    public void unspam(View view) {
      if(txtUnSpam!=view)
        return;
      XItem item = (XItem)view.getTag();
      if(item.getViewType()!=vtUser)
        return;
      XUser user = item.getUser();
      ds().flagUser(user, false, new OnCompletionListener() {
        @Override
        public void done(final boolean success) {
          if(success) {
            showToast("Unflagged %s", user.getName());
          } else {
            showToast("Failed to unflag %s", user.getName());
          }
        }
      });
    }
  }
  private class SpammedUserAdapter
    extends RecyclerView.Adapter<ViewHolder>
    implements LQListener<XUser>
  {
    private final XItemList mItems = new XItemList();
    private final LayoutInflater mInflator = getLayoutInflater();

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull final ViewGroup parent,
                                                      final int viewTypeIdx)
    {
      ViewType viewType = ViewType.valueOf(viewTypeIdx);
      switch(viewType) {
        case vtString:
        case vtUser:
          return new ViewHolder(
            mInflater.inflate(R.layout.cell_spammed_user, parent, false)
          );
        default:
          throw new IllegalStateException("Unexpected value: " + viewType);
      }
    }

    @Override
    public void onBindViewHolder(@NonNull final ViewHolder holder, final int position) {
      holder.bind(mItems.get(position));
    }

    @Override
    public int getItemCount() {
      return mItems.size();
    }

    @Override
    public void change(final Watcher<XUser> watcher) {
      mItems.addAll(Util.transform(watcher.getData(), XItem::new));
    }

    public void notifyItemChanged(final XItem item) {
      int index = mItems.indexOf(item);
      if(index>=0 && index<mItems.size()) {
        notifyItemChanged(index);
      }
    }
  }
}

