package com.parse.livequery;

import com.parse.ParseQuery;
import com.parse.codec.PointerEncoder;
import com.parse.livequery.ClientOperation;
import com.parse.model.ParseObject;

import cell411.json.JSONException;
import cell411.json.JSONObject;

class SubscribeClientOperation<T extends ParseObject> extends ClientOperation {

    private final int requestId;
    private final ParseQuery.State<T> state;
    private final String sessionToken;

    /* package */ SubscribeClientOperation(int requestId, ParseQuery.State<T> state, String sessionToken) {
        this.requestId = requestId;
        this.state = state;
        this.sessionToken = sessionToken;
    }

    @Override
    /* package */ JSONObject getJSONObjectRepresentation() throws JSONException {
        JSONObject jsonObject = new JSONObject();
        jsonObject.put("op", "subscribe");
        jsonObject.put("requestId", requestId);
        jsonObject.put("sessionToken", sessionToken);

        JSONObject queryJsonObject = new JSONObject();
        queryJsonObject.put("className", state.className());

        // TODO: add support for fields
        // https://github.com/ParsePlatform/parse-server/issues/3671
        
        PointerEncoder pointerEncoder = PointerEncoder.get();
        queryJsonObject.put("where", pointerEncoder.encode(state.constraints()));

        jsonObject.put("query", queryJsonObject);

        return jsonObject;
    }
}
