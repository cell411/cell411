#!/usr/bin/env node

await import('parse-global');
await import('../parse-login.mjs');
await initializeParse();
const user = await parseLogin();
const username=user.get("username");
const sessionToken=await user.getSessionToken();

console.log({username});

function event(event,...args){
  console.dump({event,args});
};
async function runAndAttach(query) {
  const results={};
  const subscription = await query.subscribe(sessionToken);
  const names=[ 'open','create','update','delete','enter','leave' ];
  for(var i=0;i<names.length;i++){
    const name=names[i];
    subscription.on(name,function(...args) { event(name,args); });
  };
  return results;
}
async function createOrQuery(table,value,...cols){
  var q1 = new Parse.Query(table);
  q1.equalTo(cols.shift(),value);
  console.dump({q1});
  if(cols.length) {
    var q2 = createOrQuery(table,value,cols);
    console.dump(q1,q2);
    q1 = Parse.Query.or(q1,q2);
  };
  return q1;
};
//   async function createRequestQuery() {
//     var q1 = new Parse.Query("Request");
//     q1.containedIn("status",["PENDING","RESENT"]);
//     return q1;
//   };
async function allRelated() {
//     const request = await createRequestQuery(user);
//     const users = new Parse.Query(Parse.User);
    const update = new Parse.Query("RelationshipUpdate");
    runAndAttach(update);

//     runAndAttach(request);
//     runAndAttach(users);
};
await allRelated(user);
//   async function main() {
//     allRelated(user);
//   }
//   main();
