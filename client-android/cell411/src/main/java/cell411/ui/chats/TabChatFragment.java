package cell411.ui.chats;


import com.safearx.cell411.R;

import java.util.Arrays;
import java.util.List;

import cell411.base.FragmentFactory;
import cell411.base.SelectFragment;
import cell411.ui.utils.DataDisplayFragment;

public class TabChatFragment extends SelectFragment {
  public TabChatFragment() {
    super(R.layout.fragment_tab_chats);
  }
  public List<FragmentFactory> createFactories() {
    return Arrays.asList(
      FragmentFactory.fromClass(ChatRoomsFragment.class, "Chat Rooms"),
      FragmentFactory.fromClass(DataDisplayFragment.class, "Data Display")
    );
  }

}
