#!node
async function main() {
  require("parse-global");
  await import("./parse-login.mjs");
  var user=await parseLogin();
  console.log("main: enter");
  const friendQuery = new Parse.Query(Parse.User);
  friendQuery.equalTo("friends",user);
  friendQuery.limit(1);
  var cnt=await friendQuery.count()
  var num=Math.round(Math.random()*cnt);
  console.log({num,cnt});
  friendQuery.skip(num);
  const friends=await friendQuery.find({useMasterKey: true});
  for(var i=0;i<friends.length;i++){
    const friend=friends[i];
    console.log({friend: friend.get('username')});
    await user.relation("friends").remove(friend);
    await friend.relation("friends").remove(user);
    await friend.save(null,{useMasterKey:true});
      break;
  };
  await user.save(null,{useMasterKey:true});
};
main()
