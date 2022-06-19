/*
 * Copyright (c) 2015-present, Parse, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

package com.parse;

import android.content.Context;
import android.content.pm.PackageManager;
import android.util.Log;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.parse.boltsinternal.Continuation;
import com.parse.boltsinternal.Task;
import com.parse.controller.ParseCorePlugins;
import com.parse.controller.ParsePlugins;
import com.parse.model.ParseConfig;
import com.parse.model.ParseObject;
import com.parse.model.ParseUser;
import com.parse.offline.OfflineStore;
import com.parse.operation.ParseFieldOperations;
import com.parse.rest.ParseRESTCommand;
import com.parse.rest.ParseRequest;
import com.parse.utils.PLog;
import com.parse.utils.ParseFileUtils;
import okhttp3.OkHttpClient;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.net.MalformedURLException;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.HashSet;
import java.util.Set;

/**
 * The {@code Parse} class contains static functions that handle global configuration for the Parse
 * library.
 */
@SuppressWarnings("unused")
public class Parse {
  public static final int LOG_LEVEL_VERBOSE = Log.VERBOSE;
  public static final int LOG_LEVEL_DEBUG = Log.DEBUG;
  public static final int LOG_LEVEL_INFO = Log.INFO;
  public static final int LOG_LEVEL_WARNING = Log.WARN;
  public static final int LOG_LEVEL_ERROR = Log.ERROR;

  private static Context applicationContext;


  //region LDS
  public static final int LOG_LEVEL_NONE = Integer.MAX_VALUE;
  private static final String TAG = "com.parse.Parse";
  private static final int DEFAULT_MAX_RETRIES = ParseRequest.DEFAULT_MAX_RETRIES;
  private static final Object MUTEX = new Object();
  //region ParseCallbacks
  private static final Object MUTEX_CALLBACKS = new Object();
  private static boolean isLocalDatastoreEnabled;

  //endregion
  private static OfflineStore offlineStore;
  private static Set<ParseCallbacks> callbacks = new HashSet<>();

  // Suppress constructor to prevent subclassing
  private Parse() {
    throw new AssertionError();
  }

  /**
   * Enable pinning in your application. This must be called before your application can use
   * pinning. You must invoke {@code enableLocalDatastore(Context)} before
   * {@link #initialize(Context,Configuration)}:
   * <p/>
   * <pre>
   * public class MyApplication extends Application {
   *   public void onCreate() {
   *     Parse.enableLocalDatastore(this);
   *     Parse.initialize(this);
   *   }
   * }
   * </pre>
   *
   * @param context The active {@link Context} for your application.
   */
  public static void enableLocalDatastore(Context context) {
    if (isInitialized()) {
      throw new IllegalStateException(
          "`Parse#enableLocalDatastore(Context)` must be invoked " + "before `Parse#initialize(Context)`");
    }
    PLog.w(TAG, "Parse.enableDataStore seems to have no effect.");
    isLocalDatastoreEnabled = true;
  }

  static void disableLocalDatastore() {
    setLocalDatastore(null);
    // We need to re-register ParseCurrentInstallationController otherwise it is still offline
    // controller
    ParseCorePlugins.getInstance().reset();
  }

  public static OfflineStore getLocalDatastore() {
    return offlineStore;
  }

  static void setLocalDatastore(OfflineStore offlineStore) {
    Parse.isLocalDatastoreEnabled = offlineStore != null;
    Parse.offlineStore = offlineStore;
  }

  public static boolean isLocalDatastoreEnabled() {
    return isLocalDatastoreEnabled;
  }

  /**
   * Authenticates this client as belonging to your application.
   * This must be called before your
   * application can use the Parse library. The recommended way is to put a call to
   * {@code Parse.initialize} in your {@code Application}'s {@code onCreate} method:
   * <p/>
   * <pre>
   * public class MyApplication extends Application {
   *   public void onCreate() {
   *     Parse.initialize(configuration);
   *   }
   * }
   * </pre>
   *
   * @param configuration The configuration for your application.
   */
  public static void initialize(Context context, Configuration configuration) {
    initialize(context, configuration, null);
  }

  static void initialize(Context context, Configuration configuration, ParsePlugins parsePlugins) {
    if (isInitialized()) {
      PLog.w(TAG, "Parse is already initialized");
      new Exception("Parse is already initialized!").printStackTrace();
      return;
    }
    Parse.applicationContext = context.getApplicationContext();

    // NOTE (richardross): We will need this here, as ParsePlugins uses the return value of
    // isLocalDataStoreEnabled() to perform additional behavior.
    isLocalDatastoreEnabled = configuration.localDataStoreEnabled;

    if (parsePlugins == null) {
      ParsePlugins.initialize(applicationContext, configuration);
    } else {
      ParsePlugins.set(parsePlugins);
    }

    try {
      ParseRESTCommand.server = new URL(configuration.server);
    } catch (MalformedURLException ex) {
      throw new RuntimeException(ex);
    }

    ParseObject.registerParseSubclasses();

//    if (configuration.localDataStoreEnabled) {
//      offlineStore = new OfflineStore(applicationContext);
//    } else {
//      ParseKeyValueCache.initialize(applicationContext.getCacheDir());
//    }

    // Make sure the data on disk for Parse is for the current
    // application.
    checkCacheApplicationId();

    ParseFieldOperations.registerDefaultDecoders();

//    if (!allParsePushIntentReceiversInternal()) {
//      throw new SecurityException("To prevent external tampering to your app's notifications, " +
//                                      "all receivers registered to handle the following actions must have " +
//                                      "their exported attributes set to false: com.parse.push.intent.RECEIVE, " +
//                                      "com.parse.push.intent.OPEN, com.parse.push.intent.DELETE");
//    }

    ParseUser.getCurrentUserAsync().makeVoid().continueWith((Continuation<Void, Void>) task -> {
      // Prime config in the background
      ParseConfig.getCurrentConfig();
      return null;
    }, Task.BACKGROUND_EXECUTOR);

    dispatchOnParseInitialized();

    // FYI we probably don't want to do this if we ever add other callbacks.
    synchronized (MUTEX_CALLBACKS) {
      Parse.callbacks = null;
    }
  }

  //region Server URL
  /**
   * Returns the current server URL.
   */
  public static @Nullable
  String getServer() {
    URL server = ParseRESTCommand.server;
    return server == null ? null : server.toString();
  }
  /**
   * Sets the server URL. The local client cache is not cleared.
   * <p/>
   * This can be used to update the server URL after this client has been initialized, without
   * having to {@link Parse#destroy()} this client. An example use case is server connection failover, where the
   * clients connects to another URL if the server becomes unreachable at the current URL.
   * <p/>
   * @param server The server URL to set.
   */
  public static void setServer(@NonNull String server) {
    try {
      ParseRESTCommand.server = new URL(validateServerUrl(server));
    } catch (MalformedURLException ex) {
      throw new RuntimeException(ex);
    }
  }
  /**
   * Validates the server URL.
   *
   * @param server The server URL to validate.
   * @return The validated server URL.
   */
  private static @Nullable
  String validateServerUrl(@Nullable String server) {

    // Add an extra trailing slash so that Parse REST commands include
    // the path as part of the server URL (i.e. http://api.myhost.com/parse)
    if (server != null && !server.endsWith("/")) {
      server = server + "/";
    }

    return server;
  }

  //endregion

  /**
   * Destroys this client and erases its local data store.
   * Calling this after {@link Parse#initialize} allows you to re-initialize this client with a
   * new configuration. Calling this while server requests are in progress can cause undefined
   * behavior.
   */
  public static void destroy() {
    ParseObject.unregisterParseSubclasses();

    ParseCorePlugins.getInstance().reset();
    ParsePlugins.reset();

    setLocalDatastore(null);
  }

  /**
   * @return {@code True} if {@link #initialize} has been called, otherwise {@code false}.
   */
  public static boolean isInitialized() {
    return ParsePlugins.get() != null;
  }

  public static Context getApplicationContext() {
    return applicationContext;
  }

  static File parseDir;
  static File cacheDir;
  static File filesDir;

  /**
   * Checks that each of the receivers associated with the three actions defined in
   * ParsePushBroadcastReceiver (ACTION_PUSH_RECEIVE, ACTION_PUSH_OPEN, ACTION_PUSH_DELETE) has
   * their exported attributes set to false. If this is the case for each of the receivers
   * registered in the AndroidManifest.xml or if no receivers are registered (because we will be registering
   * the default implementation of ParsePushBroadcastReceiver in PushService) then true is returned.
   * Note: the reason for iterating through lists, is because you can define different receivers
   * in the manifest that respond to the same intents and both all of the receivers will be triggered.
   * So we want to make sure all them have the exported attribute set to false.
   */
//  private static boolean allParsePushIntentReceiversInternal() {
//    List<ResolveInfo> intentReceivers = ManifestInfo.getIntentReceivers(ParsePushBroadcastReceiver.ACTION_PUSH_RECEIVE,
//                                                                        ParsePushBroadcastReceiver.ACTION_PUSH_DELETE,
//                                                                        ParsePushBroadcastReceiver.ACTION_PUSH_OPEN);
//
//    for (ResolveInfo resolveInfo : intentReceivers) {
//      if (resolveInfo.activityInfo.exported) {
//        return false;
//      }
//    }
//    return true;
//  }
  final static Object lock = new Object();

//  /**
//   * @depre cated Please use {@link #getParseCacheDir(String)} or {@link #getParseFilesDir(String)}
//   * instead.
//   */
//  @SuppressWarnings("DeprecatedIsStillUsed")
//  @Deprecated
  public static File getParseDir() {
    synchronized (lock) {
      if (parseDir == null) {
        parseDir = applicationContext.getDir("Parse", Context.MODE_PRIVATE);
      }
      return createFileDir(parseDir);
    }
 }
  public static File getCacheDir() {
    synchronized (lock) {
      if (cacheDir == null) {
        cacheDir = new File(applicationContext.getCacheDir(), "com.parse");
      }
      return createFileDir(cacheDir);
    }
  }
  static File getParseCacheDir() {
    return getCacheDir();
  }

  public static File getParseCacheDir(String subDir) {
    synchronized (MUTEX) {
      File dir = new File(getParseCacheDir(), subDir);
      if (!dir.exists()) {
        //noinspection ResultOfMethodCallIgnored
        dir.mkdirs();
      }
      return dir;
    }
  }
  private static File createFileDir(File file) {
    if (!file.exists()) {
      if (!file.mkdirs()) {
        return file;
      }
    }
    return file;
  }

  @NonNull
  public static File getFilesDir() {
    synchronized (lock) {
      if (filesDir == null) {
        filesDir = new File(applicationContext.getFilesDir(), "com.parse");
      }
      return createFileDir(filesDir);
    }
  }

  static File getParseFileDir(String subDir) {
    synchronized (MUTEX) {
      File dir = new File(getFilesDir(), subDir);
      if (!dir.exists()) {
        //noinspection ResultOfMethodCallIgnored
        dir.mkdirs();
      }
      return dir;
    }
  }

  /**
   * Verifies that the data stored on disk for Parse was generated using the same application that
   * is running now.
   */
  static void checkCacheApplicationId() {
    synchronized (MUTEX) {
      String applicationId = ParsePlugins.get().applicationId();
      if (applicationId != null) {
        File dir = Parse.getParseCacheDir();

        // Make sure the current version of the cache is for this application id.
        File applicationIdFile = new File(dir, "applicationId");
        if (applicationIdFile.exists()) {
          // Read the file
          boolean matches = false;
          try {
            RandomAccessFile f = new RandomAccessFile(applicationIdFile, "r");
            byte[] bytes = new byte[(int) f.length()];
            f.readFully(bytes);
            f.close();
            String diskApplicationId = new String(bytes, StandardCharsets.UTF_8);
            matches = diskApplicationId.equals(applicationId);
          } catch (IOException e) {
            // Hmm, the applicationId file was malformed or something. Assume it
            // doesn't match.
          }

          // The application id has changed, so everything on disk is invalid.
          if (!matches) {
            try {
              ParseFileUtils.deleteDirectory(dir);
            } catch (IOException e) {
              // We're unable to delete the directory...
            }
          }
        }

        // Create the version file if needed.
        applicationIdFile = new File(dir, "applicationId");
        try {
          FileOutputStream out = new FileOutputStream(applicationIdFile);
          out.write(applicationId.getBytes(StandardCharsets.UTF_8));
          out.close();
        } catch (IOException e) {
          // Nothing we can really do about it.
        }
      }
    }
  }

  /**
   * Gets the shared command cache object for all ParseObjects. This command cache is used to
   * locally store save commands created by the ParseObject.saveEventually(). When a new
   * ParseCommandCache is instantiated, it will begin running its run loop, which will start by
   * processing any commands already stored in the on-disk queue.
   */


  /**
   * Used by Parse LiveQuery
   */
  public static void checkInit() {
    if (ParsePlugins.get() == null) {
      throw new RuntimeException("You must call Parse.initialize(Context)" + " before using the Parse library.");
    }

    if (ParsePlugins.get().applicationId() == null) {
      throw new RuntimeException(
          "applicationId is null. " + "You must call Parse.initialize(Context)" + " before using the Parse library.");
    }
  }

  static void checkContext() {
    if (ParsePlugins.get().applicationContext() == null) {
      throw new RuntimeException("applicationContext is null. " + "You must call Parse.initialize(Context)" +
                                     " before using the Parse library.");
    }
  }

  @SuppressWarnings("BooleanMethodIsAlwaysInverted")
  public static boolean hasPermission(String permission) {
    return (getApplicationContext().checkCallingOrSelfPermission(permission) == PackageManager.PERMISSION_GRANTED);
  }

  //endregion

  //region Logging

  public static void requirePermission(String permission) {
    if (!hasPermission(permission)) {
      throw new IllegalStateException(
          "To use this functionality, add this to your AndroidManifest.xml:\n" + "<uses-permission android:name=\"" +
              permission + "\" />");
    }
  }

  /**
   * Registers a listener to be called at the completion of {@link #initialize}.
   * <p>
   * Throws {@link java.lang.IllegalStateException} if called after {@link #initialize}.
   *
   * @param listener the listener to register
   */
  static void registerParseCallbacks(ParseCallbacks listener) {
    if (isInitialized()) {
      throw new IllegalStateException("You must register callbacks before Parse.initialize(Context)");
    }

    synchronized (MUTEX_CALLBACKS) {
      if (callbacks == null) {
        return;
      }
      callbacks.add(listener);
    }
  }

  /**
   * Unregisters a listener previously registered with {@link #registerParseCallbacks}.
   *
   * @param listener the listener to register
   */
  static void unregisterParseCallbacks(ParseCallbacks listener) {
    synchronized (MUTEX_CALLBACKS) {
      if (callbacks == null) {
        return;
      }
      callbacks.remove(listener);
    }
  }

  private static void dispatchOnParseInitialized() {
    ParseCallbacks[] callbacks = collectParseCallbacks();
    if (callbacks != null) {
      for (ParseCallbacks callback : callbacks) {
        callback.onParseInitialized();
      }
    }
  }

  private static ParseCallbacks[] collectParseCallbacks() {
    ParseCallbacks[] callbacks;
    synchronized (MUTEX_CALLBACKS) {
      if (Parse.callbacks == null) {
        return null;
      }
      callbacks = new ParseCallbacks[Parse.callbacks.size()];
      if (Parse.callbacks.size() > 0) {
        callbacks = Parse.callbacks.toArray(callbacks);
      }
    }
    return callbacks;
  }

  /**
   * Returns the level of logging that will be displayed.
   */
  public static int getLogLevel() {
    return PLog.getLogLevel();
  }

  /**
   * Sets the level of logging to display, where each level includes all those below it. The default
   * level is {@link #LOG_LEVEL_NONE}. Please ensure this is set to {@link #LOG_LEVEL_ERROR}
   * or {@link #LOG_LEVEL_NONE} before deploying your app to ensure no sensitive information is
   * logged. The levels are:
   * <ul>
   * <li>{@link #LOG_LEVEL_VERBOSE}</li>
   * <li>{@link #LOG_LEVEL_DEBUG}</li>
   * <li>{@link #LOG_LEVEL_INFO}</li>
   * <li>{@link #LOG_LEVEL_WARNING}</li>
   * <li>{@link #LOG_LEVEL_ERROR}</li>
   * <li>{@link #LOG_LEVEL_NONE}</li>
   * </ul>
   *
   * @param logLevel The level of logcat logging that Parse should do.
   */
  public static void setLogLevel(int logLevel) {
    PLog.setLogLevel(logLevel);
  }

  public static boolean isTrueFalse() {
    return false;
  }

  //endregion

  interface ParseCallbacks {
    void onParseInitialized();
  }

  /**
   * Represents an opaque configuration for the {@code Parse} SDK configuration.
   */
  public static final class Configuration {
    public final String applicationId;
    public final String clientKey;
    public final String server;
    final boolean localDataStoreEnabled;
    public final OkHttpClient.Builder clientBuilder;
    public final int maxRetries;
    private Configuration(Builder builder) {
      this.applicationId = builder.applicationId;
      this.clientKey = builder.clientKey;
      this.server = builder.server;
      this.localDataStoreEnabled = builder.localDataStoreEnabled;
      this.clientBuilder = builder.clientBuilder;
      this.maxRetries = builder.maxRetries;
    }

    /**
     * Allows for simple constructing of a {@code Configuration} object.
     */
    public static final class Builder {
      private String applicationId;
      private String clientKey;
      private String server;
      private boolean localDataStoreEnabled;
      private OkHttpClient.Builder clientBuilder;
      private int maxRetries = DEFAULT_MAX_RETRIES;

      /**
       * Initialize a builder with a given context.
       * <p>
       * This context will then be passed through to the rest of the Parse SDK for use during
       * initialization.
       *
       * @param context The active {@link Context} for your application. Cannot be null.
       */
      public Builder(@NonNull Context context) {
      }

      /**
       * Set the application id to be used by Parse.
       *
       * @param applicationId The application id to set.
       * @return The same builder, for easy chaining.
       */
      public Builder applicationId(String applicationId) {
        this.applicationId = applicationId;
        return this;
      }

      /**
       * Set the client key to be used by Parse.
       *
       * @param clientKey The client key to set.
       * @return The same builder, for easy chaining.
       */
      public Builder clientKey(String clientKey) {
        this.clientKey = clientKey;
        return this;
      }

      /**
       * Set the server URL to be used by Parse.
       *
       * @param server The server URL to set.
       * @return The same builder, for easy chaining.
       */
      public Builder server(String server) {
        this.server = validateServerUrl(server);
        return this;
      }

      /**
       * Enable pinning in your application. This must be called before your application can use
       * pinning.
       *
       * @return The same builder, for easy chaining.
       */
      public Builder enableLocalDataStore() {
        localDataStoreEnabled = true;
        return this;
      }

      private Builder setLocalDatastoreEnabled(boolean enabled) {
        localDataStoreEnabled = enabled;
        return this;
      }

      /**
       * Set the {@link okhttp3.OkHttpClient.Builder} to use when communicating with the Parse
       * REST API
       * <p>
       *
       * @param builder The client builder, which will be modified for compatibility
       * @return The same builder, for easy chaining.
       */
      public Builder clientBuilder(OkHttpClient.Builder builder) {
        clientBuilder = builder;
        return this;
      }

      /**
       * Set the max number of times to retry Parse operations before deeming them a failure
       * <p>
       *
       * @param maxRetries The maximum number of times to retry. <=0 to never retry commands
       * @return The same builder, for easy chaining.
       */
      public Builder maxRetries(int maxRetries) {
        this.maxRetries = maxRetries;
        return this;
      }

      /**
       * Construct this builder into a concrete {@code Configuration} instance.
       *
       * @return A constructed {@code Configuration} object.
       */
      public Configuration build() {
        return new Configuration(this);
      }
    }
  }





  @NonNull
  public File getFilesDir(String str) {
    synchronized (lock) {
      if (filesDir == null) {
        filesDir = new File(applicationContext.getFilesDir(), "com.parse");
      }
      return createFileDir(filesDir);
    }
  }
}

