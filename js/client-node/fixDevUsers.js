#!node
require("parse-global/pg-connect");
require("pg-promise");
async function removeDevUsers() {
  console.log(await db.any(`select "objectId",username from "_User" where username like '%@copblock.app'`));
};
async function findFully(query,opts) {
  const limit=1000;
  query.limit(limit);
  var users=[];
  var batch;
  var start = new Date();
  do {
    batch=await query.find(opts);
    query.skip(users.length);
    batch.forEach((user)=>{users.push(user)});
  } while(batch.length == limit);
  var finish = new Date();
  console.log({where: "findFully()", elapsed: (finish.getTime()-start.getTime())/1000});
  return users;
};
async function populateUser(user,i){
  user.set("email",username);
  user.set("firstName","rich");
  user.set("lastName","paul (dev"+i+")");
  user.set('newPublicCellAlert', true);
  user.set("password",password);
  user.set('patrolMode', true);
  user.set("username",username);
  if(user.id==null) {
    // gotta get an objectId
    user=await user.save(null,{useMasterKey:true});
  };
  var acl = user.getACL();
  var dirty = false;
  acl=new Parse.ACL();
  dirty=true;
  if(!acl.getPublicReadAccess()) {
    acl.setPublicReadAccess(dirty=true);
  };
  if(!acl.getWriteAccess(user.id)) {
    acl.setWriteAccess(user.id,(dirty=true));
  };
  if(acl.getPublicWriteAccess()) {
    acl.setPublicWriteAccess(!(dirty=true));
  }
  if(dirty) { 
    user.setACL(acl);
    user=await user.save(null,{useMasterKey: true})
  };
};
async function main() {
  global.password=process.env.PARSE_PASSWORD;
  if(noe(password))
    throw new Error("set the password to use in PARSE_PASSWORD");
  await import("parse-global");
  await removeDevUsers();
  console.log("main: enter");
  await import('./parse-login.mjs');
  await initializeParse();
  console.log(await Parse.getServerHealth());
  const suffix=/@copblock.app$/;
  const userQuery = new Parse.Query(Parse.User);
  userQuery.matches("username",suffix);
  userQuery.descending("username");
  const users = await findFully(userQuery,{useMasterKey: true});
  const xusers={};
  for(var i=0;i<users.length;i++){
    const user=users[i];
    const username=user.get("username");
    xusers[username]=user;
  };
  for(var i=1;i<10;i++) {
    userId="dev"+i;
    username=userId+"@copblock.app";
    var user=xusers[username];
    if(user==null)
      user = new Parse.User();
    await populateUser(user,i);
    if(userId!=user.id){
      console.log([userId,user.id]);
      await db.none('update "_Session" set "user"=null where "user"=$1',[user.id]);
      await db.none('update "_User" set "objectId"=$1 where "objectId"=$2',[userId,user.id]);
      await db.none('update "_Session" set "user"=$1 where "user" is null',[userId]);
    };
  };
  await pgp.end();
  console.log("main: exit");
};
import("./parse-login.mjs").then(main);
