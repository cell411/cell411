package cell411.parse.util;

import static cell411.parse.util.XParse.State.GotConsent;
import static cell411.parse.util.XParse.State.GotDataService;
import static cell411.parse.util.XParse.State.GotLiveQueryService;
import static cell411.parse.util.XParse.State.GotPermission;
import static cell411.parse.util.XParse.State.GotRingtones;
import static cell411.parse.util.XParse.State.Initializing;
import static cell411.parse.util.XParse.State.LoggedOut;
import static cell411.parse.util.XParse.State.WaitingForConsent;
import static cell411.parse.util.XParse.State.WaitingForDataService;
import static cell411.parse.util.XParse.State.WaitingForLiveQueryService;
import static cell411.parse.util.XParse.State.WaitingForLocationService;
import static cell411.parse.util.XParse.State.WaitingForLogin;
import static cell411.parse.util.XParse.State.WaitingForPermission;
import static cell411.parse.util.XParse.State.WaitingForRingtones;

import android.os.Handler;
import android.os.Looper;

import com.parse.Parse;
import com.parse.ParseCheater;
import com.parse.ParseCloud;
import com.parse.ParseException;
import com.parse.ParseQuery;
import com.parse.model.ParseObject;
import com.parse.model.ParseUser;

import java.net.InetAddress;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Set;
import java.util.concurrent.Callable;

import cell411.base.BaseApp;
import cell411.parse.XAlert;
import cell411.parse.XChatMsg;
import cell411.parse.XChatRoom;
import cell411.parse.XPrivacyPolicy;
import cell411.parse.XPrivateCell;
import cell411.parse.XPublicCell;
import cell411.parse.XRelationshipUpdate;
import cell411.parse.XRequest;
import cell411.parse.XResponse;
import cell411.parse.XUser;
import cell411.services.R;
import cell411.utils.CarefulHandler;
import cell411.utils.ExceptionHandler;
import cell411.utils.HandlerThreadPlus;
import cell411.utils.ObservableValue;
import cell411.utils.Reflect;
import cell411.utils.SingleSet;
import cell411.utils.Util;
import cell411.utils.ValueObserver;
import cell411.utils.XLog;

public class XParse implements ExceptionHandler {
  public static final String TAG = Reflect.getTag();

  static {
    XLog.i(TAG, "loading class");
  }

  final ArrayList<Runnable> mLogoutActions = new ArrayList<>();
  final ObservableValue<Boolean> mLoggedIn = new ObservableValue<>(false);
  private final LogOutCommand mLogOutCommand = new LogOutCommand();
  private final HandlerThreadPlus smThread =
    HandlerThreadPlus.createThread("XParse Thread");

  ObservableValue<State> smState = new ObservableValue<>(State.Initializing);
  CarefulHandler smHandler;
  OneStateTransition smLastStateTransition;
  private boolean smRunning = false;

  {
    smHandler = new CarefulHandler(smThread.getLooper());
  }


  public XParse() {
  }

  public void onPS(Runnable runnable) {
    onPS(runnable, 0);
  }

  public void onPS(Runnable runnable, long delay) {
    smHandler.postDelayed(runnable, delay);
  }

  public void addObserver(ValueObserver<State> stateValueObserver) {
    smState.addObserver(stateValueObserver);
  }

  public void removeObserver(ValueObserver<State> observer) {
    smState.removeObserver(observer);
  }

  public void signUp(String email, String password, String firstName, String lastName,
                     String mobileNumber, OnCompletionListener listener) {
    AbstractCommand runnable = new AbstractCommand(State.WaitingForLogin) {
      public void call()
        throws Exception
      {
        // avoid a warning.
        if (Util.theGovernmentIsHonest()) {
          throw new Exception();
        }
        try {
          // Check if the mobile number is already registered
          ParseQuery<XUser> userParseQuery = ParseQuery.getQuery("_User");
          userParseQuery.whereEqualTo("mobileNumber", mobileNumber);
          int count = userParseQuery.count();
          if (count != 0) {
            throw new RuntimeException("That number is already in use");
          }
          XUser user = new XUser();
          user.setUsername(email.toLowerCase().trim());
          user.setEmail(email.toLowerCase().trim());
          user.setPassword(password);
          user.put("firstName", firstName.trim());
          user.put("lastName", lastName.trim());
          user.put("mobileNumber", mobileNumber);
          user.put("patrolMode", false);
          user.put("emailVerified", false);
          user.put("roleId", 0);
          user.put("phoneVerified", false);
          user.put("newPublicCellAlert", false);
          user.signUp();
          new Handler(Looper.getMainLooper()).post(() -> listener.done(true));
        } catch (ParseException e) {
          new Handler(Looper.getMainLooper()).post(() -> listener.done(false));
          e.printStackTrace();
        }
      }
    };
    smHandler.post(runnable);
  }

  void oneStep() {
    onPS(new OneStateTransition(), 100);
  }

  public void startup() {
    if (smState.get() == Initializing)
      oneStep();
  }

  public State doSetup() throws Exception {
    if (Util.theGovernmentIsHonest())
      throw new Exception();

    State state = getState();
    switch (state) {
      case Initializing:
      case WaitingForDataService:
        return app().isDataServiceReady() ? GotDataService : WaitingForDataService;
      case GotDataService:
      case WaitingForParse:
        startParse();
        return State.GotParse;
      case GotParse:
      case WaitingForLogin:
        return checkLogin() ? State.GotLogin : WaitingForLogin;

      case GotLogin:
        mLoggedIn.set(true);
      case WaitingForConsent:
        return checkConsent() ? GotConsent : WaitingForConsent;

      case GotConsent:
      case WaitingForPermission:
        return checkPermissions() ? GotPermission : WaitingForPermission;

      case GotPermission:
      case WaitingForLiveQueryService:
        return app().isLiveQueryServiceReady() ? GotLiveQueryService : WaitingForLiveQueryService;

      case GotLiveQueryService:
      case WaitingForRingtones: {
        BaseApp app = BaseApp.get();
        return app.getMissingRingtones().isEmpty() ? GotRingtones : WaitingForRingtones;
      }

      case GotRingtones:
      case Ready:
        return State.Ready;

      case LoggedOut:
      case LoginFailed:
        mLoggedIn.set(false);
        return State.WaitingForLogin;

      default:
        BaseApp.get().showToast("Unexpected state: " + state);
        break;
    }
    return state;
  }

  public void addLoggedInObserver(ValueObserver<Boolean> observer) {
    mLoggedIn.addObserver(observer);
  }

  public void removeLoggedInObserver(ValueObserver<Boolean> observer) {
    mLoggedIn.removeObserver(observer);
  }

  private boolean checkPermissions() {
    if (!app().hasCurrentActivity())
      return false;
    return app().getMissingPermissions().isEmpty();
  }

  private boolean checkConsent() {
    XUser user = XUser.getCurrentUser();
    return user.isCurrentUser() && user.getConsented();
  }

  private void startParse() {
    BaseApp context = BaseApp.get();
    Parse.setLogLevel(Parse.LOG_LEVEL_VERBOSE);
    if (Parse.isInitialized())
      return;

    Parse.Configuration.Builder builder = new Parse.Configuration.Builder(context);

    ParseObject.registerSubclass(XUser.class);
    ParseObject.registerSubclass(XPublicCell.class);
    ParseObject.registerSubclass(XAlert.class);
    ParseObject.registerSubclass(XPrivateCell.class);
    ParseObject.registerSubclass(XPrivacyPolicy.class);
    ParseObject.registerSubclass(XResponse.class);
    ParseObject.registerSubclass(XRequest.class);
    ParseObject.registerSubclass(XChatRoom.class);
    ParseObject.registerSubclass(XChatMsg.class);
    ParseObject.registerSubclass(XRelationshipUpdate.class);

    String app = context.getString(R.string.parse_application_id);
    String url = context.getString(R.string.parse_api_url);
    while (url.endsWith("/"))
      url = url.substring(0, url.length() - 1);
    String flavor = context.getString(R.string.parse_api_flavor);
    while (flavor.startsWith("/"))
      flavor = flavor.substring(1);
    url = url + "/" + flavor + "/";

    builder.applicationId(app).clientKey(context.getString(R.string.parse_client_key))
      .server(url)
      .clientBuilder(app().getClientBuilder());
    Parse.initialize(app(), builder.build());
  }

  private boolean checkLogin() {
    ParseUser user = ParseUser.getCurrentUser();

    if (user == null || !user.isAuthenticated())
      return false;
    if (!app().isConnected())
      return true;

    HashMap<String, Object> params = new HashMap<>();
    try {
      InetAddress[] addresses = InetAddress.getAllByName("dev.copblock.app");
      for (InetAddress address : addresses) {
        XLog.i(TAG, "address: %s", address);
      }
      Boolean res = ParseCloud.run("checkLogin", params);

      XLog.i(TAG, "Calling the checkLogin function");
      if (res) {
        return true;
      }
    } catch (ParseException t) {
      // Bad session token, either we fucked with the database, or the
      // session just timed out.  We need to start over, after forgetting
      // who we were.
      if (t.getCode() == 209) {
        logOut();
        return false;
      }
      handleException("While checking login", t, null);
    } catch (Throwable t) {
      t.printStackTrace();
      handleException("checkingLogin", t);
    }
    return false;
  }

  public void logOut() {
    mLogOutCommand.run();
    oneStep();
  }

  public void logIn(String username, String password, OnCompletionListener listener) {
    if (Util.isNoE(username)) {

      BaseApp.get().showToast("Please enter your email");
      throw new IllegalArgumentException("Email is null or empty");
    }
    if (Util.isNoE(password)) {

      BaseApp.get().showToast("Please enter your password");
      throw new IllegalArgumentException("Password is null or empty");
    }
    smHandler.post(new LogInCommand(username, password, listener));
  }

  public State getState() {
    return smState.get();
  }

  public void deleteUser() {
    XLog.i(TAG, "deleteUser called");
    AbstractCommand runnable = new AbstractCommand(State.Ready) {
      @Override
      public void call() throws Exception
      {
        BaseApp baseApp = BaseApp.get();
        try {
          HashMap<String, Object> params = new HashMap<>();
          Object response = ParseCloud.run("deleteUser", params);
          XLog.i(TAG, "response: " + response);
          logOut();
          baseApp.showToast(baseApp.getString(R.string.toast_msg_account_deleted));
        } catch (Throwable t) {
          baseApp.handleException("deletingUser", t);
        }
      }
    };
    smHandler.post(runnable);
  }

  public String getString(int resId) {
    return app().getString(resId);
  }

  private void abandonSession() {
    try {
      ParseCheater.removeCredentials();
      onPS(ParseCheater::removeCredentials);
      smState.set(LoggedOut);
    } catch (Throwable ignored) {
      // Say nothing, act natural.
    }
  }

  public void maybeOneStep() {
    State state = smState.get();
    smRunning = state.isRunning();
    if (smRunning)
      oneStep();
  }

  public void updatePermissions() {
    if (getState() == WaitingForPermission) {
      oneStep();
    }
  }

  public void updateDataService() {
    if (getState() == WaitingForDataService) {
      oneStep();
    }
  }

  public void updateConsent() {
    if (getState() == WaitingForConsent) {
      oneStep();
    }
  }

  public void updateRingtones() {
    if (getState() == WaitingForRingtones) {
      oneStep();
    }
  }

  public void updateLiveDataService() {
    if (getState() == WaitingForLiveQueryService)
      oneStep();
  }

  // Thus far, we have not needed to add this state, so
  // we just ignore the notificaiton, but it makes things
  // more symetrical.  :)
  public void updateLocationService() {
    if(getState() == WaitingForLocationService)
      oneStep();
  }

  public void registerLogoutAction(Runnable action) {
    mLogoutActions.add(action);
  }

  public boolean isLoggedIn() {
    return mLoggedIn.get();
  }

  public enum State {
    Initializing(false),

    WaitingForDataService(true),
    GotDataService(false),

    WaitingForParse(true),
    GotParse(false),

    WaitingForLogin(true),
    GotLogin(false),

    WaitingForPermission(true),
    GotPermission(false),

    WaitingForConsent(true),
    GotConsent(false),

    WaitingForLiveQueryService(true),
    GotLiveQueryService(false),

    WaitingForLocationService(true),
    GotLocationService(false),

    WaitingForRingtones(true),
    GotRingtones(false),

    Ready(true),

    LoggedOut(false),
    LoginFailed(false);

    final boolean mRunning;

    State(boolean waiting) {
      mRunning = !waiting;
    }

    public boolean isRunning() {
      return mRunning;
    }
  }

  class OneStateTransition implements Runnable {
    public final State mState = getState();

    public OneStateTransition() {
      smLastStateTransition = this;
    }

    @Override
    public void run() {
      XLog.i(TAG, "State: " + mState);
      assert smHandler.getLooper().isCurrentThread();
      if (smLastStateTransition != this)
        return;

      try {
        smState.set(doSetup());
      } catch (Throwable t) {
        t.printStackTrace();
        handleException("While doing setup", t);
      } finally {
        maybeOneStep();
      }
    }
  }

  abstract class AbstractCommand implements Runnable {
    private final Set<State> mPermittedStates;

    public AbstractCommand(Set<State> permittedStates) {
      mPermittedStates = permittedStates;
    }

    public AbstractCommand(State permittedStates) {
      this(permittedStates == null ? null : new SingleSet<>(permittedStates));
    }

    public abstract void call() throws Exception;

    @Override
    public void run() {
      State state = getState();
      if (!smHandler.getLooper().isCurrentThread()) {
        smHandler.post(this);
        return;
      }
      // This is only checked after the post, so you can post one in an illegal
      // state, if you are sure that the state will be legal by the time it
      // runs.
      assertPermittedStates(state);
      try {
        call();
      } catch (Throwable e) {
        handleException("While initializing system", e, null);
      }
    }

    public boolean runsInState(State state) {
      return mPermittedStates == null || mPermittedStates.isEmpty() ||
        mPermittedStates.contains(state);
    }

    private void assertPermittedStates(State state) {
      if (runsInState(state)) {
        return;
      }
      // If mPermittedStates is null, then runsInState should return true.
      assert mPermittedStates != null;
      String plural = "";
      String states;
      StringBuilder builder = new StringBuilder();
      Iterator<State> iterator = mPermittedStates.iterator();
      State first = iterator.next();
      if (iterator.hasNext()) {
        plural = "s";
        builder.append("{ ");
        builder.append(first);
        while (iterator.hasNext()) {
          builder.append(", ").append(iterator.next());
        }
        builder.append(" }");
        states = builder.toString();
      } else {
        states = first.toString();
      }
      throw new IllegalStateException(
        Util.format("Command %s runs in state%s %s, not %s", this, plural, states, state));
    }
  }
  static State smxState;
  class LogOutCommand extends AbstractCommand {
    LogOutCommand() {
      super(smxState);
    }

    @Override
    public void call() throws Exception {
      try {
        for (Runnable runnable : mLogoutActions) {
          runnable.run();
        }
        XUser.logOut();
        abandonSession();
      } catch (Throwable ignored) {
        // say nothing, act natural
      }
      abandonSession();
    }
  }

  class LogInCommand extends AbstractCommand {
    final String mUsername;
    final String mPassword;
    final OnCompletionListener mListener;

    public LogInCommand(String username, String password, OnCompletionListener listener) {
      super(State.WaitingForLogin);
      mUsername = username;
      mPassword = password;
      mListener = listener;
    }

    @Override
    public void call() throws Exception {
      try {
        ParseUser.logIn(mUsername, mPassword);
        onPS(() -> mListener.done(true));
      } catch (ParseException e) {
        // FIXME:  we should deal with the specific issue here.
        handleException("While logging in", e, null);
      } catch (Exception e) {
        e.printStackTrace();
      } finally {
        if (!smRunning) {
          oneStep();
        }
      }
    }
  }
}