package com.parse.http;
/*
 * Copyright (c) 2015-present, Parse, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */


import androidx.annotation.NonNull;
import com.parse.http.ParseHttpBody;
import com.parse.http.ParseHttpMethod;
import com.parse.http.ParseHttpRequest;
import com.parse.http.ParseHttpResponse;
import com.parse.rest.ParseHttpClient;
import com.parse.utils.PLog;
import com.parse.ParseException;
import com.parse.controller.ParsePlugins;
import com.parse.boltsinternal.Continuation;
import com.parse.boltsinternal.Task;
import com.parse.boltsinternal.TaskCompletionSource;
import com.parse.callback.ProgressCallback;
import com.parse.utils.ParseExecutors;

import java.io.IOException;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.ThreadFactory;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * A helper object to send requests to the server.
 */

public class ParseHttpHeader {
  public static final String HEADER_APPLICATION_ID = "X-Parse-Application-Id";
  public static final String HEADER_CLIENT_KEY = "X-Parse-Client-Key";
  public static final String HEADER_APP_BUILD_VERSION = "X-Parse-App-Build-Version";
  public static final String HEADER_APP_DISPLAY_VERSION = "X-Parse-App-Display-Version";
  public static final String HEADER_OS_VERSION = "X-Parse-OS-Version";
  public static final String HEADER_INSTALLATION_ID = "X-Parse-Installation-Id";
  public static final String USER_AGENT = "User-Agent";
  public static final String HEADER_SESSION_TOKEN = "X-Parse-Session-Token";
  public static final String HEADER_MASTER_KEY = "X-Parse-Master-Key";
  public static final String PARAMETER_METHOD_OVERRIDE = "_method";
}
