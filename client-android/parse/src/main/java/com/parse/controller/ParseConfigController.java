/*
 * Copyright (c) 2015-present, Parse, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

package com.parse.controller;

import com.parse.model.ParseConfig;
import com.parse.rest.ParseHttpClient;
import com.parse.boltsinternal.Continuation;
import com.parse.boltsinternal.Task;
import com.parse.codec.ParseDecoder;
import com.parse.rest.ParseRESTCommand;
import com.parse.rest.ParseRESTConfigCommand;
import cell411.json.JSONObject;

public class ParseConfigController {

  private final ParseHttpClient restClient;
  private final ParseCurrentConfigController currentConfigController;

  public ParseConfigController(
      ParseHttpClient restClient, ParseCurrentConfigController currentConfigController
  )
  {
    this.restClient = restClient;
    this.currentConfigController = currentConfigController;
  }

  /* package */
  public ParseCurrentConfigController getCurrentConfigController() {
    return currentConfigController;
  }

  public Task<ParseConfig> getAsync(String sessionToken) {
    final ParseRESTCommand command = ParseRESTConfigCommand.fetchConfigCommand(sessionToken);
    return command.executeAsync(restClient).onSuccessTask(new Continuation<JSONObject, Task<ParseConfig>>() {
      @Override
      public Task<ParseConfig> then(Task<JSONObject> task) {
        JSONObject result = task.getResult();

        final ParseConfig config = ParseConfig.decode(result, ParseDecoder.get());
        return currentConfigController.setCurrentConfigAsync(config)
                                      .continueWith(new Continuation<Void, ParseConfig>() {
                                        @Override
                                        public ParseConfig then(Task<Void> task) {
                                          return config;
                                        }
                                      });
      }
    });
  }
}

