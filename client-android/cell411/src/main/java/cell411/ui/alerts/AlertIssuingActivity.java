package cell411.ui.alerts;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.location.Location;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import cell411.Cell411;
import cell411.enums.ProblemType;
import cell411.base.BaseActivity;
import cell411.base.BaseApp;
import cell411.methods.Dialogs;
import cell411.methods.PrivilegeModules;
import cell411.parse.XAlert;
import cell411.parse.XBaseCell;
import cell411.parse.XPrivateCell;
import cell411.parse.XPublicCell;
import cell411.parse.XUser;
import cell411.parse.util.XItem;
import cell411.services.LocationService;

import cell411.utils.LocationUtil;
import cell411.utils.StorageOperations;
import cell411.utils.Util;
import cell411.utils.XLog;
import com.google.android.material.switchmaterial.SwitchMaterial;
import com.parse.Parse;
import com.parse.ParseCloud;
import com.parse.ParseQuery;
import com.safearx.cell411.R;
import org.jetbrains.annotations.NotNull;

import java.io.File;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static cell411.Cell411.getResString;
import static cell411.enums.ProblemType.Photo;
import static cell411.enums.ProblemType.Video;
import static cell411.utils.ViewType.*;

/**
 * Created by Sachin on 21-03-2018.
 */
public class AlertIssuingActivity extends BaseActivity {
  private static final String              TAG                 = "AlertIssuingActivity";
  private static final int                 REQUEST_PERMISSIONS = 1;
  final                String[]            smPerms             =
    new String[]{Manifest.permission.CAMERA, Manifest.permission.RECORD_AUDIO};
  private final        XItem               mGlobal             =
    makeItem("global", R.string.audience_global_alert);
  private final        XItem               mCells
    = makeItem("allCells", R.string.audience_cells);
  private final        XItem               mFriends            =
    makeItem("allFriends", R.string.audience_friends);
  private final        AudienceListAdapter mListAdapter        = new AudienceListAdapter();
  AudienceState mAudienceState;
  private ProblemTypeInfo    mProblemTypeInfo;
  private RecyclerView       mRecyclerView;
  private EditText           mEtAdditionalNote;
  private TextView           mTxtAlertTitle;
  private FrameLayout        mMainLayout;
  private SwitchMaterial     mStreamVideo;
  private TextView           mBtnCancel;
  private TextView           mBtnSend;
  private ProblemType        mProblemType;
  private XAlert             mAlert;
  private List<XPrivateCell> mPrivateCells;
  private List<XPublicCell>  mOwnedCells;
  private List<XPublicCell>  mJoinedCells;

  public static void start(Activity activity, ProblemType type)
  {
    Class<?> clazz  = AlertIssuingActivity.class;
    Intent   intent = new Intent(activity, clazz);
    intent.putExtra("type", type.toString());
    activity.startActivity(intent);
  }
  static XItem makeItem(String id, int res) {
    return new XItem(id, getResString(res));
  }
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    Bundle extras = getIntent().getExtras();
    String str    = extras.getString("problemType");
    if (str == null)
      str = extras.getString("type");
    if (str == null) {
      mProblemType     = ProblemType.values()[0];
      mProblemTypeInfo = ProblemTypeInfo.values()[0];
    } else {
      mProblemTypeInfo = ProblemTypeInfo.fromString(str);
      mProblemType     = mProblemTypeInfo.getType();
    }
    if (mProblemTypeInfo == null) {
      showAlertDialog("Error:  no problem type set");
      finish();
      return;
    }
    setContentView(R.layout.activity_alert_issuing);
    mMainLayout = findViewById(R.id.rl_main_container);
    mBtnCancel  = findViewById(R.id.txt_btn_cancel);
    mBtnCancel.setOnClickListener(this::cancelClicked);
    mBtnSend = findViewById(R.id.txt_btn_send);
    mBtnSend.setOnClickListener(this::sendClicked);
    mTxtAlertTitle    = findViewById(R.id.txt_alert_title);
    mEtAdditionalNote = findViewById(R.id.et_additional_note);
    mEtAdditionalNote.setHint(R.string.enter_alert_additional_note);
    mRecyclerView = findViewById(R.id.rv_audience);
    mRecyclerView.setAdapter(mListAdapter);
    mRecyclerView.setLayoutManager(new LinearLayoutManager(this));
    mStreamVideo = findViewById(R.id.switch_stream_video);
    setPopupBackground();
  }
  @Override
  public void loadData() {
    super.loadData();
    loc().addObserver(this::onLocationChanged);
    final XUser user = XUser.getCurrentUser();
//    mPrivateCells = user.getPrivateCells();
//    mOwnedCells   = user.getOwnedPublicCells();
//    mJoinedCells  = user.getJoinedPublicCells();
    ParseQuery<XPrivateCell> privateCells = XPrivateCell.q();
    privateCells.whereEqualTo("owner",user);
    ParseQuery<XPublicCell> publicCells = XPublicCell.q();
    publicCells.whereEqualTo("owner",user);
    ArrayList<ParseQuery<XPublicCell>> queries = new ArrayList<>();
    queries.add(publicCells);
    publicCells=XPublicCell.q();
    publicCells.whereEqualTo("members",user);
    queries.add(publicCells);
    publicCells=ParseQuery.or(queries);
    List<XPublicCell> cells = publicCells.find();
    mOwnedCells=new ArrayList<>();
    mJoinedCells=new ArrayList<>();
    for(XPublicCell cell : cells) {
      if(cell.getOwner().hasSameId(user)) {
        mOwnedCells.add(cell);
      } else {
        mJoinedCells.add(cell);
      }
    }
    mPrivateCells=privateCells.find();
    mPrivateCells.sort(Comparator.comparing(XPrivateCell::getCellType)
                                 .thenComparing(XPrivateCell::getName,
                                                String.CASE_INSENSITIVE_ORDER)
                                 .thenComparing(XPrivateCell::getObjectId));
    Comparator<XPublicCell> cmp =
      Comparator.comparing(XPublicCell::getName, String.CASE_INSENSITIVE_ORDER)
                .thenComparing(XPublicCell::getObjectId);
    mOwnedCells.sort(cmp);
    mJoinedCells.sort(cmp);
    createAudienceList();
  }
  private void onLocationChanged(Location location, Location location1) {
    XLog.i(TAG, "location: "+location);
  }
  private void sendClicked(View view) {
    sendAlert();
  }
  private void sendAlert() {
    ds().onDS(new AlertSender());
  }
  private void cancelClicked(View view) {
    finish();
  }
  @Override
  protected void onPause() {
    super.onPause();
  }
  @Override
  protected void onResume() {
    super.onResume();
  }
  private void setPopupBackground() {
    mMainLayout.setBackgroundColor(mProblemTypeInfo.getBackgroundColor());
    mTxtAlertTitle.setText(mProblemTypeInfo.getTitle());
  }
  private void createAudienceList() {
    if (mAudienceState == null)
      mAudienceState = new AudienceState(StorageOperations.loadAudience());

    // Now we put it all together.
    List<XItem> list = new ArrayList<>();

    mAudienceState.syncSelected(mGlobal);
    list.add(mGlobal);
    mAudienceState.syncSelected(mFriends);
    list.add(mFriends);
    mAudienceState.syncSelected(mCells);

    if (!mFriends.isSelected()) {
      // All members of private cells are friends as well,
      // so we can leave the private cells out, if friends
      // is selected.
      list.addAll(Util.transform(mPrivateCells, XItem::new));
    }
    list.add(mCells);
    if (!mCells.isSelected()) {
      // To avoid being too confusing, we treat the Cells button
      // as selecting ALL public cells.
      list.addAll(Util.transform(mOwnedCells, XItem::new));
      list.addAll(Util.transform(mJoinedCells, XItem::new));
    }
    for (XItem item : list) {
      mAudienceState.syncSelected(item);
    }

    mListAdapter.setData(list);
    StorageOperations.storeAudience(mAudienceState);
  }
  private HashMap<String, Object> createParams(boolean video)
  {
    Map<String,Object> objAlert = new HashMap<>();
    ProblemType type     = mProblemType;
    if (type == Video)
      video = true;
    try {
      objAlert.put("problemType", mProblemType.toString());
      Cell411         cell411         = Cell411.get();
      LocationService locationService = cell411.loc();
      Location        location        = locationService.getLocation();
      objAlert.put("location", LocationUtil.getGeoPoint(location));
      String      note = mEtAdditionalNote.getText().toString().trim();
      if (!Util.isNoE(note))
        objAlert.put("note", note);

      final XUser user = XUser.getCurrentUser();
      if (video || mProblemType == Photo) {
        String uploadName = user.getObjectId() + "-" + Util.isoDate();
        uploadName = uploadName.replaceAll(":", "-");
        if (video) {
          uploadName = uploadName + ".flv";
          objAlert.put("video", uploadName);
        } else {
          uploadName = uploadName + ".png";
          objAlert.put("photo", uploadName);
          File photoName = new File(getExternalFilesDir(null).getAbsolutePath());
          photoName = new File(photoName, "Photos");
          photoName = new File(photoName, "/photo_alert.png");
          //FIXME: .uploadPhoto(photoName, (String) objAlert.get("photo"));
        }
      }
       HashMap<String, Object> params = new HashMap<>();
      createAudienceList();
      ArrayList<String> arrAudience = new ArrayList<>();
      for (XItem item : mListAdapter.mItems) {
        if (!item.isSelected())
          continue;
        arrAudience.add(item.getObjectId());
      }
      params.put("audience", arrAudience);
      params.put("alert", objAlert);
      return params;
    } catch (Exception e) {
      throw new RuntimeException("Exception in createParams: ", e);
    }
  }
  @Override
  public void onBackPressed() {
    if (Dialogs.isDialogShowing()) {
      BaseApp.get().onUI(this::onBackPressed, 200);
    } else {
      super.onBackPressed();
    }
  }

  //  @Override
  public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions,
                                         @NonNull int[] grantResults)
  {
    if (requestCode != REQUEST_PERMISSIONS) {
      super.onRequestPermissionsResult(requestCode, permissions, grantResults);
      return;
    }
    if (grantResults.length == 2 && grantResults[0] == PackageManager.PERMISSION_GRANTED &&
        grantResults[1] == PackageManager.PERMISSION_GRANTED) {
      sendAlert();
    } else {
      Dialogs.showAlertDialog("Cannot record without permissions");
    }
  }

  static class AudienceState extends HashMap<String, Boolean> {
    public AudienceState(@NonNull @NotNull Map<String, Boolean> m) {
      super(m);
    }
    void syncSelected(XItem item)
    {
      Boolean selected = get(item.getObjectId());
      if (selected == null) {
        put(item.getObjectId(), item.isSelected());
      } else {
        item.setSelected(selected);
      }
    }
  }

  //  }
  //  private void streamVideo() {
  //    Cell411.later(() -> {
  //      final SharedPreferences prefs = Cell411.i()
  //                                             .getAppPrefs();
  //      boolean streamVideoToYTChannel = prefs.getBoolean("StreamVideoToYouTubeChannel", false);
  //      boolean streamVideoToMyYTChannel = prefs.getBoolean("StreamVideoToMyYouTubeChannel",
  //      false);
  //      if (streamVideoToYTChannel || streamVideoToMyYTChannel) {
  //        Location location = getLocationWatcher().getLocation();
  //        DataService.i()
  //                   .requestCity(location, address -> {
  //                     URL url = SingletonConfig.getGoLiveURL(mAlert.getCreatedAt(), address);
  //                     Task.call(new AlertIssuingActivity.NewGoLiveApiCall(url));
  //                   });
  //      } else {
  //        URL url = mAlert.getVideoLink();
  //        VideoStreamingActivity.start(AlertIssuingActivity.this, url);
  //      }
  //    });
  //    finish();
  //  }
  //  public void onClick(View v) {
  //    XLog.i(TAG, Reflect.currentMethodName() + " invoked.  isSendAlertTapped=" +
  //    mIsSendAlertTapped);
  //    int id = v.getId();
  //    if (id == R.id.txt_btn_cancel || id == R.id.img_close) {
  //      if (mIsSendAlertTapped) {
  //        Cell411.i()
  //               .showToast(getString(R.string.please_wait));
  //      } else {
  //        finish();
  //      }
  //    } else if (id == R.id.txt_btn_send) {
  //      if (mIsSendAlertTapped) {
  //        Cell411.i()
  //               .showToast(getString(R.string.please_wait));
  //      } else {
  //        setAlert();
  //        retrieveCurrentLocationAndIssueAlert();
  //      }
  //    }
  //  }
  //  static class NewGoLiveApiCall implements Callable<Boolean> {
  //    private final URL mURL;
  //
  //    public NewGoLiveApiCall(URL url) {
  //      mURL = url;
  //    }
  //
  //    @Override
  //    public Boolean call() throws Exception {
  //      if (Util.isCurrentThread(Looper.getMainLooper())) {
  //        throw new IllegalStateException("Cannot run doInBackground on main thread");
  //      }
  //      InputStream in;
  //      try {
  //        URLConnection urlConnection = mURL.openConnection();
  //        urlConnection.setConnectTimeout(30000);
  //        urlConnection.setReadTimeout(30000);
  //        urlConnection.setDoInput(true);
  //        in = new BufferedInputStream(urlConnection.getInputStream());
  //        BufferedReader reader = new BufferedReader(new InputStreamReader(in), 8);
  //        StringBuilder sb = new StringBuilder();
  //        String line;
  //        while ((line = reader.readLine()) != null) {
  //          sb.append(line);
  //        }
  //        Cell411.i()
  //               .showAlertDialog(sb.toString());
  //        XLog.i("GoLiveApiCall response: ", sb.toString());
  //        return true;
  //      } catch (final Exception e) {
  //        XLog.i("GoLiveApiCall", "Exception: " + e);
  //        return null;
  //      }
  //    }
  //  }

  final static Handler handler = new Handler(Looper.getMainLooper());

  public class AlertSender implements Runnable {
    final Cell411                 cell411;
    final boolean                 video;
    final HashMap<String, Object> params;

    public AlertSender() {

      cell411 = Cell411.get();
      video   = mStreamVideo.isChecked();
      params  = createParams(video);
    }

    public void run() {
      if(!Parse.isInitialized()) {
        handler.postDelayed(this,15000);
        return;
      }
      for(Object obj : params.values()) {
        assert(!(obj instanceof String));
      }
      HashMap<String, Object> res = ParseCloud.run("sendAlert", params);
      if (res == null)
        res = new HashMap<>();
      if (res.containsKey("error")) {
        cell411.showAlertDialog("Error sending Alert: " + res.get("error"));
        return;
      } else if (res.containsKey("alert")) {
        String alert = (String)res.get("alert");
        ParseQuery<XAlert> query = XAlert.q();
        query.whereEqualTo("objectId", alert);
        List<XAlert> result = query.find();
        if(result.size()>0)
          mAlert = result.get(0);
      } else {
        cell411.showAlertDialog("No error, no alert!");
      }
      PrivilegeModules.checkAndUpdatePrivilege(false);
      if (video)
        requestPermissions(smPerms, REQUEST_PERMISSIONS);
      else
        BaseApp.get().onUI(AlertIssuingActivity.this::finish,0);

//      URL    url    = mAlert.getVideoLink();
//      Intent intent = new Intent(AlertIssuingActivity.this, VideoStreamingActivity.class);
//      intent.putExtra("url", url);
//      startActivity(intent);
    }
  }

  private class AudienceListAdapter extends RecyclerView.Adapter<ViewHolder> {
    private final ArrayList<XItem> mItems = new ArrayList<>();

    public AudienceListAdapter()
    {
    }

    @SuppressLint("NotifyDataSetChanged")
    public void setData(List<XItem> items) {
      mItems.clear();
      mItems.addAll(items);
      if (Cell411.isUIThread())
        notifyDataSetChanged();
      else
        BaseApp.get().onUI(this::notifyDataSetChanged, 100);
    }

    public XItem getItem(int position) {
      return mItems.get(position);
    }

    public ArrayList<XItem> getItems() {
      return mItems;
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType)
    {
      LayoutInflater inflater = LayoutInflater.from(parent.getContext());
      View           v        = inflater.inflate(R.layout.cell_audience, parent, false);
      return new ViewHolder(v);
    }

    @Override
    public void onBindViewHolder(final ViewHolder viewHolder, final int position)
    {
      viewHolder.bind(mItems.get(position));
    }

    // Return the size of your data set (invoked by the layout manager)
    @Override
    public int getItemCount()
    {
      return mItems.size();
    }

    //    public ArrayList<XItem> getSelectedAudience() {
    //      ArrayList<XItem> res = new ArrayList<>();
    //      for (XItem item : mItems) {
    //        XLog.i(TAG, "audience: " + item);
    //        if (item.isSelected()) {
    //          res.add(item);
    //        }
    //      }
    //      return res;
    //    }
  }

  public class ViewHolder extends RecyclerView.ViewHolder {
    private final CheckBox  cbAudience;
    private final TextView  txtAudience;
    private final TextView  txtTotalAudience;
    private final ImageView imgExpand;
    private final ImageView imgInfo;

    public ViewHolder(View view)
    {
      super(view);
      cbAudience       = view.findViewById(R.id.cb_audience);
      txtAudience      = view.findViewById(R.id.txt_audience);
      txtTotalAudience = view.findViewById(R.id.txt_total_audience);
      imgExpand        = view.findViewById(R.id.img_expand);
      imgInfo          = view.findViewById(R.id.img_info);
    }

    public void bind(XItem item) {
      cbAudience.setOnCheckedChangeListener(null);
      cbAudience.setChecked(item.isSelected());
      cbAudience.setOnCheckedChangeListener(this::onCheckedChanged);
      imgExpand.setVisibility(View.GONE);
      imgInfo.setVisibility(View.GONE);
      txtAudience.setVisibility(View.VISIBLE);
      XUser  user    = XUser.getCurrentUser();
      String itemText;
      String audText = "";
      if (item.getViewType() == vtString) {
        itemText = item.getText();
        if (item == mCells) {
          audText = "???";
          imgExpand.setVisibility(View.VISIBLE);
        } else if (item == mFriends) {
          //FIXME audText = Util.format("(%d)", user.getFriendList().size());
          txtTotalAudience.setText(audText);
        } else if (item == mGlobal) {
          audText = "(???)";
          txtTotalAudience.setVisibility(View.GONE);
        } else {
          XLog.i(TAG, "Unexpected Title: %s", itemText);
        }
      } else if (item.getViewType() == vtPrivateCell || item.getViewType() == vtPublicCell) {
        XBaseCell cell = item.getCell();
        itemText = cell.getName();
        audText  = Util.format("(%d))", cell.getMemberIds().size());
      } else {
        itemText = "WTF?";
      }
      txtTotalAudience.setText(audText);
      txtAudience.setText(itemText);
      txtTotalAudience.setVisibility(audText.length() > 0 ? View.VISIBLE : View.GONE);
    }
    private void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
      View view = buttonView;
      while (view.getParent() != mRecyclerView) {
        view = (View) view.getParent();
      }
      int   position    = mRecyclerView.getChildAdapterPosition(view);
      XItem changedItem = mListAdapter.getItem(position);
      mAudienceState.put(changedItem.getObjectId(), isChecked);
      mAudienceState.syncSelected(changedItem);

      if (changedItem == mFriends || changedItem == mCells) {
        // mFriends removes all private cells with checked,
        // and returns them when unchecked.  This does not change
        // the states of the cells ... they will stick.
        //
        // mCells does the same with public cells.
        createAudienceList();
      }
    }
  }
}
