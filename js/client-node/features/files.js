const util = require('util');
async function main() {
  await import('../parse-login.mjs');
  console.dump(process.argv);
  await initializeParse();
  const user=await parseLogin();
  if(process.argv.length==3 && process.argv[2]=="upload") {
    const tok = {sessionToken: user.getSessionToken()};
    const name="index.html";
    var data={uri:"https:/copblock.app/index.html"};
    //var buffer = fs.readFileSync(name);
//       data.base64=buffer.toString("base64");
    const file = new Parse.File(name,data);
    user.set("testFile",file);
    await user.save(null,tok);
  } else if(process.argv.length==3 && process.argv[2]=="destroy") {
    console.dump(user.get("testFile"));
    user.get("testFile").destroy();
  } else {
    console.dump(await user.get("testFile").getData());
  };
  console.log(user.get("testFile"));
}
main()
