package com.parse.http;

import okhttp3.MediaType;
import okhttp3.RequestBody;
import okio.BufferedSink;

import java.io.IOException;

public class ParseOkHttpRequestBody extends RequestBody {

  private final ParseHttpBody parseBody;

  public ParseOkHttpRequestBody(ParseHttpBody parseBody) {
    this.parseBody = parseBody;
  }

  @Override
  public long contentLength() {
    return parseBody.getContentLength();
  }

  @Override
  public MediaType contentType() {
    String contentType = parseBody.getContentType();
    return contentType == null ? null : MediaType.parse(parseBody.getContentType());
  }

  @Override
  public void writeTo(BufferedSink bufferedSink) throws IOException {
    parseBody.writeTo(bufferedSink.outputStream());
  }
}
