/*
 * Copyright (c) 2015-present, Parse, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

package com.parse.controller;

import android.content.Context;
import android.os.Build;
import android.util.Log;
import androidx.annotation.NonNull;
import com.parse.Parse;
import com.parse.http.ParseHttpRequest;
import com.parse.offline.InstallationId;
import com.parse.rest.ParseHttpClient;
import okhttp3.OkHttpClient;
import okhttp3.Request;

import java.io.File;

/**
 * Public for LiveQuery. You probably don't need access
 */
public class ParsePlugins {

  private static final String INSTALLATION_ID_LOCATION = "installationId";

  private static final Object LOCK = new Object();
  private static ParsePlugins instance;
  public final String TAG = ParsePlugins.class.getSimpleName();
  final Object lock = new Object();
  private final Parse.Configuration configuration;
  File parseDir;
  File cacheDir;
  File filesDir;
  ParseHttpClient restClient;
  ParseHttpClient fileClient;
  private Context applicationContext;
  private InstallationId installationId;

  private ParsePlugins(Context context, Parse.Configuration configuration) {
    if (context != null) {
      applicationContext = context.getApplicationContext();
    }
    this.configuration = configuration;
  }
  public static void initialize(Context context, Parse.Configuration configuration) {
    ParsePlugins.set(new ParsePlugins(context, configuration));
  }

  public static void set(ParsePlugins plugins) {
    synchronized (LOCK) {
      if (instance != null) {
        throw new IllegalStateException("ParsePlugins is already initialized");
      }
      instance = plugins;
    }
  }
  public static ParsePlugins get() {
    synchronized (LOCK) {
      return instance;
    }
  }
  @SuppressWarnings("unused")
  public static void reset() {
    synchronized (LOCK) {
      instance = null;
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
  public String applicationId() {
    return configuration.applicationId;
  }
  @SuppressWarnings("unused")
  public String clientKey() {
    return configuration.clientKey;
  }
  public String server() {
    return configuration.server;
  }
  public Parse.Configuration configuration() {
    return configuration;
  }
  @SuppressWarnings("unused")
  public Context applicationContext() {
    return applicationContext;
  }
  public ParseHttpClient fileClient() {
    synchronized (lock) {
      if (fileClient == null) {
        fileClient = ParseHttpClient.createClient(configuration.clientBuilder);
      }
      return fileClient;
    }
  }
  public ParseHttpClient restClient() {
    synchronized (lock) {
      if (restClient == null) {
        Log.i(TAG, String.valueOf(OkHttpClient.Builder.class));
        OkHttpClient.Builder clientBuilder = configuration.clientBuilder;
        if (clientBuilder == null) {
          clientBuilder = new OkHttpClient.Builder();
        }
        //add it as the first interceptor
        clientBuilder.interceptors().add(0, chain -> {
          Request request = chain.request();
          request = ParseHttpRequest.customizeRequest(request, configuration);

          return chain.proceed(request);
        });
        restClient = ParseHttpClient.createClient(clientBuilder);
      }
      return restClient;
    }
  }

  public static String userAgent() {
    return "Parse Android SDK API Level " + Build.VERSION.SDK_INT;
  }

  @NonNull
  public InstallationId installationId() {
    synchronized (lock) {
      if (installationId == null) {
        installationId = new InstallationId(new File(getParseDir(), INSTALLATION_ID_LOCATION));
      }
      return installationId;
    }
  }

  @SuppressWarnings("DeprecatedIsStillUsed")
  @Deprecated
  @NonNull
  public File getParseDir() {
    synchronized (lock) {
      if (parseDir == null) {
        parseDir = applicationContext.getDir("Parse", Context.MODE_PRIVATE);
      }
      return createFileDir(parseDir);
    }
  }

  @NonNull
  @SuppressWarnings("unused")
  public File getCacheDir() {
    synchronized (lock) {
      if (cacheDir == null) {
        cacheDir = new File(applicationContext.getCacheDir(), "com.parse");
      }
      return createFileDir(cacheDir);
    }
  }

  @NonNull
  public File getFilesDir() {
    synchronized (lock) {
      if (filesDir == null) {
        filesDir = new File(applicationContext.getFilesDir(), "com.parse");
      }
      return createFileDir(filesDir);
    }
  }
}

