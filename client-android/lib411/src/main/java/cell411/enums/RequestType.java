package cell411.enums;

import cell411.utils.Util;

public enum RequestType {
  // Requests are Requests
  FriendRequest(false, false),
  CellJoinRequest(false, false),
  CellRecruitRequest(false, false),
  // Approves and Rejects respond to a request
  FriendApprove(true, false),
  FriendReject(true, false),
  CellJoinApprove(true, false),
  CellJoinReject(true, false),
  // Cancel and Resends manage a request
  CellJoinCancel(false, true),
  CellJoinResend(false, true),
  FriendCancel(false, true),
  FriendResend(false, true),
  ;
  private final boolean mIsResponse;
  private final boolean mIsFollowup;

  RequestType(boolean isResponse, boolean isFollowup) {
    mIsResponse = isResponse;
    mIsFollowup = isFollowup;
  }

  public static RequestType forString(String title) {
    // These are (mostly) all equivelant to the titles
    // of notifications, except that said titles contain
    // spaces.  So remove spaces if there are such, and
    // we can convert the titles directly to the enum.
    String[] parts = title.split("  *");
    if (parts.length > 1) {
      title = Util.join("", parts);
    }
    return valueOf(title);
  }

  public boolean isResponse() {
    return mIsResponse;
  }

  public boolean isFollowup() {
    return mIsFollowup;
  }
}
