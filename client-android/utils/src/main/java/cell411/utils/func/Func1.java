package cell411.utils.func;

import java.util.function.Function;

public interface Func1<R, A> extends Function<A, R> {
  @Override
  R apply(A t);
}
