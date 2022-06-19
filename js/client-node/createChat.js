#!node


async function main() {
  global.login=await import('./parse-login.mjs');
  const user = await parseLogin();

  const query = new Parse.Query("ChatMsg");
  query.exists("location");
  const msgs = await findFully(query);
  for(var i=0;i<msgs.length;i++){
    const msg = msgs[i];
    const text = msg.get("text");
    console.log({text});
    msg.save();
  };
};
main();
