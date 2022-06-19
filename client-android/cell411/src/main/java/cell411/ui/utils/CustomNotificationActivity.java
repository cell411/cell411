package cell411.ui.utils;

import static cell411.utils.ViewType.vtAlert;
import static cell411.utils.ViewType.vtString;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import cell411.base.BaseActivity;

import com.safearx.cell411.R;

import java.util.ArrayList;

import cell411.parse.XAlert;
import cell411.parse.util.XItem;

import cell411.utils.ViewType;
import cell411.utils.XLog;

/**
 * Created by Sachin on 17-04-2017.
 */
public class CustomNotificationActivity extends BaseActivity {
  public static final String TAG = "CustomNotificationActivity";

  static {
    XLog.i(TAG, "Loading Class");
  }

  boolean mMoreItems = true;
  private RecyclerView                  recyclerView;
  private CustomNotificationListAdapter customNotificationListAdapter;

  public static void start(Activity activity) {
    Intent intentCustomNotification = new Intent(activity, CustomNotificationActivity.class);
    activity.startActivity(intentCustomNotification);
  }

  @Override public boolean onOptionsItemSelected(MenuItem item)
  {
    if (item.getItemId() == android.R.id.home) {
      finish();
      return true;
    }
    return super.onOptionsItemSelected(item);
  }

  @Override protected void onCreate(Bundle savedInstanceState)
  {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_custom_notifications);
    setDisplayUpAsHome();
    recyclerView = findViewById(R.id.rv_notifications);
    recyclerView.setHasFixedSize(true);
    LinearLayoutManager linearLayoutManager = new LinearLayoutManager(this);
    recyclerView.setLayoutManager(linearLayoutManager);
    //FIXME
//    final Task<Collection<XAlert>> task = DataService.i().execute(() -> {
//      ParseQuery<XAlert> parseQuery4CustomAlerts = ParseQuery.getQuery(XAlert.class);
//      parseQuery4CustomAlerts.whereEqualTo("problemType", "Custom");
//      parseQuery4CustomAlerts.orderByDescending("createdAt");
//      parseQuery4CustomAlerts.setLimit(25);
//      return parseQuery4CustomAlerts.find();
//    });
//    task.onSuccess((Continuation<Collection<XAlert>, Void>) task1 -> {
//      Collection<XAlert> input = task1.getResult();
//      ArrayList<XItem> output = new ArrayList<>();
//      for (ParseObject cell411Obj : input) {
//        output.add(new XItem(vtAlert, cell411Obj));
//      }
//      Cell411.later(() -> {
//        customNotificationListAdapter = new CustomNotificationListAdapter(output);
//        recyclerView.setAdapter(customNotificationListAdapter);
//      });
//      return null;
//    });
  }

  public class CustomNotificationListAdapter extends RecyclerView.Adapter<CustomNotificationListAdapter.ViewHolder> {
    public ArrayList<XItem> arrayList;

    public CustomNotificationListAdapter(ArrayList<XItem> arrayList)
    {
      this.arrayList = arrayList;
    }

    @NonNull @Override
    public CustomNotificationListAdapter.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewTypeId)
    {
      ViewType viewType = ViewType.valueOf(viewTypeId);
      View v;
      if (viewType == vtAlert) {
        v = LayoutInflater.from(parent.getContext())
                          .inflate(R.layout.cell_custom_notification, parent, false);
      } else if (viewType == vtString) {
        v = LayoutInflater.from(parent.getContext())
                          .inflate(R.layout.cell_footer, parent, false);
      } else {
        throw new IllegalArgumentException("Expected NOTIFICATION or FOOTER!");
      }
      return new ViewHolder(v, viewType);
    }

    @Override public void onBindViewHolder(@NonNull final ViewHolder viewHolder, final int position)
    {
      final XItem item = arrayList.get(position);
      if (item.getViewType() == vtAlert) {
        XAlert alert = item.getAlert();
        viewHolder.txt.setText(alert.getNote());
        viewHolder.txtTime.setText(alert.getFormatCreatedAt());
      } else if (item.getViewType() == vtString) {
        final String footer = item.getText();
        viewHolder.txtInfo.setText(footer);
      } else {
        throw new IllegalStateException("item.getViewType() == " + item.getViewType());
      }
    }

    @Override public int getItemViewType(int position)
    {
      return getViewType(position).ordinal();
    }

    @Override public int getItemCount()
    {
      return arrayList.size();
    }

    ViewType getViewType(int position) {
      return getItem(position).getViewType();
    }

    private XItem getItem(int position) {
      return arrayList.get(position);
    }

    public class ViewHolder extends RecyclerView.ViewHolder {
      private TextView    txt;
      private TextView    txtTime;
      private TextView    txtInfo;

      public ViewHolder(View view, ViewType type)
      {
        super(view);
        if (type == vtAlert) {
          txt = view.findViewById(R.id.txt);
          txtTime = view.findViewById(R.id.txt_time);
        } else if (type == vtString) {
          txtInfo = view.findViewById(R.id.txt_info);
        } else {
          throw new IllegalArgumentException("Unexpected View Type: " + type);
        }
      }
    }
  }
}

