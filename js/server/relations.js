function ids(list){
  return list.map(item=>{return item.id});
};
async function idTimeMembers(list,incMembers){
  const res={};
  for(var i=0;i<list.length;i++){
    const item=list[i];
    const data={
      time: list[i].get("updatedAt").getTime()
    };
    res[item.id]=data;
    if(incMembers) {
      const members=await findFully(item.relation("members").query())
      data.members = ids(members);
    };
  };
  return res;
};
var user;
async function loadCells(dates,rels,className, owner ) {
  const query = new Parse.Query(className);
  query.equalTo(owner,user);
  var reverse=false; 
  if(owner !== "owner") {
    query.notEqualTo("owner",user)
    reverse=true;
  };
  const cellArray  = await findFully(query);
  const userRel = [ "_User", user.id, owner, reverse, className ];
  rels.push(userRel);
  for(var i=0;i<cellArray.length;i++) {
    const cell = cellArray[i];
    userRel.push(cell.id);
    const members=ids(await findFully(cell.relation("members").query()));
    members.unshift(className,cell.id,"members",false,"_User");
    rels.push(members);
    dates[cell.id]=cell.get("updatedAt").getTime();
  }
};
async function relations(req) {
  user = req.user;
  if(user==null)
    throw new Error("You must be logged in to call relations");
  const friends = await findFully(user.relation("friends").query());
  user.fetch();
  const times = {};
  const fblocks = await findFully(user.relation("spamUsers").query());
  const rblocks = await findFully(new Parse.Query(Parse.User).equalTo("spamUsers",user));
  const rels = [{}];
  const dates = rels[0];
  dates[user.id]=user.get("updatedAt").getTime();
  var temp=ids(fblocks);
  temp.unshift("_User",user.id,"spamUsers",false,"_User");
  rels.push(temp);
  temp=ids(rblocks);
  temp.unshift("_User",user.id,"spamUsers",true,"_User");
  rels.push(temp);
  await loadCells(dates,rels,"PublicCell","owner");
  await loadCells(dates,rels,"PublicCell","members");
  await loadCells(dates,rels,"PrivateCell","owner");
  await loadCells(dates,rels,"PrivateCell","members");
  rels.friends = ids(friends);
  for(var i=0;i<friends.length;i++) {
    const friend = friends[i]; 
    dates[friend.id]=friend.get("updatedAt").getTime();
  };
  console.dump(rels);
//     for(var j=0;j<cellArray.length;j++) {
//       const cell = cellArray[j];
//       relations[cell.id]={};
//       relations[cell.id].members = await ids(await findFully(cell.relation("members").query()));
//     };
//     const ownedPrivate = await findFully(new Parse.Query("PrivateCell").equalTo("owner",user));
//     const joinedPrivate = await findFully(new Parse.Query("PrivateCell").notEqualTo("owner",user).equalTo("members",user));
//     const privateMembers = [];
//     
//   
//     result.friends=await idTimeMembers(friends);
//   
//     result.userBlocks=ids(fblocks);
//     result.blocksUser=ids(rblocks); 
//   
//     result.private={};
//     result.private.joined=await idTimeMembers(joinedPrivate);
//     result.private.owned=await idTimeMembers(ownedPrivate,true);
//   
//     result.public={};
//     result.public.joined=await idTimeMembers(publicJoined);
//     result.public.owned=await idTimeMembers(publicOwned,true);
  

  return rels;
}
Parse.Cloud.define("relations",relations);
