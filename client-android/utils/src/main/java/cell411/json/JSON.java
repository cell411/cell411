/*
 * Copyright (C) 2010 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package cell411.json;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.function.Function;

@SuppressWarnings("unused")
public class JSON {
  /**
   * Returns the input if it is a JSON-permissible value; throws otherwise.
   */
  static double checkDouble(double d) throws JSONException {
    if (Double.isInfinite(d) || Double.isNaN(d)) {
      throw new JSONException("Forbidden numeric value: " + d);
    }
    return d;
  }

  public static Boolean toBoolean(Object value) {
    if (value instanceof Boolean) {
      return (Boolean) value;
    } else if (value instanceof String) {
      String stringValue = (String) value;
      if ("true".equalsIgnoreCase(stringValue)) {
        return true;
      } else if ("false".equalsIgnoreCase(stringValue)) {
        return false;
      }
    }
    return null;
  }

  static Double toDouble(Object value) {
    if (value instanceof Double) {
      return (Double) value;
    } else if (value instanceof Number) {
      return ((Number) value).doubleValue();
    } else if (value instanceof String) {
      try {
        return Double.valueOf((String) value);
      } catch (NumberFormatException ignored) {
      }
    }
    return null;
  }

  static Integer toInteger(Object value) {
    if (value instanceof Integer) {
      return (Integer) value;
    } else if (value instanceof Number) {
      return ((Number) value).intValue();
    } else if (value instanceof String) {
      try {
        return (int) Double.parseDouble((String) value);
      } catch (NumberFormatException ignored) {
      }
    }
    return null;
  }

  static Long toLong(Object value) {
    if (value instanceof Long) {
      return (Long) value;
    } else if (value instanceof Number) {
      return ((Number) value).longValue();
    } else if (value instanceof String) {
      try {
        return (long) Double.parseDouble((String) value);
      } catch (NumberFormatException ignored) {
      }
    }
    return null;
  }

  public static String toString(Object value) {
    if (value instanceof String) {
      return (String) value;
    } else if (value != null) {
      return String.valueOf(value);
    }
    return null;
  }

  public static JSONException typeMismatch(Object indexOrName, Object actual,
                                           String requiredType) throws JSONException {
    if (actual == null) {
      throw new JSONException("Value at " + indexOrName + " is null.");
    } else {
      if(actual instanceof JSONObject) {
        actual = ((JSONObject)actual).toString(2);
      }
      throw new JSONException("Value " + actual + " at " + indexOrName
                              + " of type " + actual.getClass().getName()
                              + " cannot be converted to " + requiredType);
    }
  }

  public static JSONException typeMismatch(Object actual, String requiredType)
    throws JSONException {
    if (actual == null) {
      throw new JSONException("Value is null.");
    } else {
      throw new JSONException("Value " + actual
                              + " of type " + actual.getClass().getName()
                              + " cannot be converted to " + requiredType);
    }
  }

  public static <C extends Map<String,Object>> C asMap(C c, JSONObject val) {
    for(String key : val.keySet())
      c.put(key, val.opt(key));
    return c;
  }

  public static Map<String, Object> asMap(JSONObject val) {
    return asMap(new HashMap<>(), val);
  }

  public static <X, C extends Collection<X>> C asList(C c, JSONArray json, Function<Object,X> xform)
  {
    for(int i=0;i<json.length();i++) {
      c.add(xform.apply(json.get(i)));
    }
    return c;
  }

  public static <X> List<X> asList(JSONArray array, Function<Object,X> xform) {
    return asList(new ArrayList<>(), array, xform);
  }

  public static <X> Map<String, X> asMap(HashMap<String, X> map, JSONObject temp,
                                              Function<Object,X> xform)
  {
    for(String name: temp.keySet()) {
      map.put(name, xform.apply(temp.get(name)));
    }
    return map;
  }
}
