package com.parse.livequery;

import cell411.json.JSONException;
import cell411.json.JSONObject;

abstract class ClientOperation {
     abstract JSONObject getJSONObjectRepresentation() throws JSONException;
}
