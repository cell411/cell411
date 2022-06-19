/*
 * Copyright (c) 2015-present, Parse, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

package com.parse.http;

import android.os.Build;
import androidx.annotation.NonNull;
import com.parse.Parse;
import com.parse.android.ManifestInfo;
import com.parse.controller.ParsePlugins;
import okhttp3.Headers;
import okhttp3.Request;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

/**
 * The http request we send to com.parse server. Instances of this class are not immutable. The
 * request body may be consumed only once. The other fields are immutable.
 */
@SuppressWarnings("unused")
public final class ParseHttpRequest {

  private static final String installationId = ParsePlugins.get().installationId().get();
  private static final String userAgent = ParsePlugins.userAgent();

  private final String url;
  private final ParseHttpMethod method;
  private final Map<String, String> headers;
  private final ParseHttpBody body;
  private ParseHttpRequest(Builder builder) {
    this.url = builder.url;
    this.method = builder.method;
    this.headers = Collections.unmodifiableMap(new HashMap<>(builder.headers));
    this.body = builder.body;
  }
  @NonNull
  public static Request getRequest(ParseHttpRequest parseRequest) {
    Request.Builder okHttpRequestBuilder = new Request.Builder();
    ParseHttpMethod method = parseRequest.getMethod();
    // Set method
    switch (method) {
      case GET:
        okHttpRequestBuilder.get();
        break;
      case DELETE:
      case POST:
      case PUT:
        // Since we need to set body and method at the same time for DELETE, POST, PUT, we will do it in
        // the following.
        break;
      default:
        // This case will never be reached since we have already handled this case in
        // ParseRequest.newRequest().
        throw new IllegalStateException("Unsupported http method " + method);
    }
    // Set url
    okHttpRequestBuilder.url(parseRequest.getUrl());

    // Set Header
    Headers.Builder okHttpHeadersBuilder = new Headers.Builder();
    for (Map.Entry<String, String> entry : parseRequest.getAllHeaders().entrySet()) {
      okHttpHeadersBuilder.add(entry.getKey(), entry.getValue());
    }
    // OkHttp automatically add gzip header, so we do not need to deal with it
    Headers okHttpHeaders = okHttpHeadersBuilder.build();
    okHttpRequestBuilder.headers(okHttpHeaders);

    // Set Body
    ParseHttpBody parseBody = parseRequest.getBody();
    ParseOkHttpRequestBody okHttpRequestBody = null;
    if (parseBody != null) {
      okHttpRequestBody = new ParseOkHttpRequestBody(parseBody);
    }
    switch (method) {
      case PUT:
        assert okHttpRequestBody != null;
        okHttpRequestBuilder.put(okHttpRequestBody);
        break;
      case POST:
        assert okHttpRequestBody != null;
        okHttpRequestBuilder.post(okHttpRequestBody);
        break;
      case DELETE:
        okHttpRequestBuilder.delete(okHttpRequestBody);
    }
    return okHttpRequestBuilder.build();
  }
  @NonNull
  public static Request customizeRequest(
      @NonNull Request request, @NonNull Parse.Configuration configuration
  ) {

    Headers.Builder builder = request.headers().newBuilder();
    builder.set(ParseHttpHeader.HEADER_APPLICATION_ID, configuration.applicationId)
           .set(ParseHttpHeader.HEADER_APP_BUILD_VERSION, String.valueOf(ManifestInfo.getVersionCode()))
           .set(ParseHttpHeader.HEADER_APP_DISPLAY_VERSION, ManifestInfo.getVersionName())
           .set(ParseHttpHeader.HEADER_OS_VERSION, Build.VERSION.RELEASE)
           .set(ParseHttpHeader.USER_AGENT, userAgent);
    if (request.header(ParseHttpHeader.HEADER_INSTALLATION_ID) == null) {
      // We can do this synchronously since the caller is already on a background thread
      builder.set(ParseHttpHeader.HEADER_INSTALLATION_ID, installationId);
    }
    // client key can be null with self-hosted Parse Server
    if (configuration.clientKey != null) {
      builder.set(ParseHttpHeader.HEADER_CLIENT_KEY, configuration.clientKey);
    }
    request = request.newBuilder().headers(builder.build()).build();
    return request;
  }

  /**
   * Gets the url of this {@code ParseHttpRequest}.
   *
   * @return The url of this {@code ParseHttpRequest}.
   */
  public String getUrl() {
    return url;
  }

  /**
   * Gets the {@code Method} of this {@code ParseHttpRequest}.
   *
   * @return The {@code Method} of this {@code ParseHttpRequest}.
   */
  public ParseHttpMethod getMethod() {
    return method;
  }

  /**
   * Gets all headers from this {@code ParseHttpRequest}.
   *
   * @return The headers of this {@code ParseHttpRequest}.
   */
  public Map<String, String> getAllHeaders() {
    return headers;
  }

  /**
   * Retrieves the header value from this {@code ParseHttpRequest} by the given header name.
   *
   * @param name The name of the header.
   * @return The value of the header.
   */
  public String getHeader(String name) {
    return headers.get(name);
  }

  /**
   * Gets http body of this {@code ParseHttpRequest}.
   *
   * @return The http body of this {@code ParseHttpRequest}.
   */
  public ParseHttpBody getBody() {
    return body;
  }

  /**
   * Builder of {@code ParseHttpRequest}.
   */
  public static final class Builder {

    private String url;
    private ParseHttpMethod method;
    private Map<String, String> headers;
    private ParseHttpBody body;

    /**
     * Creates an empty {@code Builder}.
     */
    public Builder() {
      this.headers = new HashMap<>();
    }

    /**
     * Creates a new {@code Builder} based on the given {@code ParseHttpRequest}.
     *
     * @param request The {@code ParseHttpRequest} where the {@code Builder}'s values come from.
     */
    public Builder(ParseHttpRequest request) {
      this.url = request.url;
      this.method = request.method;
      this.headers = new HashMap<>(request.headers);
      this.body = request.body;
    }

    /**
     * Sets the url of this {@code Builder}.
     *
     * @param url The url of this {@code Builder}.
     * @return This {@code Builder}.
     */
    public Builder setUrl(String url) {
      this.url = url;
      return this;
    }

    /**
     * Sets the {@link ParseHttpMethod} of this {@code Builder}.
     *
     * @param method The {@link ParseHttpMethod} of this {@code Builder}.
     * @return This {@code Builder}.
     */
    public Builder setMethod(ParseHttpMethod method) {
      this.method = method;
      return this;
    }

    /**
     * Sets the {@link ParseHttpBody} of this {@code Builder}.
     *
     * @param body The {@link ParseHttpBody} of this {@code Builder}.
     * @return This {@code Builder}.
     */
    public Builder setBody(ParseHttpBody body) {
      this.body = body;
      return this;
    }

    /**
     * Adds a header to this {@code Builder}.
     *
     * @param name  The name of the header.
     * @param value The value of the header.
     * @return This {@code Builder}.
     */
    public Builder addHeader(String name, String value) {
      headers.put(name, value);
      return this;
    }

    /**
     * Adds headers to this {@code Builder}.
     *
     * @param headers The headers that need to be added.
     * @return This {@code Builder}.
     */
    public Builder addHeaders(Map<String, String> headers) {
      this.headers.putAll(headers);
      return this;
    }

    /**
     * Sets headers of this {@code Builder}. All existing headers will be cleared.
     *
     * @param headers The headers of this {@code Builder}.
     * @return This {@code Builder}.
     */
    public Builder setHeaders(Map<String, String> headers) {
      this.headers = new HashMap<>(headers);
      return this;
    }

    /**
     * Builds a {@link ParseHttpRequest} based on this {@code Builder}.
     *
     * @return A {@link ParseHttpRequest} built on this {@code Builder}.
     */
    public ParseHttpRequest build() {
      return new ParseHttpRequest(this);
    }
  }
}

