process.env.PARSE_USER ||= "dev1";
const pg_conn=require('parse-global/pg-connect');
console.log(global.db);
async function setup() {
  await import('../parse-login.mjs');
  await initializeParse();
  global.current=await parseLogin();
  console.log(util.inspect(current));
  global.q = new Parse.Query("Request");
};
var number=1000;
const usernameQuery = new Parse.Query(Parse.User);

async function usernameTaken(name) {
  usernameQuery.equalTo("username",name);
  const count = await usernameQuery.count();
  return count!=0;
};
async function randomUser() {
//     const begQuery1 = new Parse.Query(Parse.User);
//     begQuery1.startsWith("username","test");
//     const begQuery2 = new Parse.Query(Parse.User);
//     begQuery2.endsWith("username","@copblock.app");
//     const begQuery=Parse.Query.and(begQuery1,begQuery2);

  while(true) {
    try {
      var username = "test"+(number++);;
      const user = new Parse.User();
      user.set("email","test"+number+"@copblocka.app");
      user.set("firstName","test"+number);
      user.set("lastName","test"+number);
      user.set('newPublicCellAlert', true);
      user.set('patrolMode', true);
      user.set("password","xxx"+number);
      user.set("username",username);
      await user.save(null,{useMasterKey: true})
      var acl = user.getACL();
      acl=new Parse.ACL();
      acl.setPublicReadAccess(true);
      acl.setWriteAccess(user.id,true);
      acl.setPublicWriteAccess(false);
      user.setACL(acl);
      await user.save(null,{useMasterKey: true})
      console.log("user: "+user.get("username"));
      return user;
    } catch ( err ) {
      console.log("err");
    };
  }
};
const list={};
async function makeRel(user1,user2,key){
  list[user1.id]=user1;
  list[user2.id]=user2;
  user1.relation(key).add(user2);
  user1.save(null,{useMasterKey: true});
  user2.save(null,{useMasterKey: true});
};
async function calcNumber() {
  const begQuery = new Parse.Query(Parse.User);
  begQuery.matches("username",/^test[0-9]*$/);
  begQuery.descending("username");
  begQuery.limit(10);
  console.dump(begQuery);
  const begData=await begQuery.find();
  if(!begData.length)
    return;
  var name=begData[0].get("username");
  name=name.substr(4);
  number=eval(name)+1;
  console.log({name,number});
  var username;
  do {
    username="test"+number;
    var res = await usernameTaken(username);
    console.log({username,res});
    if(!res)
      break;
    number++;
  } while(true);
};
async function main() {
  await setup();
  calcNumber();
  for(var i=0;i<100;i++){
    console.log("users: "+i);
    console.dump(await randomUser());
    await makeRel(current,await randomUser(),"friends");
    await makeRel(await randomUser(),current,"friends");i++;
    await makeRel(current,await randomUser(),"spamUsers");i++;
    await makeRel(await randomUser(),current,"spamUsers");i++;
    await randomUser();i++;
  };
  const cellQ = new Parse.Query("PublicCell");
  const cells = await cellQ.find();
  const sessionToken=await current.getSessionToken();
  const userQ = new Parse.Query("_User");
  userQ.limit(10000);
  const users = await userQ.find();
  for(var i=0;i<100;i++){
    var userNum=Math.round(Math.random()*cells.length);
    const user=users[userNum];
    if(user==null)
      continue;
    console.log(user);
    var cellNum=Math.round(Math.random()*cells.length);
    const cell=cells[cellNum];
    if(cell==null)
      continue;
    cell.relation("members").add(user);
    cell.save(null,{sessionToken});
  };
};
main().then(()=>{pgp.end()});
