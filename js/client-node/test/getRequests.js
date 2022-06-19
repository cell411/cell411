const util = require('util');
process.env.PARSE_USER ||= "dev1";
const start=new Date().getTime();

async function setup() {
  await import('../parse-login.mjs');
  await initializeParse();
  global.user=await parseLogin();
  global.q = new Parse.Query(Request);
};
async function etime() {
  console.log({
    elapsed: new Date().getTime()-start,
    requestCount: await q.count()
  });
};
async function main() {
  await setup();
  const dump={};
  var newFriend;
  {
    setInterval(
      async ()=>{
        const count=await new Parse.Query(Parse.User).count();
        const rand=Math.round(Math.random()*count);
        newFriend=(await new Parse.Query(User).skip(rand).limit(1).find())[0];
        await etime();
        const request=new Request({sentTo: newFriend,owner: user, entryFor: 'FR', status: "PENDING"} );
        await request.save();
      },
      2000
    );
    setTimeout(async ()=>{
      for(var i=0;i<intervals.length;i++){
        clearInterval(intervals[i]);
      };
    },30000);
  };

};
main();
