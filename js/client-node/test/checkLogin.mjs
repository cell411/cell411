await import('../parse-login.mjs');

async function main() {
  var user={};
  user.getSessionToken=function(){};
  console.log=console.trace;
  await initializeParse();
  console.log(await user.getSessionToken());
  console.log(await Parse.Cloud.run("checkLogin"));
  console.log(await user.getSessionToken());
  user = await parseLogin();
  console.log(await user.getSessionToken());
  console.log(await Parse.Cloud.run("checkLogin",null,{sessionToken: user.getSessionToken()}));
  console.log(await user.getSessionToken());
}
main()
