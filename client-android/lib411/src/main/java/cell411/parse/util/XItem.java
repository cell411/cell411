package cell411.parse.util;

import static cell411.utils.ViewType.vtAlert;
import static cell411.utils.ViewType.vtNull;
import static cell411.utils.ViewType.vtPrivateCell;
import static cell411.utils.ViewType.vtPublicCell;
import static cell411.utils.ViewType.vtRequest;
import static cell411.utils.ViewType.vtString;
import static cell411.utils.ViewType.vtUser;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.parse.model.ParseObject;

import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import cell411.parse.IObject;
import cell411.parse.XAlert;
import cell411.parse.XBaseCell;
import cell411.parse.XPrivateCell;
import cell411.parse.XPublicCell;
import cell411.parse.XRequest;
import cell411.parse.XUser;
import cell411.utils.Util;
import cell411.utils.ViewType;
// This implements an "any" class which can point to any of objects which are
// held in lists, including Cells ( Public and Private ), Users, Requests,
// Alerts, and Responses.  It is mostly used to wrap these objects in a type
// safe way for use in RecyclerViews and Lists, but does not depend on any
// GUI crap.

public class XItem {
  private static final HashMap<ViewType, Class<?>> mExpectedTypes = createExpectedTypes();
  private final ViewType mViewType;
  private final Object mData;
  private final String mObjectId;
  private boolean mSelected = true;
  private boolean mEnabled = true;

  public XItem(ViewType viewType, String objectId, Object data) {
    if (data == null) {
      mViewType = vtNull;
      mObjectId = objectId;
      mData = null;
    } else {
      Class<?> clazz = mExpectedTypes.get(viewType);
      assert clazz != null;
      if (!clazz.isInstance(data)) {
        throw new IllegalArgumentException(
          Util.format("Error:  ViewType=%s but data=%s", String.valueOf(viewType),
            data.getClass()
              .getSimpleName()));
      }
      mViewType = viewType;
      mData = data;
      mObjectId = objectId;
    }
  }

  public XItem(ViewType vt, IObject obj) {
    this(vt, vt==vtNull ? null : obj.getObjectId(), obj);
  }

  public XItem(@NonNull String objectId, @NonNull String obj) {
    this(getViewType(obj), objectId, obj);
  }

  public XItem(IObject obj) {
    this(getViewType(obj), obj);
  }

  public XItem() {
    this(getViewType(null), "", null);
  }

  public static ViewType getViewType(Object obj) {
    if (obj == null) {
      return vtNull;
    }
    Iterator<Map.Entry<ViewType, Class<?>>> iterator = mExpectedTypes.entrySet()
      .iterator();
    Class<?> objClass = obj.getClass();
    while (iterator.hasNext()) {
      Map.Entry<ViewType, Class<?>> entry = iterator.next();
      Class<?> entryClass = entry.getValue();
      if (entryClass.isAssignableFrom(objClass)) {
        return entry.getKey();
      }
    }
    throw new RuntimeException("No ViewType found for class " + objClass);
  }

  private static HashMap<ViewType, Class<?>> createExpectedTypes() {
    HashMap<ViewType, Class<?>> expectedTypes = new HashMap<>();
    expectedTypes.put(vtString, String.class);
    expectedTypes.put(vtPublicCell, XPublicCell.class);
    expectedTypes.put(vtUser, XUser.class);
    expectedTypes.put(vtAlert, XAlert.class);
    expectedTypes.put(vtRequest, XRequest.class);
    expectedTypes.put(vtPrivateCell, XPrivateCell.class);
    return expectedTypes;
  }

  public static <X extends IObject> List<XItem> asList(List<X> data) {
    return Util.transform(data, XItem::new);
  }


  public ViewType getViewType() {
    return mViewType;
  }

  @NonNull
  public String toString() {
    StringBuilder res = new StringBuilder("XItem{ type=").append(mViewType);
    res.append(",selected=")
      .append(mSelected);
    switch (mViewType) {
      case vtPublicCell:
        res.append(", cell=")
          .append(getPublicCell().getName());
        break;
      case vtPrivateCell:
        res.append(", type=")
          .append(getPrivateCell().getCellType());
        res.append(", cell=")
          .append(getPrivateCell().getName());
        break;
      case vtString:
        res.append(", title=")
          .append(getText());
        break;
      default:
        res.append(", data=")
          .append(mData);
        break;
    }
    res.append("}");
    return res.toString();
  }

  public XBaseCell getCell() {
    assert mViewType == vtPrivateCell || mViewType == vtPublicCell;
    return (XBaseCell) mData;
  }

  public XPrivateCell getPrivateCell() {
    assert mViewType == vtPrivateCell;
    return (XPrivateCell) mData;
  }

  @NonNull
  public XUser getUser() {
    assert mViewType == vtUser;
    return (XUser) mData;
  }

  @NonNull
  public XPublicCell getPublicCell() {
    assert mViewType == vtPublicCell;
    return (XPublicCell) mData;
  }

  @NonNull
  public XAlert getAlert() {
    assert mViewType == vtAlert;
    return (XAlert) mData;
  }

  @NonNull
  public String getText() {
    switch (mViewType) {
      case vtString:
        return (String) mData;
      case vtNull:
        return "";
      case vtAlert:
        return getAlert().getProblemType()
          .toString();
      case vtPrivateCell:
      case vtPublicCell:
        return extractName(getCell());
      case vtUser:
        return extractName(getUser());
      case vtRequest:
        XRequest request = getRequest();
        XUser owner = request.getOwner();
        XUser sentTo = request.getSentTo();
        String oName = extractName(owner);
        String sName = extractName(sentTo);
        return request.getType() + " from " + oName + " to " + sName;
      default:
        if (mData instanceof ParseObject) {
          ParseObject object = (ParseObject) mData;
          String res = object.getString("name");
          if (res == null) {
            res = "nameless " + object.getClassName();
          }
          return res;
        } else {
          throw new IllegalStateException(
            String.format("ViewType %s unexpected in getText()", mViewType));
        }
    }
  }

  private String extractName(final XBaseCell cell) {
    if (cell == null) {
      return "null";
    } else if (cell.has("name")) {
      return cell.getName();
    } else {
      return "nameless cell: " + cell.getObjectId();
    }
  }

  private String extractName(final XUser sentTo) {
    if (sentTo == null) {
      return "null";
    } else {
      return sentTo.getName();
    }
  }

  public ParseObject getParseObject() {
    assert mViewType.isParseObject();
    assert mData instanceof ParseObject;
    return (ParseObject) mData;
  }


  public boolean isSelected() {
    return mEnabled && mSelected;
  }

  public void setSelected(boolean selected) {
    mSelected = selected;
  }

  public boolean isEnabled() {
    return mEnabled;
  }

  public void setEnabled(boolean enabled) {
    mEnabled = enabled;
  }

  @NonNull
  public String getObjectId() {
    return mObjectId;
  }

  @NonNull
  public XRequest getRequest() {
    assert mViewType == vtRequest;
    return (XRequest) mData;
  }

  @Override
  public boolean equals(@Nullable Object obj) {
    if (obj instanceof XItem) {
      XItem item = (XItem) obj;
      if (item.getViewType() != getViewType())
        return false;
      if (mData == null && item.mData == null)
        return true;
      if (mData == null || item.mData == null)
        return false;
      return mData.equals(item.mData);
    } else if (mData == null) {
      return obj == null;
    } else {
      return mData.equals(obj);
    }
  }

}

