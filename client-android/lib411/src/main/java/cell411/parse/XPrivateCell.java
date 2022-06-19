package cell411.parse;

import com.parse.ParseClassName;

import cell411.enums.EntityType;
import com.parse.ParseQuery;

@ParseClassName("PrivateCell")
public class XPrivateCell extends XBaseCell {
  public static final String TAG = "XPrivateCell";

  public XPrivateCell() {
  }
  public static ParseQuery<XPrivateCell> q() {
    return ParseQuery.getQuery(XPrivateCell.class);
  }

  public EntityType getType() {
    return EntityType.PRIVATE_CELL;
  }

  @Override public String getEntityName() {
    String name=null;
    XUser owner=null;
    if(has("owner"))
      owner = getOwner();
    if(owner!=null && owner.has("name"))
      name=owner.getName();
    if(name==null)
      name="Dummy";

    return name+"'s private cell: "+getName();
  }

  public void setType(int type) {
    if (type < 1 || type > 4) {
      put("type", 5);
    } else {
      put("type", type);
    }
  }

  public int getCellType() {
    int res = getInt("type");
    // We do this so that we can compare cells by type,
    // and all standard cells will come before all
    // non-standard cells.
    if (res >= 1 && res <= 4) {
      return res;
    } else {
      return 5;
    }
  }
}

