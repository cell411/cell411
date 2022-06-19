#!node
await import("./parse-login.mjs");
global.xpp = await import('./pp.js');
global.util=await import('util');
async function main() {
  const user = await Parse.User.current();
  console.dump(user);
  const res = await Parse.Cloud.run("uploadProfilePic", {base64: fs.readFileSync("image.jpeg").toString("base64")});
};
main().then(()=>{ done(); });

