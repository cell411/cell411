package com.parse.livequery;

import cell411.json.JSONException;
import cell411.json.JSONObject;

class UnsubscribeClientOperation extends ClientOperation {

    private final int requestId;

    UnsubscribeClientOperation(int requestId) {
        this.requestId = requestId;
    }

    @Override
    JSONObject getJSONObjectRepresentation() throws JSONException {
        JSONObject jsonObject = new JSONObject();
        jsonObject.put("op", "unsubscribe");
        jsonObject.put("requestId", requestId);
        return jsonObject;
    }
}
