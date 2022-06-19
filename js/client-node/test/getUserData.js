const util = require('util');
async function main() {
  await import('../parse-login.mjs');
  await initializeParse();
  const user=await parseLogin();
  user.set("privilege","FIRST");
  user.save(null,{useMasterKey: true});
  const lastLoad = new Date().getTime();
  const tok = {sessionToken: user.getSessionToken()};
  const userData = await Parse.Cloud.run("getUserData",null,tok);
  console.dump(userData);
//     const nextLoad = await Parse.Cloud.run("getUserData",{lastLoadTime: lastLoad},tok);
//     const text = JSON.stringify({userData,nextLoad},null,2);
//     console.log(text);
  fs.writeFileSync('getUserData.'+process.env.PARSE_USER+'.json',JSON.stringify(userData,null,2));
}
main()
