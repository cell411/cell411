// This looks pretty cool, but java could not load the resulting class.
// Bummer.


  try {
  Class dynamicType = new ByteBuddy()
  .subclass(Object.class)
  .implement(Serializable.class)
  .method(ElementMatchers.named("toString"))
  .intercept(FixedValue.value("Hello World!"))
  .make()
  .load(Cell411.class.getClassLoader(), ClassLoadingStrategy.Default.WRAPPER)
  .getLoaded();
  XLog.i(TAG, "string: "+dynamicType.newInstance().toString());
  } catch (IllegalAccessException e) {
  e.printStackTrace();
  } catch (InstantiationException e) {
  e.printStackTrace();
  }
