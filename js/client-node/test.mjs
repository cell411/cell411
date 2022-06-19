#!node
await import('parse-global/pg-connect.js');
//   await import("parse-global");
//   await import("./parse-login.mjs");

async function main() {
  const list = await db.any("select * from \"_SCHEMA\" where \"className\" = '_User'");
  console.dump(list);
//     var user=await parseLogin();
//     console.log("main: enter");
//     const friendQuery = new Parse.Query("u2");
//     friendQuery.equalTo("objectId",'dev1');
//     const friends = await friendQuery.find();
//     console.dump(friends);
  //await user.save(null,{useMasterKey:true});
  pgp.end();
};
main()
