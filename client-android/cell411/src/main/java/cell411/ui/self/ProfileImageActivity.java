package cell411.ui.self;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.view.MenuItem;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import cell411.base.BaseActivity;
import com.safearx.cell411.R;

import cell411.Cell411;
import cell411.services.DataService;
import cell411.parse.XUser;
import cell411.parse.util.OnCompletionListener;
import it.sephiroth.android.library.imagezoom.ImageViewTouch;

/**
 * Created by Sachin on 10/3/2015.
 */
public class ProfileImageActivity extends BaseActivity {
  private ImageView mImageView;
  private ImageViewTouch mImageViewTouch;
  private TextView mTxtNoProfilePictureAvailable;

  public static void start(Activity activity, XUser user) {
    Intent profileImageIntent = new Intent(activity, ProfileImageActivity.class);
    profileImageIntent.putExtra("userId", user.getObjectId());
    activity.startActivity(profileImageIntent);
  }


  //  public static void start(Activity activity, String userObjectId, Integer imageName)
//  {
//    Intent profileImageIntent = new Intent(activity, ProfileImageActivity.class);
//    profileImageIntent.putExtra("userId", userObjectId);
//    profileImageIntent.putExtra("imageName", imageName);
//    activity.startActivity(profileImageIntent);
//  }
  @Override protected void onCreate(Bundle savedInstanceState)
  {
    super.onCreate(savedInstanceState);
     String userId = getIntent().getStringExtra("userId");

    XUser user = (XUser) ds().getObject(userId);
    if(user==null) {
      Cell411.get().showAlertDialog("No user was provided", new OnCompletionListener() {
          @Override public void done(boolean success) {
            finish();
          }
        });
      return;
    };
    setContentView(R.layout.activity_image);
    // Set up the action bar.
    setDisplayUpAsHome();
    mImageView = findViewById(R.id.img_placeholder);
    mImageViewTouch = findViewById(R.id.image);
    mTxtNoProfilePictureAvailable = findViewById(R.id.txt_no_profile_picture);
    mImageView.setImageResource(R.drawable.ic_placeholder_user);
    mTxtNoProfilePictureAvailable.setVisibility(View.VISIBLE);
    bitmapLoaded(user.getAvatarPic(this::bitmapLoaded));
    //mImageViewTouch.setImageBitmap(user.getAvatarPic(mImageViewTouch::setImageBitmap));
    mImageViewTouch.setVisibility(View.VISIBLE);
    mTxtNoProfilePictureAvailable.setVisibility(View.GONE);
  }

  private void bitmapLoaded(Bitmap bitmap) {
    mImageViewTouch.setImageBitmap(bitmap);
    mImageViewTouch.setVisibility(bitmap==null?View.GONE:View.VISIBLE);
    mTxtNoProfilePictureAvailable.setVisibility(bitmap==null?View.GONE:View.VISIBLE);
  }

  @Override public boolean onOptionsItemSelected(MenuItem item)
  {
    if (item.getItemId() == android.R.id.home) {
      finish();
      return true;
    }
    return super.onOptionsItemSelected(item);
  }
}

