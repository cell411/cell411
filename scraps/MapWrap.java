@Override
  public Map<String, Object> createEstimatedData() {
    return new Map<String, Object>() {
      HashMap<String,Object> mData;
      @Override
      public int size() {
        return mData.size();
      }

      @Override
      public boolean isEmpty() {
        return mData.isEmpty();
      }

      @Override
      public boolean containsKey(@Nullable  Object key) {
        return mData.containsKey(key);
      }

      @Override
      public boolean containsValue(@Nullable  Object value) {
        return mData.containsValue(value);
      }

      @Nullable
      
      @Override
      public Object get(@Nullable  Object key) {
        return mData.get(key);
      }

      @Nullable
      
      @Override
      public Object put(String key, Object value) {
        return mData.put(key,value);
      }

      @Nullable
      
      @Override
      public Object remove(@Nullable  Object key) {
        return mData.remove(key);
      }

      @Override
      public void putAll(@NonNull @NonNull Map<? extends String, ?> m) {
mData.putAll(m);
      }

      @Override
      public void clear() {
        mData.clear();
      }

      @NonNull
      @NonNull
      @Override
      public Set<String> keySet() {
        return mData.keySet();
      }

      @NonNull
      @NonNull
      @Override
      public Collection<Object> values() {
        return mData.values();
      }

      @NonNull
      @NonNull
      @Override
      public Set<Entry<String, Object>> entrySet() {
        throw new Error("FORBIDDEN!");
        return mData.entrySet();
      }
    };
  }