require("./parse.js");
const path = require('path');
const exec = require('child_process');

global.fs=require('fs');
global.dumpJson=function dumpJson(file, data) {
  fs.writeFileSync(file, JSON.stringify(data,null,2));
};
global.findNonExisting = function findNonExisting(prefix, num, suffix) {
  --num;
  var name;
  do {
    ++num;
    name=prefix+num+suffix;
    console.log({checking: name});
  } while(fs.existsSync(name));
  const dirname = path.dirname(name);
  exec.execSync('pwd', {stdio: [ 'inherit', 'inherit', 'inherit' ]} );
  fs.mkdirSync(dirname,{recursive: true});
  return name;
};
async function blocks(user1,user2){
  const query=new Parse.Query(Parse.User);
  query.equalTo("objectId", user1)
  query.equalTo("spamUsers", user2);
  const count = await query.count();
  return count!=0;
};
async function getFriendRequest(user,friend){
  var reqQuery;
  reqQuery = new Parse.Query(Request);
  reqQuery.equalTo("owner",user);
  reqQuery.equalTo("sentTo",friend);
  reqQuery.equalTo("status","PENDING");
  return await reqQuery.find();
};
async function markFriendRequests(user,friend,status,oneWay) {
  var res = 0;
  var req1 = await getFriendRequest(user,friend);
  for(var i=0;i<req1.length;i++){
    req1[i].set("status",status);
    req1[i].save(null,{useMasterKey: true});
    res++;
  };
  if(!oneWay) {
    var req2 = await getFriendRequest(friend,user);
    for(var i=0;i<req2.length;i++){
      req2[i].set("status",status);
      req2[i].save(null,{useMasterKey: true});
      res++;
    };
  };
  return res;
};
async function destroyFriendship(user,friend){
  user.relation("friends").remove(friend);
  friend.relation("friends").remove(user);
  user.save(null,{useMasterKey: true});
  friend.save(null,{useMasterKey: true});
};
global.destroyFriendship=destroyFriendship;
async function createFriendshipObj(user,friend){
  user.relation("friends").add(friend);
  friend.relation("friends").add(user);
  user.save(null,{useMasterKey: true});
  friend.save(null,{useMasterKey: true});
};
async function createFriendship(request){
  const owner=request.get("owner");
  const sentTo=request.get("sentTo");
 
  createFriendshipObj(owner,sentTo);
  const query=new Parse.Query("Request");
  query.containedIn("owner",[owner,sentTo]);
  query.containedIn("sentTo",[owner,sentTo]);
  query.equalTo("status","PENDING");
  const requests=await findFully(query);
  for(var i=0;i<requests.length;i++){
    const req=requests[i];
    req.set("status","APPROVED");
    await req.save(null,{useMasterKey:true});
  };
  return true;
};
global.createFriendship=createFriendship;
async function blockCheck(user1, user2) {
  if(await blocks(user1,user2))
    throw new Error(user1.getName()+" blocks "+user2.getName());
  
  if(await blocks(user2,user1))
    throw new Error(user2.getName()+" blocks "+user1.getName());
  
  return false;
}
async function storeRelationshipUpdates(req,owningId,owningClass,fieldName){
  const object=JSON.parse(JSON.stringify(req.object));
  console.dump(object);
  if(!object[fieldName]) {
    return;
  };
  if(!object[fieldName].__op) {
    return;
  };
  const op = object[fieldName].__op;
  console.dump(object[fieldName]);
  const relatedClass=object[fieldName].objects[0].className;
  for(var i=0;i<object[fieldName].objects.length;i++){
    const relatedId=object[fieldName].objects[i].objectId;
    const owningField=fieldName;
    const relatedField="objectId";
    console.log({op,owningClass,owningField,owningId,relatedClass,relatedField,relatedId});
    const info = new Parse.Object("RelationshipUpdate",{
      op,owningClass,owningField,owningId,relatedClass,relatedField,relatedId
    });
    await info.save();
  };
};
global.storeRelationshipUpdates=storeRelationshipUpdates;
module.exports.storeRelationshipUpdates=storeRelationshipUpdates;
module.exports.blockCheck=blockCheck;
module.exports.markFriendRequests=markFriendRequests;
module.exports.createFriendship=createFriendship;
module.exports.destroyFriendship=destroyFriendship;

