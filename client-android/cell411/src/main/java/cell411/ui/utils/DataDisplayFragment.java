package cell411.ui.utils;

import static cell411.base.BaseApp.isUIThread;

import android.os.Bundle;
import android.view.View;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.safearx.cell411.R;

import cell411.base.BaseFragment;
import cell411.logic.LiveQueryService;
import cell411.utils.PrintString;

public class DataDisplayFragment extends BaseFragment
{
  TextView mText;
  public DataDisplayFragment()
  {
    super(R.layout.fragment_data_display);
  }

  @Override
  public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
    super.onViewCreated(view, savedInstanceState);
    mText = view.findViewById(R.id.text);
    onDS(this::gatherDataData);
  }

  private void gatherDataData() {
    PrintString ps = new PrintString();
    LiveQueryService lqs = lqs();
    lqs.requestDataReport(ps);

    String text = mText.getText()+toString();
    text = text + ps;
    mText.setText(text);
  }
}
