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

const rev = {};
const dates = {};
const rels = [ dates ];

async function loadCells(dates,rels,className, owner ) {
  const query = new Parse.Query(className);
  query.equalTo(owner,user);
  var reverse=false; 
  if(owner !== "owner") {
    query.notEqualTo("owner",user)
    reverse=true;
  };
  const cellArray  = await findFully(query);
  const cellList = rev[owner][className];
  for(var i=0;i<cellArray.length;i++) {
    const cell = cellArray[i];
    const members=ids(await findFully(cell.relation("members").query()));
    members.unshift(className,cell.id,"members",false,"_User");
    rels.push(members);
    dates[cell.id]=cell.get("updatedAt").getTime();
    cellList.push(cell.id);
  }
};
async function loadFriends() {
  const friendRel = [ "_User", user.id, "friends", false, "_User" ];
  const friends = await findFully(user.relation("friends").query());
  rels.push(friendRel);
  for(var i=0;i<friends.length;i++) {
    const friend = friends[i]; 
    friendRel.push(friend.id);
    dates[friend.id]=friend.get("updatedAt").getTime();
  };
}
async function relations(req) {
  user = req.user;
  if(user==null)
    throw new Error("You must be logged in to call relations");
  user.fetch();
  await loadFriends();

  const fblocks = await findFully(user.relation("spamUsers").query());
  const rblocks = await findFully(new Parse.Query(Parse.User).equalTo("spamUsers",user));
  dates[user.id]=user.get("updatedAt").getTime();
  var temp=ids(fblocks);
  temp.unshift("_User",user.id,"spamUsers",false,"_User");
  rels.push(temp);
  temp=ids(rblocks);
  temp.unshift("_User",user.id,"spamUsersOf",true,"_User");
  rels.push(temp);
  rev["owner"]={};
  rev["members"]={};

  rels.push(rev["owner"]["PublicCell"]=[ "_User", user.id, "ownerOf", true, "PublicCell" ]);
  rels.push(rev["owner"]["PrivateCell"]=["_User", user.id, "ownerOf", true, "PrivateCell" ]);
  rels.push(rev["members"]["PublicCell"]=["_User", user.id, "memberOf", true, "PublicCell" ]);
  rels.push(rev["members"]["PrivateCell"]=["_User", user.id, "memberOf", true, "PrivateCell" ]);

  await loadCells(dates,rels,"PublicCell","owner");
  console.dump(rev["members"]["PublicCell"]);
  await loadCells(dates,rels,"PublicCell","members");
  await loadCells(dates,rels,"PrivateCell","owner");
  await loadCells(dates,rels,"PrivateCell","members");
  console.dump(rels);
  return rels;
}
Parse.Cloud.define("relations",relations);
