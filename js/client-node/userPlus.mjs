const util = await import('util');
const login= await import('./parse-login.mjs');

global.q=function q(c) { return new Parse.Query(c); };

const umk={useMasterKey: true};
async function main() {
  
  const params={};
  const options={};
  console.log(currentUser);
  options.sessionToken=currentUser.getSessionToken();
//    {sessionKey: currentUser.getSessionKey()});
  var query;
  query=new Parse.Query(Parse.User).startsWith("objectId",'a5').limit(10);
  const users=await query.find();  
  const relation=currentUser.relation("spamUsers");
  for(var i=0;i<users.length;i++) {
    relation.add(users[i]);
  };
  currentUser.save(null,umk);
//     for(var i=0;i<5;i++) {
//       const user=spamUsers[i];
//       currentUser.relation("spamUsers").add(user);
//     };
//     for(var i=5;i<spamUsers.length;i++) {
//       const user = spamUsers[i];
//       user.relation("spamUsers").add(currentUser);
//       user.save(null,umk);
//     };
//     currentUser.save(null,umk);
//     query.select('objectId,friends');
//     query.include('friends');
//     params.query=query.toJSON();
//     console.dump(params);
//     console.dump({params,options});
  const res = await  Parse.Cloud.run("userPlus",params,options);
  console.dump(res);
}
main()
