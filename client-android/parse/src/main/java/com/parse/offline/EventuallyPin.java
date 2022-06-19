/*
 * Copyright (c) 2015-present, Parse, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

package com.parse.offline;

import com.parse.ParseClassName;
import com.parse.model.ParseObject;
import com.parse.rest.ParseRESTCommand;

import cell411.json.JSONException;
import cell411.json.JSONObject;

/**
 * Properties
 * - time
 * Used for sort order when querying for all EventuallyPins
 * - type
 * TYPE_SAVE or TYPE_DELETE
 * - object
 * The object that the operation should notify when complete
 * - operationSetUUID
 * The operationSet to be completed
 * - sessionToken
 * The user that instantiated the operation
 */
@ParseClassName("_EventuallyPin")
public class EventuallyPin extends ParseObject {

  public EventuallyPin() {
    super("_EventuallyPin");
  }


  @Override
  public boolean needsDefaultACL() {
    return false;
  }


  public int getType() {
    return getInt("type");
  }

  public ParseObject getObject() {
    return getParseObject("object");
  }

  public String getSessionToken() {
    return getString("sessionToken");
  }

  public ParseRESTCommand getCommand() throws JSONException {
    JSONObject json = getJSONObject("command");
    ParseRESTCommand command = null;
    assert json!=null;
    if (ParseRESTCommand.isValidCommandJSONObject(json)) {
      command = ParseRESTCommand.fromJSONObject(json);
    } else if (!ParseRESTCommand.isValidOldFormatCommandJSONObject(json)) {
      throw new JSONException("Failed to load command from JSON.");
    }
    return command;
  }
}

