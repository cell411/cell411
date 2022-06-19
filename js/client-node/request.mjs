#!node
await import("./parse-login.mjs");
Parse.Object.enableSingleInstance();
global.user = await parseLogin();
const cskey = { sessionToken: user.getSessionToken() };
const mkey = { useMasterKey: true, sessionToken: user.getSessionToken() };
const forward=false;
const reverse=true;
global.util = await import('util');

async function randomCell(rev) {
  var cellQ;
  if(rev) {
    cellQ = new Parse.Query("PublicCell");
    cellQ.equalTo("owner",user);
  } else {
    const excludeQ = Parse.Query.or(
      new Parse.Query("PublicCell").equalTo("owner",user),
      new Parse.Query("PublicCell").equalTo("members",user),
    );
    const revQ = new Parse.Query("PublicCell");
    revQ.doesNotMatchKeyInQuery("objectId","objectId",excludeQ);
    cellQ=revQ;
  };
  while(true) {
    const count=await cellQ.count();
    var cell;
    if(count==0){
      cell = new PublicCell();
      cell.set("owner",user);
      cell.set("description", "automatically created");
      cell.set("Category",3);
      cell.set("name","the cell nobody knows about");
      console.dump(cell);
      cell.save(null,{mkey});
      console.dump(cell);
      continue;
    };
    const skip = Math.round(Math.random()*count);
    console.log({count,skip});
    cellQ.skip(skip);
    cellQ.limit(1);
    const cells=await cellQ.find();
    cell=cells[0];
    if(cell)
      return cell;
    console.dump(cellQ);
  };
};
async function cellRequest(rev) {
  const mark=makeTimer("cellRequest");
  mark("starting");
  var cell=await randomCell(rev);
  const params={
    type: "CellJoinRequest",
    objectId: cell.id
  };
  const other = await randomUser(rev,cell.relation("members").query(),mark);
  var skey = { sessionToken: null };
  if(rev) {
    skey.sessionToken=other.getSessionToken();
  } else {
    skey.sessionToken=cskey.sessionToken;
  }
  var res =await Parse.Cloud.run("sendRequest",params,skey);
  var req = res.request;
  var owner = req.get("owner").toString();
  var sentTo = req.get("sentTo").toString();
  cell = req.get("cell").toString();
  req=req.toString();
  console.log({req,owner,sentTo,cell});
}
async function getOneRequestQuery(rev){
  return new Parse.Query("Request");
};
async function getRequestQuery(friend,rev){
  const userKey = rev ? "sentTo" : "owner";
  const otherKey = rev ? "owner" : "sentTo";
  const requestQ = await getOneRequestQuery(rev);
  requestQ.equalTo(userKey,user);
  requestQ.containedIn("status",[ "PENDING", "RESENT" ]);
  requestQ.include(otherKey);
  if(friend){
    requestQ.doesNotExist("cell");
  } else {
    requestQ.exists("cell");
  };
  return await requestQ.find();
};
async function getFriendRequests(rev){
  return await getRequestQuery(true,rev);
};
async function getCellRequests(rev){
  return await getRequestQuery(false,rev);
};
async function acceptFriendRequest(rev) {
  const reqs = await getFriendRequests(rev);
  console.log(`found ${reqs.length} reqs ${rev?"for":"from"} you`);
  var i=0;
  if(reqs.length>1){
    i=Math.random()*i;
  };
  const req=reqs[i];
  if(reqs.length>0) {
    const owner=req.get("owner");
    owner.fetch();
    const sentTo=req.get("sentTo");
    sentTo.fetch();
    const status=req.get("status");
    console.dump({owner,sentTo});
    console.log(`accepting request from ${owner.get('username')} to ${sentTo.get('username')}`);
    console.log({owner,sentTo,status});
    return await acceptRequest(reqs[i]);
  } else {
    return { message: "no reqs found" };
  };
};
async function acceptRequest(request){
  const sentTo=request.get("sentTo");
  const skey={sessionToken: null};
  if(sentTo.id !== user.id){
    sentTo.set("password","asdf");
    await sentTo.save(null,mkey);
    await sentTo.logIn();
    const sessionToken=sentTo.getSessionToken();
    console.dump({sentTo});
    skey.sessionToken=sessionToken;;
  } else {
    console.dump({user});
    const sessionToken=cskey.sessionToken;
    skey.sessionToken=sessionToken;
  };
  console.dump({skey});
  const cell=request.get("cell");
  const params={
    objectId:request.id,
    type: (cell==null?"FriendApprove":"CellJoinApprove")
  };
  console.log(params);
  const res = await Parse.Cloud.run("sendRequestResponse",params,skey);
  return res;
};
async function jiggleAll(rev) {
  const requests = await getFriendRequests(rev);
  for(var i=0;i<requests.length;i++){
    requests[i].set("status","RESENT");
    requests[i].save(null,mkey);
    requests[i].set("status","PENDING");
    requests[i].save(null,mkey);
  };
};
function time() {
  return new Date().getTime();
};
function makeTimer(tag){
  if(tag==null||tag==""){
    tag="Unnamed";
  };
  const start=time();
  const mark=function mark(comment){
    var elapsed=""+(time()-start);
    while(elapsed.length<5){
      elapsed=" "+elapsed;
    };
    console.log(elapsed,tag," ",comment);
  };
  mark("start");
  return mark;
};
async function randomUser(rev,excludeQ,mark) {
  mark("got count");
  const otherQ = await new Parse.Query(Parse.User);
  otherQ.exists("email");
  otherQ.exists("username");
  console.dump({otherQ,excludeQ});
  if(excludeQ)
    otherQ.doesNotMatchKeyInQuery("objectId","objectId",excludeQ);
  var count=await otherQ.count(mkey);
  var skip=Math.random()*count;
  console.log({count,skip});
  otherQ.skip(skip);
  otherQ.limit(1);
  console.dump(otherQ);
  mark("running query");
  const newFriends=await otherQ.find(mkey);
  mark("query done");
  console.dump(otherQ);
  if(newFriends==null || newFriends.length==0) {
    mark("failed");
    throw new Error( "Failed to find unfriended user" );
  };
  const newFriend = newFriends[0];
  if(rev) {
    mark("setting newFriend's password");
    newFriend.set("password","asdf");
    await newFriend.save(null,mkey);
    mark("logging in");
    await newFriend.logIn();
    mark("logged in");
  };
  return newFriend;
};
async function spam(rev) {
  const mark=makeTimer("spamRequest");
  const newFriend = await randomUser(rev,null,mark);
  console.dump({newFriend});
  if(rev){
    newFriend.relation("spamUsers").add(user);
    newFriend.save(null,mkey);
  } else {
    user.relation("spamUsers").add(newFriend);
    user.save(null,mkey);
  }
};
async function friendRequest(rev) {
  //  const promise=new Promise(async (resolve,reject)=>{
  const mark=makeTimer("friendRequest");
  var i=0;
  const params={
    type: "FriendRequest",
    objectId: null
  };
  const friendQ = user.relation("friends").query();
  const newFriend = await randomUser(rev,friendQ,mark);
  const skey = { sessionToken: null };
  if(rev) {
    skey.sessionToken=await newFriend.getSessionToken();
    params.objectId=user.id;
  } else {
    skey.sessionToken=await cskey.sessionToken;
    params.objectId=newFriend.id;
  };
  mark("running function");
  console.log({params,skey});
  const res = await Parse.Cloud.run("sendRequest",params,skey);
  mark("done");
  console.log({res});
  return (res);
}
function pad(i) {
  var res=""+i;
  while(res.length<5){
    res=" "+res;
  };
  return res;
};
function menu() {
  console.log("MENU: ");
  for(var i of Object.keys(options)) {
    console.log(`${pad(i)}) ${options[i].text}`);
  };
};
function selfDump() {
  console.dump(user);
};
async function makeRequest(owned,cell,active){
  const query = new Parse.Query("Request");
  if(owned) {
    query.equalTo("owner",user);
  } else {
    query.equalTo("sentTo",user);
  };
  if(cell) {
    query.exists("cell");
  } else {
    query.doesNotExist("cell");
  };
  if(active) {
    query.containedIn("status",[ "PENDING", "RESENT" ]);
  };
  return query.count().then((count)=>{
    return { owned, cell, active, count };
  });
};

async function countRequests() {
  const promises=[];
  promises.push(makeRequest(false  ,false  ,false  ));
  promises.push(makeRequest(false  ,false  ,true   ));
  promises.push(makeRequest(false  ,true   ,false  ));
  promises.push(makeRequest(false  ,true   ,true   ));
  promises.push(makeRequest(true   ,false  ,false  ));
  promises.push(makeRequest(true   ,false  ,true   ));
  promises.push(makeRequest(true   ,true   ,false  ));
  promises.push(makeRequest(true   ,true   ,true   ));
  const result = await Promise.all(promises);
  console.table(result);
  return "that's it";
};
const readLine = await getReadline();
async function end() {
  readLine.close();
};
const options={
  m:   {  text:  "menu",                    func:  ()=>{  return  menu();                      }  },
  q:   {  text:  "exit",                    func:  ()=>{  return  end();                       }  },
  d:   {  text:  "count_requests",          func:  ()=>{  return  countRequests();             }  },
  a:   {  text:  "Send Alert",              func:  ()=>{  return  sendAlert();                 }  },

  sd:  {  text:  "self-dump",               func:  ()=>{  return  selfDump();                  }  },
  fo:  {  text:  "Send_Friend_Request",     func:  ()=>{  return  friendRequest(false);        }  },
  fi:  {  text:  "Receive_Friend_Request",  func:  ()=>{  return  friendRequest(true);         }  },
  so:  {  text:  "Spam_A_User",             func:  ()=>{  return  spam(false);        }  },
  si:  {  text:  "User_Spam_You",           func:  ()=>{  return  spam(true);         }  },
  co:  {  text:  "Send_Cell_Request",       func:  ()=>{  return  cellRequest(false);          }  },
  ci:  {  text:  "Receive_Cell_Request",    func:  ()=>{  return  cellRequest(true);           }  },
  ao:  {  text:  "Accept_Out_Friend",       func:  ()=>{  return  acceptFriendRequest(true);   }  },
  ai:  {  text:  "Accept_In_Friend",        func:  ()=>{  return  acceptFriendRequest(false);  }  },
  ji:  {  text:  "Jiggle_One_Incoming",     func:  ()=>{  return  jiggleOne(false);            }  },
  jo:  {  text:  "Jiggle_One_Outgoing",     func:  ()=>{  return  jiggleOne(true);             }  },
};
async function command(txt) {
  console.log("calling options[index].func()");
  if(options[txt]){
    var p=await options[txt].func();
  } else {
    console.log("No command for: "+txt);
  };
};
async function sendAlert() {
  const params={};
  params.alert={};
  params.alert.problemType="CRIMINAL";
  params.alert.location=new Parse.GeoPoint(42.927950,-72.275078);
  params.audience=[];
  params.audience.push("global");
//     params.audience.push("allFriends");
//     params.audience.push("allCells");
  Parse.Cloud.run("sendAlert",params,{sessionToken:user.getSessionToken()});
}
async function main(){
  var i=0;
  user.set("lastName","x "+user.get("lastName"));
  user.save(null,mkey);
  readLine.on('close',()=>{
    console.log("bye, now!");
    process.exit(0);
  });
  readLine.on('line',async (line)=>{
    for(const word of line.trim().split(/ +/)){
      await command(word);
    };
    console.log("*");
    readLine.prompt();
  });
  await command("m");
  readLine.prompt();
};
main();
