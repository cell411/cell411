package cell411.ui.welcome;

import android.os.Bundle;
import android.view.View;
import android.widget.Button;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.safearx.cell411.R;

import java.util.Arrays;
import java.util.List;

import cell411.base.FragmentFactory;
import cell411.base.SelectFragment;

public class GalleryFragment extends SelectFragment {
  public final static String TAG = GalleryFragment.class.getSimpleName();

  private Button mBtnSignIn;
  private Button mBtnSignUp;
  private final View.OnClickListener mButtonListener = this::onButtonClicked;

  public GalleryFragment() {
    super(R.layout.fragment_gallery);
  }

  @Override
  public List<FragmentFactory> createFactories() {
    return Arrays.asList(
      GalleryImageFragment.makeFactory(0),
      GalleryImageFragment.makeFactory(1),
      GalleryImageFragment.makeFactory(2)
    );
  }


  private void onButtonClicked(View view) {
    if (view == mBtnSignIn) {
      LoginActivity.start(activity());
//      if(mBtnSignIn.getCurrentTextColor()==0xff000000) {
//        mBtnSignIn.setTextColor(0xffffffff);
//      } else {
//        mBtnSignIn.setTextColor(0xff000000);
//      }
    } else if (view == mBtnSignUp) {
      RegisterActivity.start(activity());
//      if(mBtnSignUp.getCurrentTextColor()==0xff000000) {
//        mBtnSignUp.setTextColor(0xffffffff);
//      } else {
//        mBtnSignUp.setTextColor(0xff000000);
//      }
    } else {
      throw new RuntimeException("Unexpected view: " + view);
    }
  }

  @Override
  public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
    super.onViewCreated(view, savedInstanceState);
    mBtnSignIn = view.findViewById(R.id.btn_signin);
    mBtnSignUp = view.findViewById(R.id.btn_signup);
    mBtnSignIn.setOnClickListener(mButtonListener);
    mBtnSignUp.setOnClickListener(mButtonListener);
  }
}
