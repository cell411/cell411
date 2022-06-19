package cell411.methods;

import android.os.Looper;

import com.parse.ParseException;
import com.parse.ParseQuery;
import com.parse.callback.CountCallback;
import com.parse.model.ParseRelation;
import com.parse.model.ParseUser;

import java.util.ArrayList;
import java.util.List;

import cell411.Cell411;
import cell411.base.BaseApp;
import cell411.parse.XAlert;
import cell411.parse.XUser;
import cell411.utils.Reflect;
import cell411.utils.Util;
import cell411.utils.XLog;

/**
 * Created by Sachin on 01-06-2016.
 */
public class PrivilegeModules {
  private static final String TAG = "PrivilegeModules";

  public static void checkAndUpdatePrivilege(final boolean isAlertCheckRequired) {
    if (Util.isCurrentThread(Looper.getMainLooper())) {
      new Thread(() -> {
        checkAndUpdatePrivilege(isAlertCheckRequired);
      });
      return;
    }
    final XUser currentUser = XUser.getCurrentUser();
    final String privilege = currentUser.getPrivilege();
    if (privilege == null || privilege.equals("FIRST") || privilege.equals("")) {
      // check if user has added at least two friends and has issued an alert to private cell
      // if the above condition is met then he/she can issue alerts globally
      ParseUser user = currentUser;
      ParseRelation<XUser> relFriends = user.getRelation("friends");
      ParseQuery<XUser> query4Friends = relFriends.getQuery();
      query4Friends.countInBackground(new CountCallback() {
        @Override
        public void done(int count, ParseException e) {
          if (e == null) {
            // The count request succeeded. XLog the count
            XLog.i(TAG, "Total Friends: " + count);
            if (count >= 2) {
              if (!isAlertCheckRequired) {
                XUser parseUser = XUser.getCurrentUser();
                parseUser.put("privilege", "SECOND");
                parseUser.saveInBackground();
                return;
              }
              ParseQuery<XAlert> parseQuery4SelfCell411Alerts = ParseQuery.getQuery(XAlert.class);
              parseQuery4SelfCell411Alerts.whereEqualTo("issuedBy", XUser.getCurrentUser());
              parseQuery4SelfCell411Alerts.whereDoesNotExist("cellName");
              parseQuery4SelfCell411Alerts.whereNotEqualTo("isGlobal", true);
              parseQuery4SelfCell411Alerts.whereDoesNotExist("entryFor");
              parseQuery4SelfCell411Alerts.whereDoesNotExist("to");
              parseQuery4SelfCell411Alerts.whereDoesNotExist("cellId");
              parseQuery4SelfCell411Alerts.whereExists("problemType");
              ParseQuery<XAlert> parseQuery4ForwardedCell411Alerts = ParseQuery.getQuery(XAlert.class);
              parseQuery4ForwardedCell411Alerts.whereEqualTo("forwardedBy", XUser.getCurrentUser());
              parseQuery4ForwardedCell411Alerts.whereExists("forwardedAlert");
              parseQuery4ForwardedCell411Alerts.whereNotEqualTo("isGlobal", true);
              parseQuery4ForwardedCell411Alerts.whereDoesNotExist("cellId");
              parseQuery4ForwardedCell411Alerts.whereDoesNotExist("cellName");
              List<ParseQuery<XAlert>> queries = new ArrayList<>();
              queries.add(parseQuery4SelfCell411Alerts);
              queries.add(parseQuery4ForwardedCell411Alerts);
              ParseQuery<XAlert> mainQuery = ParseQuery.or(queries);
              mainQuery.countInBackground(new CountCallback() {
                @Override
                public void done(int count, ParseException e) {
                  if (e == null) {
                    // The count request succeeded. XLog the count
                    XLog.i(TAG, "Total Alerts: " + count);
                    if (count >= 1) {
                      XUser parseUser = XUser.getCurrentUser();
                      parseUser.put("privilege", "SECOND");
                      parseUser.saveInBackground();
                    } else if (privilege == null) {
                      XUser parseUser = XUser.getCurrentUser();
                      parseUser.put("privilege", "FIRST");
                      parseUser.saveInBackground();
                    }
                  }  // The request failed
                }
              });
            } else if (privilege == null) {
              XUser parseUser = XUser.getCurrentUser();
              parseUser.put("privilege", "FIRST");
              parseUser.saveInBackground();
            }
          }  // The request failed
        }
      });
    }
  }

  public static void checkPrivilege() {
    if (Util.isCurrentThread(Looper.getMainLooper())) {
      throw new RuntimeException(Reflect.currentMethodName() + " should not be called on UI thread");
    }
    try {
      final XUser currentUser = XUser.getCurrentUser();
      String privilege = currentUser.getString("privilege");
      XLog.i(TAG, "privilege: " + privilege);
      if (privilege == null) {
        privilege = "FIRST";
        currentUser.put("privilege", privilege);
        currentUser.saveInBackground();
      }
      if (privilege.equals("BANNED") || privilege.contains("SUSPENDED")) {
        // user is permanently banned
        BaseApp.get().logOut();
        return;
      }
      if (privilege.equals("FIRST")) {
        // check if user has added at least two friends and has issued an alert to private cell
        // if the above condition is met then he/she can issue alerts globally
        ParseRelation<XUser> relFriends = currentUser.getRelation("friends");
        ParseQuery<XUser> query4Friends = relFriends.getQuery();
        int count = query4Friends.count();
        XLog.i(TAG, "Total Friends Check: " + count);
        if (count < 2) {
          return;
        }
        ParseQuery<XAlert> parseQuery4SelfCell411Alerts = ParseQuery.getQuery(XAlert.class);
        parseQuery4SelfCell411Alerts.whereEqualTo("issuedBy", currentUser);
        parseQuery4SelfCell411Alerts.whereDoesNotExist("cellName");
        parseQuery4SelfCell411Alerts.whereNotEqualTo("isGlobal", true);
        parseQuery4SelfCell411Alerts.whereDoesNotExist("entryFor");
        parseQuery4SelfCell411Alerts.whereDoesNotExist("to");
        parseQuery4SelfCell411Alerts.whereDoesNotExist("cellId");
        parseQuery4SelfCell411Alerts.whereExists("problemType");
        parseQuery4SelfCell411Alerts.whereExists("targetMembers");
        count = parseQuery4SelfCell411Alerts.count();
        if (count >= 1) {
          currentUser.put("privilege", "SECOND");
        }
        XLog.i(TAG, "Total Alerts Check: " + count);
      }
    } catch (ParseException e) {
      Cell411.get().handleException("checking privilege", e, null);
    } finally {
      XLog.i(TAG, "checkPrivilege done");
    }
  }

}

