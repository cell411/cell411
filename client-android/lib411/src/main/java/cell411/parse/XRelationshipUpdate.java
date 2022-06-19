package cell411.parse;

import com.parse.ParseClassName;
import com.parse.ParseQuery;
import com.parse.model.ParseObject;

@ParseClassName("RelationshipUpdate")
public class XRelationshipUpdate extends ParseObject {

  public static ParseQuery<XRelationshipUpdate> q() {
    return ParseQuery.getQuery(XRelationshipUpdate.class);
  }
}
