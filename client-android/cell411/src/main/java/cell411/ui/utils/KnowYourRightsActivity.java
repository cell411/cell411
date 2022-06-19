package cell411.ui.utils;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.MenuItem;

import androidx.appcompat.app.ActionBar;

import cell411.base.BaseActivity;
import com.safearx.cell411.R;



/**
 * Created by Sachin on 19-04-2016.
 */
public class KnowYourRightsActivity extends BaseActivity {
  public static void start(Activity activity) {
    Intent intentKnowYourRights = new Intent(activity, KnowYourRightsActivity.class);
    activity.startActivity(intentKnowYourRights);
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
    setContentView(R.layout.activity_know_your_rights);
    // Set up the action bar.
    final ActionBar actionBar = getSupportActionBar();
    actionBar.setDisplayHomeAsUpEnabled(true);
  }
}

