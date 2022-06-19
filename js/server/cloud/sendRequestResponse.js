const parse = require('./lib/parse.js');
const { blockCheck, markFriendRequests } = require("./lib/modelUtils.js");
const mk = {useMasterKey: true};

async function sendRequestResponse(req){
  const user = req.user;

  if(user==null)
    throw new Error("User not logged in");

  const params=req.params;

  const objectId = params['objectId'];
  if(objectId==null)
    throw new Error("Expected objectId");

  const type = params['type'];
  const query = new Parse.Query("Request");
  const request = await query.get(objectId);
  if(request.get("status")!=="PENDING")
    throw new Error("You can only approve pending requests");

  var relation;
  if(type == "FriendApprove") {
    console.log("approving friend request");
    if(request.get("sentTo").id!=user.id)
      throw new Error("You can only approve requests sent to you");
    const friend = request.get("owner");
    friend.fetch();

    if(request.get("cell")!=null)
      throw new Error("You can only approve friend requests that are friend requests");

    createFriendship(request);
    await markFriendRequests(user,friend,"APPROVED"); 
    return { requestType: type, friend: friend.id, success: true };
  } else if(type == "FriendReject") {
    console.log("rejecting friend request");
    if(request.get("sentTo").id!=user.id)
      throw new Error("You can only approve requests sent to you");
    const friend = request.get("owner");
    friend.fetch();
    
    if(request.get("cell")!=null)
      throw new Error("You can only reject friend requests that are friend requests\n\n"+pp(request));

    await destroyFriendship(user,friend);
    await user.save(null,mk);
    await friend.save(null,mk);
    await markFriendRequests(user,friend,"REJECTED"); 
    return { requestType: type, friend: friend.id, success: true };
  } else if (type == "CellJoinApprove") {
    console.log("approving cell join request");

    if(request.get("cell")==null)
      throw new Error("You can only approve cell requests that are cell requests");

    // It looks weird but the owner of the request it talking to the owner of
    // the cell ...
    const member = request.get("owner");
    if(member==null)
      throw new Error("CellJoinApprove missing owner");
    await member.fetch();
    const cell = request.get("cell");
    await cell.fetch();
    const owner = cell.get("owner");
    await owner.fetch();
    if(owner.id!=user.id)
      throw new Error("You can only approve cell requests to your cells");

    cell.relation("members").add(member);
    await cell.save(null,mk);
    request.set("status", "APPROVED");
    await request.save(null, mk);
    
    return { requestType: type, cell: cell.id, member: member.id, success: true };
  } else if (type == "CellJoinReject") {
    console.log("rejecting cell join request");
    if(request.get("cell")==null)
      throw new Error("You can only reject cell requests that are cell requests");

    const member = request.get("owner");
    const cell = request.get("cell");
    await cell.fetch();
    if(cell.get("owner")!=user)
      throw new Error("You can only reject cell requests to your cells");
    
    cell.relation("members").remove(member);
    await cell.save(null,mk);
    request.set("status", "REJECTED");
    await request.save(null, mk);

    return { requestType: type, cell: cell.id, member: member.id, success: true };
  } else {
    throw new Error("unexpected request type: "+type);
  };
};
Parse.Cloud.define("sendRequestResponse",sendRequestResponse);
