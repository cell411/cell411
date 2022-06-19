package cell411.parse.util;

import androidx.annotation.NonNull;

import com.parse.model.ParseObject;

import org.jetbrains.annotations.NotNull;

import java.util.ArrayList;
import java.util.Collection;

public class ParseList extends ArrayList<ParseObject> {
  public ParseList(int initialCapacity) {
    super(initialCapacity);
  }

  public ParseList() {
    super();
  }

  public ParseList(@NonNull @NotNull Collection<? extends ParseObject> c) {
    super(c);
  }
}
