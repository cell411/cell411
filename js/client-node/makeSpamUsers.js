#!node
async function main() {
  require("parse-global");
  await import("./parse-login.mjs");
  var user=await parseLogin();
  console.log("main: enter");
  {
    const spammerQuery = new Parse.Query(User);
    const biSpammers=[];
    {
      const spammerQuery = await user.relation("spamUser").query();
      const spammers = await spammerQuery.find();
      for(var i=0;i<spammers.length;i++){
        biSpammers.push(spammers[i].id);
      };
    };
    {
      const spammerQuery = new Parse.Query(User);
      spammerQuery.equalTo("spamUsers",user.id);
      const spammers = await spammerQuery.find();
      for(var i=0;i<spammers.length;i++){
        biSpammers.push(spammers[i].id);
      };
    };
    spammerQuery.notContainedIn("objectId",biSpammers);
    var cnt=await spammerQuery.count()
    var num=Math.round(Math.random()*cnt);
    console.log({num,cnt});
    spammerQuery.skip(num);
    spammerQuery.limit(5);
    const spammers=await spammerQuery.find({useMasterKey: true});
    for(var i=0;i<spammers.length;i++){
      const spammer=spammers[i];
      console.log({spammer: await spammer.get('username')});
      if(i%2 == 0) {
        await user.relation("spamUsers").add(spammer);
      } else {
        await spammer.relation("spamUsers").add(user);
        await spammer.save(null,{useMasterKey: true});
      };
    };
    await user.save(null,{useMasterKey:true});
  }
  {
    var spammerQuery = user.relation("spamUsers").query();
    var spammers = await spammerQuery.find();
    console.log("spamUsers");
    for(var i=0;i<spammers.length;i++) {
      console.log("  "+spammers[i].get("username"));
    };
    spammerQuery = new Parse.Query(User);
    spammerQuery.equalTo("spamUsers",user);
    spammers = await spammerQuery.find();
    console.log("");
    console.log("userSpams");
    for(var i=0;i<spammers.length;i++) {
      console.log("  "+spammers[i].get("username"));
    };
  }
};
main()
