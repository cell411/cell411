/*
 * Copyright (c) 2015-present, Parse, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

package com.parse.rest;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.parse.http.ParseHttpRequest;
import com.parse.http.ParseHttpResponse;
import okhttp3.Call;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;

import java.io.IOException;

/**
 * Internal http client which wraps an {@link OkHttpClient}
 */
public class ParseHttpClient {

  private final OkHttpClient okHttpClient;
  private boolean hasExecuted;

  private ParseHttpClient(@Nullable OkHttpClient.Builder builder) {

    if (builder == null) {
      builder = new OkHttpClient.Builder();
    }

    okHttpClient = builder.build();
  }

  public static ParseHttpClient createClient(@Nullable OkHttpClient.Builder builder) {
    return new ParseHttpClient(builder);
  }

  public final ParseHttpResponse execute(ParseHttpRequest request) throws IOException {
    if (!hasExecuted) {
      hasExecuted = true;
    }
    return executeInternal(request);
  }

  /**
   * Execute internal. Keep default protection for tests
   *
   * @param parseRequest request
   * @return response
   * @throws IOException exception
   */
  ParseHttpResponse executeInternal(ParseHttpRequest parseRequest) throws IOException {
    Request okHttpRequest = getRequest(parseRequest);
    Call okHttpCall = okHttpClient.newCall(okHttpRequest);

    Response okHttpResponse = okHttpCall.execute();

    return ParseHttpResponse.getResponse(okHttpResponse);
  }

  @NonNull
  public static Request getRequest(ParseHttpRequest parseRequest) {
    return ParseHttpRequest.getRequest(parseRequest);
  }

}

