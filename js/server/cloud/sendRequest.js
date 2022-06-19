const parse = require('./lib/parse.js');
const {  createFriendship, blockCheck, markFriendRequests }   = require('./lib/modelUtils.js');

async function checkForPendingRequests(user,friend){
  const query = new Parse.Query("Request");
  query.equalTo("owner",user);
  query.equalTo("sentTo",friend);
  query.equalTo("status","PENDING");
  const count=await query.count();
  return (count>0);
}
async function sendRequest(req){
  const user = req.user;
  if(user==null)
    throw new Error("User not logged in");
  const objectId = req.params['objectId'];
  if(objectId==null)
    throw new Error("Expected objectId");
  const type = req.params['type'];
  var title, message, users, data;
  data={};

  if(type == "FriendRequest") {
    const query = new Parse.Query(Parse.User);
    if(user.id == objectId)
      return {
        success: false,
        message: "Cannot send a friend request to yourself"
      };
    const friend = await query.get(objectId);
    if(await checkForPendingRequests(user,friend)) {
      return {
        success: false,
        message: `There is already a friend request from `
                 +`${user.getName()} to ${friend.getName()} pending`,
      };
    };
    if(await checkForPendingRequests(friend,user)) {
      await createFriendship(request);
      return {
        success: true,
        message: "created friendship, target user had requested sender",
        request
      };
    } else {
      request = new Request();
      if(req.params.reverse) {
        request.set("sentTo",user);
        request.set("owner",friend);
      } else {
        request.set("owner", user);
        request.set("sentTo", friend);
      };
      request.set("status", 'PENDING');
      await request.save(null,{useMasterKey: true});
      //console.log(JSON.stringify({type: type, request: request},null,2));
      return {
        success: true,
        message: "request sent",
        request
      };
    };
  } else if(type == "FriendResend") {
    const query = new Parse.Query(Request);
    query.include("owner");
    query.include("sentTo");
    const request = await query.get(objectId);
    const owner = request.get("owner");
    if(owner==null || user.id != owner.id)
      return {
        success: false,
        message: `Friend requests can only be resent by their owner`
      };
    const friend = request.get("sentTo"); 
    if(friend==null)
      return {
        success: false,
        message: `Friend request missing destination`
      };
    await blockCheck(user,friend);
    // FIXME:  this is not really resending it, except that
    // it will draw the attention of the app if it is running,
    // and update the last update field.
    request.set("status","RESENT");
    await request.save(null,{useMasterKey: true});
    request.set("status","PENDING");
    await request.save(null,{useMasterKey: true});
    //console.log(JSON.stringify({type: type, request: request},null,2));
    return {
      success: true,
      message: "Request resent",
      request
    };
  } else if ( type == "FriendCancel" ) {
    const query = new Parse.Query(Request);
    const request = await query.get(objectId);
    if(request.get("owner").id!=user.id)
      return {
        success: false,
        message: `Friend requests can only be canceled by their owner`
      };
    const friend = request.get("sentTo");
    friend.fetch();
    var count = await markFriendRequests(user, request.get("sentTo"),"CANCELED",true);    
    //console.log(JSON.stringify({type: type, request: request, count: count},null,2));
    return {
      success: true,
      message: "Request Canceled",
      request
    };
  } else if (type == "CellJoinRequest") {
    const cellQuery = new Parse.Query("PublicCell");
    const cell = await cellQuery.get(objectId);
    const owner = cell.get("owner");
    await owner.fetch();
    request = new Request();
    request.set("owner", user);
    request.set("sentTo", owner);
    request.set("cell", cell);
    request.set("status", 'PENDING');
    await request.save(null,{useMasterKey: true});
    //console.log(JSON.stringify({type: type, request: request},null,2));
    return {
      success: true,
      message: "Request sent",
      request
    };
  } else {
    return {
      success: false,
      message: "Unexpected request type"
    }
  };
  throw new Error("Fell off the end of the function without sending a request");
};
Parse.Cloud.define("sendRequest",sendRequest);
