package cell411.ui.utils.ip;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.ProgressBar;
import android.widget.TextView;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.CallSuper;
import androidx.annotation.Nullable;
import androidx.core.util.Pair;

import cell411.base.BaseActivity;
import cell411.utils.ImageUtils;
import cell411.utils.Reflect;
import cell411.utils.XLog;
import com.safearx.cell411.R;


import java.io.File;


/**
 * Created by Sachin on 11/1/2015.
 */
public class ImagePickerActivity extends BaseActivity {
  private static final String            TAG = Reflect.getTag();
  static {
    XLog.i(TAG, "loading class");
  }
  ActivityResultContracts.TakePicture mTakePicture = new ActivityResultContracts.TakePicture();
  ActivityResultLauncher<Uri> mTPLauncher =  registerForActivityResult(mTakePicture, this::tpCallback);
  void tpCallback(final Boolean success) {
    if(!success) {
      showToast("Failed to take picture");
      return;
    }
    mPicPrefs.mBitmap = ImageUtils.loadCameraImage(mPicPrefs.mFile);
    onUI(this::gotBitmap);
  }

  public void gotBitmap() {
    Intent intent = new Intent();
    int index = ImagePickerContract.checkPicPrefs(mPicPrefs);
    intent.putExtra("index", index);
    setResult(RESULT_OK, intent);
    finish();
  }

  ActivityResultContracts.GetContent mGetContent = new ActivityResultContracts.GetContent();
  ActivityResultLauncher<String> mGCLauncher =
    registerForActivityResult(mGetContent, this::gcCallback);

  private void gcCallback(final Uri uri) {
    mPicPrefs.mUri=uri;
    mPicPrefs.mBitmap=ImageUtils.loadGalleryImage(uri);
    onUI(this::gotBitmap);
  }

  private TextView txtComments;

  private PicPrefs mPicPrefs;
  private ProgressBar pbUpload;

  private Button btnPickPic;
  private Button btnTakePic;
  public ImagePickerActivity()
  {
  }
  @CallSuper
  @Override
  protected void onActivityResult(int requestCode, int resultCode,
                                  @Nullable  Intent data)
  {
    super.onActivityResult(requestCode, resultCode, data);
  }
  @Override
  protected void onCreate(@Nullable Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_image_picker);
    btnPickPic = findViewById(R.id.btn_pick_pic);
    btnPickPic.setOnClickListener(this::onButtonClick);
    btnTakePic = findViewById(R.id.btn_take_pic);
    btnTakePic.setOnClickListener(this::onButtonClick);
    txtComments = findViewById(R.id.txt_comments);
    pbUpload = findViewById(R.id.pb_progress);
    txtComments.setText(R.string.choosing_method);
    Intent intent   = getIntent();
    PicPrefs prefs = new PicPrefs();
    prefs.updateFromIntent(intent);
    mPicPrefs=prefs;
  }
  private void onButtonClick(View view) {
    if (view == btnTakePic) {
      txtComments.setText(R.string.taking_new_picture);
      Pair<File,Uri> pair = ImageUtils.createUriAndFile(mPicPrefs.mBaseName,
        ".file.provider");
      if(pair==null) {
        showToast("Failed to get file and url");
        return;
      }
      mPicPrefs.mFile=pair.first;
      mPicPrefs.mUri=pair.second;
      mTPLauncher.launch(mPicPrefs.mUri);
    } else if (view == btnPickPic) {
      txtComments.setText(R.string.picking_from_gallery);
      mGCLauncher.launch(mPicPrefs.mMimeType);
    } else {
      showAlertDialog("I don't know what that view you clicked is for.  :(");
    }
  }
}

