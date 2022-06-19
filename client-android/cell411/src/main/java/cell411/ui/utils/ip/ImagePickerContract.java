package cell411.ui.utils.ip;

import static android.app.Activity.RESULT_OK;

import android.content.Context;
import android.content.Intent;

import androidx.activity.result.ActivityResultCaller;
import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContract;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.ArrayList;

public class ImagePickerContract extends ActivityResultContract<PicPrefs, Integer> {
  protected final ActivityResultCaller mCaller;
  protected ActivityResultLauncher<PicPrefs> mLauncher;
  private PicPrefs mPrefs;
  static ArrayList<PicPrefs> smPicPrefs = new ArrayList<>();

  public ImagePickerContract(ActivityResultCaller caller, Callback callback) {
    mCaller = caller;
    mLauncher =
      mCaller.registerForActivityResult(this, callback);
  }

  public static PicPrefs claimPicPref(final int index) {
    PicPrefs res = smPicPrefs.get(index);
    smPicPrefs.set(index,null);
    return res;
  }

  public static int checkPicPrefs(final PicPrefs picPrefs) {
    int index = smPicPrefs.size();
    smPicPrefs.add(picPrefs);
    return index;
  }

  @NonNull
  public Intent createIntent(@NonNull Context context, PicPrefs prefs) {
    Intent intent = new Intent(context, ImagePickerActivity.class);
    prefs.addToIntent(intent);
    return intent;
  }


  @Override
  public Integer parseResult(int resultCode,
                         @Nullable Intent intent) {
    if (resultCode == RESULT_OK)
    {
      int index=-1;
      if(intent!=null)
        index = intent.getIntExtra("index", index);
      if(index<0) {
        index=smPicPrefs.size();
        smPicPrefs.add(mPrefs);
      }
      return index;
    } else {
      return null;
    }
  }

  public void launch(PicPrefs prefs) {
    mPrefs = prefs;
    mLauncher.launch(prefs);
  }

}
