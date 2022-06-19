package cell411.ui.alerts;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Bundle;
import android.view.MenuItem;
import android.view.View;
import androidx.appcompat.app.ActionBar;
import cell411.Cell411;
import cell411.base.BaseActivity;
import cell411.parse.XAlert;
import cell411.utils.ImageFactory;
import cell411.utils.NetUtils;
import com.parse.ParseQuery;
import com.safearx.cell411.R;
import it.sephiroth.android.library.imagezoom.ImageViewTouch;

import java.io.File;
import java.net.URL;

/**
 * Created by Sachin on 10/3/2015.
 */
public class ImageScreenActivity extends BaseActivity {
  private ImageViewTouch mImage;

  public static void start(Activity activity, String alertId) {
    Intent myIntent = new Intent(activity, ImageScreenActivity.class);
    myIntent.putExtra("cell411AlertId", alertId);
    activity.startActivity(myIntent);
  }

  @Override
  public boolean onOptionsItemSelected(MenuItem item)
  {
    if (item.getItemId() == android.R.id.home) {
      finish();
      return true;
    }
    return super.onOptionsItemSelected(item);
  }

  @Override
  protected void onCreate(Bundle savedInstanceState)
  {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_image);
    // Set up the action bar.
    mImage = findViewById(R.id.image);
    final ActionBar actionBar = getSupportActionBar();
    if (actionBar != null) {
      actionBar.setDisplayHomeAsUpEnabled(true);
      actionBar.setDisplayShowHomeEnabled(true);
    }
  }
  public void loadData() {
    super.loadData();
    String alertId  = getIntent().getStringExtra("alertId");
    String path     = getIntent().getStringExtra("path");
    URL    imageUrl = NetUtils.toURL(getIntent().getStringExtra("imageUrl"));
    if (alertId == null) {
      if (imageUrl == null)
        imageUrl = NetUtils.toURL(Uri.fromFile(new File(path)));
      setImage(ImageFactory.loadBitmapAsync(imageUrl, this::setImage));
      return;
    }

    ds().onDS(() -> {
      try {

        XAlert alert = (XAlert) ds().getObject(alertId);
        if (alert == null) {
          ParseQuery<XAlert> query = ParseQuery.getQuery(XAlert.class);
          alert = query.get(alertId);
        }
        if (alert == null) {
          String message = "Unable to load alert " + alertId;
          Cell411.get().showAlertDialog(message, success -> finish());
          //          return;
        }
        //        ParseFile applicantResume = alert.getPhoto();
        //        byte[] data = applicantResume.getData();
        //        BitmapFactory.Options options = new BitmapFactory.Options();
        //        Bitmap bmp = BitmapFactory.decodeByteArray(data, 0, data.length, options);
        //        Cell411.later(()->setImage(bmp));
      } catch (Exception e) {
        handleException("loading Alert.getPhoto()", e, success -> finish());
      }
    });
  }
  void setImage(Bitmap bitmap)
  {
    if (bitmap != null) {
      mImage.setImageBitmap(bitmap);
      mImage.setVisibility(View.VISIBLE);
    }
  }
}

