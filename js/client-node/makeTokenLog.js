#!node

const ParseGlobal = require('parse-global');

async function findFully(query) {
  const limit=1000;
  query.limit(limit);
  var users=[];
  var batch;
  var start = new Date();
  do {
    batch=await query.find();
    query.skip(users.length);
    batch.forEach((user)=>{users.push(user)});
  } while(batch.length == limit);
  var finish = new Date();
  console.log((finish.getTime()-start.getTime())/1000);
  return users;
};
async function main() {
  console.log("main: enter");

  const TokenLog = Parse.Object.extend("TokenLog");
  const tokenLog = new TokenLog();
  tokenLog.set("owner", {__type: "Pointer", className: "_User", value:null});
  tokenLog.set("deviceToken", "xxxxxxxxxxxxxxxxxxxxxxxxx");
  tokenLog.save(null,{useMasterKey: true});
};
main();
