var callCount = 0;
var lastLoadTime=0;

// Given a user, load all friends.  Save the objects to ret.objects,
// and save the objectIds to ret.friends
// 
// Note:  we always load the exhaustive friend list, because
//        otherwise, we would have no way of recognizing
//        removed friendships.
//
async function loadFriends(user, ret) {
  const friendQuery = user.relation("friends").query();
  const friends = await findFully(friendQuery);
  for(var i=0;i<friends.length;i++){
    ret.friends[friends[i].id]=1;
    ret.objects[friends[i].id]=friends[i];
  };
}
// Given a user, load all owned cells.  Save the objects to ret.owned,
// and save their objectIds to ret.ownedCells.
//
// Also, save the ids of members, which we will use to flesh out ret.objects with
// the objects who are not friends, but share a cell with the current user.

async function loadPublicCells(user, ret, memberIds) {
  const ownedCellQ = new Parse.Query('PublicCell');
  ownedCellQ.equalTo('owner',user);

  const joinedCellQ = new Parse.Query('PublicCell');
  joinedCellQ.equalTo('members',user);

  const publicCellQ = Parse.Query.or(ownedCellQ,joinedCellQ);
  publicCellQ.greaterThan("updatedAt",new Date(lastLoadTime));

  const publicCells=await findFully(publicCellQ);

  for(var i=0;i<publicCells.length;i++) {
    const cell = publicCells[i];
    ret.ownedCells[cell.id]=cell;
    const owner = cell.get("owner");
    if(owner==null)
      continue;
    
    ret.objects[cell.id]=cell;
    if(owner.id === user.id) {
      ret.ownedCells[cell.id]=1;
    } else {
      ret.joinedCells[cell.id]=1;
    };
    const memberQ = cell.relation("members").query();
    const members = await findFully(memberQ);
    if(ret.memberMap[cell.id]==null)
      ret.memberMap[cell.id]={};
    const map = ret.memberMap[cell.id];
    for(var j=0;j<members.length;j++){
      const member=members[j];
      map[member.id]=1;
      ret.objects[member.id]=member;
    };
  };
};
// given a list of all members of all cells, load those objects and store
// them in ret.objects.  We do not have to record which cells they belong
// to, because that information is in ret.memberMap
async function loadMembers(memberIds, ret) {
  const memberQ = new Parse.Query(Parse.User);
  var partIds;
  while(memberIds.length){
    partIds = memberIds.splice(0,100);
    memberQ.containedIn('objectId',partIds);
    const part = await findFully(memberQ);
    for(var i=0;i<part.length;i++) {
      ret.objects[part[i].id]=part[i];
    }
  };
};
// given a user, save all of the objectIds of people who have annoyed him with
// spam.  We save only the ids, they don't go on ret.objects, because we only
// need to filter them out of things.  The objectIds are sufficient.
//
// We always send all spam objects, otherwise we would not recognize deletions
async function loadUserSpams(user, ret) {
  const userSpamsQ = new Parse.Query("_User");
  userSpamsQ.equalTo("spamUsers",user);
  userSpamsQ.greaterThan("updatedAt", new Date(lastLoadTime));
  const userSpams = await findFully(userSpamsQ);
  for(var i=0;i<userSpams.length;i++){
    ret.userSpams[userSpams[i].id]=1;
  };
};
// given a user, save all of the objectIds of people who have been annoyed *BY*
// him with spam.  We save only the ids, they don't go on ret.objects, because we
// only need to filter them out of things.  The objectIds are sufficient.
//
// We always send all spam objects, otherwise we would not recognize deletions
async function loadSpamUsers(user, ret) {
  const spamUserR = user.relation('spamUsers');
  const spamUserQ = spamUserR.query();
  spamUserQ.greaterThan("updatedAt", new Date(lastLoadTime));
  const spamUsers = await findFully(spamUserQ);
  for(var i=0;i<spamUsers.length;i++){
    ret.spamUsers[spamUsers[i].id]=1;
  };
};
// given a user, save all of the objectIds of people to whom he has sent a
// friend request which is still pending.  We save only the ids, they don't go
// on ret.objects, because we only need to filter them out of things.  The
// objectIds are sufficient.
async function loadPendingFriends(user, ret) {
  const request1Q = new Parse.Query('Request');
  request1Q.equalTo("owner",user);
  const request2Q = new Parse.Query('Request');
  request2Q.equalTo("sentTo",user);
  const requestQ = Parse.Query.or(request1Q,request2Q);
  requestQ.equalTo("status",'PENDING');
  const requests = await findFully(requestQ);
  for(var i=0;i<requests.length;i++){
    const request = requests[i];
    const sentBy = request.get("owner");
    if(sentBy==null){
      console.warn("sentBy==null");
      continue;
    };
    const sentTo = request.get("sentTo");
    if(sentTo==null){
      console.warn("sentTo==null");
      continue;
    };
    console.dump({sentTo,sentBy});
    if(sentBy.id==user.id){
      ret["pendingFriends"][sentTo.id]=sentTo;
    } else if ( sentTo.id==user.id ) {
      ret["friendingPends"][sentBy.id]=sentBy;
    };
  };
};
// given a user, load all of his private cells.  We do not store
// the user objects, because only friends will be in your private cells.
async function loadPrivateCells(user, ret) {
  const privateCellQ = new Parse.Query('PrivateCell');
  privateCellQ.equalTo("owner", user);
  privateCellQ.greaterThan("updatedAt", new Date(lastLoadTime));
  const privateCells = await findFully(privateCellQ);
  for(var i=0;i<privateCells.length;i++) {
    const cell = privateCells[i]; 
    ret.objects[cell.id]=cell;
    ret.privateCells[cell.id]=cell;
    if(ret.memberMap[cell.id]==null)
      ret.memberMap[cell.id]={};
    const map = ret.memberMap[cell.id];
    const memberQ = cell.relation("members").query();
    const members = await findFully(memberQ);
    for(var j=0;j<members.length;j++){
      const member=members[j];
      map[member.id]=1;
      ret.objects[member.id]=member;
    };
  };
  //});
}
// we use objects as maps to weed out duplicate objects and cells.
// when we are done, we use this function to replace the object
// with an array of objects.  we don't need to send the keys, since
// they already exist within the objects.
function objToValueList(k,ret){
  const objs = [];
  for( var id in ret[k] )
    objs.push(ret[k][id]);
  ret[k]=objs;
  ret.counts[k]=objs.length;
};
// convert the objects which have been used to accumulate key lists
// to arrays of objectIds.  k is the name of the list we are working
// on.  ret[k] is the list itself.
function objToKeyList(k,ret) {
  const objs = [];
  for( var id in ret[k] ) {
    objs.push(id);
  };
  ret[k]=objs;
  ret.counts[k]=objs.length;
};
async function checkUserConsent(user){
  const query = new Parse.Query("PrivacyPolicy");
  query.descending("createdAt");
  query.limit(1);
  const res = await query.find();
  if(res.length==0) {
    return true;
  };
  const policy=res[0];
  console.dump(policy);
  console.log(policy);
  const userConsent=user.get("lastConsent");
  return userConsent!=null && userConsent.id == policy.id;
};
async function loadAlerts(user,ret) {
  const q1 = new Parse.Query("Alert");
  q1.equalTo("owner", user);
  const q2 = new Parse.Query("Response");
  q2.equalTo("owner", user);
  const q3 = new Parse.Query("Alert");
  q3.matchesKeyInQuery("objectId", "alert", q2);
  const q = Parse.Query.or(q1,q3);
  const list = await q.find();
  var time = new Date().getTime();
  time -= 1000*86400;
  time=Math.max(lastLoadTime, time);
  q.greaterThan("updatedAt",time);
  for(var i=0;i<list.length;i++) {
    const item=list[i];
    ret.alerts[item.id]=1;
    ret.objects[item.id]=item;
  };
}
async function doGetUserData(user) {
  if(!user)
    return {fatal:  'not logged in!' };
  const ret = {
    owner: {},
    privateCells: {},
    friends: {},
    alerts: {},
    objects: {},
    ownedCells: {},
    joinedCells: {},
    spamUsers: {},
    userSpams: {},
    pendingFriends: {},
    friendingPends: {},
    memberMap: {},
    loadTime: lastLoadTime,
    counts: {callCount: callCount++},
  };

  {
    user.fetch();
    ret.owner=user.id;
    const memberIds={};
    ret.objects[user.id]=user;
    console.log("loadFriends");
    await loadFriends(user,ret);

    console.log("loadPrivateCells");
    await loadPrivateCells(user,ret,memberIds);
    console.log("loadPublicCells");
    await loadPublicCells(user,ret,memberIds);
    
    console.log("loadPendingFriends");
    await loadPendingFriends(user,ret);
  
    console.log("loadUserSpams");
    await loadUserSpams(user,ret);
    console.log("loadSpamUsers");
    await loadSpamUsers(user,ret);

    console.log("loadAlerts");
    await loadAlerts(user,ret);

    const memberList=[];
    for( var id in memberIds ) {
      console.log(ret.objects[id]);
      memberList.push(id);
    };
    console.log("loadMembers");
    await loadMembers(memberList,ret);

  }

  for(var cell in ret.memberMap) {
    var map = ret.memberMap[cell];
    var list = [];
    ret.memberMap[cell]=list;
    for(var member in map) {
      list.push(member);
    };
  }
  delete ret.objects[user.id];
  [ 
    'friends',       "friendingPends",  'pendingFriends',
    'privateCells',  'ownedCells',      'joinedCells',
    'userSpams',     'spamUsers',       "alerts"
  ].forEach((k)=>{
    objToKeyList(k,ret);
  });
  objToValueList('objects',ret);
  delete ret.counts;
  return ret;  
}

async function getUserData(req) {
  try {
    var nextLoadTime=new Date().getTime();
    const user = req.user;
    console.log(user);
    lastLoadTime = req.params.lastLoadTime;
    if(lastLoadTime==null)
      lastLoadTime=0;
    lastLoadTime = new Date(lastLoadTime);
    const ret = await doGetUserData(user);
    ret.loadTime=nextLoadTime;
    return ret;
  } catch ( err ) {
    console.log(err);
    try {
    console.log(err.stack());
    } catch ( xxx ) {
      console.log(err);
    };
    throw (`error getting data: ${err}`);
  };
};
Parse.Cloud.define("getUserData", getUserData);
