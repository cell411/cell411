package cell411.ui.welcome;

import android.content.res.TypedArray;
import android.os.Bundle;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import cell411.Cell411;
import cell411.base.BaseFragment;
import cell411.base.FragmentFactory;

import com.safearx.cell411.R;
import org.jetbrains.annotations.NotNull;

/**
 * Created by Sachin on 15-04-2016.
 */
public class GalleryImageFragment extends BaseFragment {
  private int    imageId;
  private String title;
  private String desc;
  private int    index;

  public GalleryImageFragment() {
    super(R.layout.fragment_gallery_page);
  }
  static TypedArray imageArray  = Cell411.get()
                                         .getResources()
                                         .obtainTypedArray(R.array.gallery_images);
  static String[]   titlesArray = Cell411.get()
                                         .getResources()
                                         .getStringArray(R.array.gallery_titles);
  static              String[]             descArray       = Cell411.get()
                                                                    .getResources()
                                                                    .getStringArray(R.array.gallery_desc);

  static GalleryImageFragment makeFragment(int arg0) {
    Bundle               args     = new Bundle();
    args.putString("title", titlesArray[arg0]);
    args.putString("desc", descArray[arg0]);
    args.putInt("imageId", imageArray.getResourceId(arg0, -1));

    GalleryImageFragment fragment = new GalleryImageFragment();
    fragment.setArguments(args);
    return fragment;
  }
  static FragmentFactory makeFactory(int arg0) {
    return new FragmentFactory() {
      @Override
      public BaseFragment create() {
        return makeFragment(arg0);
      }

      @Override
      public String getTitle() {
        return titlesArray[arg0];
      }
    };
  }

  @Override
  public void onCreate(Bundle savedInstanceState)
  {
    super.onCreate(savedInstanceState);
    Bundle arguments = getArguments();
    if (arguments != null) {
      imageId = arguments.getInt("imageId");
      title   = arguments.getString("title");
      desc    = arguments.getString("desc");
      index   = arguments.getInt("index");
    }
  }
  @Override
  public void onViewCreated(@NonNull @NotNull View view,
                            @Nullable  Bundle savedInstanceState)
  {
    super.onViewCreated(view, savedInstanceState);
    ImageView imgGallery = view.findViewById(R.id.img_gallery);
    TextView  txtTitle   = view.findViewById(R.id.lbl_title);
    TextView  txtDesc    = view.findViewById(R.id.lbl_description);
    View      avatar     = view.findViewById(R.id.avatar);
    View      avatarBG   = view.findViewById(R.id.view_avatag_bg);
    if (index > 0) { // Cell 411 or gallery page other than 1
      if (view instanceof ViewGroup) {
        ViewGroup group = (ViewGroup) view;
        group.removeView(avatar);
        group.removeView(avatarBG);
      } else {
        if(avatar!=null)
          avatar.setVisibility(View.GONE);
        if(avatarBG!=null)
          avatarBG.setVisibility(View.GONE);
      }
    } else {
      if(avatar!=null)
        avatar.setVisibility(View.VISIBLE);
      if(avatarBG!=null)
        avatarBG.setVisibility(View.VISIBLE);
    }
    imgGallery.setImageResource(imageId);
    txtTitle.setText(title);
    txtDesc.setText(desc);

  }
}

