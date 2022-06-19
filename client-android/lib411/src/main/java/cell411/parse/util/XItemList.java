package cell411.parse.util;

import java.util.ArrayList;

import cell411.parse.IObject;

public class XItemList extends ArrayList<XItem> {
  public boolean addItem(IObject object) {
    return add(new XItem(object));
  }

  public boolean addItems(Iterable<IObject> objects) {
    boolean res = false;
    for (IObject object : objects)
      if (addItem(object))
        res = true;
    return res;
  }

}
