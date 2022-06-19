package cell411.utils;

import android.view.View;
import android.view.ViewGroup;

public class GuiUtils {
  public static void traverse(PrintString ps, View view, String tag) {
    ps.pl(tag);
    if (view == null) {
      ps.pl("null");
    } else {
      ps.pl(view);
      ps.pl(view.getClass().getSimpleName());
      ps.pl("dims: %f %f %d %d",
        view.getX(), view.getY(), view.getWidth(), view.getHeight());
    }
    if (view instanceof ViewGroup) {
      ps.println("isParent");
      ViewGroup parent = (ViewGroup) view;
      ps.println("children: " + parent.getChildCount());
      ps.push();
      ps.pl("{");
      for (int i = 0; i < parent.getChildCount(); i++) {
        traverse(ps, parent.getChildAt(i), tag + " - " + i);
      }
      ps.pop();
      ps.pl("}");
    }
  }
}
