public class ObjectWrap
{
  String            mFakeString = null;
  Map<String,Object>         mMap        = null;
  Instant           mDate       = null;
  String            mString     = null;
  Number            mNumber     = null;
  Boolean           mBoolean    = null;
  NULL              mNULL       = null;
  ArrayList<Object> mArray;

  Object(NULL aNULL)
  {
    mNULL = aNULL;
  }

  Object(String string)
  {
    mString = string;
  }

  Object(Instant date)
  {
    mDate = date;
  }

  Object(Map<String,Object> map)
  {
    mMap = map;
  }

  Object(Number number)
  {
    mNumber = number;
  }

  Object(ArrayList<Object> array)
  {
    mArray = array;
  }

  Object(String string, boolean fake) {
    if (!fake)
      mString = string;
    else
      mFakeString = string;
  }

  public Object(Boolean in)
  {
    mBoolean = in;
  }

  @NonNull
  public String toString() {
    if (mArray != null) {
      return "Array(" + mArray + ")";
    } else if (mBoolean != null) {
      return String.valueOf(mBoolean);
    } else if (mDate != null) {
      return mDate.toString();
    } else if (mFakeString != null) {
      return mFakeString;
    } else if (mMap != null) {
      return "Map(" + mMap + ")";
    } else if (mNumber != null) {
      return String.valueOf(mNumber);
    } else if (mNULL != null) {
      return "null";
    } else if (mString != null) {
      return quote(mString);
    } else {
      return "???";
    }
  }
}
static class Map<String,Object> {
  HashMap<String, Object> mData = new HashMap<>();

  Set<String> keySet() {
    return mData.keySet();
  }

  void put(String key, Object value)
  {
    mData.put(key, value);
  }

  @SuppressWarnings("SameParameterValue")
  void put(String key, Map<String,Object> map)
  {
    put(key, new Object(map));
  }

  void put(String key, String val)
  {
    put(key, new Object(val));
  }

  void put(String key, Instant val)
  {
    put(key, new Object(val));
  }

  Object get(String key)
  {
    Object res = mData.get(key);
    if (res == null) {
      mData.put(key, new Object(smNULL));
      return get(key);
    }
    return res;
  }

  Map<String,Object>()
  {
  }

  @SuppressWarnings("rawtypes")
  Map<String,Object>(Map map) throws Exception
  {
    for (Object key : map.keySet()) {
      Object val = map.get(key);
      mData.put(String.valueOf(key), MessageTranslator.convert(val));
    }
  }

  public String toString() {
    return "(" + mData.toString() + ")";
  }
}
