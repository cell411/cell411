package cell411.ui.alerts;

import static cell411.Cell411.TIME_TO_LIVE_FOR_CHAT_ON_ALERTS;

import android.content.ActivityNotFoundException;
import android.content.Intent;
import android.content.res.ColorStateList;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.graphics.Matrix;
import android.hardware.Camera;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.text.style.ClickableSpan;
import android.text.style.URLSpan;
import android.view.MenuItem;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.google.android.material.floatingactionbutton.FloatingActionButton;
import com.parse.ParseQuery;
import com.safearx.cell411.R;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.net.URL;

import cell411.Cell411;
import cell411.base.BaseActivity;
import cell411.enums.ProblemType;
import cell411.methods.AddFriendModules;
import cell411.parse.XAlert;
import cell411.parse.XUser;
import cell411.services.DataService;
import cell411.ui.friends.UserActivity;
import cell411.ui.self.ProfileImageActivity;
import cell411.ui.utils.CircularImageView;
import cell411.utils.Cell411GuiUtils;
import cell411.utils.ImageUtils;
import cell411.utils.NetUtils;
import cell411.utils.Reflect;
import cell411.utils.Util;
import cell411.utils.XLog;

public class AlertDetailActivity extends BaseActivity implements View.OnClickListener {
  private static final String TAG = Reflect.getTag();

  static {
    XLog.i(TAG, "loading class");
  }

  private XAlert mAlert;
  private LinearLayout llBtnFlag;
  private FloatingActionButton fabSaveOrDownloadOrDownloaded;
  private boolean isDeleteVideoEnabled;
  private TextView mAddress;
  private TextView txtLblDownloadProgress;
  /**
   * Callback for when picture is taken
   */
  @SuppressWarnings("deprecation")
  private final Camera.PictureCallback mPicture = (data, camera) -> {
    XLog.i("Camera", "onPictureTaken() invoked..");
    Bitmap photo = BitmapFactory.decodeByteArray(data, 0, data.length);
    Matrix matrix2 = new Matrix();
    Camera.CameraInfo info = new Camera.CameraInfo();
    Camera.getCameraInfo(0, info);
    // Perform matrix rotations/mirrors depending on camera that took the photo
    float[] mirrorY = {-1, 0, 0, 0, 1, 0, 0, 0, 1};
    Matrix matrixMirrorY = new Matrix();
    matrixMirrorY.setValues(mirrorY);
    matrix2.postConcat(matrixMirrorY);
    photo = Bitmap.createBitmap(photo, 0, 0, photo.getWidth(), photo.getHeight(), matrix2, true);
    Matrix matrix = new Matrix();
    matrix.preRotate(90, (float) photo.getWidth() / 2, (float) photo.getHeight() / 2);
    photo = Bitmap.createBitmap(photo, 0, 0, photo.getWidth(), photo.getHeight(), matrix, true);
    // save captured image
    saveImage(NetUtils.toURL("/photo.bmp"), photo);
  };
  private TextView txtUserName;
  private TextView txtAlertTime;
  private RelativeLayout rlAdditionalNote;
  private TextView txtAdditionalNote;
  private TextView txtMedical;
  private ImageView mImgAlertType;
  private RelativeLayout rlLive;
  private View mViewAlertConnector;
  private ImageView mImgAlertHead;
  private FloatingActionButton fabViewOrPlay;
  private FloatingActionButton fabChat;
  private FloatingActionButton fabDeleteVideo;
  private CircularImageView imgUser;

  static public File getMediaOutputDir(String type) {
    return ImageUtils.getMediaOutputDir(type);
  }

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    mAlert = null;
    setContentView(R.layout.activity_alert_detail);
    imgUser = findViewById(R.id.img_user);
    txtUserName = findViewById(R.id.txt_name);
    txtAlertTime = findViewById(R.id.txt_alert_time);
    rlAdditionalNote = findViewById(R.id.rl_additional_note);
    txtAdditionalNote = findViewById(R.id.txt_additional_note);
    txtMedical = findViewById(R.id.txt_medical);
    llBtnFlag = findViewById(R.id.rl_btn_flag);
    mImgAlertType = findViewById(R.id.img_alert_type);
    mAddress = findViewById(R.id.txt_city);
    txtLblDownloadProgress = findViewById(R.id.txt_lbl_download_progress);
    isDeleteVideoEnabled = Cell411.get().getAppPrefs().getBoolean("DeleteVideo", false);
    rlLive = findViewById(R.id.rl_live);
    mViewAlertConnector = findViewById(R.id.view_alert_connector);
    mImgAlertHead = findViewById(R.id.img_alert_head);
    ImageView imgClose = findViewById(R.id.img_close);
    imgClose.setOnClickListener(v -> finish());
    fabSaveOrDownloadOrDownloaded = findViewById(R.id.fab_save_or_download_or_downloaded);
    fabViewOrPlay = findViewById(R.id.fab_view_or_play);
    fabChat = findViewById(R.id.fab_chat);
    FloatingActionButton fabNavigate = findViewById(R.id.fab_navigate);
    fabDeleteVideo = findViewById(R.id.fab_delete_video);
    fabSaveOrDownloadOrDownloaded.setOnClickListener(this);
    fabViewOrPlay.setOnClickListener(this);
    fabChat.setOnClickListener(this);
    fabNavigate.setOnClickListener(this);
    fabDeleteVideo.setOnClickListener(this);
    llBtnFlag.setOnClickListener(this);
  }

  @Override
  public void loadData() {
    super.loadData();
    String objectId = getIntent().getStringExtra("objectId");

    mAlert = (XAlert) ds().getObject(objectId);
    if (mAlert == null) {
      ParseQuery<XAlert> query = ParseQuery.getQuery(XAlert.class);
      mAlert = query.get(objectId);
    }
    mAlert.fetchIfNeeded();
    XUser owner = mAlert.getOwner();
    if (owner != null)
      owner.fetchIfNeeded();
  }

  @Override
  public void populateUI() {
    super.populateUI();
    XUser owner = mAlert.getOwner();
    if (System.currentTimeMillis() >=
      mAlert.getCreatedAt().getTime() + TIME_TO_LIVE_FOR_CHAT_ON_ALERTS) {
      // the chat is expired
      fabChat.hide();
    }
    assert !relWatcher().isUserBlocked(owner);
    llBtnFlag.setVisibility(View.VISIBLE);
    llBtnFlag.setBackgroundResource(R.drawable.bg_user_flag);
    imgUser.setOnClickListener(view -> {
      XLog.i(TAG, "start");
      ProfileImageActivity.start(AlertDetailActivity.this, owner);
    });
    imgUser.setImageBitmap(owner.getThumbNailPic(imgUser::setImageBitmap));
    String issuerEntity;
    if (mAlert.isSelfAlert()) {
      issuerEntity = getString(R.string.i);
    } else {
      issuerEntity = "<a href='profile'>" + owner.getName() + "</a>";
    }
    String resString = ProblemTypeInfo.valueOf(mAlert.getProblemType().ordinal()).resString();
    XUser forwardedBy = mAlert.getForwardedBy();
    if (forwardedBy != null) {
      String description =
        getString(R.string.alert_message_forwarded, issuerEntity, resString, forwardedBy);
      Cell411GuiUtils.setTextViewHTML(txtUserName, description, this::getClickable);
    } else {
      String description;
      if (mAlert.isSelfAlert()) {
        description = getString(R.string.alert_message_self, resString);
      } else {
        description = getString(R.string.alert_message, issuerEntity, resString);
      }
      Cell411GuiUtils.setTextViewHTML(txtUserName, description, this::getClickable);
    }
    txtAlertTime.setText(Util.formatDateTime(mAlert.getCreatedAt()));
    ProblemType problemType = mAlert.getProblemType();
    ProblemTypeInfo problemTypeInfo = ProblemTypeInfo.valueOf(problemType.ordinal());
    mImgAlertType.setImageResource(problemTypeInfo.getImageRes());
    mImgAlertType.setBackgroundColor(problemTypeInfo.getBackgroundColor());
    mViewAlertConnector.setBackgroundColor(problemTypeInfo.getBackgroundColor());
    mImgAlertHead.setImageResource(problemTypeInfo.getImageRes());
    String note = mAlert.getNote();
    if (Util.isNoE(note)) {
      txtAdditionalNote.setText(note);
    } else {
      rlAdditionalNote.setVisibility(View.GONE);
    }
    if (mAlert.isSelfAlert()) {
      llBtnFlag.setVisibility(View.GONE);
    }
    if (mAlert.getProblemType() == ProblemType.Video) {
      XLog.i(TAG, "VIDEO ALERT");
      if (!mAlert.getStatus().equals("VOD")) {
        XLog.i(TAG, "VOD");
        fabSaveOrDownloadOrDownloaded.setImageResource(R.drawable.fab_download_disabled);
        String COLOR_GRAY_CCC = "#cccccc";
        fabSaveOrDownloadOrDownloaded.setBackgroundTintList(
          ColorStateList.valueOf(Color.parseColor(COLOR_GRAY_CCC)));
        rlLive.setVisibility(View.VISIBLE);
        fabSaveOrDownloadOrDownloaded.setEnabled(false);
      } else {
        fabSaveOrDownloadOrDownloaded.setImageResource(R.drawable.fab_download_enabled);
        fabSaveOrDownloadOrDownloaded.setEnabled(true);
      }
      fabViewOrPlay.setImageResource(R.drawable.fab_play);
      if (!isDeleteVideoEnabled) {
        fabDeleteVideo.hide();
      }
    } else if (mAlert.getProblemType() == ProblemType.Photo) {
      XLog.i(TAG, "PHOTO ALERT");
      fabSaveOrDownloadOrDownloaded.setImageResource(R.drawable.fab_save);
      fabViewOrPlay.setImageResource(R.drawable.fab_view);
      fabDeleteVideo.hide();
    } else {
      XLog.i(TAG, "OTHER ALERT");
      fabSaveOrDownloadOrDownloaded.hide();
      fabViewOrPlay.hide();
      fabDeleteVideo.hide();
    }
    if (mAlert.getProblemType() != ProblemType.Medical) {
      txtMedical.setVisibility(View.GONE);
    } else {
      String medical = "";
      String bloodType = owner.getBloodType();
      String allergies = owner.getAllergies();
      String otherMedicalConditions = owner.getOtherMedicalConditions();
      if (!Util.isNoE(bloodType)) {
        medical += "\n" + getString(R.string.blood_type) + ": " + bloodType;
      }
      if (!Util.isNoE(allergies)) {
        medical += "\n" + getString(R.string.allergies) + ": " + allergies;
      }
      if (!Util.isNoE(otherMedicalConditions)) {
        medical +=
          "\n" + getString(R.string.other_medical_conditions) + ": " + otherMedicalConditions;
      }
      if (Util.isNoE(medical)) {
        txtMedical.setVisibility(View.GONE);
      } else {
        txtMedical.setText(medical);
      }
    }
    // Obtain the SupportMapFragment and get notified when the map is ready to be used.
    String text = "Waiting for city";
    mAddress.setText(text);
    if (mAlert.getLocation() != null) {

      ds()
        .requestCity(mAlert.getLocation(), address -> mAddress.setText(address.mAddress));
    }

  }

  ClickableSpan getClickable(URLSpan ignored) {
    return new ClickableSpan() {
      public void onClick(View view) {
        Intent intentUser = new Intent(AlertDetailActivity.this, UserActivity.class);
        intentUser.putExtra("objectId", mAlert.getOwner().getObjectId());
        startActivity(intentUser);
      }
    };
  }

  @Override
  public boolean onOptionsItemSelected(MenuItem item) {
    if (item.getItemId() == android.R.id.home) {
      finish();
      return true;
    }
    return super.onOptionsItemSelected(item);
  }

  public void saveImage(URL url, Bitmap photo) {
    ByteArrayOutputStream baos = new ByteArrayOutputStream();
    assert photo != null;
    photo.compress(Bitmap.CompressFormat.JPEG, 100, baos);
    byte[] b = baos.toByteArray();
    File pictureDir = getMediaOutputDir(Environment.DIRECTORY_PICTURES);
    File pictureFile = new File(pictureDir, Util.getBaseName(url));
    FileOutputStream fos;
    try {
      fos = new FileOutputStream(pictureFile);
      fos.write(b);
      fos.close();
    } catch (IOException e) {
      e.printStackTrace();
    }
    galleryAddPic(pictureFile);
    XLog.i("Camera", "Image Saved");
    if (mAlert.getProblemType() == ProblemType.Photo) {
      txtLblDownloadProgress.setText(R.string.saved);
    }
  }

  // add picture to the gallery
  private void galleryAddPic(File f2) {
    Intent mediaScanIntent = new Intent("android.intent.action.MEDIA_SCANNER_SCAN_FILE");
    Uri contentUri = Uri.fromFile(f2);
    mediaScanIntent.setData(contentUri);
    sendBroadcast(mediaScanIntent);
  }

  @Override
  public void onClick(View v) {
    int id = v.getId();
    if (id == R.id.fab_view_or_play) {
      if (mAlert.getProblemType() == ProblemType.Video) {
        openVideo();
      } else {
        openPhoto();
      }
    } else if (id == R.id.fab_chat) {
      openChat();
    } else if (id == R.id.fab_navigate) {
      openMapForNavigation();
    } else if (id == R.id.rl_btn_flag) {
      XUser owner = mAlert.getOwner();
      if (owner == null) {
        showAlertDialog("Alert has unknown owner");
        return;
      }
      AddFriendModules.showFlagAlertDialog(activity(), mAlert.getOwner());
    } else if (id == R.id.fab_save_or_download_or_downloaded) {
      checkPermissionAndDownload();
    } else if (id == R.id.fab_delete_video) {
      deleteVideo();
    }
  }

  public void deleteVideo() {
  }

  private void checkPermissionAndDownload() {
    if (mAlert.getProblemType() == ProblemType.Video) {
      downloadVideo();
    } else {
      downloadAndSaveImage();
    }
  }


  private void openVideo() {
    URL videoLink = mAlert.getVideoStreamLink();
    try {
      Intent myIntent = new Intent(Intent.ACTION_VIEW, Uri.parse(videoLink.toString()));
      startActivity(myIntent);
    } catch (ActivityNotFoundException e) {
      Cell411.get().showToast(getString(R.string.video_app_not_found));
      e.printStackTrace();
    }
  }

  private void openPhoto() {
    Intent myIntent = new Intent(this, ImageScreenActivity.class);
    myIntent.putExtra("cell411AlertId", mAlert.getObjectId());
    startActivity(myIntent);
  }

  private void openChat() {
    Cell411.get().openChat(mAlert);
    finish();
  }

  private void openMapForNavigation() {
    try {
      double latitude = mAlert.getLocation().getLatitude();
      double longitude = mAlert.getLocation().getLongitude();
      String label = mAlert.getOwner().getFirstName();
      String uriBegin = "geo:" + latitude + "," + longitude;
      String query = latitude + "," + longitude + "(" + label + ")";
      String encodedQuery = Uri.encode(query);
      String uriString = uriBegin + "?q=" + encodedQuery + "&z=16";
      Uri uri = Uri.parse(uriString);
      Intent intent = new Intent(Intent.ACTION_VIEW, uri);
      startActivity(intent);
    } catch (ActivityNotFoundException e) {
      e.printStackTrace();
      Cell411.get().showToast(getString(R.string.maps_app_not_installed));
    }
  }

  private void downloadAndSaveImage() {
//    if (Looper.getMainLooper().isCurrentThread()) {
//      if (mDownloading) {
//        return;
//      }
//      mDownloading = true;
//
//      ds().later(this::downloadAndSaveImage);
//      return;
//    } else if (DataService.isCurrentThread()) {
//      try {
//        txtLblDownloadProgress.setVisibility(View.VISIBLE);
//        txtLblDownloadProgress.setText(R.string.downloading);
//        //        ParseFile parseFile = mAlert.getPhoto();
//        //        if (parseFile == null) {
//        //          Cell411.i()
//        //                 .showAlertDialog("No photo attached to alert of type " + mAlert
//        //                 .getProblemType());
//        //          return;
//        //        }
//        //        byte[] data = parseFile.getData();
//        //        BitmapFactory.Options options = new BitmapFactory.Options();
//        //        Bitmap bmp = BitmapFactory.decodeByteArray(data, 0, data.length, options);
//        //        txtLblDownloadProgress.setText(R.string.saving);
//        //        saveImage(NetUtils.toURL(parseFile.getName()), bmp);
//      } catch (ParseException pe) {
//        txtLblDownloadProgress.setText(R.string.unable_to_save);
//        handleException("downloading image for alert", pe, null);
//        return;
//      } finally {
//        mDownloading = false;
//      }
//    } else {
//      throw new RuntimeException("What are we doing on this thread?");
//    }
  }

  private void downloadVideo() {
//    if (Looper.getMainLooper().isCurrentThread()) {
//      if (mProgress != null) {
//        Cell411.get().showAlertDialog("Video Download In Progress");
//        return;
//      }
//      mProgress = 0;
//      txtLblDownloadProgress.setVisibility(View.VISIBLE);
//      publishProgress();
//      new Thread(this::downloadVideo).start();
//      return;
//    }
//    try {
//      URL u = mAlert.getVideoLink();
//      XLog.i("Video Download status", "URL: " + u);
//      URLConnection conn = u.openConnection();
//      int contentLength = conn.getContentLength();
//      XLog.i("Video Download status", "Content Length: " + contentLength);
//      DataInputStream stream = new DataInputStream(u.openStream());
//      File videoFile = getMediaOutputDir(Environment.DIRECTORY_MOVIES);
//      DataOutputStream fos = new DataOutputStream(new FileOutputStream(videoFile));
//      byte[] data = new byte[1024 * 16];
//      int count;
//      int total = 0;
//      while ((count = stream.read(data, 0, data.length)) != -1) {
//        fos.write(data, 0, count);
//        total += count;
//        mProgress = total * 100 / contentLength;
//      }
//      stream.close();
//      fos.flush();
//      fos.close();
//      XLog.i("Video Download status", "Video Saved");
//      galleryAddVideo(videoFile);
//      mHandler.post(this::downloadVideoComplete);
//      mProgress = null;
//    } catch (IOException e) {
//      e.printStackTrace();
//      Cell411.get().showAlertDialog("Failed to download video: " + e);
//      mProgress = null;
//    }
  }

  public void downloadVideoComplete() {
    fabSaveOrDownloadOrDownloaded.setImageResource(R.drawable.fab_download_disabled);
    Cell411.get().showAlertDialog("Download Complete.  Seek your video in the Gallery");
  }

  private void galleryAddVideo(File f2) {
    Intent mediaScanIntent = new Intent("android.intent.action.MEDIA_SCANNER_SCAN_FILE");
    Uri contentUri = Uri.fromFile(f2);
    mediaScanIntent.setData(contentUri);
    sendBroadcast(mediaScanIntent);
  }


}

