package cell411.ui.alerts;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import cell411.base.BaseActivity;
import com.parse.ParseQuery;
import com.safearx.cell411.R;

import cell411.base.BaseApp;
import cell411.parse.XResponse;
import cell411.parse.XUser;



public class AlertResponseActivity extends BaseActivity {
  private TextView mTxtContent;
  private Button   mClose;
  private TextView mTxtNote;
  private XResponse mNote;
  private XUser  mSender;
  Runnable mDataLoader = new Runnable() {
    public void run() {
      final String objectId = getObjectId();

      mNote = (XResponse) ds()
                                     .getObject(objectId);
      if (mNote == null) {
        ParseQuery<XResponse> alertQuery = ParseQuery.getQuery(XResponse.class);
        mNote = alertQuery.get(objectId);
      }
      mSender = (XUser) mNote.getParseUser("user");
      if (mSender != null) {
        mSender.fetchIfNeeded();
      }

      System.out.println(ds()
                                    .loadTime());
      BaseApp.get().onUI(AlertResponseActivity.this::objectLoaded,0);
    }
  };

  @Override protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.alert_response_activity);

    ds()
               .onDS(mDataLoader);
    mTxtContent = findViewById(R.id.txt_content);
    mTxtNote = findViewById(R.id.txt_note);
    mClose = findViewById(R.id.txt_btn_close);
    mClose.setOnClickListener(this::onClick);
  }

  private String getObjectId() {
    Intent intent = getIntent();
    String objectId = intent.getStringExtra("objectId");
    if (objectId == null) {
      objectId = "LElLHkkQRH";
    }
    return objectId;
  }

  private void onClick(View view) {
    if (view == mClose) {
      finish();
    }
  }

  private void objectLoaded() {
    String text = getString(R.string.helper_on_way, mSender.getName());
    text += " his estimated travel time is " + mNote.getTravelTime();
    mTxtContent.setText(text);
    String note = mNote.getNote();
    if (note.isEmpty()) {
      mTxtNote.setVisibility(View.GONE);
    } else {
      mTxtNote.setVisibility(View.VISIBLE);
      mTxtNote.setText(note);
    }
  }
}
