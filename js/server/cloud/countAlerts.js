async function countAlerts(req) {
	var user = req.user;
	var token;
  if(user!=null)
    token=user.getSessionToken();
  if(user == null || token==null)
    throw new Error("failed:  user not logged in");

  var otherId = req.params.user;
  if(otherId==null) {
    throw new Error("countAlerts(user) failed.  No user provided");
  };
  const otherQuery = new Parse.Query("_User");
  otherQuery.equalTo("objectId", otherId);
  const others = await otherQuery.find();
  const other=others[0];

  var res={};
  {
    const query = new Parse.Query("Alert");
    query.equalTo("owner",other);
    res.sent=await query.count({useMasterKey: true});
  }
  {
    const query = new Parse.Query("Response");
    query.equalTo("owner",other);
    query.exists("canHelp");
    query.equalTo("seen",true);
    res.responded=await query.count({useMasterKey: true});
  };
  return res;
}
Parse.Cloud.define("countAlerts", countAlerts);
