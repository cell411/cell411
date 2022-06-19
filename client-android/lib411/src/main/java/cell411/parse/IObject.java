package cell411.parse;

import com.parse.model.ParseObject;

import java.util.Map;

import cell411.base.BaseApp;
import cell411.services.DataService;
import cell411.utils.ExceptionHandler;

public interface IObject
  extends Comparable<IObject>
{
  IObject sObj = new IObject() {
    @Override
    public String getObjectId() {
      return null;
    }
  };

  default DataService ds() {
    return BaseApp.get().ds();
  }
  String getObjectId();
  default String getKey() {
    return getObjectId();
  }
  default IObject getValue() {
    return this;
  }
  default ParseObject getParseObject() {
    return (ParseObject)this;
  }
  default int compareTo(IObject o) {
    return getObjectId().compareTo(o.getObjectId());
  }
  default IObject setValue(IObject value){
    if(value==this)
      return this;
    else
      throw new RuntimeException("That's not how ANY of this WORKS!");
  }
}
