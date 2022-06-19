package cell411.streamer;

import android.app.Dialog;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.BaseAdapter;
import android.widget.ListView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.DialogFragment;


import java.io.Serializable;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.function.Function;

import cell411.streamer.api.utils.Resolution;
import cell411.utils.Collect;

/**
 * Created by faraway on 2/3/15.
 */
public class CameraResolutionsFragment extends DialogFragment {
  private static final String                     CAMERA_RESOLUTIONS   = "CAMERA_RESOLUTIONS";
  private static final String                     SELECTED_SIZE_WIDTH  = "SELECTED_SIZE_WIDTH";
  private static final String                     SELECTED_SIZE_HEIGHT = "SELECTED_SIZE_HEIGHT";
  private final        ResAdapter                 mResolutionAdapter   = new ResAdapter();
  private final        ArrayList<Resolution>      mCameraResolutions   = new ArrayList<>();
  private final        Function<Resolution, Void> mResolutionnListener;
  private              ListView                   mCameraResolutionsListView;
  private              Dialog                     mDialog;
  private              int                        mSelectedSizeWidth;
  private              int                        mSelectedSizeHeight;

  public CameraResolutionsFragment(Function<Resolution, Void> resolutionnListener) {
    mResolutionnListener = resolutionnListener;
  }

  @Nullable @Override public Dialog getDialog() {
    return mDialog;
  }

  public void setCameraResolutions(ArrayList<Resolution> cameraResolutions, Resolution selectedSize)
  {
    Collect.replaceAll(this.mCameraResolutions, cameraResolutions);
    this.mSelectedSizeWidth = selectedSize.width;
    this.mSelectedSizeHeight = selectedSize.height;
    mResolutionAdapter.setCameraResolutions(mCameraResolutions);
  }

  @Override public void onSaveInstanceState(@NonNull Bundle outState) {
    super.onSaveInstanceState(outState);
    outState.putSerializable(CAMERA_RESOLUTIONS, mCameraResolutions);
    outState.putInt(SELECTED_SIZE_WIDTH, mSelectedSizeWidth);
    outState.putInt(SELECTED_SIZE_HEIGHT, mSelectedSizeHeight);
  }

  private void restoreState(Bundle savedInstanceState) {
    if (savedInstanceState != null) {
      if (savedInstanceState.containsKey(CAMERA_RESOLUTIONS)) {
        Serializable serializable = savedInstanceState.getSerializable(CAMERA_RESOLUTIONS);
        Collect.replaceAll(this.mCameraResolutions, Arrays.asList((Resolution[]) serializable));
      }
      if (savedInstanceState.containsKey(SELECTED_SIZE_WIDTH) && savedInstanceState.containsKey(SELECTED_SIZE_WIDTH)) {
        mSelectedSizeWidth = savedInstanceState.getInt(SELECTED_SIZE_WIDTH);
        mSelectedSizeHeight = savedInstanceState.getInt(SELECTED_SIZE_HEIGHT);
      }
      mResolutionAdapter.setCameraResolutions(mCameraResolutions);
    }
  }

  @Nullable @Override public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState)
  {
    restoreState(savedInstanceState);
    View v = inflater.inflate(R.layout.layout_camera_resolutions, container, false);
    mCameraResolutionsListView = v.findViewById(R.id.camera_resolutions_listview);
    mCameraResolutionsListView.setAdapter(mResolutionAdapter);
    mCameraResolutionsListView.setOnItemClickListener(this::onItemClick);
    mCameraResolutionsListView.setChoiceMode(ListView.CHOICE_MODE_SINGLE);
    mDialog = getDialog();
    return v;
  }

  public void onItemClick(AdapterView<?> adapterView, View view, int i, long l)
  {
    mResolutionnListener.apply(mResolutionAdapter.getItem(i));
  }

  class ResAdapter extends BaseAdapter {
    ArrayList<Resolution> mCameraResolutions;

    public void setCameraResolutions(ArrayList<Resolution> cameraResolutions) {
      this.mCameraResolutions = cameraResolutions;
    }

    @Override public int getCount() {
      return mCameraResolutions.size();
    }

    @Override public Resolution getItem(int i) {
      //reverse order. Highest resolution is at top
      return mCameraResolutions.get(getCount() - 1 - i);
    }

    @Override public long getItemId(int i) {
      return i;
    }

    @Override public View getView(int i, View convertView, ViewGroup viewGroup) {
      ViewHolder holder;
      if (convertView == null) {
        LayoutInflater inflater = getLayoutInflater();
        convertView = inflater.inflate(android.R.layout.simple_list_item_single_choice, viewGroup, false);
        holder = new ViewHolder();
        holder.resolutionText = convertView.findViewById(android.R.id.text1);
        convertView.setTag(holder);
      } else {
        holder = (ViewHolder) convertView.getTag();
      }
      //reverse order. Highest resolution is at top
      Resolution size = getItem(i);
      if (size.width == mSelectedSizeWidth && size.height == mSelectedSizeHeight) {
        {
          mCameraResolutionsListView.setItemChecked(i, true);
        }
      }
      String resolutionText = size.width + " x " + size.height;
      // adding auto resolution adding it to the first
      holder.resolutionText.setText(resolutionText);
      return convertView;
    }

    public class ViewHolder {
      public TextView resolutionText;
    }
  }
}
