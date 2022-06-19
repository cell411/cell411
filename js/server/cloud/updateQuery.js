async function updateQuery(req) {
  const queryStr = req.params.query;
  const ids = req.params.ids;
  const dates = req.params.dates;
  const updateDates = {};
  for(var i=0;i<ids.length;i++){
    updateDates[ids[i]]=dates[i];
  };
  const queryObj = JSON.parse(queryStr);
  console.dump(queryObj);
  const query = new Parse.Query(queryObj.className);
  delete queryObj.className;
  query.withJSON(queryObj);
  const objects = await findFully(query);
  const ret={};
  for(var i=0;i<objects.length;i++) {
    const object = objects[i];
    const id = object.id;
    const updateTime = object.get("updatedAt").getTime();
    const inputTime = updateDates[id];
    console.log({updateTime, inputTime});
    if(inputTime != updateTime) {
      ret[id]=object;
    }
    delete updateDates[id];
  };
  for(var id in updateDates) {
    ret[id]=null;
  }
  console.dump(ret);
  return ret;
}
Parse.Cloud.define("updateQuery",updateQuery);
