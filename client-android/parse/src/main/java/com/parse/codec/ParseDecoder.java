/*
 * Copyright (c) 2015-present, Parse, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

package com.parse.codec;

import android.util.Base64;
import com.parse.utils.ParseDateFormat;
import com.parse.operation.ParseFieldOperations;
import com.parse.model.ParseFile;
import com.parse.model.ParseGeoPoint;
import com.parse.model.ParseObject;
import com.parse.ParsePolygon;
import com.parse.model.ParseRelation;
import cell411.json.JSONArray;
import cell411.json.JSONException;
import cell411.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

/**
 * A {@code ParseDecoder} can be used to transform JSON data structures into actual objects, such as
 * {@link ParseObject}s.
 *
 * @see ParseEncoder
 */
public class ParseDecoder {

  // This class isn't really a Singleton, but since it has no state, it's more efficient to get the
  // default instance.
  private static final ParseDecoder INSTANCE = new ParseDecoder();

  protected ParseDecoder() {
    // do nothing
  }

  public static ParseDecoder get() {
    return INSTANCE;
  }

  /* package */
  public List<Object> convertJSONArrayToList(JSONArray array) {
    List<Object> list = new ArrayList<>();
    for (int i = 0; i < array.length(); ++i) {
      list.add(decode(array.opt(i)));
    }
    return list;
  }

  /* package */
  public Map<String, Object> convertJSONObjectToMap(JSONObject object) {
    Map<String, Object> outputMap = new HashMap<>();
    Iterator<String> it = object.keys();
    while (it.hasNext()) {
      String key = it.next();
      Object value = object.opt(key);
      outputMap.put(key, decode(value));
    }
    return outputMap;
  }

  /**
   * Gets the <code>ParseObject</code> another object points to. By default a new
   * object will be created.
   */
  protected ParseObject decodePointer(String className, String objectId) {
    return ParseObject.createWithoutData(className, objectId);
  }

  public Object decode(Object object) {
    if (object instanceof JSONArray) {
      return convertJSONArrayToList((JSONArray) object);
    }

    if (object == JSONObject.NULL) {
      return null;
    }

    if (!(object instanceof JSONObject)) {
      return object;
    }

    JSONObject jsonObject = (JSONObject) object;

    String opString = jsonObject.optString("__op", null);
    if (opString != null) {
      try {
        return ParseFieldOperations.decode(jsonObject, this);
      } catch (JSONException e) {
        throw new RuntimeException(e);
      }
    }

    String typeString = jsonObject.optString("__type", null);
    if (typeString == null) {
      return convertJSONObjectToMap(jsonObject);
    }

    if (typeString.equals("Date")) {
      String iso = jsonObject.optString("iso");
      return ParseDateFormat.getInstance().parse(iso);
    }

    if (typeString.equals("Bytes")) {
      String base64 = jsonObject.optString("base64");
      return Base64.decode(base64, Base64.NO_WRAP);
    }

    if (typeString.equals("Pointer")) {
      return decodePointer(jsonObject.optString("className"), jsonObject.optString("objectId"));
    }

    if (typeString.equals("File")) {
      return new ParseFile(jsonObject, this);
    }

    if (typeString.equals("GeoPoint")) {
      double latitude, longitude;
      try {
        latitude = jsonObject.getDouble("latitude");
        longitude = jsonObject.getDouble("longitude");
      } catch (JSONException e) {
        throw new RuntimeException(e);
      }
      return new ParseGeoPoint(latitude, longitude);
    }

    if (typeString.equals("Polygon")) {
      List<ParseGeoPoint> coordinates = new ArrayList<>();
      try {
        JSONArray array = jsonObject.getJSONArray("coordinates");
        for (int i = 0; i < array.length(); ++i) {
          JSONArray point = array.getJSONArray(i);
          coordinates.add(new ParseGeoPoint(point.getDouble(0), point.getDouble(1)));
        }
      } catch (JSONException e) {
        throw new RuntimeException(e);
      }
      return new ParsePolygon(coordinates);
    }

    if (typeString.equals("Object")) {
      return ParseObject.fromJSON(jsonObject, null, this);
    }

    if (typeString.equals("Relation")) {
      return new ParseRelation<>(jsonObject, this);
    }

    if (typeString.equals("OfflineObject")) {
      throw new RuntimeException("An unexpected offline pointer was encountered.");
    }

    return null;
  }
}

