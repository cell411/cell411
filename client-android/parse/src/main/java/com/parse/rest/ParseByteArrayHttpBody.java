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
import com.parse.http.ParseHttpBody;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.UnsupportedEncodingException;
import java.nio.charset.StandardCharsets;

class ParseByteArrayHttpBody extends ParseHttpBody {
  /* package */ final byte[] content;
  /* package */ final InputStream contentInputStream;

  public ParseByteArrayHttpBody(String content, String contentType, ParseRESTCommand parseRESTCommand)
      throws UnsupportedEncodingException
  {
    this(content.getBytes(StandardCharsets.UTF_8), contentType, parseRESTCommand);
  }
  public ParseByteArrayHttpBody(byte[] content, String contentType, ParseRESTCommand parseRESTCommand) {
    super(contentType, content.length);
    this.content = content;
    this.contentInputStream = new ByteArrayInputStream(content);
  }
  @NonNull
  public String toString() {
    char[] temp = new char[content.length];
    for (int i = 0; i < temp.length; i++) {
      temp[i] = (char) content[i];
    }
    return new String(temp);
  }
  @Override
  public InputStream getContent() {
    return contentInputStream;
  }

  @Override
  public void writeTo(OutputStream out) throws IOException {
    if (out == null) {
      throw new IllegalArgumentException("Output stream may not be null");
    }

    out.write(content);
  }
}

