const createAudience=require('./createAudience.js');
async function createAlert(user, alert) {
  var cell411Alert = new Alert();
  if(cell411Alert==null)
    throw new Error("failed to create alert object");

  cell411Alert.set("note", alert.note);
  cell411Alert.set("owner", user);
  cell411Alert.set("problemType", alert.problemType);
  cell411Alert.set("objectId", alert.alertId);
  cell411Alert.set("location", alert.location);
  return cell411Alert;
}
module.exports=createAlert;
