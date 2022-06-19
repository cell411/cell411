package cell411.ui.chats;

import androidx.annotation.LayoutRes;
import com.safearx.cell411.R;

enum ChatViewType {
  VIEW_TYPE_RECEIVED(R.layout.cell_msg_received),
  VIEW_TYPE_DATE(R.layout.cell_date),
  VIEW_TYPE_RECEIVED_LOCATION(R.layout.cell_msg_received_loc),
  VIEW_TYPE_RECEIVED_IMAGE(R.layout.cell_msg_received_img),
  VIEW_TYPE_SENT(R.layout.cell_msg_sent),
  VIEW_TYPE_SENT_LOCATION(R.layout.cell_msg_sent_loc),
  VIEW_TYPE_SENT_IMAGE(R.layout.cell_msg_sent_img);

  final @LayoutRes
  int mLayout;
  ChatViewType(@LayoutRes int layout) {
    mLayout = layout;
  }
  public static ChatViewType valueOf(int iViewType) {
    return values()[iViewType];
  }
  @LayoutRes
  int getLayout() {
    return mLayout;
  }
}
