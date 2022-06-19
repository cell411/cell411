await import('parse-global');
await import('../parse-login.mjs');
//  import('parse-global');
//promise.then((res)=>{console.log(res);});
//promise.then(()=>{import("../parse-login.mjs")});
//promise.then((res)=>{console.log(res);});
//promise.then(()=>{console.log(global.parseLogin)});

async function main() {
  console.dump(process.argv);
  await initializeParse();
  var userQuery = new Parse.Query(Parse.User);
  var friendshipQuery = new Parse.Query(Friendship);
  global.user = await parseLogin();
  friendshipQuery.equalTo("friend1",user);
  friendshipQuery.include("friend2");
  const friendships = await friendshipQuery.find();
  const users = {};
  for(var i=0;i<friendships.length;i++){
    const friend1=friendships[i].get("friend1");
    const friend2=friendships[i].get("friend2");
    users[friend1.id]=friend1;
    users[friend2.id]=friend2;
  };
  var otherQuery=new Parse.Query(Parse.User);
  otherQuery.notContainedIn("objectId",Object.keys(users));
  const count=await otherQuery.count();
  const first=Math.round(Math.random()*count);
  console.log({count,first});
  otherQuery.skip(first);
  otherQuery.limit(1);
  const other=(await otherQuery.find())[0];
  const request = new Request();
  request.set("owner",other);
  console.dump(user);
  request.set("sentTo",user);
  await request.save();
  console.dump(request);
  await request.fetch();
  console.dump(request);
}
await main();
