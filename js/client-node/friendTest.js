#!node

const parse_global=require('parse-global');
const util=require('util');
const ft = "friendTest";

const CoreManager = require('./node_modules/parse/lib/node/CoreManager.js');
const StorageController = require('./StorageController.js');
CoreManager.setStorageController(StorageController);
Parse.User.enableUnsafeCurrentUser();

async function signUpOrLogIn(first,last) {
  console.log("signUpOrLogIn");
  const username=first+last;
  try {
    const user=await Parse.User.logIn(username,"aa");
    return user;
  } catch ( error ) {
    console.log({username: username});
    console.log(error);
  };
  const user = new User();
  user.set("username",username);
  user.set("password","aa");
  user.set("firstName",""+first);
  user.set("lastName",""+last);
  user.save(null,{useMasterKey: true});
  await user.signUp();
  console.log("signed up");
  const acl = new Parse.ACL();
  acl.setReadAccess('*',true);
  user.setACL(acl);
  console.log(Parse.User.currentUser);
  console.log({sessionToken: user.get("sessionToken")});
  await user.save(null,{sessionToken: user.get("sessionToken")});
  console.log("signUpOrLogInd done");
  return user;
};
async function findUsers() {
  console.log("findUsers");
  const query = new Parse.Query("_User");
  query.startsWith("username",ft);
  const users={};
  const list = await query.find({useMasterKey: true});
  for(var i=0;i<list.length;i++) {
    const user = list[i];
    users[user.get("username")]=user;
  };
  console.log("findUsers done");
  return users;
};
async function main() {
  console.log("enter main");
  console.log(JSON.stringify(Parse.User.current(),null,2));
  const users = await findUsers();
  console.dump(users);
  const user1=Parse.User.current()||await signUpOrLogIn("friendTest","1")
  if(users['friendTest2']==null) {
    users['friendTest2'] = await signUpOrLogIn("friendTest","2");
  };

  const user2=users['friendTest2'];
  console.log(user2);

  console.log(user1.getSessionToken());
  Parse.User.become(
    user1.getSessionToken()
  );
   
   
  const request = new Request( {
    owner: user1,
    sentTo: user2,
    entryFor: "FR",
    status: "PENDING",
  });
  await request.save(null,{useMasterKey: true});

  Parse.Cloud.run("sendRequest", { objectId: user2.id, type: "FriendRequest" });
   
  console.log("main: exit");
};
main();
