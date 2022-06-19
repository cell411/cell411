package cell411.logic;

import com.parse.ParseQuery;
import com.parse.livequery.SubscriptionHandler.Event;
import com.parse.model.ParseObject;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashSet;
import java.util.Set;

import cell411.parse.XRequest;
import cell411.parse.XUser;

public class RequestWatcher extends Watcher<XRequest> {
  private static final Set<String> smStatusSet;

  static {
    HashSet<String> statusSet = new HashSet<>(Arrays.asList("PENDING", "RESENT"));
    smStatusSet = Collections.unmodifiableSet(statusSet);
  }

  RequestWatcher(LiveQueryService service) {
    super("Requests", XRequest.class);
  }


  @Override
  void greetObject(XRequest object, ArrayList<ParseObject> list) {
    super.greetObject(object, list);
    checkIn(list, object.getParseObject("sentTo"));
    checkIn(list, object.getParseObject("owner"));
    checkIn(list, object.getParseObject("cell"));
  }

  @Override
  public ParseQuery<XRequest> query() {
    ArrayList<ParseQuery<XRequest>> list = new ArrayList<>();
    ParseQuery<XRequest> query;
    query = XRequest.q();
    query.whereEqualTo("owner", XUser.getCurrentUser());
    list.add(query);
    query = XRequest.q();
    query.whereEqualTo("sentTo", XUser.getCurrentUser());
    query = ParseQuery.or(list);
    query.whereContainedIn("status", smStatusSet);
    return query;
  }

  @Override
  void onEvents(ParseQuery<XRequest> query, Event event, XRequest object) {
    super.onEvents(query, event, object);
  }
}
