package cell411.utils.func;

import kotlin.jvm.functions.Function0;

@SuppressWarnings("unused")
public class F {
  public static <A1,A2> Func0<Void> b(Func2V<A1, A2> f2, A1 a1, A2 a2)
  {
    return ()->{f2.apply(a1,a2); return null;};
  }

  public static <R, A1, A2> Func0<R> b(Func2<R, A1, A2> f, A1 a1, A2 a2)
  {
    return () -> f.apply(a1, a2);
  }

  public static <R, A1, A2> Func1<R,A2> b1(Func2<R, A1, A2> f2, A1 a1)
  {
    return a2 -> f2.apply(a1, a2);
  }

  public static <R, A1, A2> Func1<R, A1> b2(Func2<R, A1, A2> f2, A2 a2)
  {
    return a1 -> f2.apply(a1, a2);
  }

  public static <R,A> Func0<R> b(Func1<R, A> f1, A a) {
    return () -> f1.apply(a);
  }

  public static <A> Func0V b(Func1V<A> f1, A a) {
    return () -> f1.apply(a);
  }
  public static Func0V compose(Func0V f1, Func0V f2) {
    return ()->{f1.apply();f2.apply();};
  }
  public static <R> Func0V discard(Func0<R> f1) {
    return f1::apply;
  }
  public static <R> Func0<R> retNull(Func0V f1) {
    return ()->{f1.apply(); return null; };
  }
  public static <R> Func0<R> compose(Func0V f1, Func0<R> f2) {
    return ()->{ f1.apply(); return f2.apply(); };
  }
  public static <R> Func0<R> compose(Func0<R>f1, Func0V f2) {
    return ()->{ R r = f1.apply(); f2.apply(); return r; };
  }
  public static <AR,A1,A2> Func1V<A1> compose(Func1<AR, A1> f1, Func1V<AR> f2)
  {
    return a1 -> f2.apply(f1.apply(a1));
  }
  public static <R2,AR,A1> Func1<R2,A1> compose(Func1<R2,AR> f1, Func1<AR,A1> f2) {
    return a1 -> f1.apply(f2.apply(a1));
  }
  public static <A1,A2> Func2V<A1,A2> nop2() {
    return (a1,a2)->{};
  }
  public static <A> Func1V<A> nop1() {
    return (A)->{};
  }
  public static <A> Func0V nop0() {
    return ()->{};
  }

  <R> void x(Function0<R> fuck)
  {
    fuck.invoke();
  };
  public static <R> Func0V cb(Func0 <R> f, Func1V<R> cb) {
    return () -> {
      R r = f.apply();
      cb.apply(r);
    };
  }
  public static Runnable cb(Runnable r, Runnable cb){
    return ()->{
      r.run();
      cb.run();
    };
  }
}
