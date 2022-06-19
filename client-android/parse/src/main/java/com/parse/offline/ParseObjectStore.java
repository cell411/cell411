/*
 * Copyright (c) 2015-present, Parse, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

package com.parse.offline;

import com.parse.model.ParseObject;
import com.parse.boltsinternal.Task;

public interface ParseObjectStore<T extends ParseObject> {
  T get();

  Task<T> getAsync();

  boolean set(T object);

  Task<Void> setAsync(T object);

  boolean exists();

  Task<Boolean> existsAsync();

  void delete();

  Task<Void> deleteAsync();
}

