package cell411.logic;

import com.parse.ParseException;
import com.parse.livequery.SubscriptionHandler;
import com.parse.model.ParseObject;

public interface LQListener<X extends ParseObject>
{
  default void done(Watcher<X> watcher, ParseException e){
    if(e==null)
      change(watcher);
  }

  default void onEvents(Watcher<X> watcher, SubscriptionHandler.Event event, X object){
    change(watcher);
  }

  void change(Watcher<X> watcher);
}
