package com.parse.livequery;

import android.util.Log;

import com.parse.Parse;
import com.parse.codec.ParseDecoder;
import com.parse.controller.ParsePlugins;
import com.parse.model.ParseObject;
import com.parse.ParseQuery;

import cell411.json.JSONException;
import cell411.json.JSONObject;

import java.net.URI;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Locale;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.Executor;

import com.parse.boltsinternal.Continuation;
import com.parse.boltsinternal.Task;
import com.parse.model.ParseUser;
import com.parse.utils.PLog;

import cell411.utils.XLog;
import okhttp3.OkHttpClient;

@SuppressWarnings("unused")
public class ParseLiveQueryClient {
  public final static String TAG = "ParseLiveQueryClient";
  @SuppressWarnings("unused")
  public static class Factory {

    public static ParseLiveQueryClient getClient() {
      return new ParseLiveQueryClient();
    }

    public static ParseLiveQueryClient getClient(WebSocketClientFactory webSocketClientFactory) {
      return new ParseLiveQueryClient(webSocketClientFactory);
    }

    public static ParseLiveQueryClient getClient(URI uri) {
      return new ParseLiveQueryClient(uri);
    }

    public static ParseLiveQueryClient getClient(URI uri, WebSocketClientFactory webSocketClientFactory) {
      return new ParseLiveQueryClient(uri, webSocketClientFactory);
    }

    public static ParseLiveQueryClient getClient(URI uri, WebSocketClientFactory webSocketClientFactory, Executor taskExecutor) {
      return new ParseLiveQueryClient(uri, webSocketClientFactory, taskExecutor);
    }

  }

  private static final String LOG_TAG = "ParseLiveQueryClient";

  private final Executor taskExecutor;
  private final String applicationId;
  private final String clientKey;
  private final ConcurrentHashMap<Integer, Subscription<? extends ParseObject>> subscriptions
    = new ConcurrentHashMap<>();
  private final URI uri;
  private final WebSocketClientFactory webSocketClientFactory;
  private final WebSocketClient.WebSocketClientCallback webSocketClientCallback;

  private final List<ParseLiveQueryClientCallbacks> mCallbacks = new ArrayList<>();

  private WebSocketClient webSocketClient;
  private int requestIdCount = 1;
  private boolean userInitiatedDisconnect = false;
  private boolean hasReceivedConnected = false;

  /* package */ ParseLiveQueryClient() {
    this(getDefaultUri());
  }

  /* package */ ParseLiveQueryClient(URI uri) {
    this(uri, new OkHttp3SocketClientFactory(new OkHttpClient()), Task.BACKGROUND_EXECUTOR);
  }

  /* package */ ParseLiveQueryClient(URI uri, WebSocketClientFactory webSocketClientFactory) {
    this(uri, webSocketClientFactory, Task.BACKGROUND_EXECUTOR);
  }

  /* package */ ParseLiveQueryClient(WebSocketClientFactory webSocketClientFactory) {
    this(getDefaultUri(), webSocketClientFactory, Task.BACKGROUND_EXECUTOR);
  }

  /* package */ ParseLiveQueryClient(URI uri, WebSocketClientFactory webSocketClientFactory, Executor taskExecutor) {
    Parse.checkInit();
    this.uri = uri;
    this.applicationId = ParsePlugins.get().applicationId();
    this.clientKey = ParsePlugins.get().clientKey();
    if(clientKey.equals(applicationId)){
      PLog.i("ParseLiveQueryClient", "That's weird!");
    }
    this.webSocketClientFactory = webSocketClientFactory;
    this.taskExecutor = taskExecutor;
    this.webSocketClientCallback = getWebSocketClientCallback();
  }

  private static URI getDefaultUri() {
    String url = ParsePlugins.get().server();
    if (url.contains("https")) {
      url = url.replaceFirst("https", "wss");
    } else {
      url = url.replaceFirst("http", "ws");
    }
    try {
      return new URI(url);
    } catch (URISyntaxException e) {
      e.printStackTrace();
      throw new RuntimeException(e.getMessage());
    }
  }

  public <T extends ParseObject> SubscriptionHandler<T> subscribe(ParseQuery<T> query) {
    int requestId = requestIdGenerator();
    Subscription<T> subscription = new Subscription<>(requestId, query);
    subscriptions.put(requestId, subscription);

    if (isConnected()) {
      sendSubscription(subscription);
    } else if (userInitiatedDisconnect) {
      Log.w(LOG_TAG, "Warning: The client was explicitly disconnected! You must explicitly call .reconnect() in order to process your subscriptions.");
    } else {
      connectIfNeeded();
    }

    return subscription;
  }

  public void connectIfNeeded() {
    XLog.i(TAG, "connectIfNeeded");
    switch (getWebSocketState()) {
      case CONNECTED:
      case CONNECTING:
      default:
        break;

      case NONE:
      case DISCONNECTING:
      case DISCONNECTED:
        XLog.i(TAG, "connectIfNeeded() => needed");
        reconnect();
        break;


    }
  }

  public <T extends ParseObject> void unsubscribe(final ParseQuery<T> query) {
    if (query != null) {
      for (Subscription<? extends ParseObject> subscription : subscriptions.values()) {
        if (query.equals(subscription.getQuery())) {
          sendUnsubscription(subscription);
        }
      }
    }
  }

  public <T extends ParseObject> void unsubscribe(final ParseQuery<T> query, final SubscriptionHandler<T> subscriptionHandler) {
    if (query != null && subscriptionHandler != null) {
      for (Subscription<? extends ParseObject> subscription : subscriptions.values()) {
        if (query.equals(subscription.getQuery()) && subscriptionHandler.equals(subscription)) {
          sendUnsubscription(subscription);
        }
      }
    }
  }
  public int getOpens() {
    return mOpens;
  }
  int mOpens=0;
  public synchronized void reconnect() {
    XLog.i(TAG, "reconnect");
    mOpens++;
    if (webSocketClient != null) {
      webSocketClient.close();
    }

    userInitiatedDisconnect = false;
    hasReceivedConnected = false;
    webSocketClient = webSocketClientFactory.createInstance(webSocketClientCallback, uri);
    webSocketClient.open();
  }

  public synchronized void disconnect() {
    if (webSocketClient != null) {
      webSocketClient.close();
      webSocketClient = null;
    }

    userInitiatedDisconnect = true;
    hasReceivedConnected = false;
  }

  public void registerListener(ParseLiveQueryClientCallbacks listener) {
    mCallbacks.add(listener);
  }

  public void unregisterListener(ParseLiveQueryClientCallbacks listener) {
    mCallbacks.remove(listener);
  }

  // Private methods

  private synchronized int requestIdGenerator() {
    return requestIdCount++;
  }

  private WebSocketClient.State getWebSocketState() {
    WebSocketClient.State state = webSocketClient == null ? null : webSocketClient.getState();
    return state == null ? WebSocketClient.State.NONE : state;
  }

  private boolean isConnected() {
    return hasReceivedConnected && inAnyState(WebSocketClient.State.CONNECTED);
  }

  private boolean inAnyState(WebSocketClient.State... states) {
    return Arrays.asList(states).contains(getWebSocketState());
  }

  private Task<Void> handleOperationAsync(final String message) {
    return Task.call(() -> {
      parseMessage(message);
      return null;
    }, taskExecutor);
  }

  private Task<Void> sendOperationAsync(final ClientOperation clientOperation) {
    return Task.call(() -> {
      JSONObject jsonEncoded = clientOperation.getJSONObjectRepresentation();
      String jsonString = jsonEncoded.toString(2);
      if (Parse.getLogLevel() <= Parse.LOG_LEVEL_DEBUG) {
        Log.d(LOG_TAG, "Sending over websocket: " + jsonString);
      }
      webSocketClient.send(jsonString);
      return null;
    }, taskExecutor);
  }

  private void parseMessage(String message) throws LiveQueryException {
    try {
      JSONObject jsonObject = new JSONObject(message);
      String rawOperation = jsonObject.getString("op");

      switch (rawOperation) {
        case "connected":
          hasReceivedConnected = true;
          dispatchConnected();
          int size = subscriptions.size();
          Log.v(LOG_TAG,
                format("Connected, sending %d pending subscriptions",size));
          for (Subscription<? extends ParseObject> subscription : subscriptions.values()) {
            sendSubscription(subscription);
          }
          break;
        case "redirect":
          String url = jsonObject.getString("url");
          // TODO: Handle redirect.
          Log.d(LOG_TAG, "Redirect is not yet handled");
          break;
        case "subscribed":
          handleSubscribedEvent(jsonObject);
          break;
        case "unsubscribed":
          handleUnsubscribedEvent(jsonObject);
          break;
        case "enter":
          handleObjectEvent(Subscription.Event.ENTER, jsonObject);
          break;
        case "leave":
          handleObjectEvent(Subscription.Event.LEAVE, jsonObject);
          break;
        case "update":
          handleObjectEvent(Subscription.Event.UPDATE, jsonObject);
          break;
        case "create":
          handleObjectEvent(Subscription.Event.CREATE, jsonObject);
          break;
        case "delete":
          handleObjectEvent(Subscription.Event.DELETE, jsonObject);
          break;
        case "error":
          handleErrorEvent(jsonObject);
          break;
        default:
          throw new LiveQueryException.InvalidResponseException(message);
      }
    } catch (JSONException e) {
      throw new LiveQueryException.InvalidResponseException(message);
    }
  }
  private String format(String s, Object ...args) {
    return String.format(Locale.US, s, args);
  }

  private void dispatchConnected() {
    for (ParseLiveQueryClientCallbacks callback : mCallbacks) {
      callback.onLiveQueryClientConnected(this);
    }
  }

  private void dispatchDisconnected() {
    for (ParseLiveQueryClientCallbacks callback : mCallbacks) {
      callback.onLiveQueryClientDisconnected(this, userInitiatedDisconnect);
    }
  }


  private void dispatchServerError(LiveQueryException exc) {
    for (ParseLiveQueryClientCallbacks callback : mCallbacks) {
      callback.onLiveQueryError(this, exc);
    }
  }

  private void dispatchSocketError(Throwable reason) {
    userInitiatedDisconnect = false;

    for (ParseLiveQueryClientCallbacks callback : mCallbacks) {
      callback.onSocketError(this, reason);
    }

    dispatchDisconnected();
  }

  private <T extends ParseObject> void handleSubscribedEvent(JSONObject jsonObject) throws JSONException {
    final int requestId = jsonObject.getInt("requestId");
    final Subscription<T> subscription = subscriptionForRequestId(requestId);
    if (subscription != null) {
      subscription.didSubscribe(subscription.getQuery());
    }
  }

  private <T extends ParseObject> void handleUnsubscribedEvent(JSONObject jsonObject) throws JSONException {
    final int requestId = jsonObject.getInt("requestId");
    final Subscription<T> subscription = subscriptionForRequestId(requestId);
    if (subscription != null) {
      subscription.didUnsubscribe(subscription.getQuery());
      subscriptions.remove(requestId);
    }
  }

  private <T extends ParseObject> void handleObjectEvent(Subscription.Event event, JSONObject jsonObject) throws JSONException {
    final int requestId = jsonObject.getInt("requestId");
    final Subscription<T> subscription = subscriptionForRequestId(requestId);
    if (subscription != null) {
      T object = ParseObject.fromJSON(jsonObject.getJSONObject("object"), subscription.getQueryState().className(), ParseDecoder.get(), subscription.getQueryState().selectedKeys());
      subscription.didReceive(event, subscription.getQuery(), object);
    }
  }

  private <T extends ParseObject> void handleErrorEvent(JSONObject jsonObject) throws JSONException {
    int requestId = jsonObject.getInt("requestId");
    int code = jsonObject.getInt("code");
    String error = jsonObject.getString("error");
    boolean reconnect = jsonObject.getBoolean("reconnect");
    final Subscription<T> subscription = subscriptionForRequestId(requestId);
    LiveQueryException exc = new LiveQueryException.ServerReportedException(code, error, reconnect);

    if (subscription != null) {
      subscription.didEncounter(exc, subscription.getQuery());
    }

    dispatchServerError(exc);
  }

  private <T extends ParseObject> Subscription<T> subscriptionForRequestId(int requestId) {
    //noinspection unchecked
    return (Subscription<T>) subscriptions.get(requestId);
  }

  private <T extends ParseObject> void sendSubscription(final Subscription<T> subscription) {
    ParseUser.getCurrentSessionTokenAsync().onSuccess((Continuation<String, Void>) task -> {
      String sessionToken = task.getResult();
      SubscribeClientOperation<T> op = new SubscribeClientOperation<>(subscription.getRequestId(), subscription.getQueryState(), sessionToken);

      // dispatch errors
      sendOperationAsync(op).continueWith((Continuation<Void, Void>) task1 -> {
        Exception error = task1.getError();
        if (error != null) {
          if (error instanceof RuntimeException) {
            subscription.didEncounter(new LiveQueryException.UnknownException(
              "Error when subscribing", (RuntimeException) error), subscription.getQuery());
          }
        }
        return null;
      });
      return null;
    });
  }

  private <T extends ParseObject> void sendUnsubscription(Subscription<T> subscription) {
    sendOperationAsync(new UnsubscribeClientOperation(subscription.getRequestId()));
  }

  private WebSocketClient.WebSocketClientCallback getWebSocketClientCallback() {
    return new WebSocketClient.WebSocketClientCallback() {
      @Override
      public void onOpen() {
        hasReceivedConnected = false;
        Log.v(LOG_TAG, "Socket opened");
        ParseUser.getCurrentSessionTokenAsync().onSuccessTask(task -> {
          String sessionToken = task.getResult();
          return sendOperationAsync(new ConnectClientOperation(applicationId, sessionToken));
        }).continueWith((Continuation<Void, Void>) task -> {
          Exception error = task.getError();
          if (error != null) {
            Log.e(LOG_TAG, "Error when connection client", error);
          }
          return null;
        });
      }

      @Override
      public void onMessage(String message) {
        Log.v(LOG_TAG, "Socket onMessage " + message);
        handleOperationAsync(message).continueWith((Continuation<Void, Void>) task -> {
          Exception error = task.getError();
          if (error != null) {
            Log.e(LOG_TAG, "Error handling message", error);
          }
          return null;
        });
      }

      @Override
      public void onClose() {
        Log.v(LOG_TAG, "Socket onClose");

        hasReceivedConnected = false;
        dispatchDisconnected();
      }

      @Override
      public void onError(Throwable exception) {
        PLog.e(LOG_TAG, "Socket onError", exception);
        hasReceivedConnected = false;
        dispatchSocketError(exception);
      }

      @Override
      public void stateChanged() {
        PLog.v(LOG_TAG, "Socket stateChanged");
      }
    };
  }
}
