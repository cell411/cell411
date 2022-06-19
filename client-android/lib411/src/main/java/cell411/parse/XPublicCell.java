package cell411.parse;

import cell411.utils.Collect;
import com.parse.ParseClassName;
import com.parse.ParseQuery;
import com.parse.model.ParseGeoPoint;

import cell411.enums.CellCategory;
import cell411.enums.EntityType;
import cell411.utils.Util;
import cell411.utils.XLog;

import java.util.Arrays;
import java.util.List;

@ParseClassName("PublicCell")
public class XPublicCell extends XBaseCell {
  public static final String TAG = XPublicCell.class.getSimpleName();

  public XPublicCell() {
//    XLog.i(TAG, "constructor");
  }

  public static ParseQuery<XPublicCell> q() {
    return ParseQuery.getQuery(XPublicCell.class);
  }

  public static XPublicCell fakePublicCell() {
    XPublicCell cell = create(XPublicCell.class);
    cell.setOwner(XUser.fakeUser());
    cell.setName("Lambos, Hookers, and Blow");
    cell.setCategory(CellCategory.Education);
    cell.setLocation(new ParseGeoPoint(-72.299983,42.9521465));
    return cell;
  }

  public String getDescription() {
    return getString("description");
  }

  public void setDescription(String description) {
    put("description", description);
  }

  public ParseGeoPoint getLocation() {
    return getParseGeoPoint("location");
  }

  public void setLocation(ParseGeoPoint parseGeoPoint) {
    if (parseGeoPoint == null) {
      remove("location");
    } else {
      put("location", parseGeoPoint);
    }
  }

  final public int getVerificationStatus() {
    return getInt("verificationStatus");
  }

  final public void setVerificationStatus(int status) {
    put("verificationStatus", status);
  }



  public CellCategory getCategory() {
    String category = getString("category");
    if (Util.isNoE(category)) {
      setCategory(CellCategory.None);
      return getCategory();
    } else {
      try {
        return CellCategory.forString(category);
      } catch ( IllegalArgumentException iae ) {
        return CellCategory.None;
      }
    }
  }

  public void setCategory(CellCategory category) {
    put("category", category.toString());
  }

  public boolean isVerified() {
    return getVerificationStatus() > 0;
  }

  @Override public EntityType getType() {
    return EntityType.PUBLIC_CELL;
  }

  @Override public String getEntityName() {
    return "PublicCell: "+getName();
  }
}

