package cell411.utils.func;

public interface Func0V extends Runnable {
  void apply();
  default void run() {
    apply();
  }
}
