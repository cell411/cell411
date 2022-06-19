package cell411.ui.welcome;

import static android.content.Context.MODE_PRIVATE;
import static android.media.RingtoneManager.ACTION_RINGTONE_PICKER;
import static android.media.RingtoneManager.EXTRA_RINGTONE_EXISTING_URI;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.media.RingtoneManager;
import android.net.Uri;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import androidx.activity.result.ActivityResultCallback;
import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContract;
import androidx.annotation.IdRes;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.safearx.cell411.R;

import java.util.Arrays;

import cell411.NotificationCenter;
import cell411.base.BaseActivity;
import cell411.base.BaseApp;
import cell411.base.BaseFragment;
import cell411.parse.XAlert;
import cell411.parse.XChatMsg;
import cell411.parse.XRequest;
import cell411.utils.NetUtils;
import cell411.utils.Util;

public class SelectRingtoneFragment extends BaseFragment {
  BaseActivity mActivity;
  Button mDone;
  int mIdx = -1;
  Button[] mPickButtons = new Button[]{
    null, null, null
  };
  TextView[] mTextViews = new TextView[]{
    null, null, null
  };
  Button[] mFauxButtons = new Button[]{
    null, null, null
  };

  static class RingtoneData {
    Uri mUri;
    String mTitle;
  }
  RingtoneData[] mData;


  RingtoneManager mRingtoneManager;
  PickRingtone mContract = new PickRingtone();
  private View mView;
  ActivityResultCallback<Uri> mCallback = result -> {
    if (result != null) {
      mData[mIdx].mUri=result;
      String title = result.getQueryParameter("title");
      mData[mIdx].mTitle="Title "+mIdx;
      mData[mIdx].mTitle=title;
      store();
    }
  };
  ActivityResultLauncher<RingtoneData> mLauncher = registerForActivityResult(mContract, mCallback);

  public SelectRingtoneFragment() {
    super(R.layout.select_ringtone_fragment);
    mData = ringtoneData(mData);
  }

  public void setup(int idx, @IdRes int txt, @IdRes int btn, @IdRes int faux) {
    String text = "";

    if(mData[idx].mUri!=null) {
      Uri uri = mData[idx].mUri;
      text=mData[idx].mTitle= uri.getQueryParameter("title");
    }
    mPickButtons[idx] = mView.findViewById(btn);
    mTextViews[idx] = mView.findViewById(txt);
    mFauxButtons[idx] = mView.findViewById(faux);
    Button pickButton, fauxButton;
    TextView textView;

    Arrays.asList(
      pickButton = mPickButtons[idx],
      textView = mTextViews[idx],
      fauxButton = mFauxButtons[idx]
    ).forEach((view) -> view.setTag(idx));

    pickButton.setTag(idx);
    textView.setTag(idx);
    textView.setText(text);
    pickButton.setOnClickListener(this::onButtonClicked);
    fauxButton.setOnClickListener(this::onSimulateClicked);
  }

  private void onSimulateClicked(final View view) {
    NotificationCenter center = new NotificationCenter();
    center.restore();
    int tag = (int) view.getTag();
    switch (tag) {
      case 0:
        center.sendAlertNotification(XAlert.fakeAlert());
        break;
      case 1:
        center.sendRequestNotification(XRequest.fakeRequest());
        break;
      case 2:
        center.sendChatNotification(XChatMsg.fakeChatMsg());
        break;
    }
  }

  public void restore() {
    mData = ringtoneData(mData);
    setup();
  }
  SharedPreferences prefs() {
    return app().getSharedPreferences("Tones", MODE_PRIVATE);
  }

  private RingtoneData[] ringtoneData(RingtoneData[] data) {
    SharedPreferences tones = prefs();
    if(data==null)
      data = new RingtoneData[3];
    for (int idx = 0; idx < data.length; idx++) {
      if(data[idx]==null)
        data[idx] = new RingtoneData();
      Uri uri = NetUtils.toUri(tones.getString("uri" + idx, ""));
      if(uri==null || uri.toString().length()==0) {
        uri=null;
      }
      String title = tones.getString("title"+idx, "");
      if(Util.isNoE(title)){
        if(uri==null)
          title=null;
        else
          title=uri.getQueryParameter("title");
      }
      data[idx].mUri=uri;
      data[idx].mTitle=title;
    }
    return data;
  }

  public void store() {
    SharedPreferences tones = prefs();
    Editor edit = tones.edit();
    for (int idx = 0; idx < mData.length; idx++) {
      String text = mData[idx].mUri == null ? "" : mData[idx].mUri.toString();
      String title = mData[idx].mTitle == null ? "" : mData[idx].mTitle;
      String tkey="title"+idx;
      String ukey = "uri" + idx;
      if(Util.isNoE(text) || Util.isNoE(title)) {
        edit.remove(ukey);
        edit.remove(tkey);
      } else {
        edit.putString(ukey,text);
        edit.putString(tkey,title);
      }
    }
    edit.apply();
    restore();
  }


  @Override
  public void onViewCreated(@NonNull final View view, @Nullable final Bundle savedInstanceState) {
    super.onViewCreated(view, savedInstanceState);
    mView = view;
    mDone = mView.findViewById(R.id.btn_done);
    mDone.setOnClickListener(this::onDoneButtonClicked);
    restore();

    mRingtoneManager = new RingtoneManager(getActivity());
  }

  private void onDoneButtonClicked(final View view) {
    store();
    for (final RingtoneData datum : mData) {
      if (datum.mUri == null) {
        datum.mUri = RingtoneManager.getActualDefaultRingtoneUri(getContext(),
          RingtoneManager.TYPE_ALARM);
      }
    }
    store();
    BaseApp app = BaseApp.get();
    app.updateRingtones();
  }

  private void setup() {
    setup(0, R.id.txt_alert_ringtone, R.id.btn_alert_ringtone, R.id.btn_faux_alert);
    setup(1, R.id.txt_request_ringtone, R.id.btn_request_ringtone, R.id.btn_faux_request);
    setup(2, R.id.txt_chat_ringtone, R.id.btn_chat_ringtone, R.id.btn_faux_chat);
  }

  private void onButtonClicked(final View view) {
    mIdx = (int) (Integer) view.getTag();
    mLauncher.launch(mData[mIdx]);
  }

  public static class PickRingtone extends ActivityResultContract<RingtoneData, Uri> {
    @NonNull
    @Override
    public Intent createIntent(@NonNull Context context, @NonNull RingtoneData ringtoneType) {
      Intent intent = new Intent(ACTION_RINGTONE_PICKER);
      intent.putExtra(EXTRA_RINGTONE_EXISTING_URI, ringtoneType.mUri);
//      intent.putExtra(EXTRA_RINGTONE_TYPE, ringtoneType.mType);
      return intent;
    }

    @Override
    public Uri parseResult(int resultCode, @Nullable Intent result) {
      if (resultCode != Activity.RESULT_OK || result == null) {
        return null;
      }

      return result.getParcelableExtra(RingtoneManager.EXTRA_RINGTONE_PICKED_URI);
    }
  }
}
