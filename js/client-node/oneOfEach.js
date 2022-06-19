#!node
global.user=global.user;

const users=[];
users.push([]);

async function main() {
  await import("./parse-login.mjs");
  const user = await parseLogin();
  const q1 = new Parse.Query(Parse.User);
  const num  = await q1.count();
  var skip = Math.round(num*Math.random());
  q1.skip(skip);
  q1.limit(10);
  const list = await q1.find();
  console.dump(list);
  console.log(list.length);
  var idx=0;
  const umk = { useMasterKey: true };
  list[idx].relation("friends").add(user);
  list[idx++].save(null,umk);
  user.relation("friends").add(list[idx++]);

  list[idx].relation("spamUsers").add(user);
  list[idx++].save(null,umk);
  user.relation("spamUsers").add(list[idx++]);

  user.save(null,umk);

}
main();
